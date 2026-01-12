codeunit 50105 "ARC KorberItemMgt"
{
    // SOW11 Körber Edge WMS Integration

    Permissions = tabledata Item = r,
                  tabledata "ARC Korber Item Entry" = rim;

    var
        KorberSetup: Record "ARC Korber Setup";
        EntryNoToSend: BigInteger;
        Initialized: Boolean;
        CRNL: Text;

    trigger OnRun();
    begin
        Initialize();
        if not KorberSetup."Process Queue Enabled" then
            exit;
        if not KorberSetup."Send Items" then
            exit;
        if EntryNoToSend <> 0 then begin
            SendEntry();
            exit;
        end;
        SendEntries();
    end;

    procedure EnqueueItem(var _Item: Record Item; _action: Code[10])
    var
        _ItemEntry: Record "ARC Korber Item Entry";
    begin
        Initialize();
        if not KorberSetup."Send Items" then
            exit;
        if _Item.IsTemporary() then
            exit;
        if UpperCase(_action) in ['DELETE','INSERT','MODIFY'] then
            if not KorberSetup."Activate Item Subscribers" then
                exit;
        _ItemEntry."Entry No." := 0;
        _ItemEntry."Item No." := CopyStr(_Item."No.",1,MaxStrLen(_ItemEntry."Item No."));
        _ItemEntry."Record Action" := CopyStr(_action,1,MaxStrLen(_action));
        _ItemEntry.Insert();
    end;

    local procedure GetUnitsOfMeasureData(_Item: Record Item; var _tempBuf: Record "ARC Buffer" temporary)
    var
        _ItemUom: Record "Item Unit of Measure";
        _entryNo: BigInteger;
        _Height: Decimal;
        _Length: Decimal;
        _Weight: Decimal;
        _Width: Decimal;
        _QtyPerUom: Integer;
    begin
        Clear(_tempBuf);
        _tempBuf.DeleteAll();
        _ItemUom.SetCurrentKey("Item No.","Qty. per Unit of Measure");
        _ItemUom.SetRange("Item No.",_Item."No.");
        _ItemUom.SetFilter("Qty. per Unit of Measure",'<>0');
        if _ItemUom.FindSet(false) then
            repeat
                // round height, length, width, weight to 0.01 per Cody - Thu 10 Nov 2022
                _Height := GetRoundedDecimal(_ItemUom.Height);
                _Length := GetRoundedDecimal(_ItemUom.Length);
                _Weight := GetRoundedDecimal(_ItemUom.Weight);
                _Width := GetRoundedDecimal(_ItemUom.Width);
                _QtyPerUom := Round(_ItemUom."Qty. per Unit of Measure",1,'>');
                _tempBuf.SetRange("Integer 01",_QtyPerUom);
                if not _tempBuf.FindFirst() then begin
                    _entryNo += 1;
                    _tempBuf.Init();
                    _tempBuf."Entry No." := _entryNo;
                    _tempBuf."Integer 01" := _QtyPerUom;
                    _tempBuf."Text 01" := CopyStr('Size' + Format(_entryNo),1,MaxStrLen(_tempBuf."Text 01"));
                    _tempBuf."Text 02" := CopyStr('FormalSize' + Format(_entryNo),1,MaxStrLen(_tempBuf."Text 02"));
                    _tempBuf.Insert();
                end;
                if _Height > _tempBuf."Decimal 01" then
                    _tempBuf."Decimal 01" := _Height;
                if _Length > _tempBuf."Decimal 02" then
                    _tempBuf."Decimal 02" := _Length;
                if _Weight > _tempBuf."Decimal 03" then
                    _tempBuf."Decimal 03" := _Weight;
                if _Width > _tempBuf."Decimal 04" then
                    _tempBuf."Decimal 04" := _Width;
                _tempBuf.Modify();
            until _ItemUom.Next() = 0;
        _tempBuf.Reset();
    end;

    local procedure GetUpc(_ItemNo: Code[20]) : Text
    var
        _ItemCrossRef: Record "Item Cross Reference";
    begin
        _ItemCrossRef.SetRange("Item No.",_ItemNo);
        _ItemCrossRef.SetRange("Cross-Reference Type",_ItemCrossRef."Cross-Reference Type"::"Bar Code");
        if _ItemCrossRef.FindFirst() then
            exit(_ItemCrossRef."Cross-Reference Type No.")
        else
            exit('');
    end;

    local procedure GetRoundedDecimal(_decimal: Decimal) _newDecimal : Decimal
    begin
        _newDecimal := Round(_decimal,0.01);
        /* commented based on concall Thu 17 Nov 2022 at 12 Eastern - zeroes ensure users are prompted to take item to Cubiscan machine
        if _newDecimal < 0.01 then
            _newDecimal := 0.01;
        */
    end;

    procedure GetRoundedDecimalText(_decimal: Decimal) : Text
    begin
        exit(DelChr(Format(GetRoundedDecimal(_decimal)),'=',','));
    end;

    local procedure GetWholeValue(_decimal: Decimal) _int: Integer
    begin
        _int := Round(_decimal,1,'>');
        if _int = 0 then
            _int := 1;
    end;

    local procedure Initialize()
    var
        _CR: Char;
        _NL: Char;
    begin
        if Initialized then
            exit;
        KorberSetup.Get();
        _CR := 13;
        _NL := 10;
        CRNL := CopyStr(Format(_CR) + Format(_NL),1,MaxStrLen(CRNL));
        Initialized := true;
    end;

    procedure OnBeforeInsertItemEntry(var Rec: Record "ARC Korber Item Entry"; RunTrigger: Boolean)
    var
        _time: Time;
    begin
        _time := Time();
        Rec."Created by" := CopyStr(UserId(),1,MaxStrLen(Rec."Created by"));
        Rec."Created at Date" := Today();
        Rec."Created at DateTime" := CreateDateTime(Today(),_time);
        Rec."Created at Time" := _time;
    end;

    local procedure OutputXmlToFile(_fullFilename: Text; var _tempBlob: Record TempBlob temporary)
    var
        _file: File;
        _is: InStream;
        _os: OutStream;
    begin
        _tempBlob.Blob.CreateInStream(_is);
        _file.TextMode(true);
        _file.WriteMode(true);
        _file.Create(_fullFilename);
        _file.CreateOutStream(_os);
        CopyStream(_os,_is);
        _file.Close();
        _tempBlob.CalcFields(Blob);
    end;

    procedure ResetEntry(var _KorberItemEntry: Record "ARC Korber Item Entry")
    var
        _KorberItemEntry2: Record "ARC Korber Item Entry";
        _count: Integer;
        _Text000Qst: Label 'Entries selected: %1.  Are you SURE you want to reset?';
        _Text001Msg: Label '*** RESET *** %1 No. %2, Item %3';
    begin
        Initialize();
        _count := _KorberItemEntry.Count();
        if GuiAllowed() then
            if not Confirm(_Text000Qst,false,_count) then
                exit;
        if _KorberItemEntry.FindSet(false) then
            repeat
                Clear(_KorberItemEntry2);
                _KorberItemEntry2.Reset();
                _KorberItemEntry2.LockTable();
                _KorberItemEntry2.Get(_KorberItemEntry."Entry No.");
                _KorberItemEntry2."Sent to WMS" := 0;
                _KorberItemEntry2."Sent to WMS at DateTime" := 0DT;
                _KorberItemEntry2."Sent to WMS Data Entry No." := 0;
                _KorberItemEntry2."Sent to WMS Duration" := 0;
                _KorberItemEntry2."Sent to WMS Error Text" := '';
                _KorberItemEntry2."Sent to WMS No. of Attempts" := 0;
                _KorberItemEntry2.Modify();
                WriteLog(KorberSetup."Log Level"::Normal,_KorberItemEntry."Entry No.",0,
                    StrSubstNo(_Text001Msg,_KorberItemEntry2.TableCaption(),_KorberItemEntry2."Entry No.",_KorberItemEntry2."Item No."),'');
            until _KorberItemEntry.Next() = 0;
        _KorberItemEntry.Reset();
    end;

    local procedure SendEntries()
    var
        _ItemEntry: Record "ARC Korber Item Entry";
        _ItemEntry2: Record "ARC Korber Item Entry";
        _ItemMgt: Codeunit "ARC KorberItemMgt";
        _result: Boolean;
        _entriesProcessed: Integer;
        _timeBegin: Time;
        _timeEnd: Time;
    begin
        _ItemEntry.SetCurrentKey("Sent to WMS");
        _ItemEntry.SetRange("Sent to WMS",0);
        if _ItemEntry.FindSet(false) then
            repeat
                _timeBegin := Time();
                Clear(_ItemMgt);
                _ItemMgt.SetEntryNoToSend(_ItemEntry."Entry No.");
                Commit();
                _result := _ItemMgt.Run();
                if not _result then begin
                    Clear(_ItemEntry2);
                    _ItemEntry2.Reset();
                    _ItemEntry2.LockTable();
                    if _ItemEntry2.Get(_ItemEntry."Entry No.") then begin
                        _timeEnd := Time();
                        _ItemEntry2."Sent to WMS Error Text" := CopyStr(GetLastErrorText(),1,MaxStrLen(_ItemEntry2."Sent to WMS Error Text"));
                        _ItemEntry2."Sent to WMS No. of Attempts" := _ItemEntry2."Sent to WMS No. of Attempts" + 1;
                        _ItemEntry2."Sent to WMS at DateTime" := CreateDateTime(Today(),_timeEnd);
                        _ItemEntry2."Sent to WMS Duration" := _timeEnd - _timeBegin;
                        if _ItemEntry2."Sent to WMS No. of Attempts" >= KorberSetup."Maximum No. of Attempts" then
                            _ItemEntry2."Sent to WMS" := -1;
                        _ItemEntry2.Modify();
                    end;
                end;
                _entriesProcessed += 1;
            until (_ItemEntry.Next() = 0) or (_entriesProcessed >= KorberSetup."Process Queue No. Entries");
    end;

    local procedure SendEntry()
    var
        _Item: Record Item;
        _ItemEntry: Record "ARC Korber Item Entry";
        _ItemEntry2: Record "ARC Korber Item Entry";
        _tempBlob: Record TempBlob temporary;
        _tempBuf: Record "ARC Buffer" temporary;
        _tempXmlBuf: Record "XML Buffer" temporary;
        _DataMgt: Codeunit "ARC DataMgt";
        _KorberMgt: Codeunit "ARC KorberMgt";
        _XmlBufWriter: Codeunit "XML Buffer Writer";
        _os: OutStream;
        _ContainerBatchRefHeader: Text;
        _DateTimeText: Text;
        _desc: Text;
        _filename: Text;
        _fullFilename: Text;
        _xmlContent: Text;
        _timeBegin: Time;
        _timeEnd: Time;
        _xmlDoc: XmlDocument;
        _xmlDec: XmlDeclaration;
        _xmlElement: XmlElement;
        _xmlElement2: XmlElement;
        _Text000Lbl: Label 'Method SendEntry(): Item Entry %1, item %2, filename %3';
        _Text001Err: Label 'Method SendEntry(): empty XML';
        _Text002Err: Label 'Method SendEntry(): full outbound filename is empty, check Korber Setup; source filename: %1';
    begin
        _timeBegin := Time();
        _ItemEntry.Get(EntryNoToSend);
        _Item.Get(_ItemEntry."Item No.");
        _desc := CopyStr(StrSubstNo(_Text000Lbl,_ItemEntry."Entry No.",_ItemEntry."Item No."),1,MaxStrLen(_desc));
        // get item unit of measure data
        GetUnitsOfMeasureData(_Item,_tempBuf);
        _tempBuf.FindSet(false);
        // holding space for item data
        Clear(_tempBlob);
        _tempBlob.DeleteAll();
        _tempBlob.Blob.CreateOutStream(_os,TextEncoding::UTF8);
        // generate Xml
        _xmlDoc := XmlDocument.Create();
        _xmlDec := XmlDeclaration.Create('1.0','utf-8','yes');
        _xmlDoc.SetDeclaration(_xmlDec);
        _xmlElement := XmlElement.Create('InventoryItem');
        XmlAppend(_xmlElement,'ProductCode',_Item."No.");
        XmlAppend(_xmlElement,'VendorProductNumber',_Item."Vendor Item No.");
        XmlAppend(_xmlElement,'Description', CopyStr(_Item.Description + ' ' + _Item."Description 2",1,100));
        XmlAppend(_xmlElement,'VendorNumber',_Item."Vendor No.");
        XmlAppend(_xmlElement,'UPC',GetUpc(_Item."No."));
        XmlAppend(_xmlElement,'MinimumDaysToExpiry','30');
        XmlAppend(_xmlElement,'SupplierType','1');
        // Pick Attribute Tracking - surfaced in XML meeting - Wed 31 Aug 2022 at 3p Eastern
        Clear(_xmlElement2);
        _xmlElement2 := XmlElement.Create('PickAttributeTracking');
        XmlAppend(_xmlElement2,'Attribute1Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute2Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute3Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute4Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute5Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute6Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute7Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute8Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute9Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute10Tracking','NotTracked');
        _xmlElement.Add(_xmlElement2);
        // Receive Attribute Tracking - surfaced in XML meeting - Wed 31 Aug 2022 at 3p Eastern
        Clear(_xmlElement2);
        _xmlElement2 := XmlElement.Create('ReceiveAttributeTracking');
        XmlAppend(_xmlElement2,'Attribute1Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute2Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute3Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute4Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute5Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute6Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute7Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute8Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute9Tracking','NotTracked');
        XmlAppend(_xmlElement2,'Attribute10Tracking','NotTracked');
        _xmlElement.Add(_xmlElement2);
        XmlAppend(_xmlElement,'ExpiryDateRequired','false');  // surfaced in XML meeting - Wed 31 Aug 2022 at 3p Eastern
        // base item unit of measure data
        XmlAppend(_xmlElement,'Weight',GetRoundedDecimalText(_tempBuf."Decimal 03"));
        XmlAppend(_xmlElement,'Length',GetRoundedDecimalText(_tempBuf."Decimal 02"));
        XmlAppend(_xmlElement,'Width',GetRoundedDecimalText(_tempBuf."Decimal 04"));
        XmlAppend(_xmlElement,'Height',GetRoundedDecimalText(_tempBuf."Decimal 01"));
        repeat
            XmlAppend(_xmlElement,_tempBuf."Text 01",_KorberMgt.GetFormattedWholeValue(_tempBuf."Integer 01"));
        until _tempBuf.Next() = 0;
        // other
        XmlAppend(_xmlElement,'ProductClass','60');
        XmlAppend(_xmlElement,'Buyer','');
        XmlAppend(_xmlElement,'TariffCode',_Item."Tariff No.");
        XmlAppend(_xmlElement,'CommodityCode','85');
        XmlAppend(_xmlElement,'MinimumReplenishmentLevel1','1');
        XmlAppend(_xmlElement,'MinimumReplenishmentLevel2','1');
        XmlAppend(_xmlElement,'MaximumReplenishmentLevel1','50');
        XmlAppend(_xmlElement,'MaximumReplenishmentLevel2','200');
        XmlAppend(_xmlElement,'CartonDef','1');
        XmlAppend(_xmlElement,'BeeLine','');
        XmlAppend(_xmlElement,'HandleCode',_KorberMgt.GetProductClass(_Item."No."));
        XmlAppend(_xmlElement,'CommodityCode','');
        XmlAppend(_xmlElement,'CartonSize','12');
        XmlAppend(_xmlElement,'ProductUDF1','ProductUDF11');
        XmlAppend(_xmlElement,'ProductUDF2','ProductUDF21');
        XmlAppend(_xmlElement,'ProductUDF3','ProductUDF31');
        XmlAppend(_xmlElement,'ProductUDF4','ProductUDF41');
        XmlAppend(_xmlElement,'ProductUDF5','ProductUDF51');
        // item unit of measure data
        _tempBuf.FindSet(false);
        repeat
            Clear(_xmlElement2);
            _xmlElement2 := XmlElement.Create(_tempBuf."Text 02");
            XmlAppend(_xmlElement2,'Length',GetRoundedDecimalText(_tempBuf."Decimal 02"));
            XmlAppend(_xmlElement2,'Width',GetRoundedDecimalText(_tempBuf."Decimal 04"));
            XmlAppend(_xmlElement2,'Height',GetRoundedDecimalText(_tempBuf."Decimal 01"));
            XmlAppend(_xmlElement2,'Weight',GetRoundedDecimalText(_tempBuf."Decimal 03"));
            _xmlElement.Add(_xmlElement2);
            Clear(_xmlElement2);
        until _tempBuf.Next() = 0;
        // other
        XmlAppend(_xmlElement,'PackClass','');
        XmlAppend(_xmlElement,'CountryOfOrigin',_Item."Country/Region of Origin Code");
        _xmlDoc.Add(_xmlElement);
        _xmlDoc.WriteTo(_os);
        _tempBlob.Insert();
        _tempBlob.CalcFields(Blob);
        if not _tempBlob.Blob.HasValue() then
            Error(_Text001Err);
        // build text strings
        _DateTimeText := CopyStr(_KorberMgt.GetFormattedDateTime(),1,MaxStrLen(_DateTimeText));
        _ContainerBatchRefHeader := CopyStr('ITEM_' + _DateTimeText,1,MaxStrLen(_ContainerBatchRefHeader));
        _filename := CopyStr(_ContainerBatchRefHeader,1,MaxStrLen(_filename));
        _fullFilename := CopyStr(_KorberMgt.GetFullOutboundPathInclFilename(_filename),1,MaxStrLen(_fullFilename));
        if _fullFilename = '' then
            Error(_Text002Err,_filename);
        _desc := CopyStr(StrSubstNo(_Text000Lbl,_ItemEntry."Entry No.",_ItemEntry."Item No.",_filename),1,MaxStrLen(_desc));
        // export to file the Xml generated
        OutputXmlToFile(_fullFilename,_tempBlob);
        // generate separate files for each barcode found
        SendEntryBarcodes(_ItemEntry,_tempBlob,_DateTimeText);
        // lock/process/modify staging table record
        _ItemEntry2.LockTable();
        _ItemEntry2.Get(_ItemEntry."Entry No.");
        _ItemEntry2."Sent to WMS No. of Attempts" := _ItemEntry2."Sent to WMS No. of Attempts" + 1;
        _ItemEntry2."Sent to WMS Data Entry No." := _DataMgt.NewDataEntryUsingTempBlob('KORITMMGT',_desc,_tempBlob);
        _timeEnd := Time();
        _ItemEntry2."Sent to WMS at DateTime" := CreateDateTime(Today(),_timeEnd);
        _ItemEntry2."Sent to WMS Duration" := _timeEnd - _timeBegin;
        _ItemEntry2."Sent to WMS" := 1;
        _ItemEntry2.Modify();
    end;

    local procedure SendEntryBarcodes(_ItemEntry: Record "ARC Korber Item Entry"; var _tempBlob: Record TempBlob temporary; _dateTimeText: Text)
    var
        _ItemCrossReference: Record "Item Cross Reference";
        _ItemUom: Record "Item Unit of Measure";
        _tempBlob2: Record TempBlob temporary;
        _KorberMgt: Codeunit "ARC KorberMgt";
        _xmlContentOrig: BigText;
        _xmlContentNew: BigText;
        _is: InStream;
        _os: OutStream;
        _filename: Text;
        _fullFilename: Text;
        _xmlContent: Text;
        _xmlDoc: XmlDocument;
        _xmlDec: XmlDeclaration;
        _xmlElement: XmlElement;
        _Text000Lbl: Label 'Item %1, UOM %2, Packsize/QtyPerUOM %3, Barcode %4, Filename: %5';
        _Text001Err: Label 'Method SendEntryBarcodes(): empty XML';
    begin
        _ItemCrossReference.SetRange("Item No.",_ItemEntry."Item No.");
        _ItemCrossReference.SetRange("Cross-Reference Type",_ItemCrossReference."Cross-Reference Type"::"Bar Code");
        _ItemCrossReference.SetFilter("Unit of Measure",'<>%1','');
        _ItemCrossReference.SetFilter("Cross-Reference Type No.",'<>%1','');
        if _ItemCrossReference.FindSet(false) then begin
            // get original item master XML generated in SendEntry()
            _tempBlob.CalcFields(Blob);
            _tempBlob.Blob.CreateInStream(_is);
            _xmlContentOrig.Read(_is);
            // for each barcode found, output a new file
            repeat
                if _ItemUom.Get(_ItemEntry."Item No.",_ItemCrossReference."Unit of Measure") then begin
                    // prepare tempBlob2 for barcode XML
                    Clear(_tempBlob2);
                    _tempBlob2.DeleteAll();
                    _tempBlob2.Init();
                    _tempBlob2.Blob.CreateOutStream(_os);
                    // generate XML for barcode
                    Clear(_xmlDoc);
                    Clear(_xmlDec);
                    Clear(_xmlElement);
                    Clear(_xmlContent);
                    Clear(_xmlContentNew);
                    _xmlDoc := XmlDocument.Create();
                    _xmlDec := XmlDeclaration.Create('1.0','utf-8','yes');
                    _xmlDoc.SetDeclaration(_xmlDec);
                    _xmlElement := XmlElement.Create('BarcodeItem');
                    XmlAppend(_xmlElement,'ProductCode',_ItemCrossReference."Item No.");
                    XmlAppend(_xmlElement,'ForeignBarCode',_ItemCrossReference."Cross-Reference Type No.");
                    XmlAppend(_xmlElement,'SCC14','');
                    XmlAppend(_xmlElement,'Packsize',_KorberMgt.GetFormattedWholeValue(_ItemUom."Qty. per Unit of Measure"));
                    _xmlDoc.Add(_xmlElement);
                    _xmlDoc.WriteTo(_os);
                    _tempBlob2.Insert();
                    _tempBlob2.CalcFields(Blob);
                    if _tempBlob2.Blob.HasValue() then begin
                        // build text strings
                        _filename := CopyStr('ITEM_' + _DateTimeText + '_' + _KorberMgt.GetFormattedWholeValue(_ItemUom."Qty. per Unit of Measure"),1,MaxStrLen(_filename));
                        _fullFilename := CopyStr(_KorberMgt.GetFullOutboundPathInclFilename(_filename),1,MaxStrLen(_fullFilename));
                        // export to file the barcode XML generated
                        OutputXmlToFile(_fullFilename,_tempBlob2);
                        _tempBlob2.Blob.CreateInStream(_is);
                        _xmlContentNew.Read(_is);
                        _xmlContentNew.GetSubText(_xmlContent,1);
                        // append barcode XML to original XML
                        _xmlContentOrig.AddText(CRNL);
                        _xmlContentOrig.AddText(StrSubstNo(_Text000Lbl,_ItemCrossReference."Item No.",_ItemCrossReference."Unit of Measure",
                            _ItemUom."Qty. per Unit of Measure",_ItemCrossReference."Cross-Reference Type No.",_filename) + CRNL + CRNL);
                        _xmlContentOrig.AddText(_xmlContent + CRNL);
                    end;
                end;
            until _ItemCrossReference.Next() = 0;
            // output revised content to _tempBlob
            Clear(_tempBlob.Blob);
            _tempBlob.Blob.CreateOutStream(_os);
            _xmlContentOrig.Write(_os);
        end;
    end;

    procedure SetEntryNoToSend(_EntryNoToSend: BigInteger)
    begin
        EntryNoToSend := _EntryNoToSend;
    end;

    procedure ShowItem(_ItemEntry: Record "ARC Korber Item Entry")
    var
        _Item: Record Item;
    begin
        _Item.Get(_ItemEntry."Item No.");
        Page.Run(Page::"Item Card",_Item);
    end;

    local procedure WriteLog(_logLevel: Integer; _relatedEntryNo: BigInteger; _relatedDataEntryNo: BigInteger; _msg: Text; _err: Text)
    var
        _KorberMgt: Codeunit "ARC KorberMgt";
    begin
        _KorberMgt.WriteLog(_logLevel,Codeunit::"ARC KorberItemMgt",'KORITMMGT',_relatedEntryNo,_relatedDataEntryNo,_msg,_err);
    end;

    local procedure XmlAppend(var _xmlElement: XmlElement; _tag: Text; _value: Text)
    var
        _xmlElement2: XmlElement;
    begin
        _xmlElement2 := XmlElement.Create(_tag);
        _xmlElement2.Add(XmlText.Create(_value));
        _xmlElement.Add(_xmlElement2);
    end;
}
codeunit 50102 "ARC KorberMgt"
{
    // SOW11 Körber Edge WMS Integration

    Permissions = tabledata "ARC Event Log Entry" = rim,
                  tabledata "Job Queue Entry" = rim,
                  tabledata "ARC Korber Setup" = r;

    var
        KorberSetup: Record "ARC Korber Setup";
        EntryNoToImport: BigInteger;
        EntryNoToProcess: BigInteger;
        Initialized: Boolean;
        CRNL: Text;
        PathArchive: Text;
        PathError: Text;
        PathImport: Text;
        KorberCode: Label 'KORBER_MGT';

    trigger OnRun();
    begin
        Initialize();
        if EntryNoToImport <> 0 then begin
            ImportFile();
            exit;
        end;
        if EntryNoToProcess <> 0 then begin
            ProcessEntry();
            exit;
        end;
        ListFiles();
        ImportFiles();
        ProcessEntries();
    end;

    local procedure CreateJobQueueEntry(_objType: Integer; _objID: Integer)
    var
        _JobQueueEntry: Record "Job Queue Entry";
    begin
        _JobQueueEntry.SetRange("Object Type to Run",_objType);
        _JobQueueEntry.SetRange("Object ID to Run",_objID);
        if _JobQueueEntry.IsEmpty() then begin
            _JobQueueEntry.Init();
            _JobQueueEntry.Validate("Object Type to Run",_objType);
            _JobQueueEntry.Validate("Object ID to Run",_objID);
            _JobQueueEntry.Insert(true);
            _JobQueueEntry.Validate("Run on Sundays",true);
            _JobQueueEntry.Validate("Run on Mondays",true);
            _JobQueueEntry.Validate("Run on Tuesdays",true);
            _JobQueueEntry.Validate("Run on Wednesdays",true);
            _JobQueueEntry.Validate("Run on Thursdays",true);
            _JobQueueEntry.Validate("Run on Fridays",true);
            _JobQueueEntry.Validate("Run on Saturdays",true);
            case _objType of
                _JobQueueEntry."Object Type to Run"::Report:
                    begin
                        _JobQueueEntry.Validate("No. of Minutes between Runs",60);
                        _JobQueueEntry.Validate("Starting Time",220000T);
                        _JobQueueEntry.Validate("Ending Time",223000T);
                    end;
                _JobQueueEntry."Object Type to Run"::Codeunit:
                    begin
                        _JobQueueEntry.Validate("No. of Minutes between Runs",1);
                        _JobQueueEntry.Validate("Starting Time",001000T);  // 12:10 AM
                        _JobQueueEntry.Validate("Ending Time",235000T);  // 11:50 PM
                    end;
            end;
            _JobQueueEntry.Validate("Earliest Start Date/Time",CreateDateTime(Today(),000000T));
            _JobQueueEntry.Modify(true);
            _JobQueueEntry.SetStatus(_JobQueueEntry.Status::"On Hold");
        end;
    end;

    procedure GetCRNL() : Text
    var
        _CR: Char;
        _NL: Char;
    begin
        _CR := 13;
        _NL := 10;
        exit(Format(_CR) + Format(_NL));
    end;

    procedure GetFormattedDateTime() _dateTimeText: Text
    begin
        _dateTimeText := Format(CurrentDateTime(),0,'<Year4><Filler Character,0><Month,2><Day,2><Hours24><Minutes,2><Seconds,2><Second dec.>');
        _dateTimeText := DelChr(_dateTimeText,'=','.,');
    end;

    procedure GetFormattedWholeValue(_decimal: Decimal) : Text
    begin
        exit(DelChr(Format(Round(_decimal,1,'>')),'=',','));
    end;

    procedure GetFullOutboundPathInclFilename(_filename: Text) _fullFilename: Text
    begin
        Initialize();
        if KorberSetup."Outb. Base File Path" = '' then
            exit;
        if _filename = '' then
            exit;
        if KorberSetup."Outb. Base File Path"[StrLen(KorberSetup."Outb. Base File Path")] <> '\' then
            KorberSetup."Outb. Base File Path" := KorberSetup."Outb. Base File Path" + '\';
        _fullFilename := CopyStr(KorberSetup."Outb. Base File Path" + _filename + '.xml',1,MaxStrLen(_fullFilename));
    end;

    procedure GetLocation(_Code: Code[10]; var _Location: Record Location): Boolean
    begin
        Clear(_Location);
        _Location.Reset();
        if _Code = '' then
            exit(false);
        if not _Location.Get(_Code) then
            exit(false);
        if not _Location."ARC Enable Korber WMS" then
            exit(false);
        exit(true);
    end;

    local procedure GetPaths()
    begin
        KorberSetup.TestField("Inb. Base File Path");
        PathImport := CopyStr(KorberSetup."Inb. Base File Path",1,MaxStrLen(PathImport));
        if PathImport[StrLen(PathImport)] <> '\' then
            PathImport := PathImport + '\';
        PathArchive := CopyStr(PathImport + 'Archive\',1,MaxStrLen(PathArchive));
        PathError := CopyStr(PathImport + 'Error\',1,MaxStrLen(PathError));
    end;

    procedure GetProductClass(_itemNo: Code[20]) _productClass: Text[1]
    var
        _ItemAttr: Record "Item Attribute";
        _ItemAttrVal: Record "Item Attribute Value";
        _ItemAttrValMap: Record "Item Attribute Value Mapping";
        _ItemAttrID: Integer;
        _ItemAttrValID: Integer;
        _ItemAttrCode: Code[1];
    begin
        // item attributes for product class / handling
        //   orig reqmnt: Körber item classification: A = Aerosol, P = Pest Control, H = Hazardous, or G = General
        //   for full background see email fr Jennifer Gunter dated Mon 27 Jun 2022 at 221pm Eastern with subj containing "item master data"
        if _ItemAttrID = 0 then begin
            _ItemAttr.SetFilter(Name,'@*handl*');
            if _ItemAttr.FindFirst() then
                _ItemAttrID := _ItemAttr.ID;
        end;
        if _ItemAttrID <> 0 then begin
            Clear(_ItemAttrValMap);
            _ItemAttrValMap.Reset();
            _ItemAttrValMap.SetRange("Table ID",Database::Item);
            _ItemAttrValMap.SetRange("No.",_itemNo);
            _ItemAttrValMap.SetRange("Item Attribute ID",_ItemAttrID);
            if _ItemAttrValMap.FindFirst() then begin
                _ItemAttrValID := _ItemAttrValMap."Item Attribute Value ID";
                Clear(_ItemAttrVal);
                _ItemAttrVal.Reset();
                _ItemAttrVal.SetRange("Attribute ID",_ItemAttrID);
                _ItemAttrVal.SetRange(ID,_ItemAttrValID);
                if _ItemAttrVal.FindFirst() then
                    _productClass := UpperCase(CopyStr(_ItemAttrVal.Value,1,1));
                /* ref concall Thu 22 Sep 2022 at 9am Eastern; ref email fr Jennifer Gunter Wed 21 Sep 2022 at 203pm Eastern
                if (not (_productClass in ['A','P','H','G'])) then
                    Clear(_productClass);
                */
            end;
        end;
    end;

    procedure GetStripText(_value: Text): Text
    begin
        Initialize();
        if not KorberSetup."Remove Special Characters" then
            exit(_value);
        if KorberSetup."Special Characters" = '' then
            exit(_value);
        if _value = '' then
            exit(_value);
        // YES: `~''!$%^&*()=+[]{}\|;:"<>/?  NO: @# (email, address suite no.)
        _value := DelChr(_value,'=',KorberSetup."Special Characters");
        if _value <> '' then
            _value := DelChr(_value,'<>',' ');
        exit(_value);
    end;

    local procedure ImportFile()
    var
        _KorberImportEntry: Record "ARC Korber Import Entry";
        _KorberImportEntry2: Record "ARC Korber Import Entry";
        _tempBlob: Record TempBlob temporary;
        _DataMgt: Codeunit "ARC DataMgt";
        _file: File;
        _is: InStream;
        _os: OutStream;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Msg: Label 'ImportFile(): %1';
    begin
        _timeBegin := Time();
        _KorberImportEntry.Get(EntryNoToImport);
        // prepare temporary space to store file contents
        _tempBlob.DeleteAll();
        _tempBlob.Init();
        _tempBlob.Blob.CreateOutStream(_os);
        // open the file to import
        _file.TextMode(true);
        _file.WriteMode(false);
        _file.Open(PathImport + _KorberImportEntry."File Name");
        _file.CreateInStream(_is);
        // copy file contents and close source file
        CopyStream(_os,_is);
        _file.Close();
        _tempBlob.Insert();
        // write success
        _KorberImportEntry2.LockTable();
        _KorberImportEntry2.Get(EntryNoToImport);
        _KorberImportEntry2.Imported := 1;
        _KorberImportEntry2."Imported No. of Attempts" := _KorberImportEntry2."Imported No. of Attempts" + 1;
        _timeEnd := Time();
        _KorberImportEntry2."Imported at DateTime" := CreateDateTime(Today(),_timeEnd);
        _KorberImportEntry2."Imported Duration" := _timeEnd - _timeBegin;
        _KorberImportEntry2."Imported Data Entry No." := _DataMgt.CreateDataEntry(KorberCode,
            StrSubstNo(_Text000Msg,_KorberImportEntry."File Name"),_KorberImportEntry."File Size",_tempBlob,false);
        _KorberImportEntry2.Process := true;
        _KorberImportEntry2.Modify();
        // write file contents to file archive location
        _tempBlob.CalcFields(Blob);
        _tempBlob.Blob.CreateInStream(_is);
        Clear(_file);
        _file.TextMode(true);
        _file.WriteMode(true);
        _file.Create(PathArchive + _KorberImportEntry."File Name");
        _file.CreateOutStream(_os);
        CopyStream(_os,_is);
        _file.Close();
        // erase the imported file
        Erase(PathImport + _KorberImportEntry."File Name");
    end;

    local procedure ImportFiles()
    var
        _KorberImportEntry: Record "ARC Korber Import Entry";
        _KorberImportEntry2: Record "ARC Korber Import Entry";
        _KorberMgt: Codeunit "ARC KorberMgt";
        _result: Boolean;
        _entriesProcessed: Integer;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Msg: Label 'KorberMgt, method ImportFiles(): total attempts: %1';
    begin
        _KorberImportEntry.SetCurrentKey(Import,Imported);
        _KorberImportEntry.SetRange(Import,true);
        _KorberImportEntry.SetRange(Imported,0);
        if _KorberImportEntry.FindSet(false) then
            repeat
                _timeBegin := Time();
                Clear(_KorberMgt);
                _KorberMgt.SetEntryNoToImport(_KorberImportEntry."Entry No.");
                Commit();
                _result := _KorberMgt.Run();
                if not _result then begin
                    Clear(_KorberImportEntry2);
                    _KorberImportEntry2.Reset();
                    _KorberImportEntry2.LockTable();
                    if _KorberImportEntry2.Get(_KorberImportEntry."Entry No.") then begin
                        _KorberImportEntry2."Imported Error Text" := CopyStr(GetLastErrorText(),1,MaxStrLen(_KorberImportEntry2."Imported Error Text"));
                        _timeEnd := Time();
                        _KorberImportEntry2."Imported Duration" := _timeEnd - _timeBegin;
                        _KorberImportEntry2."Imported at DateTime" := CreateDateTime(Today(),_timeEnd);
                        _KorberImportEntry2."Imported No. of Attempts" := _KorberImportEntry2."Imported No. of Attempts" + 1;
                        if _KorberImportEntry2."Imported No. of Attempts" >= KorberSetup."Maximum No. of Attempts" then begin
                            _KorberImportEntry2.Imported := -1;
                            WriteFileContentsPathError(_KorberImportEntry);
                        end;
                        _KorberImportEntry2.Modify();
                    end;
                end;
                _entriesProcessed += 1;
            until (_KorberImportEntry.Next() = 0) or (_entriesProcessed >= KorberSetup."Process Queue No. Entries");
        if _entriesProcessed > 0 then
            WriteLog(KorberSetup."Log Level"::Verbose,Codeunit::"ARC KorberMgt",KorberCode,0,0,StrSubstNo(_Text000Msg,_entriesProcessed),'');
    end;

    local procedure ListFiles()
    var
        _fileRec: Record File;
        _KorberImportEntry: Record "ARC Korber Import Entry";
        _time: Time;
    begin
        _fileRec.SetRange("Is a file",true);
        _fileRec.SetRange(Path,PathImport);
        if _fileRec.FindSet(false) then
            repeat
                Clear(_KorberImportEntry);
                _KorberImportEntry.Reset();
                _KorberImportEntry.SetCurrentKey(Imported,"File Name");
                _KorberImportEntry.SetRange(Imported,0);
                _KorberImportEntry.SetRange("File Name",_fileRec.Name);
                if _KorberImportEntry.IsEmpty() then begin
                    _time := Time();
                    Clear(_KorberImportEntry);
                    _KorberImportEntry.Reset();
                    _KorberImportEntry.Init();
                    _KorberImportEntry."Entry No." := 0;
                    _KorberImportEntry."Created at Date" := Today();
                    _KorberImportEntry."Created at DateTime" := CreateDateTime(Today(),_time);
                    _KorberImportEntry."Created at Time" := _time;
                    _KorberImportEntry."File Name" := CopyStr(_fileRec.Name,1,MaxStrLen(_KorberImportEntry."File Name"));
                    _KorberImportEntry."File Path" := CopyStr(_fileRec.Path,1,MaxStrLen(_KorberImportEntry."File Path"));
                    _KorberImportEntry."File Date" := _fileRec.Date;
                    _KorberImportEntry."File Time" := _fileRec.Time;
                    _KorberImportEntry."File Size" := _fileRec.Size;
                    _KorberImportEntry.Import := true;
                    _KorberImportEntry.Insert();
                end;
            until _fileRec.Next() = 0;
    end;

    local procedure Initialize()
    var
    _CR: Char;
    _NL: Char;
    begin
        if Initialized then
            exit;
        KorberSetup.Get();
        GetPaths();
        Initialized := true;
        _CR := 13;
        _NL := 10;
        CRNL := CopyStr(Format(_CR) + Format(_NL),1,MaxStrLen(CRNL));
    end;

    procedure OnAfterReleaseTransferDoc(var TransferHeader: Record "Transfer Header")
    var
        _KorberRcptMgt: Codeunit "ARC KorberRcptMgt";
        _KorberShptMgt: Codeunit "ARC KorberShptMgt";
    begin
        _KorberShptMgt.OnAfterReleaseTransferDoc(TransferHeader);
        _KorberRcptMgt.OnAfterReleaseTransferDoc(TransferHeader);
    end;

    procedure OnAfterModifyLocation(var Rec: Record Location; var xRec: Record Location; RunTrigger: Boolean)
    begin
        if not Rec."ARC Enable Korber WMS" then
            exit;
        TestLocationSetup(Rec);
    end;

    procedure OnAfterValidateLocationEnableKorberWMS(var Rec: Record Location; var xRec: Record Location; CurrFieldNo: Integer)
    var
        _Text000Msg: Label 'Korber WMS enabled for Location %1';
    begin
        Initialize();
        if not Rec."ARC Enable Korber WMS" then
            exit;
        TestLocationSetup(Rec);
        WriteLog(KorberSetup."Log Level"::Normal,Codeunit::"ARC KorberMgt",'KORBERWMS',0,0,StrSubstNo(_Text000Msg,Rec.Code),'');
    end;

    procedure OnUpgradeKorberPerCompany()
    var
        _JobQueueEntry: Record "Job Queue Entry";
    begin
        CreateJobQueueEntry(_JobQueueEntry."Object Type to Run"::Report,Report::"ARC Korber Data Purge");
        CreateJobQueueEntry(_JobQueueEntry."Object Type to Run"::Codeunit,Codeunit::"ARC KorberMgt");
        CreateJobQueueEntry(_JobQueueEntry."Object Type to Run"::Codeunit,Codeunit::"ARC KorberShptMgt");
        CreateJobQueueEntry(_JobQueueEntry."Object Type to Run"::Codeunit,Codeunit::"ARC KorberRcptMgt");
        CreateJobQueueEntry(_JobQueueEntry."Object Type to Run"::Codeunit,Codeunit::"ARC KorberItemMgt");
        CreateJobQueueEntry(_JobQueueEntry."Object Type to Run"::Codeunit,Codeunit::"ARC KorberItemAdjmtMgt");
    end;

    local procedure ProcessEntries()
    var
        _KorberImportEntry: Record "ARC Korber Import Entry";
        _KorberImportEntry2: Record "ARC Korber Import Entry";
        _KorberMgt: Codeunit "ARC KorberMgt";
        _result: Boolean;
        _entriesProcessed: Integer;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Msg: Label 'KorberMgt, method ProcessFiles(): total attempts: %1';
    begin
        _KorberImportEntry.SetCurrentKey(Process,Processed);
        _KorberImportEntry.SetRange(Process,true);
        _KorberImportEntry.SetRange(Processed,0);
        if _KorberImportEntry.FindSet(false) then
            repeat
                _timeBegin := Time();
                Clear(_KorberMgt);
                _KorberMgt.SetEntryNoToProcess(_KorberImportEntry."Entry No.");
                Commit();
                _result := _KorberMgt.Run();
                if not _result then begin
                    Clear(_KorberImportEntry2);
                    _KorberImportEntry2.Reset();
                    _KorberImportEntry2.LockTable();
                    if _KorberImportEntry2.Get(_KorberImportEntry."Entry No.") then begin
                        _KorberImportEntry2."Processed Error Text" := CopyStr(GetLastErrorText(),1,MaxStrLen(_KorberImportEntry2."Processed Error Text"));
                        _timeEnd := Time();
                        _KorberImportEntry2."Processed Duration" := _timeEnd - _timeBegin;
                        _KorberImportEntry2."Processed at DateTime" := CreateDateTime(Today(),_timeEnd);
                        _KorberImportEntry2."Processed No. of Attempts" := _KorberImportEntry2."Processed No. of Attempts" + 1;
                        if _KorberImportEntry2."Processed No. of Attempts" >= KorberSetup."Maximum No. of Attempts" then
                            _KorberImportEntry2.Processed := -1;
                        _KorberImportEntry2.Modify();
                    end;
                end;
                _entriesProcessed += 1;
            until (_KorberImportEntry.Next() = 0) or (_entriesProcessed >= KorberSetup."Process Queue No. Entries");
        if _entriesProcessed > 0 then
            WriteLog(KorberSetup."Log Level"::Verbose,Codeunit::"ARC KorberMgt",KorberCode,0,0,StrSubstNo(_Text000Msg,_entriesProcessed),'');
    end;

    local procedure ProcessEntry()
    var
        _DataEntry: Record "ARC Data Entry";
        _KorberImportEntry: Record "ARC Korber Import Entry";
        _is: InStream;
        _rootName: Text;
        _text: Text;
        _timeBegin: Time;
        _timeEnd: Time;
        _xmlDoc: XmlDocument;
        _xmlRoot: XmlElement;
        _Text000Err: Label 'File type unrecognized: %1';
    begin
        _timeBegin := Time();
        _KorberImportEntry.LockTable();
        _KorberImportEntry.Get(EntryNoToProcess);
        _KorberImportEntry.TestField("Imported Data Entry No.");
        _DataEntry.Get(_KorberImportEntry."Imported Data Entry No.");
        _DataEntry.CalcFields(Data);
        _DataEntry.Data.CreateInStream(_is);
        XmlDocument.ReadFrom(_is,_xmlDoc);
        _xmlDoc.GetRoot(_xmlRoot);
        _rootName := CopyStr(DelChr(_xmlRoot.Name(),'=',':'),1,MaxStrLen(_rootName));
        _KorberImportEntry."Document Type" := CopyStr(_rootName,1,MaxStrLen(_KorberImportEntry."Document Type"));
        case _rootName of
            'Adjustment'          : ProcessEntryItemAdjmt(_KorberImportEntry,_xmlDoc);
            'ReceiptConfirmation' : ProcessEntryRcptConfirmation(_KorberImportEntry,_xmlDoc);
            'PickConfirmation'    ,
            'ShipmentConfirmation': ProcessEntryShptConfirmation(_KorberImportEntry,_xmlDoc);
            'TransferConfirmation': ProcessEntryTransferConfirmation(_KorberImportEntry,_xmlDoc);
            else                    Error(_Text000Err,_rootName);
        end;
        _KorberImportEntry.Processed := 1;
        _KorberImportEntry."Processed No. of Attempts" := _KorberImportEntry."Processed No. of Attempts" + 1;
        _timeEnd := Time();
        _KorberImportEntry."Processed at DateTime" := CreateDateTime(Today(),_timeEnd);
        _KorberImportEntry."Processed Duration" := _timeEnd - _timeBegin;
        _KorberImportEntry.Modify();
    end;

    local procedure ProcessEntryGetXmlContents(_EntryNo: BigInteger; _xmlDoc: XmlDocument; var _xmlBuf: Record "XML Buffer" temporary): BigInteger
    var
        _tempBlob: Record TempBlob temporary;
        _DataMgt: Codeunit "ARC DataMgt";
        _bt: BigText;
        _is: InStream;
        _os: OutStream;
        _xmlElement: XmlElement;
        _Text000Lbl: Label 'Korber Import Entry No. %1 (formatted XML)';
    begin
        _tempBlob.DeleteAll();
        _tempBlob.Init();
        _tempBlob.Blob.CreateOutStream(_os);
        _xmlDoc.WriteTo(_os);
        _tempBlob.Insert();
        _tempBlob.CalcFields(Blob);
        _tempBlob.Blob.CreateInStream(_is);
        _xmlBuf.Load(_is);
        //_xmlBuf.SetRange(Type,_xmlBuf.Type::Element);
        if _xmlBuf.FindSet(false) then
            repeat
                _bt.AddText(StrSubstNo('Entry No.       : %1',_xmlBuf."Entry No.") + CRNL);
                _bt.AddText(StrSubstNo('Data Type       : %1',_xmlBuf."Data Type") + CRNL);
                _bt.AddText(StrSubstNo('Depth           : %1',_xmlBuf.Depth) + CRNL);
                _bt.AddText(StrSubstNo('Import ID       : %1',_xmlBuf."Import ID") + CRNL);
                _bt.AddText(StrSubstNo('Name            : %1',_xmlBuf.Name) + CRNL);
                _bt.AddText(StrSubstNo('Namespace       : %1',_xmlBuf.Namespace) + CRNL);
                _bt.AddText(StrSubstNo('Node Number     : %1',_xmlBuf."Node Number") + CRNL);
                _bt.AddText(StrSubstNo('Parent Entry No.: %1',_xmlBuf."Parent Entry No.") + CRNL);
                _bt.AddText(StrSubstNo('Path            : %1',_xmlBuf.Path) + CRNL);
                _bt.AddText(StrSubstNo('Type            : %1',_xmlBuf.Type) + CRNL);
                _bt.AddText(StrSubstNo('Value           : %1',_xmlBuf.Value) + CRNL);
                _bt.AddText(CRNL);
            until _xmlBuf.Next() = 0;
        exit(_DataMgt.NewDataEntry(KorberCode,StrSubstNo(_Text000Lbl,_EntryNo),_bt));
    end;

    local procedure ProcessEntryItemAdjmt(var _KorberImportEntry: Record "ARC Korber Import Entry"; _xmlDoc: XmlDocument)
    var
        _tempBuf: Record "ARC Buffer" temporary;
        _xmlBuf: Record "XML Buffer" temporary;
        _KorberItemAdjmtMgt: Codeunit "ARC KorberItemAdjmtMgt";
    begin
        _KorberImportEntry."Processed Data Entry No." := ProcessEntryGetXmlContents(_KorberImportEntry."Entry No.",_xmlDoc,_xmlBuf);
        _tempBuf.DeleteAll();
        _tempBuf.Init();
        _tempBuf."BigInteger 01" := _KorberImportEntry."Imported Data Entry No.";
        if _xmlBuf.FindSet(false) then
            repeat
                case _xmlBuf.Name of
                    'Quantity':
                        begin
                            _tempBuf."Text 04" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Text 04"));
                            if Evaluate(_tempBuf."Decimal 01",_xmlBuf.Value) then;
                        end;
                    'RowId': _tempBuf."Text 01" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Text 01"));
                    'AdjustmentDate': _tempBuf."Text 02" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Text 02"));
                    'BinLocation': _tempBuf."Code 01" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Code 01"));
                    'OperatorName': _tempBuf."Code 02" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Code 02"));
                    'OrderNum': _tempBuf."Text 03" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Text 03"));
                    'ProductCode': _tempBuf."Code 03" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Code 03"));
                    'ReasonCode':  _tempBuf."Code 04" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Code 04"));
                    'TransactionCode': _tempBuf."Code 05" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Code 05"));
                    'Warehouse': _tempBuf."Code 06" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Code 06"));
                    'Zone': 
                        begin
                            _tempBuf."Code 07" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Code 07"));
                            _tempBuf.Insert();
                            _KorberItemAdjmtMgt.CreateItemAdjmtWMS(_tempBuf);
                        end;
                end;
            until _xmlBuf.Next() = 0;
    end;

    local procedure ProcessEntryRcptConfirmation(var _KorberImportEntry: Record "ARC Korber Import Entry"; _xmlDoc: XmlDocument)
    var
        _tempBuf: Record "ARC Buffer" temporary;
        _xmlBuf: Record "XML Buffer" temporary;
        _KorberRcptMgt: Codeunit "ARC KorberRcptMgt";
        _mark: Boolean;
        _Text000Err: Label 'Method ProcessEntryRcptConfirmation(): failed to locate originating entry no. in <Extra2> tag';
    begin
        _KorberImportEntry."Processed Data Entry No." := ProcessEntryGetXmlContents(_KorberImportEntry."Entry No.",_xmlDoc,_xmlBuf);
        _tempBuf.DeleteAll();
        _tempBuf.Init();
        if _xmlBuf.FindSet(false) then
            repeat
                case _xmlBuf.Name of
                    // tags for Korber Import Entry
                    'Action': _KorberImportEntry."Action Text" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Action Text"));
                    'ContainerBatchReference': _KorberImportEntry."Container Batch Reference" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Container Batch Reference"));
                    'Date': _KorberImportEntry."Date Text" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Date Text"));
                    'OrderNumber': _KorberImportEntry."Order Number" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Order Number"));
                    'OrderType': _KorberImportEntry."Order Type" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Order Type"));
                    'PurchaseOrderNumber': _KorberImportEntry."Purchase Order Number" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Purchase Order Number"));
                    'Status': _KorberImportEntry.Status := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry.Status));
                    'Time': _KorberImportEntry."Time Text" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Time Text"));
                    // actionable tags
                    'ReceiptConfirmationLine':
                        begin
                            _tempBuf.DeleteAll();
                            _tempBuf.Init();
                            _mark := true;
                        end;
                    'Extra2': if Evaluate(_tempBuf."BigInteger 01",_xmlBuf.Value) then;
                    'LineNum': if Evaluate(_tempBuf."Integer 01",_xmlBuf.Value) then;
                    'ProductCode': _tempBuf."Code 01" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Code 01"));
                    'QuantityReceived': if Evaluate(_tempBuf."Decimal 01",_xmlBuf.Value) then;
                    'Warehouse':
                        if _mark then begin
                            _tempBuf."Code 02" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Code 02"));
                            _tempBuf."BigInteger 02" := _KorberImportEntry."Entry No.";
                            if _tempBuf."BigInteger 01" <> 0 then begin
                                _KorberRcptMgt.CreateProcessEntry(_tempBuf);
                            end else
                                WriteLog(KorberSetup."Log Level"::Error,Codeunit::"ARC KorberMgt",KorberCode,_KorberImportEntry."Entry No.",0,_Text000Err,'');
                            _mark := false;
                        end;
                end;
            until _xmlBuf.Next() = 0;
    end;

    local procedure ProcessEntryShptConfirmation(var _KorberImportEntry: Record "ARC Korber Import Entry"; _xmlDoc: XmlDocument)
    var
        _tempBuf: Record "ARC Buffer" temporary;
        _xmlBuf: Record "XML Buffer" temporary;
        _KorberShptMgt: Codeunit "ARC KorberShptMgt";
        _entryNo: BigInteger;
        _initialized: Boolean;
        _packSize: Decimal;
        _totalShptChg: Decimal;
        _DocNoText: Text;
        _Text000Err: Label 'Method ProcessEntryShptConfirmation(): failed to locate originating entry no. in <Extra2> tag';
    begin
        _KorberImportEntry."Processed Data Entry No." := ProcessEntryGetXmlContents(_KorberImportEntry."Entry No.",_xmlDoc,_xmlBuf);
        _tempBuf.DeleteAll();
        _tempBuf.Init();
        if _xmlBuf.FindSet(false) then
            repeat
                case _xmlBuf.Name of
                    // tags for Korber Import Entry
                    'Action': _KorberImportEntry."Action Text" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Action Text"));
                    'ContainerBatchReference': _KorberImportEntry."Container Batch Reference" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Container Batch Reference"));
                    'Date': _KorberImportEntry."Date Text" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Date Text"));
                    'OrderNumber': _KorberImportEntry."Order Number" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Order Number"));
                    'OrderType': _KorberImportEntry."Order Type" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Order Type"));
                    'PurchaseOrderNumber': _KorberImportEntry."Purchase Order Number" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Purchase Order Number"));
                    'Status': _KorberImportEntry.Status := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry.Status));
                    'Time': _KorberImportEntry."Time Text" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Time Text"));
                    // actionable tags
                    'CartonLine':
                        begin
                            _entryNo += 1;
                            _tempBuf.Init();
                            _tempBuf."Entry No." := _entryNo;
                            _tempBuf.Insert();
                            _initialized := true;
                        end;
                    'HostOrder': _DocNoText := CopyStr(_xmlBuf.Value,1,MaxStrLen(_DocNoText));
                    'Extra2': if Evaluate(_tempBuf."BigInteger 01",_xmlBuf.Value) then;
                    'LineNum': if Evaluate(_tempBuf."Integer 01",_xmlBuf.Value) then;
                    'ProductCode': _tempBuf."Code 01" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Code 01"));
                    'PickerId': _tempBuf."Code 03" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Code 03"));
                    'ShipVia': 
                        if not _tempBuf.IsEmpty() then
                            if Format(_xmlBuf.Value) <> '' then
                                _tempBuf.ModifyAll("Code 04",CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Code 04")));
                    'ShipmentCarrier': 
                        if not _tempBuf.IsEmpty() then
                            if Format(_xmlBuf.Value) <> '' then
                                _tempBuf.ModifyAll("Code 05",CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Code 05")));
                    'ShipServc': 
                        if not _tempBuf.IsEmpty() then
                            if Format(_xmlBuf.Value) <> '' then
                                _tempBuf.ModifyAll("Code 06",CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Code 06")));
                    'TotalShipmentCharge': 
                        begin
                            if Evaluate(_totalShptChg,_xmlBuf.Value) then 
                                if _totalShptChg <> 0 then begin
                                    _KorberImportEntry."Total Shipment Charge" := _totalShptChg;
                                    if not _tempBuf.IsEmpty() then
                                        _tempBuf.ModifyAll("Decimal 02",_totalShptChg);
                                end;
                        end;
                    'Packsize': if Evaluate(_packSize,_xmlBuf.Value) then;
                    'QuantityPacked': if Evaluate(_tempBuf."Decimal 01",_xmlBuf.Value) then;  // represents actual qty in carton for item - Thu 27 Oct 2022
                    'TrackTraceNumber': 
                        if not _tempBuf.IsEmpty() then
                            if Format(_xmlBuf.Value) <> '' then
                                _tempBuf.ModifyAll("Text 01",CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Text 01")));
                    'ShipmentId': 
                        if not _tempBuf.IsEmpty() then
                            if Format(_xmlBuf.Value) <> '' then
                                _tempBuf.ModifyAll("Text 02",CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Text 02")));
                    'Warehouse':
                        if not _tempBuf.IsEmpty() then
                            if Format(_xmlBuf.Value) <> '' then
                                _tempBuf.ModifyAll("Code 02",CopyStr(_xmlBuf.Value,1,MaxStrLen(_tempBuf."Code 02")));
                    'TotalQtyLineAttribute','UPC','UPCCaseCode','UoM','WMSUDF1','WMSUDF2','Weight','Zone':
                        if _initialized then begin
                            if _tempBuf."Decimal 01" = 0 then // QuantityPacked
                                _tempBuf.Delete()
                            else
                                _tempBuf.Modify();
                            Clear(_packSize);
                            _initialized := false;
                        end;
                end;
            until _xmlBuf.Next() = 0;
        // create entries for processing shipment
        if not _tempBuf.IsEmpty() then
            _tempBuf.ModifyAll("BigInteger 02",_KorberImportEntry."Entry No.");
        if _tempBuf.FindSet(false) then
            repeat
                if _tempBuf."BigInteger 01" <> 0 then  // tag Extra2 = ShptEntryNo
                    _KorberShptMgt.CreateProcessEntry(_tempBuf)
                else
                    WriteLog(KorberSetup."Log Level"::Error,Codeunit::"ARC KorberMgt",KorberCode,_KorberImportEntry."Entry No.",0,_Text000Err,'');
            until _tempBuf.Next() = 0;
    end;

    local procedure ProcessEntryTransferConfirmation(var _KorberImportEntry: Record "ARC Korber Import Entry"; _xmlDoc: XmlDocument)
    var
        _xmlBuf: Record "XML Buffer" temporary;
    begin
        _KorberImportEntry."Processed Data Entry No." := ProcessEntryGetXmlContents(_KorberImportEntry."Entry No.",_xmlDoc,_xmlBuf);
        if _xmlBuf.FindSet(false) then
            repeat
                case _xmlBuf.Name of
                    'Action': _KorberImportEntry."Action Text" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Action Text"));
                    'ContainerBatchReference': _KorberImportEntry."Container Batch Reference" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Container Batch Reference"));
                    'Date': _KorberImportEntry."Date Text" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Date Text"));
                    'OrderNumber': _KorberImportEntry."Order Number" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Order Number"));
                    'OrderType': _KorberImportEntry."Order Type" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Order Type"));
                    'PurchaseOrderNumber': _KorberImportEntry."Purchase Order Number" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Purchase Order Number"));
                    'Status': _KorberImportEntry.Status := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry.Status));
                    'Time': _KorberImportEntry."Time Text" := CopyStr(_xmlBuf.Value,1,MaxStrLen(_KorberImportEntry."Time Text"));
                end;
            until _xmlBuf.Next() = 0;
    end;

    procedure ResetEntry(var _KorberImportEntry: Record "ARC Korber Import Entry")
    var
        _KorberImportEntry2: Record "ARC Korber Import Entry";
        _count: Integer;
        _Text000Qst: Label 'Entries selected: %1.  Are you SURE you want to reset?';
        _Text001Msg: Label '*** RESET *** %1 No. %2';
    begin
        Initialize();
        _count := _KorberImportEntry.Count();
        if GuiAllowed() then
            if not Confirm(_Text000Qst,false,_count) then
                exit;
        if _KorberImportEntry.FindSet(false) then
            repeat
                Clear(_KorberImportEntry2);
                _KorberImportEntry2.Reset();
                _KorberImportEntry2.LockTable();
                _KorberImportEntry2.Get(_KorberImportEntry."Entry No.");
                _KorberImportEntry2.Processed := 0;
                _KorberImportEntry2."Processed at DateTime" := 0DT;
                _KorberImportEntry2."Processed Duration" := 0;
                _KorberImportEntry2."Processed Error Text" := '';
                _KorberImportEntry2."Processed No. of Attempts" := 0;
                _KorberImportEntry2."Processed Data Entry No." := 0;
                _KorberImportEntry2.Modify();
                WriteLog(KorberSetup."Log Level"::Normal,Codeunit::"ARC KorberMgt",KorberCode,_KorberImportEntry."Entry No.",0,
                    StrSubstNo(_Text001Msg,_KorberImportEntry.TableCaption(),_KorberImportEntry."Entry No."),'');
            until _KorberImportEntry.Next() = 0;
    end;

    procedure SetEntryNoToImport(_EntryNoToImport: BigInteger)
    begin
        EntryNoToImport := _EntryNoToImport;
    end;

    procedure SetEntryNoToProcess(_EntryNoToProcess: BigInteger)
    begin
        EntryNoToProcess := _EntryNoToProcess;
    end;

    procedure ShowErrorLog()
    begin
        Page.Run(Page::"ARC Event Log Entries");
    end;

    procedure ShowJobQueue()
    var
        _JobQueueEntry: Record "Job Queue Entry";
    begin
        _JobQueueEntry.SetRange("Object Type to Run",_JobQueueEntry."Object Type to Run"::Codeunit);
        _JobQueueEntry.SetFilter("Object Caption to Run",'*Korber*');
        Page.Run(Page::"Job Queue Entries",_JobQueueEntry);
    end;

    local procedure TestLocationSetup(var _Location: Record Location)
    begin
        Initialize();
        _Location.TestField("Bin Mandatory",false);
        _Location.TestField("Directed Put-away and Pick",false);
        _Location.TestField("Require Pick",false);
        _Location.TestField("Require Put-away",false);
        // _Location.TestField("Require Receive",false);
        // _Location.TestField("Require Shipment",false);
    end;

    local procedure WriteFileContentsPathError(_KorberImportEntry: Record "ARC Korber Import Entry")
    var
        _tempBlob: Record TempBlob temporary;
        _file: File;
        _is: InStream;
        _os: OutStream;
    begin
        // prepare temporary space to store file contents
        _tempBlob.DeleteAll();
        _tempBlob.Init();
        _tempBlob.Blob.CreateOutStream(_os);
        // attempt to open the file to import
        _file.TextMode(true);
        _file.WriteMode(false);
        if _file.Open(PathImport + _KorberImportEntry."File Name") then begin
            _file.CreateInStream(_is);
            // copy file contents and close source file
            CopyStream(_os,_is);
            _file.Close();
            _tempBlob.Insert();
            // write file contents to file error location
            _tempBlob.CalcFields(Blob);
            _tempBlob.Blob.CreateInStream(_is);
            Clear(_file);
            _file.TextMode(true);
            _file.WriteMode(true);
            if _file.Create(PathArchive + _KorberImportEntry."File Name") then begin
                _file.CreateOutStream(_os);
                CopyStream(_os,_is);
                _file.Close();
                // erase the imported file
                if Erase(PathImport + _KorberImportEntry."File Name") then;
            end;
        end;
    end;

    procedure WriteLog(
        _logLevel: Integer; 
        _codeunitNo: Integer; 
        _code: Code[20]; 
        _relatedEntryNo: BigInteger; 
        _relatedDataEntryNo: BigInteger; 
        _msg: Text; 
        _err: Text)
    var
        _EventLogEntry: Record "ARC Event Log Entry";
        _status: Integer;
    begin
        Initialize();
        if _logLevel > KorberSetup."Log Level" then
            exit;
        if _err <> '' then
            _status := _EventLogEntry.Status::Error
        else
            _status := _EventLogEntry.Status::Message;
        _EventLogEntry.Init();
        _EventLogEntry."Entry No." := 0;
        _EventLogEntry.Code := CopyStr(_code,1,MaxStrLen(_EventLogEntry.Code));
        _EventLogEntry."Related Entry No." := _relatedEntryNo;
        _EventLogEntry."Related Data Entry No." := _relatedDataEntryNo;
        _EventLogEntry."Object Type" := _EventLogEntry."Object Type"::Codeunit;
        _EventLogEntry."Object ID" := _codeunitNo;
        _EventLogEntry.Status := _status;
        _EventLogEntry."Message Text" := CopyStr(_msg,1,MaxStrLen(_EventLogEntry."Message Text"));
        _EventLogEntry."Error Text" := CopyStr(_err,1,MaxStrLen(_EventLogEntry."Error Text"));
        _EventLogEntry."Created by" := CopyStr(UserId(),1,MaxStrLen(_EventLogEntry."Created by"));
        _EventLogEntry."Created at DateTime" := CurrentDateTime();
        _EventLogEntry.Insert();
    end;
}
codeunit 50103 "ARC KorberShptMgt"
{
    // SOW11 Körber Edge WMS Integration

    Permissions = tabledata "ARC Korber Shpt. Entry" = rim;

    trigger OnRun();
    begin
        Initialize();
        if not KorberSetup."Process Queue Enabled" then
            exit;
        if not KorberSetup."Send Shipments" then
            exit;
        if EntryNoToAnalyze <> 0 then begin
            AnalyzeEntry();
            exit;
        end;
        if EntryNoToProcess <> 0 then begin
            ProcessEntry();
            exit;
        end;
        if EntryNoToSend <> 0 then begin
            SendEntry();
            exit;
        end;
        AnalyzeEntries();
        SendEntries();
        ProcessEntries();
    end;

    var
        KorberSetup: Record "ARC Korber Setup";
        KorberMgt: Codeunit "ARC KorberMgt";
        EntryNoToAnalyze: BigInteger;
        EntryNoToProcess: BigInteger;
        EntryNoToSend: BigInteger;
        DiagText: BigText;
        Initialized: Boolean;
        CRNL: Text;
        DiagLabel: Label 'KORSHPMGT';

    local procedure AnalyzeDropShipPurchases(_PurchaseLine: Record "Purchase Line"): Boolean
    var
        _Purchasing: Record Purchasing;
    begin
        if KorberSetup."Shipment - Incl. Drop Ship" then
            exit(true);
        if _PurchaseLine."Purchasing Code" = '' then
            exit(true);
        if not _Purchasing.Get(_PurchaseLine."Purchasing Code") then
            exit(true);
        if not _Purchasing."Drop Shipment" then
            exit(true);
        exit(false);
    end;

    local procedure AnalyzeDropShipSales(_SalesLine: Record "Sales Line"): Boolean
    var
        _Purchasing: Record Purchasing;
    begin
        if KorberSetup."Shipment - Incl. Drop Ship" then
            exit(true);
        if _SalesLine."Purchasing Code" = '' then
            exit(true);
        if not _Purchasing.Get(_SalesLine."Purchasing Code") then
            exit(true);
        if not _Purchasing."Drop Shipment" then
            exit(true);
        exit(false);
    end;

    local procedure AnalyzeEntries()
    var
        _KorberShptEntry: Record "ARC Korber Shpt. Entry";
        _KorberShptEntry2: Record "ARC Korber Shpt. Entry";
        _KorberShptMgt: Codeunit "ARC KorberShptMgt";
        _DataMgt: Codeunit "ARC DataMgt";
        _result: Boolean;
        _entriesProcessed: Integer;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Msg: Label 'KorberShptMgt, entries analyzed: %1';
        _Text001Lbl: Label 'Diagnostic text captured during attempt to analyze shpt entry';
    begin
        _KorberShptEntry.SetCurrentKey(Analyze,Analyzed);
        _KorberShptEntry.SetRange(Analyze,true);
        _KorberShptEntry.SetRange(Analyzed,0);
        if _KorberShptEntry.FindSet(false) then
            repeat
                _timeBegin := Time();
                Clear(_KorberShptMgt);
                _KorberShptMgt.SetEntryNoToAnalyze(_KorberShptEntry."Entry No.");
                Commit();
                _result := _KorberShptMgt.Run();
                if not _result then begin
                    Clear(_KorberShptEntry2);
                    _KorberShptEntry2.Reset();
                    _KorberShptEntry2.LockTable();
                    if _KorberShptEntry2.Get(_KorberShptEntry."Entry No.") then begin
                        _timeEnd := Time();
                        _KorberShptMgt.GetDiagText(DiagText);
                        _KorberShptEntry2."Analyzed at DateTime" := CreateDateTime(Today(),_timeEnd);
                        _KorberShptEntry2."Analyzed Duration" := _timeEnd - _timeBegin;
                        _KorberShptEntry2."Analyzed No. of Attempts" := _KorberShptEntry2."Analyzed No. of Attempts" + 1;
                        _KorberShptEntry2."Analyzed Data Entry No." := _DataMgt.NewDataEntry(DiagLabel,_Text001Lbl,DiagText);
                        _KorberShptEntry2."Analyzed Error Text" := CopyStr(GetLastErrorText(),1,MaxStrLen(_KorberShptEntry2."Analyzed Error Text"));
                        if _KorberShptEntry2."Analyzed No. of Attempts" >= KorberSetup."Maximum No. of Attempts" then
                            _KorberShptEntry2.Analyzed := -1;
                        _KorberShptEntry2.Modify();
                    end;
                end;
                _entriesProcessed += 1;
            until (_KorberShptEntry.Next() = 0) or (_entriesProcessed >= KorberSetup."Process Queue No. Entries");
        if _entriesProcessed > 0 then
            WriteLog(KorberSetup."Log Level"::Verbose,0,0,StrSubstNo(_Text000Msg,_entriesProcessed),'');
    end;

    local procedure AnalyzeEntry()
    var
        _KorberShptEntry: Record "ARC Korber Shpt. Entry";
    begin
        _KorberShptEntry.Get(EntryNoToAnalyze);
        case _KorberShptEntry."Document Area" of
            _KorberShptEntry."Document Area"::Purchases:
                AnalyzeEntryPurchases(_KorberShptEntry);
            _KorberShptEntry."Document Area"::Sales:
                AnalyzeEntrySales(_KorberShptEntry);
            _KorberShptEntry."Document Area"::Transfers:
                AnalyzeEntryTransfers(_KorberShptEntry);
        end;
    end;

    local procedure AnalyzeEntryPurchases(_KorberShptEntry: Record "ARC Korber Shpt. Entry")
    var
        _KorberShptEntry2: Record "ARC Korber Shpt. Entry";
        _Location: Record Location;
        _PurchaseHeader: Record "Purchase Header";
        _PurchaseLine: Record "Purchase Line";
        _DataMgt: Codeunit "ARC DataMgt";
        _continue: Boolean;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Lbl: Label 'Diagnostic text captured during attempt to analyze shpt entry';
        _Text001Lbl: Label 'Purchase Line Filters: %1';
        _Text002Lbl: Label 'Failed to retrieve location %1 ... do not transmit this line';
        _Text003Lbl: Label 'Method IsAlreadySent() returned Yes for Item %1, ReturnQtyToShip %2 ... do not transmit this line';
        _Text004Lbl: Label 'Shpt. Entry %1 created for Item %2, ReturnQtyToShip (base) %3';
        _Text005Lbl: Label 'Method AnalyzeEntryPurchases(): %1';
    begin
        _timeBegin := Time();
        WriteDiagText(StrSubstNo(_Text005Lbl,'begin'));
        _PurchaseHeader.Get(_KorberShptEntry."Document Type",_KorberShptEntry."Document No.");
        _PurchaseLine.SetRange("Document Type",_PurchaseHeader."Document Type");
        _PurchaseLine.SetRange("Document No.",_PurchaseHeader."No.");
        _PurchaseLine.SetRange(Type,_PurchaseLine.Type::Item);
        _PurchaseLine.SetFilter("No.",'<>%1','');
        _PurchaseLine.SetFilter("Return Qty. to Ship",'<>0');
        WriteDiagText(StrSubstNo(_Text005Lbl,StrSubstNo(_Text001Lbl,_PurchaseLine.GetFilters())));
        if _PurchaseLine.FindSet(false) then
            repeat
                _continue := true;
                if not AnalyzeDropShipPurchases(_PurchaseLine) then begin
                    WriteDiagText(StrSubstNo(_Text005Lbl,'AnalyzeDropShipPurchases() returned No ... do not transmit this line'));
                    _continue := false;
                end;
                if not KorberMgt.GetLocation(_PurchaseLine."Location Code",_Location) then begin
                    WriteDiagText(StrSubstNo(_Text005Lbl,StrSubstNo(_Text002Lbl,_PurchaseLine."Location Code")));
                    _continue := false;
                end;
                if _continue then
                    if IsAlreadySent(_KorberShptEntry,_PurchaseLine."Line No.",_PurchaseLine."No.",_PurchaseLine.Quantity) then begin
                        WriteDiagText(StrSubstNo(_Text005Lbl,StrSubstNo(_Text003Lbl,_PurchaseLine."No.",_PurchaseLine."Return Qty. to Ship")));
                        _continue := false;
                    end;
                if _continue then begin
                    Clear(_KorberShptEntry2);
                    _KorberShptEntry2.Reset();
                    _KorberShptEntry2 := _KorberShptEntry;
                    _KorberShptEntry2."Entry No." := 0;
                    _KorberShptEntry2."Document Line No." := _PurchaseLine."Line No.";
                    _KorberShptEntry2."Item No." := CopyStr(_PurchaseLine."No.",1,MaxStrLen(_KorberShptEntry2."Item No."));
                    _KorberShptEntry2."Unit of Measure Code" := CopyStr(_PurchaseLine."Unit of Measure Code",1,MaxStrLen(_KorberShptEntry2."Unit of Measure Code"));
                    _KorberShptEntry2."Location Code" := CopyStr(_PurchaseLine."Location Code",1,MaxStrLen(_KorberShptEntry2."Location Code"));
                    _KorberShptEntry2.Quantity := _PurchaseLine."Return Qty. to Ship";
                    _KorberShptEntry2."Qty. per Unit of Measure" := _PurchaseLine."Qty. per Unit of Measure";
                    _KorberShptEntry2."Quantity (Base)" := _PurchaseLine."Return Qty. to Ship (Base)";
                    _KorberShptEntry2.Analyze := false;
                    _KorberShptEntry2.Analyzed := 0;
                    _KorberShptEntry2."Analyzed at DateTime" := 0DT;
                    _KorberShptEntry2."Analyzed Duration" := 0;
                    _KorberShptEntry2."Analyzed Error Text" := '';
                    _KorberShptEntry2."Analyzed No. of Attempts" := 0;
                    _KorberShptEntry2."Analyzed Data Entry No." := 0;
                    _KorberShptEntry2."Send to WMS" := true;
                    _KorberShptEntry2.Insert(false);
                    WriteDiagText(StrSubstNo(_Text005Lbl,StrSubstNo(_Text004Lbl,_KorberShptEntry2."Entry No.",_KorberShptEntry2."Item No.",_KorberShptEntry2."Quantity (Base)")));
                end;
            until _PurchaseLine.Next() = 0;
        _timeEnd := Time();
        Clear(_KorberShptEntry2);
        _KorberShptEntry2.Reset();
        _KorberShptEntry2.LockTable();
        _KorberShptEntry2.Get(_KorberShptEntry."Entry No.");
        _KorberShptEntry2."Analyzed at DateTime" := CreateDateTime(Today(),_timeEnd);
        _KorberShptEntry2."Analyzed No. of Attempts" := _KorberShptEntry2."Analyzed No. of Attempts" + 1;
        _KorberShptEntry2."Analyzed Duration" := _timeEnd - _timeBegin;
        _KorberShptEntry2."Analyzed Data Entry No." := _DataMgt.NewDataEntry(DiagLabel,_Text000Lbl,DiagText);
        _KorberShptEntry2.Analyzed := 1;
        _KorberShptEntry2.Modify(false);
        WriteDiagText(StrSubstNo(_Text005Lbl,'end'));
    end;

    local procedure AnalyzeEntrySales(_KorberShptEntry: Record "ARC Korber Shpt. Entry")
    var
        _KorberShptEntry2: Record "ARC Korber Shpt. Entry";
        _Location: Record Location;
        _SalesHeader: Record "Sales Header";
        _SalesLine: Record "Sales Line";
        _DataMgt: Codeunit "ARC DataMgt";
        _continue: Boolean;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Lbl: Label 'Diagnostic text captured during attempt to analyze shpt entry';
        _Text001Lbl: Label 'Purchase Line Filters: %1';
        _Text002Lbl: Label 'Failed to retrieve location %1 ... do not transmit this line';
        _Text003Lbl: Label 'Method IsAlreadySent() returned Yes for Item %1, QtyToShip %2 ... do not transmit this line';
        _Text004Lbl: Label 'Shpt. Entry %1 created for Item %2, ReturnQtyToShip (base) %3';
        _Text005Lbl: Label 'Method AnalyzeEntrySales(): %1';
    begin
        _timeBegin := Time();
        WriteDiagText(StrSubstNo(_Text005Lbl,'begin'));
        _SalesHeader.Get(_KorberShptEntry."Document Type",_KorberShptEntry."Document No.");
        _SalesLine.SetRange("Document Type",_SalesHeader."Document Type");
        _SalesLine.SetRange("Document No.",_SalesHeader."No.");
        _SalesLine.SetRange(Type,_SalesLine.Type::Item);
        _SalesLine.SetFilter("No.",'<>%1','');
        _SalesLine.SetFilter("Qty. to Ship",'<>0');
        if _SalesLine.FindSet(false) then
            repeat
                _continue := true;
                if not AnalyzeDropShipSales(_SalesLine) then begin
                    WriteDiagText(StrSubstNo(_Text005Lbl,'AnalyzeDropShipSales() returned No ... do not transmit this line'));
                    _continue := false;
                end;
                if not KorberMgt.GetLocation(_SalesLine."Location Code",_Location) then begin
                    WriteDiagText(StrSubstNo(_Text005Lbl,StrSubstNo(_Text002Lbl,_SalesLine."Location Code")));
                    _continue := false;
                end;
                if _continue then
                    if IsAlreadySent(_KorberShptEntry,_SalesLine."Line No.",_SalesLine."No.",_SalesLine.Quantity) then begin
                        WriteDiagText(StrSubstNo(_Text005Lbl,StrSubstNo(_Text003Lbl,_SalesLine."No.",_SalesLine."Qty. to Ship")));
                        _continue := false;
                    end;
                if _continue then begin
                    Clear(_KorberShptEntry2);
                    _KorberShptEntry2.Reset();
                    _KorberShptEntry2 := _KorberShptEntry;
                    _KorberShptEntry2."Entry No." := 0;
                    _KorberShptEntry2."Document Line No." := _SalesLine."Line No.";
                    _KorberShptEntry2."Item No." := CopyStr(_SalesLine."No.",1,MaxStrLen(_KorberShptEntry2."Item No."));
                    _KorberShptEntry2."Unit of Measure Code" := CopyStr(_SalesLine."Unit of Measure Code",1,MaxStrLen(_KorberShptEntry2."Unit of Measure Code"));
                    _KorberShptEntry2."Location Code" := CopyStr(_SalesLine."Location Code",1,MaxStrLen(_KorberShptEntry2."Location Code"));
                    _KorberShptEntry2.Quantity := _SalesLine."Qty. to Ship";
                    _KorberShptEntry2."Qty. per Unit of Measure" := _SalesLine."Qty. per Unit of Measure";
                    _KorberShptEntry2."Quantity (Base)" := _SalesLine."Qty. to Ship (Base)";
                    _KorberShptEntry2.Analyze := false;
                    _KorberShptEntry2.Analyzed := 0;
                    _KorberShptEntry2."Analyzed at DateTime" := 0DT;
                    _KorberShptEntry2."Analyzed Duration" := 0;
                    _KorberShptEntry2."Analyzed Error Text" := '';
                    _KorberShptEntry2."Analyzed No. of Attempts" := 0;
                    _KorberShptEntry2."Analyzed Data Entry No." := 0;
                    _KorberShptEntry2."Send to WMS" := true;
                    _KorberShptEntry2.Insert(false);
                    WriteDiagText(StrSubstNo(_Text005Lbl,StrSubstNo(_Text004Lbl,_KorberShptEntry2."Entry No.",_KorberShptEntry2."Item No.",_KorberShptEntry2."Quantity (Base)")));
                end;
            until _SalesLine.Next() = 0;
        _timeEnd := Time();
        Clear(_KorberShptEntry2);
        _KorberShptEntry2.Reset();
        _KorberShptEntry2.LockTable();
        _KorberShptEntry2.Get(_KorberShptEntry."Entry No.");
        _KorberShptEntry2."Analyzed at DateTime" := CreateDateTime(Today(),_timeEnd);
        _KorberShptEntry2."Analyzed No. of Attempts" := _KorberShptEntry2."Analyzed No. of Attempts" + 1;
        _KorberShptEntry2."Analyzed Duration" := _timeEnd - _timeBegin;
        _KorberShptEntry2."Analyzed Data Entry No." := _DataMgt.NewDataEntry(DiagLabel,_Text000Lbl,DiagText);
        _KorberShptEntry2.Analyzed := 1;
        _KorberShptEntry2.Modify(false);
        WriteDiagText(StrSubstNo(_Text005Lbl,'end'));
    end;

    local procedure AnalyzeEntryTransfers(_KorberShptEntry: Record "ARC Korber Shpt. Entry")
    var
        _KorberShptEntry2: Record "ARC Korber Shpt. Entry";
        _Location: Record Location;
        _TransferHeader: Record "Transfer Header";
        _TransferLine: Record "Transfer Line";
        _DataMgt: Codeunit "ARC DataMgt";
        _continue: Boolean;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Err: Label 'Transfer-from Location %1 is not Korber-enabled, so Korber Edge will not be alerted to ship Transfer Order %2.';
        _Text001Lbl: Label 'Diagnostic text captured during attempt to analyze shpt entry';
        _Text002Lbl: Label 'Purchase Line Filters: %1';
        _Text003Lbl: Label 'Failed to retrieve location %1 ... do not transmit this line';
        _Text004Lbl: Label 'Method IsAlreadySent() returned Yes for Item %1, QtyToShip %2 ... do not transmit this line';
        _Text005Lbl: Label 'Shpt. Entry %1 created for Item %2, ReturnQtyToShip (base) %3';
        _Text006Lbl: Label 'Qty(base) %1 minus QtyShipped(base) %2 is zero or less ... do not transmit this line';
        _Text007Lbl: Label 'Method AnalyzeEntryTransfers(): %1';
    begin
        _timeBegin := Time();
        WriteDiagText(StrSubstNo(_Text007Lbl,'begin'));
        _TransferHeader.Get(_KorberShptEntry."Document No.");
        if not KorberMgt.GetLocation(_TransferHeader."Transfer-from Code",_Location) then begin
            // WriteLog(KorberSetup."Log Level"::Error,_KorberShptEntry."Entry No.",0,'',
            //     StrSubstNo(_Text000Err,_TransferHeader."Transfer-to Code",_KorberShptEntry."Document No."));
            // exit;
			Error(_Text000Err,_TransferHeader."Transfer-to Code",_KorberShptEntry."Document No.");
        end;
        _TransferLine.SetRange("Document No.",_TransferHeader."No.");
        _TransferLine.SetRange("Derived From Line No.",0);
        _TransferLine.SetFilter("Outstanding Qty. (Base)",'<>0');
        if _TransferLine.FindSet(false) then
            repeat
                _continue := true;
                if _TransferLine."Quantity (Base)" - _TransferLine."Qty. Shipped (Base)" <= 0 then begin
                    WriteDiagText(StrSubstNo(_Text007Lbl,StrSubstNo(_Text006Lbl,_TransferLine."Quantity (Base)",_TransferLine."Qty. Shipped (Base)")));
                    _continue := false;
                end;
                if _continue then
                    if IsAlreadySent(_KorberShptEntry,_TransferLine."Line No.",_TransferLine."Item No.",_TransferLine.Quantity) then begin
                        WriteDiagText(StrSubstNo(_Text007Lbl,StrSubstNo(_Text003Lbl,_TransferLine."Item No.",_TransferLine."Qty. to Ship")));
                        _continue := false;
                    end;
                if _continue then begin
                    Clear(_KorberShptEntry2);
                    _KorberShptEntry2.Reset();
                    _KorberShptEntry2 := _KorberShptEntry;
                    _KorberShptEntry2."Entry No." := 0;
                    _KorberShptEntry2."Document Line No." := _TransferLine."Line No.";
                    _KorberShptEntry2."Item No." := CopyStr(_TransferLine."Item No.",1,MaxStrLen(_KorberShptEntry2."Item No."));
                    _KorberShptEntry2."Unit of Measure Code" := CopyStr(_TransferLine."Unit of Measure Code",1,MaxStrLen(_KorberShptEntry2."Unit of Measure Code"));
                    _KorberShptEntry2."Location Code" := CopyStr(_TransferHeader."Transfer-from Code",1,MaxStrLen(_KorberShptEntry2."Location Code"));
                    _KorberShptEntry2.Quantity := _TransferLine.Quantity;
                    _KorberShptEntry2."Qty. per Unit of Measure" := _TransferLine."Qty. per Unit of Measure";
                    _KorberShptEntry2."Quantity (Base)" := _TransferLine."Quantity (Base)";
                    _KorberShptEntry2.Analyze := false;
                    _KorberShptEntry2.Analyzed := 0;
                    _KorberShptEntry2."Analyzed at DateTime" := 0DT;
                    _KorberShptEntry2."Analyzed Duration" := 0;
                    _KorberShptEntry2."Analyzed Error Text" := '';
                    _KorberShptEntry2."Analyzed No. of Attempts" := 0;
                    _KorberShptEntry2."Analyzed Data Entry No." := 0;
                    _KorberShptEntry2."Send to WMS" := true;
                    _KorberShptEntry2.Insert(false);
                    WriteDiagText(StrSubstNo(_Text007Lbl,StrSubstNo(_Text005Lbl,_KorberShptEntry2."Entry No.",_KorberShptEntry2."Item No.",_KorberShptEntry2."Quantity (Base)")));
                end;
            until _TransferLine.Next() = 0;
        _timeEnd := Time();
        Clear(_KorberShptEntry2);
        _KorberShptEntry2.Reset();
        _KorberShptEntry2.LockTable();
        _KorberShptEntry2.Get(_KorberShptEntry."Entry No.");
        _KorberShptEntry2."Analyzed at DateTime" := CreateDateTime(Today(),_timeEnd);
        _KorberShptEntry2."Analyzed No. of Attempts" := _KorberShptEntry2."Analyzed No. of Attempts" + 1;
        _KorberShptEntry2."Analyzed Duration" := _timeEnd - _timeBegin;
        _KorberShptEntry2."Analyzed Data Entry No." := _DataMgt.NewDataEntry(DiagLabel,_Text001Lbl,DiagText);
        _KorberShptEntry2.Analyzed := 1;
        _KorberShptEntry2.Modify(false);
        WriteDiagText(StrSubstNo(_Text007Lbl,'end'));
    end;

    procedure CreateProcessEntry(var _tempBuf: Record "ARC Buffer" temporary)
    var
        _ShptEntry: Record "ARC Korber Shpt. Entry";
        _ShptEntry2: Record "ARC Korber Shpt. Entry";
        _continue: Boolean;
        _time: Time;
    begin
        // designed to be called from codeunit 50102 "ARC KorberMgt" when XML is imported
        _time := Time();
        _ShptEntry.Get(_tempBuf."BigInteger 01");
        _ShptEntry2 := _ShptEntry;
        _ShptEntry2."Entry No." := 0;
        if _tempBuf."Integer 01" <> 0 then
            _ShptEntry2."Document Line No." := _tempBuf."Integer 01";
        if _tempBuf."Code 01" <> '' then
            _ShptEntry2."Item No." := CopyStr(_tempBuf."Code 01",1,MaxStrLen(_ShptEntry2."Item No."));
        if _tempBuf."Code 02" <> '' then
            _ShptEntry2."Location Code" := CopyStr(_tempBuf."Code 02",1,MaxStrLen(_ShptEntry2."Location Code"));
        if _tempBuf."Code 03" <> '' then
            _ShptEntry2."Picker ID" := CopyStr(_tempBuf."Code 03",1,MaxStrLen(_ShptEntry2."Picker ID"));
        if _tempBuf."Code 04" <> '' then
            _ShptEntry2."Ship Via" := CopyStr(_tempBuf."Code 04",1,MaxStrLen(_ShptEntry2."Ship Via"));
        if _tempBuf."Code 05" <> '' then
            _ShptEntry2."Shipment Carrier" := CopyStr(_tempBuf."Code 05",1,MaxStrLen(_ShptEntry2."Shipment Carrier"));
        if _tempBuf."Code 06" <> '' then
            _ShptEntry2."Shipment Service" := CopyStr(_tempBuf."Code 06",1,MaxStrLen(_ShptEntry2."Shipment Service"));
        if _tempBuf."Decimal 02" <> 0 then
            _ShptEntry2."Total Shipment Charge" := _tempBuf."Decimal 02";
        if _tempBuf."Decimal 01" <> 0 then begin
            /* qtys per UOM always base according to Erik - scenario tested Mon 24 Oct 2022
            **   concall re [RENT] SOW11 Körber Edge WMS Integration -- Session 1: End to End workshop for UAT/ WMS - Paola Montgomery
            _ShptEntry2.Quantity := _tempBuf."Decimal 01";
            _ShptEntry2."Quantity (Base)" := _ShptEntry2.Quantity * _ShptEntry2."Qty. per Unit of Measure";
            */
            _ShptEntry2."Quantity (Base)" := _tempBuf."Decimal 01";
            if _ShptEntry2."Qty. per Unit of Measure" <> 0 then
                _ShptEntry2.Quantity := _tempBuf."Decimal 01" / _ShptEntry2."Qty. per Unit of Measure";
        end;
        if _tempBuf."Text 01" <> '' then
            _ShptEntry2."Track Trace Number" := CopyStr(_tempBuf."Text 01",1,MaxStrLen(_ShptEntry2."Track Trace Number"));
        if _tempBuf."Text 02" <> '' then
            _ShptEntry2."Shipment ID" := CopyStr(_tempBuf."Text 02",1,MaxStrLen(_ShptEntry2."Shipment ID"));
        _ShptEntry2."Created by" := CopyStr(UserId(),1,MaxStrLen(_ShptEntry2."Created by"));
        _ShptEntry2."Created at Date" := Today();
        _ShptEntry2."Created at DateTime" := CreateDateTime(Today(),_time);
        _ShptEntry2."Created at Time" := _time;
        _ShptEntry2.Analyze := false;
        _ShptEntry2.Analyzed := 0;
        _ShptEntry2."Analyzed at DateTime" := 0DT;
        _ShptEntry2."Analyzed Duration" := 0;
        _ShptEntry2."Analyzed Error Text" := '';
        _ShptEntry2."Analyzed Data Entry No." := 0;
        _ShptEntry2."Analyzed No. of Attempts" := 0;
        _ShptEntry2."Send to WMS" := false;
        _ShptEntry2."Sent to WMS" := 0;
        _ShptEntry2."Sent to WMS at DateTime" := 0DT;
        _ShptEntry2."Sent to WMS Data Entry No." := 0;
        _ShptEntry2."Sent to WMS Duration" := 0;
        _ShptEntry2."Sent to WMS Error Text" := '';
        _ShptEntry2."Sent to WMS No. of Attempts" := 0;
        _ShptEntry2.Process := true;
        _ShptEntry2."Import Entry No." := _tempBuf."BigInteger 02";
        _ShptEntry2.Insert();
    end;

    procedure EnqueueManualEntry(): BigInteger
    var
        _KorberShptEntry: Record "ARC Korber Shpt. Entry";
        _PurchaseHeader: Record "Purchase Header";
        _SalesHeader: Record "Sales Header";
        _TransferHeader: Record "Transfer Header";
        _GenConfDialog: page "General Confirmation Dialog";
        _DocNo: Code[20];
        _Text000Qst: Label 'Are you absolutely SURE you want to manually enqueue a document?';
        _Text001Msg: Label 'KorberShptMgt, EnqueueManualEntry(): %1';
    begin
        if not GuiAllowed() then
            exit;
        if not Confirm(_Text000Qst,false) then
            exit;
        _GenConfDialog.SetWindowTitle('Manual Enqueue');
        _GenConfDialog.SetInstructionalText('Enter the document no. to enqueue manually');
        _GenConfDialog.SetFieldCaptionValue('Document No.');
        _GenConfDialog.SetCodeVisible();
        if (not (_GenConfDialog.RunModal() in ["Action"::LookupOK,"Action"::OK,"Action"::Yes])) then
            exit;
        _DocNo := CopyStr(_GenConfDialog.GetCodeValue(),1,MaxStrLen(_DocNo));
        if _DocNo = '' then
            exit;
        _KorberShptEntry.Init();
        _KorberShptEntry."Entry No." := 0;
        case true of
            _SalesHeader.Get(_SalesHeader."Document Type"::Order,_DocNo): _KorberShptEntry."Document Area" := _KorberShptEntry."Document Area"::Sales;
            _PurchaseHeader.Get(_PurchaseHeader."Document Type"::Order,_DocNo): _KorberShptEntry."Document Area" := _KorberShptEntry."Document Area"::Purchases;
            _TransferHeader.Get(_DocNo): _KorberShptEntry."Document Area" := _KorberShptEntry."Document Area"::Transfers;
        end;
        _KorberShptEntry."Document No." := CopyStr(_DocNo,1,MaxStrLen(_KorberShptEntry."Document No."));
        _KorberShptEntry.Analyze := true;
        _KorberShptEntry.Insert(true);
        WriteLog(KorberSetup."Log Level"::Verbose,_KorberShptEntry."Entry No.",0,StrSubstNo(_Text001Msg,_DocNo),'');
        Message('Done');
        exit(_KorberShptEntry."Entry No.");
    end;

    procedure GetDiagText(var _diagText: BigText)
    begin
        _diagText := DiagText;
    end;

    local procedure Initialize()
    var
        _CR: Char;
        _NL: Char;
    begin
        if Initialized then
            exit;
        _CR := 13;
        _NL := 10;
        CRNL := Format(_CR) + Format(_NL);
        KorberSetup.Get();
        Initialized := true;
    end;

    local procedure IsAlreadySent(_KorberShptEntry: Record "ARC Korber Shpt. Entry"; _LineNo: Integer; _ItemNo: Code[20]; _Qty: Decimal): Boolean
    var
        _KorberShptEntry2: Record "ARC Korber Shpt. Entry";
    begin
        _KorberShptEntry2.SetCurrentKey("Document Area","Document Type","Document No.","Document Line No.");
        _KorberShptEntry2.SetRange("Document Area",_KorberShptEntry."Document Area");
        _KorberShptEntry2.SetRange("Document Type",_KorberShptEntry."Document Type");
        _KorberShptEntry2.SetRange("Document No.",_KorberShptEntry."Document No.");
        _KorberShptEntry2.SetRange("Document Line No.",_LineNo);
        _KorberShptEntry2.SetRange("Item No.",_ItemNo);
        _KorberShptEntry2.SetRange(Quantity,_Qty);
        _KorberShptEntry2.SetRange("Unit of Measure Code",_KorberShptEntry."Unit of Measure Code");
        _KorberShptEntry2.SetRange("Sent to WMS",1);
        exit(not _KorberShptEntry2.IsEmpty());
    end;

    procedure OnAfterReleasePurchDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; LinesWereModified: Boolean)
    var
        _KorberShptEntry: Record "ARC Korber Shpt. Entry";
        _Text000Lbl: Label 'Method OnAfterReleasePurchDoc(): analyze %1';
    begin
        Initialize();
        if not KorberSetup."Send Shipments" then
            exit;
        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::"Return Order" then
            exit;
        _KorberShptEntry.SetCurrentKey("Document Area","Document Type","Document No.");
        _KorberShptEntry.SetRange("Document Area",_KorberShptEntry."Document Area"::Purchases);
        _KorberShptEntry.SetRange("Document Type",PurchaseHeader."Document Type");
        _KorberShptEntry.SetRange("Document No.",CopyStr(PurchaseHeader."No.",1,MaxStrLen(_KorberShptEntry."Document No.")));
        _KorberShptEntry.SetRange(Analyze,true);
        _KorberShptEntry.SetRange(Analyzed,0);
        if _KorberShptEntry.IsEmpty() then begin
            _KorberShptEntry."Entry No." := 0;
            _KorberShptEntry."Document Area" := _KorberShptEntry."Document Area"::Purchases;
            _KorberShptEntry."Document Type" := PurchaseHeader."Document Type";
            _KorberShptEntry."Document No." := CopyStr(PurchaseHeader."No.",1,MaxStrLen(_KorberShptEntry."Document No."));
            _KorberShptEntry.Analyze := true;
            _KorberShptEntry."Sell-to/Buy-from Entity No." := CopyStr(PurchaseHeader."Buy-from Vendor No.",1,MaxStrLen(_KorberShptEntry."Sell-to/Buy-from Entity No."));
            _KorberShptEntry.Insert(false);
        end;
    end;

    procedure OnAfterReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; LinesWereModified: Boolean)
    var
        _KorberShptEntry: Record "ARC Korber Shpt. Entry";
        _Text000Lbl: Label 'Method OnAfterReleaseSalesDoc(): analyze %1';
    begin
        Initialize();
        if not KorberSetup."Send Shipments" then
            exit;
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;
        _KorberShptEntry.SetCurrentKey("Document Area","Document Type","Document No.");
        _KorberShptEntry.SetRange("Document Area",_KorberShptEntry."Document Area"::Sales);
        _KorberShptEntry.SetRange("Document Type",SalesHeader."Document Type");
        _KorberShptEntry.SetRange("Document No.",SalesHeader."No.");
        _KorberShptEntry.SetRange(Analyze,true);
        _KorberShptEntry.SetRange(Analyzed,0);
        if _KorberShptEntry.IsEmpty() then begin
            _KorberShptEntry."Entry No." := 0;
            _KorberShptEntry."Document Area" := _KorberShptEntry."Document Area"::Sales;
            _KorberShptEntry."Document Type" := SalesHeader."Document Type";
            _KorberShptEntry."Document No." := CopyStr(SalesHeader."No.",1,MaxStrLen(_KorberShptEntry."Document No."));
            _KorberShptEntry.Analyze := true;
            _KorberShptEntry."Sell-to/Buy-from Entity No." := CopyStr(SalesHeader."Sell-to Customer No.",1,MaxStrLen(_KorberShptEntry."Sell-to/Buy-from Entity No."));
            _KorberShptEntry.Insert(false);
        end;
    end;

    procedure OnAfterReleaseSalesDocNo(_SalesOrderNo: Code[20])
    var
        _SalesHeader: Record "Sales Header";
    begin
        if not _SalesHeader.Get(_SalesHeader."Document Type"::Order,_SalesOrderNo) then
            exit;
        OnAfterReleaseSalesDoc(_SalesHeader,false,false);
    end;

    procedure OnAfterReleaseTransferDoc(var TransferHeader: Record "Transfer Header")
    var
        _KorberShptEntry: Record "ARC Korber Shpt. Entry";
        _Text000Lbl: Label 'Method OnAfterReleaseTransferDoc(): analyze %1';
    begin
        Initialize();
        if not KorberSetup."Send Shipments" then
            exit;
        _KorberShptEntry.SetCurrentKey("Document Area","Document Type","Document No.");
        _KorberShptEntry.SetRange("Document Area",_KorberShptEntry."Document Area"::Transfers);
        _KorberShptEntry.SetRange("Document Type",_KorberShptEntry."Document Type"::Order);
        _KorberShptEntry.SetRange("Document No.",CopyStr(TransferHeader."No.",1,MaxStrLen(_KorberShptEntry."Document No.")));
        _KorberShptEntry.SetRange(Analyze,true);
        _KorberShptEntry.SetRange(Analyzed,0);
        if _KorberShptEntry.IsEmpty() then begin
            _KorberShptEntry."Entry No." := 0;
            _KorberShptEntry."Document Area" := _KorberShptEntry."Document Area"::Transfers;
            _KorberShptEntry."Document Type" := _KorberShptEntry."Document Type"::Order;
            _KorberShptEntry."Document No." := CopyStr(TransferHeader."No.",1,MaxStrLen(_KorberShptEntry."Document No."));
            _KorberShptEntry.Analyze := true;
            _KorberShptEntry."Sell-to/Buy-from Entity No." := CopyStr(TransferHeader."Transfer-from Code",1,MaxStrLen(_KorberShptEntry."Sell-to/Buy-from Entity No."));
            _KorberShptEntry.Insert(false);
        end;
    end;

    procedure OnBeforeInsertShptEntry(var Rec: Record "ARC Korber Shpt. Entry"; RunTrigger: Boolean)
    var
        _time: Time;
    begin
        _time := Time();
        Rec."Created by" := CopyStr(UserId(),1,MaxStrLen(Rec."Created by"));
        Rec."Created at Date" := Today();
        Rec."Created at DateTime" := CreateDateTime(Today(),_time);
        Rec."Created at Time" := _time;
    end;

    local procedure ProcessEntries()
    var
        _KorberShptEntry: Record "ARC Korber Shpt. Entry";
        _KorberShptEntry2: Record "ARC Korber Shpt. Entry";
        _DataMgt: Codeunit "ARC DataMgt";
        _KorberShptMgt: Codeunit "ARC KorberShptMgt";
        _currEntryNo: BigInteger;
        _ImportEntryNo: BigInteger;
        _result: Boolean;
        _entriesProcessed: Integer;
        _NoOfAttempts: Integer;
        _docNo: Text;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Msg: Label 'KorberShptMgt, document groups processed: %1';
        _Text001Err: Label 'EntryNo: %1, Err: %2';
        _Text002Lbl: Label 'Diagnostic text captured during process attempt';
    begin
        _KorberShptEntry.SetCurrentKey(Process,Processed,"Import Entry No.");
        _KorberShptEntry.SetRange(Process,true);
        _KorberShptEntry.SetRange(Processed,0);
        if _KorberShptEntry.FindSet(false) then
            repeat
                if _ImportEntryNo <> _KorberShptEntry."Import Entry No." then begin
                    _timeBegin := Time();
                    _currEntryNo := _KorberShptEntry."Entry No.";
                    _ImportEntryNo := _KorberShptEntry."Import Entry No.";
                    Clear(_KorberShptMgt);
                    _KorberShptMgt.SetEntryNoToProcess(_KorberShptEntry."Entry No.");
                    Commit();
                    _result := _KorberShptMgt.Run();
                    if not _result then begin
                        Clear(_KorberShptEntry2);
                        _KorberShptEntry2.Reset();
                        _KorberShptEntry2.SetCurrentKey(Process,Processed,"Import Entry No.");
                        _KorberShptEntry2.SetRange(Process,true);
                        _KorberShptEntry2.SetRange(Processed,0);
                        _KorberShptEntry2.SetRange("Import Entry No.",_ImportEntryNo);
                        if _KorberShptEntry2.FindSet(true) then begin
                            _KorberShptMgt.GetDiagText(DiagText);
                            _timeEnd := Time();
                            _KorberShptEntry2.ModifyAll("Processed Data Entry No.",_DataMgt.NewDataEntry(DiagLabel,_Text002Lbl,DiagText));
                            _KorberShptEntry2.ModifyAll("Processed at DateTime",CreateDateTime(Today(),_timeEnd));
                            _KorberShptEntry2.ModifyAll("Processed No. of Attempts",_KorberShptEntry."Processed No. of Attempts" + 1);
                            _KorberShptEntry2.ModifyAll("Processed Error Text",CopyStr(StrSubstNo(_Text001Err,_currEntryNo,GetLastErrorText()),1,250));
                            _KorberShptEntry2.ModifyAll("Processed Duration",_timeEnd - _timeBegin);
                            if _KorberShptEntry."Processed No. of Attempts" + 1 > KorberSetup."Maximum No. of Attempts" then
                                _KorberShptEntry2.ModifyAll(Processed,-1);
                            _KorberShptEntry2.Reset();
                        end;
                    end;
                    _entriesProcessed += 1;
                end;
            until (_KorberShptEntry.Next() = 0) or (_entriesProcessed >= KorberSetup."Process Queue No. Entries");
        if _entriesProcessed > 0 then
            WriteLog(KorberSetup."Log Level"::Verbose,0,0,StrSubstNo(_Text000Msg,_entriesProcessed),'');
    end;

    local procedure ProcessEntry()
    var
        _KorberShptEntry: Record "ARC Korber Shpt. Entry";
        _KorberShptEntry2: Record "ARC Korber Shpt. Entry";
        _DataMgt: Codeunit "ARC DataMgt";
        _NoOfAttempts: Integer;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Lbl: Label 'Diagnostic text captured during process attempt';
    begin
        _timeBegin := Time();
        _KorberShptEntry.Get(EntryNoToProcess);
        _KorberShptEntry.TestField("Import Entry No.");
        _KorberShptEntry.SetCurrentKey(Process,Processed,"Import Entry No.");
        _KorberShptEntry.SetRange(Process,true);
        _KorberShptEntry.SetRange(Processed,0);
        _KorberShptEntry.SetRange("Import Entry No.",_KorberShptEntry."Import Entry No.");
        _KorberShptEntry.FindSet(false);
        _NoOfAttempts := _KorberShptEntry."Processed No. of Attempts" + 1;
        case _KorberShptEntry."Document Area" of
            _KorberShptEntry."Document Area"::Purchases: ProcessEntryPurchases(_KorberShptEntry);
            _KorberShptEntry."Document Area"::Sales: ProcessEntrySales(_KorberShptEntry);
            _KorberShptEntry."Document Area"::Transfers: ProcessEntryTransfers(_KorberShptEntry);
        end;
        _KorberShptEntry2.SetCurrentKey(Process,Processed,"Import Entry No.");
        _KorberShptEntry2.SetRange(Process,true);
        _KorberShptEntry2.SetRange(Processed,0);
        _KorberShptEntry2.SetRange("Import Entry No.",_KorberShptEntry."Import Entry No.");
        _KorberShptEntry2.FindSet(true);
        _timeEnd := Time();
        _KorberShptEntry2.ModifyAll("Processed No. of Attempts",_NoOfAttempts);
        _KorberShptEntry2.ModifyAll("Processed at DateTime",CreateDateTime(Today(),_timeEnd));
        _KorberShptEntry2.ModifyAll("Processed Duration",_timeEnd - _timeBegin);
        _KorberShptEntry2.ModifyAll("Processed Data Entry No.",_DataMgt.NewDataEntry(DiagLabel,_Text000Lbl,DiagText));
        _KorberShptEntry2.ModifyAll(Processed,1);
    end;

    local procedure ProcessEntryPurchases(var _KorberShptEntry: Record "ARC Korber Shpt. Entry")
    var
        _ItemUom: Record "Item Unit of Measure";
        _PurchaseHeader: Record "Purchase Header";
        _PurchaseLine: Record "Purchase Line";
        _tempBuf: Record "ARC Buffer" temporary;
        _PurchPost: codeunit "Purch.-Post";
        _ReleasePurchaseDoc: Codeunit "Release Purchase Document";
        _entryNo: BigInteger;
        _Text000Err: Label 'Qty. per Unit of Measure must NOT be zero';
        _Text001Lbl: Label 'Korber Shpt Entry Filters: %1';
        _Text002Lbl: Label 'DocType %1, DocNo %2, LineNo %3, ItemNo %4, QtyToShip %5';
        _Text003Lbl: Label 'Method ProcessEntryPurchases(): %1';
        _Text004Lbl: Label 'Purchase Line Filters(): %1';
    begin
        // FIRST, build a temporary table to derive a TOTAL QTY SHIPPED per item, since the same item could appear in 
        //   multiple cartons - ref wkshop Thu 27 Oct 2022 - fr COD50102 "ARC KorberMgt", method ProcessEntryShptConfirmation:
        Clear(_tempBuf);
        _tempBuf.DeleteAll();
        WriteDiagText(StrSubstNo(_Text003Lbl,'begin'));
        WriteDiagText(StrSubstNo(_Text003Lbl,StrSubstNo(_Text001Lbl,_KorberShptEntry.GetFilters())));
        if _KorberShptEntry.FindSet(false) then
            repeat
                _tempBuf.SetRange("Integer 01",_KorberShptEntry."Document Type");
                _tempBuf.SetRange("Integer 02",_KorberShptEntry."Document Line No.");
                _tempBuf.SetRange("Code 01",_KorberShptEntry."Document No.");
                _tempBuf.SetRange("Code 02",_KorberShptEntry."Item No.");
                if not _tempBuf.FindFirst() then begin
                    _entryNo += 1;
                    _tempBuf.Init();
                    _tempBuf."Entry No." := _entryNo;
                    _tempBuf."Integer 01" := _KorberShptEntry."Document Type";
                    _tempBuf."Integer 02" := _KorberShptEntry."Document Line No.";
                    _tempBuf."Code 01" := CopyStr(_KorberShptEntry."Document No.",1,MaxStrLen(_tempBuf."Code 01"));
                    _tempBuf."Code 02" := CopyStr(_KorberShptEntry."Item No.",1,MaxStrLen(_tempBuf."Code 02"));
                    _tempBuf.Insert();
                end;
                _tempBuf."Decimal 01" := _tempBuf."Decimal 01" + _KorberShptEntry."Quantity (Base)";
                _tempBuf.Modify();
            until _KorberShptEntry.Next() = 0;
        // release filters
        _tempBuf.SetRange("Integer 01");  // Document Type
        _tempBuf.SetRange("Integer 02");  // Document Line No.
        _tempBuf.SetRange("Code 01");     // Document No.
        _tempBuf.SetRange("Code 02");     // Item No.
        // SECOND, retrieve (with lock) and modify the purchase header
        WriteDiagText(StrSubstNo(_Text003Lbl,'reopen, posting date, ship'));
        _PurchaseHeader.SetHideValidationDialog(true);
        _PurchaseHeader.LockTable();
        _PurchaseHeader.Get(_KorberShptEntry."Document Type",_KorberShptEntry."Document No.");
        _ReleasePurchaseDoc.Reopen(_PurchaseHeader);
        _PurchaseHeader.Validate("Posting Date",Today());
        _PurchaseHeader.Ship := true;
        _PurchaseHeader.Invoice := KorberSetup."Post Invoice for Outb. Shpts.";
        _PurchaseHeader.Modify(true);
        _PurchaseHeader.Reset();
        // THIRD, prepare for partial shpts; initialize return qty. to ship and qty. to invoice to zero for all lines
        _PurchaseLine.SetRange("Document Type",_KorberShptEntry."Document Type");
        _PurchaseLine.SetRange("Document No.",_KorberShptEntry."Document No.");
        _PurchaseLine.SetRange(Type,_PurchaseLine.Type::Item);
        _PurchaseLine.SetFilter("Outstanding Quantity",'<>0');
        WriteDiagText(StrSubstNo(_Text003Lbl,StrSubstNo(_Text004Lbl,_PurchaseLine.GetFilters())));
        if _PurchaseLine.FindSet(true) then
            repeat
                _PurchaseLine.Validate("Return Qty. to Ship",0);
                _PurchaseLine.Validate("Qty. to Invoice",0);
                _PurchaseLine.Modify(true);
            until _PurchaseLine.Next() = 0;
        // FOURTH, set return qtys to ship [and qty to invoice]
        _tempBuf.FindSet(false);
        repeat
            WriteDiagText(StrSubstNo(_Text003Lbl,StrSubstNo(_Text002Lbl,_tempBuf."Integer 01",_tempBuf."Code 01",_tempBuf."Integer 02",_tempBuf."Code 02",_tempBuf."Decimal 01")));
            Clear(_PurchaseLine);
            _PurchaseLine.Reset();
            _PurchaseLine.LockTable();
            _PurchaseLine.Get(_tempBuf."Integer 01",_tempBuf."Code 01",_tempBuf."Integer 02");
            // according to Korber and Rentokil-NA/Target teams, QuantityShipped will always be in the item base unit of measure
            if _PurchaseLine."Qty. per Unit of Measure" = 0 then
                Error(_Text000Err);
            /* qtys per UOM always base according to Erik - scenario tested Mon 24 Oct 2022
            **   concall re [RENT] SOW11 Körber Edge WMS Integration -- Session 1: End to End workshop for UAT/ WMS - Paola Montgomery
            _PurchaseLine.Validate("Return Qty. to Ship",_KorberShptEntry.Quantity / _PurchaseLine."Qty. per Unit of Measure");
            if KorberSetup."Post Invoice for Outb. Shpts." then
                _PurchaseLine.Validate("Qty. to Invoice",_KorberShptEntry.Quantity / _PurchaseLine."Qty. per Unit of Measure");
            */
            _PurchaseLine.Validate("Return Qty. to Ship",_tempBuf."Decimal 01" / _PurchaseLine."Qty. per Unit of Measure");
            // BEGIN - action item fr wkshop Tue 25 Oct 2022 at 9a Eastern - must not invoice Purchase Return Orders
            //if KorberSetup."Post Invoice for Outb. Shpts." then
            //    _PurchaseLine.Validate("Qty. to Invoice",_KorberShptEntry."Quantity (Base)" / _PurchaseLine."Qty. per Unit of Measure");
            _PurchaseLine.Validate("Qty. to Invoice",0);
            // END
            _PurchaseLine.Modify(true);
        until _tempBuf.Next() = 0;
        // release lock
        _PurchaseLine.Reset();
        Clear(_PurchaseLine);
        // FIFTH, release document
        WriteDiagText(StrSubstNo(_Text003Lbl,'release and optionally post'));
        Clear(_PurchaseHeader);
        _PurchaseHeader.SetHideValidationDialog(true);
        _PurchaseHeader.LockTable();
        _PurchaseHeader.Get(_KorberShptEntry."Document Type",_KorberShptEntry."Document No.");
        _ReleasePurchaseDoc.Run(_PurchaseHeader);
        // SIXTH, post document
        if KorberSetup."Post Shipment" then
            _PurchPost.Run(_PurchaseHeader);
        // release lock
        _PurchaseHeader.Reset();
        Clear(_PurchaseHeader);
        WriteDiagText(StrSubstNo(_Text003Lbl,'end'));
    end;

    local procedure ProcessEntrySales(var _KorberShptEntry: Record "ARC Korber Shpt. Entry")
    var
        _SalesHeader: Record "Sales Header";
        _SalesLine: Record "Sales Line";
        _ShipMethod: Record "Shipment Method";
        _ShippingAgent: Record "Shipping Agent";
        _ShippingAgentSvc: Record "Shipping Agent Services";
        _tempBuf: Record "ARC Buffer" temporary;
        _ReleaseSalesDoc: Codeunit "Release Sales Document";
        _SalesPost: Codeunit "Sales-Post";
        _entryNo: BigInteger;
        _ShipMethodCode: Code[10];
        _ShippingAgentCode: Code[10];
        _ShippingAgentSvcCode: Code[10];
        _Text000Err: Label 'Qty. per Unit of Measure must NOT be zero';
        _Text001Lbl: Label 'Korber Shpt Entry Filters: %1';
        _Text002Lbl: Label 'DocType %1, DocNo %2, LineNo %3, ItemNo %4, QtyToShip %5';
        _Text003Lbl: Label 'Method ProcessEntrySales(): %1';
        _Text004Lbl: Label 'Sales Line Filters: %1';
    begin
        WriteDiagText(StrSubstNo(_Text003Lbl,'begin'));
        WriteDiagText(StrSubstNo(_Text003Lbl,StrSubstNo(_Text001Lbl,_KorberShptEntry.GetFilters())));
        // FIRST, build a temporary table to derive a TOTAL QTY SHIPPED per item, since the same item could appear in 
        //   multiple cartons - ref wkshop Thu 27 Oct 2022 - fr COD50102 "ARC KorberMgt", method ProcessEntryShptConfirmation:
        Clear(_tempBuf);
        _tempBuf.DeleteAll();
        if _KorberShptEntry.FindSet(false) then
            repeat
                _tempBuf.SetRange("Integer 01",_KorberShptEntry."Document Type");
                _tempBuf.SetRange("Integer 02",_KorberShptEntry."Document Line No.");
                _tempBuf.SetRange("Code 01",_KorberShptEntry."Document No.");
                _tempBuf.SetRange("Code 02",_KorberShptEntry."Item No.");
                if not _tempBuf.FindFirst() then begin
                    _entryNo += 1;
                    _tempBuf.Init();
                    _tempBuf."Entry No." := _entryNo;
                    _tempBuf."Integer 01" := _KorberShptEntry."Document Type";
                    _tempBuf."Integer 02" := _KorberShptEntry."Document Line No.";
                    _tempBuf."Code 01" := CopyStr(_KorberShptEntry."Document No.",1,MaxStrLen(_tempBuf."Code 01"));
                    _tempBuf."Code 02" := CopyStr(_KorberShptEntry."Item No.",1,MaxStrLen(_tempBuf."Code 02"));
                    _tempBuf.Insert();
                end;
                _tempBuf."Decimal 01" := _tempBuf."Decimal 01" + _KorberShptEntry."Quantity (Base)";
                _tempBuf.Modify();
            until _KorberShptEntry.Next() = 0;
        // release filters
        _tempBuf.SetRange("Integer 01");  // Document Type
        _tempBuf.SetRange("Integer 02");  // Document Line No.
        _tempBuf.SetRange("Code 01");     // Document No.
        _tempBuf.SetRange("Code 02");     // Item No.
        // SECOND, retrieve (with lock) and modify the sales header
        WriteDiagText(StrSubstNo(_Text003Lbl,'reopen, posting date, shptMethod, shipAgent, pkgTrack'));
        _SalesHeader.SetHideValidationDialog(true);
        _SalesHeader.LockTable();
        _SalesHeader.Get(_KorberShptEntry."Document Type",_KorberShptEntry."Document No.");
        // reopen sales order
        _ReleaseSalesDoc.Reopen(_SalesHeader);
        // posting date
        _SalesHeader.Validate("Posting Date",Today());
        // shipment method
        _ShipMethodCode := CopyStr(_KorberShptEntry."Ship Via",1,MaxStrLen(_ShipMethodCode));
        if _ShipMethodCode <> '' then
            if _ShipMethod.Get(_ShipMethodCode) then
                _SalesHeader.Validate("Shipment Method Code",_ShipMethodCode);
        // shipping agent and service
        _ShippingAgentCode := CopyStr(_KorberShptEntry."Shipment Carrier",1,MaxStrLen(_ShippingAgentCode));
        if _ShippingAgentCode = '' then
            WriteDiagText(StrSubstNo(_Text003Lbl,'Shipment Carrier is empty in Korber Shpt Entry'))
        else
            if not _ShippingAgent.Get(_ShippingAgentCode) then 
                WriteDiagText(StrSubstNo(_Text003Lbl,'Failed to retrieve Shipping Agent using Shipment Carrier value in Korber Shpt Entry'))
            else begin
                _SalesHeader.Validate("Shipping Agent Code",_ShippingAgentCode);
                _ShippingAgentSvcCode := CopyStr(_KorberShptEntry."Shipment Service",1,MaxStrLen(_ShippingAgentSvcCode));
                if _ShippingAgentSvcCode = '' then
                    WriteDiagText(StrSubstNo(_Text003Lbl,'Shipment Service field is empty in Korber Shpt Entry'))
                else
                    if not _ShippingAgentSvc.Get(_ShippingAgentCode,_ShippingAgentSvcCode) then
                        WriteDiagText(StrSubstNo(_Text003Lbl,'Failed to retrieve Shipping Agent Service using Shipment Carrier and Shipment Service fields in Korber Shpt Entry'))
                    else
                        _SalesHeader.Validate("Shipping Agent Service Code",_ShippingAgentSvcCode);
            end;
        // other fields on header
        _SalesHeader.Ship := KorberSetup."Post Shipment";
        _SalesHeader.Invoice := KorberSetup."Post Invoice for Outb. Shpts.";
        if _KorberShptEntry."Track Trace Number" = '' then
            WriteDiagText(StrSubstNo(_Text003Lbl,'Failed to add Package Tracking No because Track Trace Number is empty in Korber Shpt Entry'))
        else
            _SalesHeader."Package Tracking No." := CopyStr(_KorberShptEntry."Track Trace Number",1,MaxStrLen(_SalesHeader."Package Tracking No."));
        _SalesHeader.Modify(true);
        //_SalesHeader.Reset();
        // THIRD, prepare for partial shpts; initialize qty. to ship, qty. to invoice to zero for all lines
        WriteDiagText(StrSubstNo(_Text003Lbl,'setting filters to initialize QtyToShip, QtyToInvoice on all lines'));
        _SalesLine.SetRange("Document Type",_KorberShptEntry."Document Type");
        _SalesLine.SetRange("Document No.",_KorberShptEntry."Document No.");
        _SalesLine.SetRange(Type,_SalesLine.Type::Item);
        _SalesLine.SetFilter("Outstanding Qty. (Base)",'<>0');
        WriteDiagText(StrSubstNo(_Text003Lbl,StrSubstNo(_Text004Lbl,_SalesLine.GetFilters())));
        if _SalesLine.FindSet(true) then
            repeat
                _SalesLine.Validate("Qty. to Ship",0);
                _SalesLine.Validate("Qty. to Invoice",0);
                _SalesLine.Modify(true);
            until _SalesLine.Next() = 0;
        // FOURTH, set qtys to ship [and invoice]
        WriteDiagText(StrSubstNo(_Text003Lbl,'set QtysToShip, QtysToInvoice on select lines'));
        _tempBuf.FindSet(false);
        repeat
            WriteDiagText(StrSubstNo(_Text003Lbl,StrSubstNo(_Text002Lbl,_tempBuf."Integer 01",_tempBuf."Code 01",_tempBuf."Integer 02",_tempBuf."Code 02",_tempBuf."Decimal 01")));
            Clear(_SalesLine);
            _SalesLine.Reset();
            _SalesLine.LockTable();
            _SalesLine.Get(_tempBuf."Integer 01",_tempBuf."Code 01",_tempBuf."Integer 02");
            // according to Korber and Rentokil-NA/Target teams, QuantityShipped will always be in the item base unit of measure
            if _SalesLine."Qty. per Unit of Measure" = 0 then
                Error(_Text000Err);
            /* qtys per UOM always base according to Erik - scenario tested Mon 24 Oct 2022
            **   concall re [RENT] SOW11 Körber Edge WMS Integration -- Session 1: End to End workshop for UAT/ WMS - Paola Montgomery
            _SalesLine.Validate("Qty. to Ship",_tempBuf."Decimal 01" / _SalesLine."Qty. per Unit of Measure");
            if KorberSetup."Post Invoice for Outb. Shpts." then
                _SalesLine.Validate("Qty. to Invoice",_tempBuf."Decimal 01" / _SalesLine."Qty. per Unit of Measure");
            */
            _SalesLine.Validate("Qty. to Ship",_tempBuf."Decimal 01" / _SalesLine."Qty. per Unit of Measure");
            if KorberSetup."Post Invoice for Outb. Shpts." then
                _SalesLine.Validate("Qty. to Invoice",_tempBuf."Decimal 01" / _SalesLine."Qty. per Unit of Measure");
            _SalesLine.Modify(true);
        until _tempBuf.Next() = 0;
        // release any lock
        _SalesLine.Reset();
        Clear(_SalesLine);
        // FIFTH, add any applicable shipment charge
        ProcessEntryShptChg(_KorberShptEntry,_SalesHeader);
        // SIXTH, release document
        WriteDiagText(StrSubstNo(_Text003Lbl,'release and optionally ship, invoice'));
        Clear(_SalesHeader);
        _SalesHeader.SetHideValidationDialog(true);
        _SalesHeader.LockTable();
        _SalesHeader.Get(_KorberShptEntry."Document Type",_KorberShptEntry."Document No.");
        _ReleaseSalesDoc.Run(_SalesHeader);
        // SEVENTH, post document
        if KorberSetup."Post Shipment" then
            _SalesPost.Run(_SalesHeader);
        _SalesHeader.Reset();
        Clear(_SalesHeader);
        WriteDiagText(StrSubstNo(_Text003Lbl,'end'));
    end;

    local procedure ProcessEntryShptChg(_KorberShptEntry: Record "ARC Korber Shpt. Entry"; var _SalesHeader: Record "Sales Header")
    var
        _CustomerBillTo: Record Customer;
        _CustomerSellTo: Record Customer;
        _Field: Record Field;
        _GenBusPostGrp: Record "Gen. Business Posting Group";
        _KorberImportEntry: Record "ARC Korber Import Entry";
        _OrderTranslationEntry: Record "ARC Order Translation Entry";
        _RNASetup: Record "ARC RNA Setup";
        _SalesHeaderArchive: Record "Sales Header Archive";
        _SalesHeaderTotal: Decimal;
        _SalesLine: Record "Sales Line";
        _freeFreight: Boolean;
        _dim1code: Code[20];
        _dim2code: Code[20];
        _fieldRef: FieldRef;
        _dimSetId: Integer;
        _lineNo: Integer;
        _recRef: RecordRef;
        _Text000Lbl: Label 'Method ProcessEntryShptChg(): %1';
    begin
        WriteDiagText(StrSubstNo(_Text000Lbl,'begin'));
        // evaluate whether freight charges can be bypassed
        if not KorberSetup."Freight Charges Active" then begin
            WriteDiagText(StrSubstNo(_Text000Lbl,'Freight Charges not active in Korber Setup (exit)'));
            exit;
        end;
        if not _GenBusPostGrp.Get(_SalesHeader."Gen. Bus. Posting Group") then begin
            WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Failed to find GenBusPostGroup %1 (exit)',_SalesHeader."Gen. Bus. Posting Group")));
            exit;
        end;
        if _GenBusPostGrp."ARC Korber Freight" = _GenBusPostGrp."ARC Korber Freight"::"No change" then begin
            WriteDiagText(StrSubstNo(_Text000Lbl,'Korber Freight is "No change" in GenBusPostGroup (exit)'));
            exit;
        end;
        if _GenBusPostGrp."ARC Korber Frgt Resource No." = '' then begin
            WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Korber Freight Resource No. is empty in GenBusPostGroup %1 (exit)',_SalesHeader."Gen. Bus. Posting Group")));
            exit;
        end;
        if not _KorberImportEntry.Get(_KorberShptEntry."Import Entry No.") then begin
            WriteDiagText(StrSubstNo(_Text000Lbl,'Failed to retrieve Korber Import Entry (exit)'));
            exit;
        end;
        if _KorberImportEntry."Total Shipment Charge" = 0 then begin
            WriteDiagText(StrSubstNo(_Text000Lbl,'Total Shipment Charge is zero in Korber Import Entry (exit)'));
            exit;
        end;
        if not _CustomerSellTo.Get(_SalesHeader."Sell-to Customer No.") then begin
            WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Failed to retrieve Sell-to Customer %1 (exit)',_SalesHeader."Sell-to Customer No.")));
            exit;
        end;
        _Field.SetRange(TableNo,Database::Customer);
        _Field.SetRange("No.",14000702);  // Free Freight, an E-Ship field
        if not _Field.IsEmpty() then begin
            _recRef.GetTable(_CustomerSellTo);
            _fieldRef := _recRef.Field(14000702);
            WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Free Freight %1, Sell-to Customer %2',Format(_fieldRef),_CustomerSellTo."No.")));
            if Evaluate(_freeFreight,Format(_fieldRef)) then
                if _freeFreight then
                    WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Sell-to Customer %1 has free freight (customer card) (do not exit per Cody Mon 18 Sep 2023 at 1245pm)',_SalesHeader."Sell-to Customer No.")));
            _recRef.Close();
            if not _freeFreight then
                if _SalesHeader."Bill-to Customer No." <> '' then
                    if _SalesHeader."Bill-to Customer No." <> _SalesHeader."Sell-to Customer No." then begin
                        if not _CustomerBillTo.Get(_SalesHeader."Bill-to Customer No.") then begin
                            WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Failed to retrieve Bill-to Customer %1 (exit)',_SalesHeader."Bill-to Customer No.")));
                            exit;
                        end;
                        Clear(_recRef);
                        Clear(_fieldRef);
                        _recRef.GetTable(_CustomerBillTo);
                        _fieldRef := _recRef.Field(14000702);
                        WriteDiagText(StrSubstNo('Free Freight %1, Bill-to Customer %2',Format(_fieldRef),_CustomerBillTo."No."));
                        if Evaluate(_freeFreight,Format(_fieldRef)) then
                            if _freeFreight then
                                WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Bill-to Customer %1 has free freight (customer card) (do not exit per Cody Mon 18 Sep 2023 at 1245pm)',_SalesHeader."Bill-to Customer No.")));
                        _recRef.Close();
                    end;
        end;
        // get last line number on document
        _SalesLine.SetRange("Document Type",_SalesHeader."Document Type");
        _SalesLine.SetRange("Document No.",_SalesHeader."No.");
        if _SalesLine.FindLast() then
            _lineNo := _SalesLine."Line No.";
        _lineNo := Round(_lineNo + 10000,100,'>');
        // get DimSetId from first line
        if _SalesLine.FindFirst() then begin
            _dimSetId := _SalesLine."Dimension Set ID";
            _dim1code := CopyStr(_SalesLine."Shortcut Dimension 1 Code",1,MaxStrLen(_dim1code));
            _dim2code := CopyStr(_SalesLine."Shortcut Dimension 2 Code",1,MaxStrLen(_dim2code));
            WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Dimension Set ID %1, dim1code %2, dim2code %3 grabbed from first sales line',_dimSetId,_dim1code,_dim2code)));
        end;
        // delete existing freight charges
        _SalesLine.SetRange(Type,_SalesLine.Type::Resource);
        _SalesLine.SetRange("No.",_GenBusPostGrp."ARC Korber Frgt Resource No.");
        if not _SalesLine.IsEmpty() then
            _SalesLine.DeleteAll();
        _SalesLine.SetRange(Type);
        _SalesLine.SetRange("No.");
        // insert new sales line for freight charge
        _SalesLine.Init();
        _SalesLine.SetHideValidationDialog(true);
        _SalesLine."Document Type" := _SalesHeader."Document Type";
        _SalesLine."Document No." := CopyStr(_SalesHeader."No.",1,MaxStrLen(_SalesLine."Document No."));
        _SalesLine."Line No." := _lineNo;
        _SalesLine.Insert(true);
        _SalesLine.Validate(Type,_SalesLine.Type::Resource);
        _SalesLine.Validate("No.",_GenBusPostGrp."ARC Korber Frgt Resource No.");
        _SalesLine.Validate(Quantity,1);
        _SalesLine.Validate("Unit Price",_KorberImportEntry."Total Shipment Charge");
        if (not (_dimSetId in [0,_SalesLine."Dimension Set ID"])) then begin
            WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Original Dimension Set ID: %1',_SalesLine."Dimension Set ID")));
            WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Original Dimension Code 1: %1',_SalesLine."Shortcut Dimension 1 Code")));
            WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Original Dimension Code 2: %1',_SalesLine."Shortcut Dimension 2 Code")));
            _SalesLine."Dimension Set ID" := _dimSetId;
            _SalesLine."Shortcut Dimension 1 Code" := CopyStr(_dim1code,1,MaxStrLen(_SalesLine."Shortcut Dimension 1 Code"));
            _SalesLine."Shortcut Dimension 2 Code" := CopyStr(_dim2code,1,MaxStrLen(_SalesLine."Shortcut Dimension 2 Code"));
            WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Override Dimension Set ID: %1',_SalesLine."Dimension Set ID")));
            WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Override Dimension Code 1: %1',_SalesLine."Shortcut Dimension 1 Code")));
            WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Override Dimension Code 2: %1',_SalesLine."Shortcut Dimension 2 Code")));
        end;
        _SalesLine.Modify();
        WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Added freight amount %1, GenBusPostGrp %2',_KorberImportEntry."Total Shipment Charge",_SalesHeader."Gen. Bus. Posting Group")));
        if _GenBusPostGrp."ARC Korber Freight" <> _GenBusPostGrp."ARC Korber Freight"::"Free Freight" then begin
            WriteDiagText(StrSubstNo(_Text000Lbl,'Korber Freight is not "Free Freight" (exit)'));
            exit;
        end;
        _SalesHeader.CalcFields(Amount);
        WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('SalesHeader Amount: %1',_SalesHeader.Amount)));
        WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('GenBusPostGrp %1, Max Threshold %2',
            _SalesHeader."Gen. Bus. Posting Group",_GenBusPostGrp."ARC Korber Frgt Max Threshold")));
        // email fr Jennifer Gunter dated Wed 30 Aug 2023 at 551pm Eastern
        //   ****** Yes we are referring to looking at the archive orders to see if they get free freight or not. if we need call let me know and I will get it booked
        // email fr Cody Weeks dated Thu 31 Aug 2023 at 805am Eastern
        //   This is a newer request yes. To me either of your proposals sounds like it could work.
        _SalesHeaderTotal := _SalesHeader.Amount;
        if not _freeFreight then
            if _RNASetup.Get() then begin
                WriteDiagText(StrSubstNo(_Text000Lbl,'found RNA Setup'));
                if _RNASetup."Order Management Active" then begin
                    WriteDiagText(StrSubstNo(_Text000Lbl,'Order Management Active is Yes in RNA Setup'));
                    _OrderTranslationEntry.SetCurrentKey("Updated Document No.");
                    _OrderTranslationEntry.SetRange("Updated Document No.",_SalesHeader."No.");
                    _OrderTranslationEntry.SetFilter("Document No.",'<>%1','');
                    WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Order Translation Entry Filters: %1',_OrderTranslationEntry.GetFilters())));
                    if not _OrderTranslationEntry.FindLast() then
                        WriteDiagText(StrSubstNo(_Text000Lbl,'OrderTranslationEntry.FindLast() failed'))
                    else begin
                        WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Found original Document No.: %1, searching Sales Header Archive',_OrderTranslationEntry."Document No.")));
                        _SalesHeaderArchive.SetRange("Document Type",_SalesHeader."Document Type");
                        _SalesHeaderArchive.SetRange("No.",_OrderTranslationEntry."Document No.");
                        WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Sales Header Archive Filters: %1',_SalesHeaderArchive.GetFilters())));
                        if not _SalesHeaderArchive.FindLast() then
                            WriteDiagText(StrSubstNo(_Text000Lbl,'SalesHeaderArchive.FindLast() failed'))
                        else begin
                                _SalesHeaderArchive.CalcFields(Amount);
                                WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('found Sales Header Archive %1, %2, %3, %4 with amount %5',
                                    _SalesHeaderArchive."Document Type",_SalesHeaderArchive."No.",_SalesHeaderArchive."Doc. No. Occurrence",_SalesHeaderArchive."Version No.",_SalesHeaderArchive.Amount)));
                                if _SalesHeaderArchive.Amount > _SalesHeaderTotal then begin
                                    _SalesHeaderTotal := _SalesHeaderArchive.Amount;
                                    WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Order total for comparison overridden: %1',_SalesHeaderTotal)));
                                    WriteDiagText(StrSubstNo(_Text000Lbl,'more info: email fr Jennifer Gunter dated Wed 30 Aug 2023 at 551pm Eastern'));
                                    WriteDiagText(StrSubstNo(_Text000Lbl,'more info: email fr Cody Weeks dated Thu 31 Aug 2023 at 805am Eastern'));
                                end;
                        end;
                    end;
                end;
            end;
        if not _freeFreight then
            if _SalesHeaderTotal <= _GenBusPostGrp."ARC Korber Frgt Max Threshold" then begin
                WriteDiagText(StrSubstNo(_Text000Lbl,'No free freight *and* Amount <= Threshold (exit)'));
                exit;
            end;
        // insert new sales line for freight charge reversal
        _lineNo := Round(_lineNo + 10000,100,'>');
        Clear(_SalesLine);
        _SalesLine.Reset();
        _SalesLine.Init();
        _SalesLine.SetHideValidationDialog(true);
        _SalesLine."Document Type" := _SalesHeader."Document Type";
        _SalesLine."Document No." := CopyStr(_SalesHeader."No.",1,MaxStrLen(_SalesLine."Document No."));
        _SalesLine."Line No." := _lineNo;
        _SalesLine.Insert(true);
        _SalesLine.Validate(Type,_SalesLine.Type::Resource);
        _SalesLine.Validate("No.",_GenBusPostGrp."ARC Korber Frgt Resource No.");
        _SalesLine.Validate(Quantity,-1);
        _SalesLine.Validate("Unit Price",_KorberImportEntry."Total Shipment Charge");
        if (not (_dimSetId in [0,_SalesLine."Dimension Set ID"])) then begin
            WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Original Dimension Set ID: %1',_SalesLine."Dimension Set ID")));
            _SalesLine."Dimension Set ID" := _dimSetId;
            WriteDiagText(StrSubstNo(_Text000Lbl,StrSubstNo('Override Dimension Set ID: %1',_SalesLine."Dimension Set ID")));
        end;
        _SalesLine.Modify();
        WriteDiagText(StrSubstNo(_Text000Lbl,'Added free freight line'));
    end;

    local procedure ProcessEntryTransfers(var _KorberShptEntry: Record "ARC Korber Shpt. Entry")
    var
        _TransferHeader: Record "Transfer Header";
        _TransferLine: Record "Transfer Line";
        _tempBuf: Record "ARC Buffer" temporary;
        _TransferPost: Codeunit "TransferOrder-Post Shipment";
        _TransferRelease: Codeunit "Release Transfer Document";
        _entryNo: BigInteger;
        _Text000Err: Label 'Qty. per Unit of Measure must NOT be zero: line %1, item %2';
        _Text001Lbl: Label 'Korber Shpt Entry Filters: %1';
        _Text002Lbl: Label 'DocType %1, DocNo %2, LineNo %3, ItemNo %4, QtyToShip %5';
        _Text003Lbl: Label 'Method ProcessEntryTransfers(): %1';
    begin
        WriteDiagText(StrSubstNo(_Text003Lbl,'begin'));
        WriteDiagText(StrSubstNo(_Text003Lbl,StrSubstNo(_Text001Lbl,_KorberShptEntry.GetFilters())));
        // FIRST, build a temporary table to derive a TOTAL QTY SHIPPED per item, since the same item could appear in 
        //   multiple cartons - ref wkshop Thu 27 Oct 2022 - fr COD50102 "ARC KorberMgt", method ProcessEntryShptConfirmation:
        Clear(_tempBuf);
        _tempBuf.DeleteAll();
        if _KorberShptEntry.FindSet(false) then
            repeat
                _tempBuf.SetRange("Integer 01",_KorberShptEntry."Document Type");
                _tempBuf.SetRange("Integer 02",_KorberShptEntry."Document Line No.");
                _tempBuf.SetRange("Code 01",_KorberShptEntry."Document No.");
                _tempBuf.SetRange("Code 02",_KorberShptEntry."Item No.");
                if not _tempBuf.FindFirst() then begin
                    _entryNo += 1;
                    _tempBuf.Init();
                    _tempBuf."Entry No." := _entryNo;
                    _tempBuf."Integer 01" := _KorberShptEntry."Document Type";
                    _tempBuf."Integer 02" := _KorberShptEntry."Document Line No.";
                    _tempBuf."Code 01" := CopyStr(_KorberShptEntry."Document No.",1,MaxStrLen(_tempBuf."Code 01"));
                    _tempBuf."Code 02" := CopyStr(_KorberShptEntry."Item No.",1,MaxStrLen(_tempBuf."Code 02"));
                    _tempBuf.Insert();
                end;
                _tempBuf."Decimal 01" := _tempBuf."Decimal 01" + _KorberShptEntry."Quantity (Base)";
                _tempBuf.Modify();
            until _KorberShptEntry.Next() = 0;
        // release filters
        _tempBuf.SetRange("Integer 01");  // Document Type
        _tempBuf.SetRange("Integer 02");  // Document Line No.
        _tempBuf.SetRange("Code 01");     // Document No.
        _tempBuf.SetRange("Code 02");     // Item No.
        // SECOND, retrieve (with lock) and modify the transfer header
        WriteDiagText(StrSubstNo(_Text003Lbl,'reopen, posting date'));
        _TransferHeader.SetHideValidationDialog(true);
        _TransferHeader.LockTable();
        _TransferHeader.Get(_KorberShptEntry."Document No.");
        _TransferRelease.Reopen(_TransferHeader);
        _TransferHeader.Validate("Posting Date",Today());
        _TransferHeader.Modify(true);
        _TransferHeader.Reset();
        // THIRD, prepare for partial shpts; initialize qty. to ship to zero for all lines
        WriteDiagText(StrSubstNo(_Text003Lbl,'initialize QtyToShip to zero for all lines'));
        _TransferLine.SetRange("Document No.",_TransferHeader."No.");
        _TransferLine.FindSet(true);
        repeat
            _TransferLine.Validate("Qty. to Ship",0);
            _TransferLine.Modify(true);
        until _TransferLine.Next() = 0;
        // FOURTH, set qtys to ship
        _tempBuf.FindSet(false);
        repeat
            WriteDiagText(StrSubstNo(_Text003Lbl,StrSubstNo(_Text002Lbl,_tempBuf."Integer 01",_tempBuf."Code 01",_tempBuf."Integer 02",_tempBuf."Code 02",_tempBuf."Decimal 01")));
            Clear(_TransferLine);
            _TransferLine.Reset();
            _TransferLine.LockTable();
            _TransferLine.Get(_tempBuf."Code 01",_tempBuf."Integer 02");
            // according to Korber and Rentokil-NA/Target teams, QuantityShipped will always be in the item base unit of measure
            if _TransferLine."Qty. per Unit of Measure" = 0 then
                Error(_Text000Err);
            /* qtys per UOM always base according to Erik - scenario tested Mon 24 Oct 2022
            **   concall re [RENT] SOW11 Körber Edge WMS Integration -- Session 1: End to End workshop for UAT/ WMS - Paola Montgomery
            _TransferLine.Validate("Qty. to Ship",_KorberShptEntry.Quantity / _TransferLine."Qty. per Unit of Measure");
            */
            _TransferLine.Validate("Qty. to Ship",_tempBuf."Decimal 01" / _TransferLine."Qty. per Unit of Measure");
            _TransferLine.Modify(true);
        until _tempBuf.Next() = 0;
        // release any lock
        _TransferLine.Reset();
        Clear(_TransferLine);
        // FIFTH, release
        WriteDiagText(StrSubstNo(_Text003Lbl,'release and optionally post shipment'));
        Clear(_TransferHeader);
        _TransferHeader.Reset();
        _TransferHeader.LockTable();
        _TransferHeader.Get(_KorberShptEntry."Document No.");
        _TransferRelease.Run(_TransferHeader);
        _TransferHeader.Modify(true);
        // SIXTH, post
        if KorberSetup."Post Shipment" then
            _TransferPost.Run(_TransferHeader);
        _TransferHeader.Reset();
        Clear(_TransferHeader);
        WriteDiagText(StrSubstNo(_Text003Lbl,'end'));
    end;

    procedure ResetEntry(var _KorberShptEntry: Record "ARC Korber Shpt. Entry")
    var
        _KorberShptEntry2: Record "ARC Korber Shpt. Entry";
        _KorberShptEntry3: Record "ARC Korber Shpt. Entry";
        _choice: Integer;
        _count: Integer;
        _SetOfFields: Text;
        _Text001Msg: Label '*** RESET *** Korber Shipment Entry No. %1, Item %2, set of fields: %3';
        _Text002Qst: Label 'Analyzed,Sent to WMS,Processed,Mark all sent as failed for document';
        _Text003Qst: Label 'Record count: %1; choose which set of fields to reset';
        _Text004Lbl: Label 'Manually marked as sent failed by user %1';
    begin
        Initialize();
        _count := _KorberShptEntry.Count();
        _choice := StrMenu(_Text002Qst,0,StrSubstNo(_Text003Qst,_count));
        if _choice = 0 then
            exit;
        if _choice = 4 then begin
            _KorberShptEntry3 := _KorberShptEntry;
            Clear(_KorberShptEntry);
            _KorberShptEntry.Reset();
            _KorberShptEntry.SetCurrentKey("Send to WMS","Sent to WMS","Document Area","Document Type","Document No.");
            _KorberShptEntry.SetRange("Send to WMS",true);
            _KorberShptEntry.SetRange("Sent to WMS",1);
            _KorberShptEntry.SetRange("Document Area",_KorberShptEntry3."Document Area");
            _KorberShptEntry.SetRange("Document Type",_KorberShptEntry3."Document Type");
            _KorberShptEntry.SetRange("Document No.",_KorberShptEntry3."Document No.");
        end;
        if _KorberShptEntry.FindSet(false) then
            repeat
                Clear(_KorberShptEntry2);
                _KorberShptEntry2.Reset();
                _KorberShptEntry2.LockTable();
                _KorberShptEntry2.Get(_KorberShptEntry."Entry No.");
                case _choice of
                    1:
                        begin
                            _KorberShptEntry2.Analyzed := 0;
                            _KorberShptEntry2."Analyzed at DateTime" := 0DT;
                            _KorberShptEntry2."Analyzed Duration" := 0;
                            _KorberShptEntry2."Analyzed Error Text" := '';
                            _KorberShptEntry2."Analyzed No. of Attempts" := 0;
                            _KorberShptEntry2."Analyzed Data Entry No." := 0;
                            _SetOfFields := CopyStr('Analyzed',1,MaxStrLen(_SetOfFields));
                        end;
                    2:
                        begin
                            _KorberShptEntry2."Sent to WMS" := 0;
                            _KorberShptEntry2."Sent to WMS at DateTime" := 0DT;
                            _KorberShptEntry2."Sent to WMS Data Entry No." := 0;
                            _KorberShptEntry2."Sent to WMS Duration" := 0;
                            _KorberShptEntry2."Sent to WMS Error Text" := '';
                            _KorberShptEntry2."Sent to WMS No. of Attempts" := 0;
                            _SetOfFields := CopyStr('Sent to WMS',1,MaxStrLen(_SetOfFields));
                        end;
                    3:
                        begin
                            _KorberShptEntry2.Processed := 0;
                            _KorberShptEntry2."Processed at DateTime" := 0DT;
                            _KorberShptEntry2."Processed Data Entry No." := 0;
                            _KorberShptEntry2."Processed Duration" := 0;
                            _KorberShptEntry2."Processed Error Text" := '';
                            _KorberShptEntry2."Processed No. of Attempts" := 0;
                            _SetOfFields := CopyStr('Processed',1,MaxStrLen(_SetOfFields));
                        end;
                    4:
                        begin
                            _KorberShptEntry2."Sent to WMS" := -1;
                            _KorberShptEntry2."Sent to WMS Error Text" := CopyStr(StrSubstNo(_Text004Lbl,UserId()),1,MaxStrLen(_KorberShptEntry2."Sent to WMS Error Text"));
                            _SetOfFields := CopyStr('Sent to WMS',1,MaxStrLen(_SetOfFields));
                        end;
                end;
                _KorberShptEntry2.Modify();
                WriteLog(KorberSetup."Log Level"::Normal,_KorberShptEntry."Entry No.",0,
                    StrSubstNo(_Text001Msg,_KorberShptEntry."Entry No.",_KorberShptEntry."Item No.",_SetOfFields),'');
            until _KorberShptEntry.Next() = 0;
        _KorberShptEntry.ClearMarks();
        _KorberShptEntry.Reset();
        if _KorberShptEntry.FindLast() then;
        _KorberShptEntry.Ascending(false);
    end;

    local procedure SendEntries()
    var
        _KorberShptEntry: Record "ARC Korber Shpt. Entry";
        _KorberShptEntry2: Record "ARC Korber Shpt. Entry";
        _KorberShptMgt: Codeunit "ARC KorberShptMgt";
        _result: Boolean;
        _entriesProcessed: Integer;
        _NoOfAttempts: Integer;
        _docNo: Text;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Msg: Label 'KorberShptMgt, document groups processed: %1';
    begin
        _KorberShptEntry.SetCurrentKey("Send to WMS","Sent to WMS");
        _KorberShptEntry.SetRange("Send to WMS",true);
        _KorberShptEntry.SetRange("Sent to WMS",0);
        if _KorberShptEntry.FindSet(false) then
            repeat
                if _docNo <> _KorberShptEntry."Document No." then begin
                    _docNo := CopyStr(_KorberShptEntry."Document No.",1,MaxStrLen(_docNo));
                    _NoOfAttempts := _KorberShptEntry."Sent to WMS No. of Attempts";
                    _timeBegin := Time();
                    Clear(_KorberShptMgt);
                    _KorberShptMgt.SetEntryNoToSend(_KorberShptEntry."Entry No.");
                    Commit();
                    _result := _KorberShptMgt.Run();
                    if not _result then begin
                        _NoOfAttempts += 1;
                        Clear(_KorberShptEntry2);
                        _KorberShptEntry2.Reset();
                        _KorberShptEntry2.SetCurrentKey("Send to WMS","Sent to WMS","Document Area","Document Type","Document No.");
                        _KorberShptEntry2.SetRange("Send to WMS",true);
                        _KorberShptEntry2.SetRange("Sent to WMS",0);
                        _KorberShptEntry2.SetRange("Document Area",_KorberShptEntry."Document Area");
                        _KorberShptEntry2.SetRange("Document Type",_KorberShptEntry."Document Type");
                        _KorberShptEntry2.SetRange("Document No.",_KorberShptEntry."Document No.");
                        _KorberShptEntry2.FindSet(true);
                        _timeEnd := Time();
                        _KorberShptEntry2.ModifyAll("Sent to WMS at DateTime",CreateDateTime(Today(),_timeEnd));
                        _KorberShptEntry2.ModifyAll("Sent to WMS Duration",_timeEnd - _timeBegin);
                        _KorberShptEntry2.ModifyAll("Sent to WMS No. of Attempts",_NoOfAttempts);
                        _KorberShptEntry2.ModifyAll("Sent to WMS Error Text",CopyStr(GetLastErrorText(),1,MaxStrLen(_KorberShptEntry2."Sent to WMS Error Text")));
                        if _NoOfAttempts >= KorberSetup."Maximum No. of Attempts" then
                            _KorberShptEntry2.ModifyAll("Sent to WMS",-1);
                    end;
                    _entriesProcessed += 1;
                end;
            until (_KorberShptEntry.Next() = 0) or (_entriesProcessed >= KorberSetup."Process Queue No. Entries");
        if _entriesProcessed > 0 then
            WriteLog(KorberSetup."Log Level"::Verbose,0,0,StrSubstNo(_Text000Msg,_entriesProcessed),'');
    end;

    local procedure SendEntry()
    var
        _KorberShptEntry: Record "ARC Korber Shpt. Entry";
        _KorberShptEntry2: Record "ARC Korber Shpt. Entry";
        _PurchaseHeader: Record "Purchase Header";
        _SalesHeader: Record "Sales Header";
        _TransferHeader: Record "Transfer Header";
        _tempBuf: Record "ARC Buffer" temporary;
        _tempBlob: Record TempBlob temporary;
        _DataMgt: Codeunit "ARC DataMgt";
        _entryNo: BigInteger;
        _file: File;
        _is: InStream;
        _NoOfAttempts: Integer;
        _os: OutStream;
        _desc: Text;
        _filename: Text;
        _fullFilename: Text;
        _timeBegin: Time;
        _timeEnd: Time;
        _KorberShptXmlport: XmlPort "ARC KorberShpt";
        _Text000Lbl: Label 'Shpt. Entry %1, document %2, filename %3, XML outbound to WMS';
        _Text001Err: Label 'No XML was generated using XmlPort "ARC KorberShpt"';
        _Text002Err: Label 'Full outbound filename is empty, check Korber Setup; source filename: %1';
    begin
        _timeBegin := Time();
        // create the temporary recordset containing the sales lines
        _tempBuf.DeleteAll();
        _KorberShptEntry.Get(EntryNoToSend);
        _NoOfAttempts := _KorberShptEntry."Sent to WMS No. of Attempts";
        _desc := CopyStr(StrSubstNo(_Text000Lbl,_KorberShptEntry."Entry No.",_KorberShptEntry."Document No."),1,MaxStrLen(_desc));
        _KorberShptEntry.SetCurrentKey("Send to WMS","Sent to WMS","Document Area","Document Type","Document No.");
        _KorberShptEntry.SetRange("Send to WMS",true);
        _KorberShptEntry.SetRange("Sent to WMS",0);
        _KorberShptEntry.SetRange("Document Area",_KorberShptEntry."Document Area");
        _KorberShptEntry.SetRange("Document Type",_KorberShptEntry."Document Type");
        _KorberShptEntry.SetRange("Document No.",_KorberShptEntry."Document No.");
        case _KorberShptEntry."Document Area" of
            _KorberShptEntry."Document Area"::Purchases: SendEntryDocLinesPurchases(_KorberShptEntry,_tempBuf,_PurchaseHeader);
            _KorberShptEntry."Document Area"::Sales: SendEntryDocLinesSales(_KorberShptEntry,_tempBuf,_SalesHeader);
            _KorberShptEntry."Document Area"::Transfers: SendEntryDocLinesTransfers(_KorberShptEntry,_tempBuf,_TransferHeader);
        end;
        // prep the tempBlob to store the Xml
        _tempBlob.DeleteAll();
        _tempBlob.Init();
        _tempBlob.Blob.CreateOutStream(_os);
        // call the Xmlport
        _KorberShptXmlport.LoadRecordset(_tempBuf);
        case _KorberShptEntry."Document Area" of
            _KorberShptEntry."Document Area"::Purchases: _KorberShptXmlport.SetPurchaseReturn(_PurchaseHeader);
            _KorberShptEntry."Document Area"::Sales: _KorberShptXmlport.SetSalesOrder(_SalesHeader);
            _KorberShptEntry."Document Area"::Transfers: _KorberShptXmlport.SetTransferOrder(_TransferHeader);
        end;
        _KorberShptXmlport.SetDestination(_os);
        _KorberShptXmlport.Export();
        // store the Xml generated
        _tempBlob.Insert();
        _tempBlob.CalcFields(Blob);
        // build text strings
        _filename := CopyStr(_KorberShptXmlport.GetContainerBatchRefHeader(),1,MaxStrLen(_filename));
        _fullFilename := CopyStr(KorberMgt.GetFullOutboundPathInclFilename(_filename),1,MaxStrLen(_fullFilename));
        _desc := CopyStr(StrSubstNo(_Text000Lbl,_KorberShptEntry."Entry No.",_KorberShptEntry."Document No.",_filename),1,MaxStrLen(_desc));
        // export to file the Xml generated
        if not _tempBlob.Blob.HasValue() then
            Error(_Text001Err);
        if _fullFilename = '' then
            Error(_Text002Err,_filename);
        _tempBlob.Blob.CreateInStream(_is);
        _file.TextMode(true);
        _file.WriteMode(true);
        _file.Create(_fullFilename);
        _file.CreateOutStream(_os);
        CopyStream(_os,_is);
        _file.Close();
        _tempBlob.CalcFields(Blob);
        // mark the entries as sent
        _NoOfAttempts += 1;
        Clear(_KorberShptEntry2);
        _KorberShptEntry2.Reset();
        _KorberShptEntry2.SetCurrentKey("Send to WMS","Sent to WMS","Document Area","Document Type","Document No.");
        _KorberShptEntry2.SetRange("Send to WMS",true);
        _KorberShptEntry2.SetRange("Sent to WMS",0);
        _KorberShptEntry2.SetRange("Document Area",_KorberShptEntry."Document Area");
        _KorberShptEntry2.SetRange("Document Type",_KorberShptEntry."Document Type");
        _KorberShptEntry2.SetRange("Document No.",_KorberShptEntry."Document No.");
        _KorberShptEntry2.FindSet(true);
        _timeEnd := Time();
        _KorberShptEntry2.ModifyAll("Sent to WMS at DateTime",CreateDateTime(Today(),_timeEnd));
        _KorberShptEntry2.ModifyAll("Sent to WMS Duration",_timeEnd - _timeBegin);
        _KorberShptEntry2.ModifyAll("Sent to WMS No. of Attempts",_NoOfAttempts);
        _KorberShptEntry2.ModifyAll("Sent to WMS Data Entry No.",_DataMgt.NewDataEntryUsingTempBlob('KORSHPMGT',_desc,_tempBlob));
        _KorberShptEntry2.ModifyAll("Sent to WMS",1);
    end;

    local procedure SendEntryDocLinesPurchases(
        var _KorberShptEntry: Record "ARC Korber Shpt. Entry"; 
        var _tempBuf: Record "ARC Buffer" temporary;
        var _PurchaseHeader: Record "Purchase Header")
    var
        _PurchaseLine: Record "Purchase Line";
        _entryNo: BigInteger;
    begin
        if _KorberShptEntry.FindSet(false) then
            repeat
                if _PurchaseHeader."No." = '' then
                    _PurchaseHeader.Get(_KorberShptEntry."Document Type",_KorberShptEntry."Document No.");
                if not _PurchaseLine.Get(_KorberShptEntry."Document Type",_KorberShptEntry."Document No.",_KorberShptEntry."Document Line No.") then begin
                    WriteDiagText(StrSubstNo('failed to retrieve purchase line no %1',_KorberShptEntry."Document Line No."));
                    WriteLog(KorberSetup."Log Level"::Error,_KorberShptEntry."Entry No.",0,'',StrSubstNo('failed to retrieve purchase line no %1',_KorberShptEntry."Document Line No."));
                end else begin
                    _entryNo += 1;
                    _tempBuf."Entry No." := _entryNo;
                    _tempBuf."Code 01" := CopyStr(KorberMgt.GetStripText(_KorberShptEntry."Item No."),1,MaxStrLen(_tempBuf."Code 01"));
                    _tempBuf."Code 02" := CopyStr(KorberMgt.GetStripText(_KorberShptEntry."Location Code"),1,MaxStrLen(_tempBuf."Code 02"));
                    _tempBuf."Code 04" := CopyStr(KorberMgt.GetStripText(_KorberShptEntry."Unit of Measure Code"),1,MaxStrLen(_tempBuf."Code 04"));
                    _tempBuf."Decimal 01" := _KorberShptEntry."Quantity (Base)";
                    _tempBuf."Decimal 02" := _PurchaseLine."Outstanding Qty. (Base)";
                    _tempBuf."Decimal 03" := _PurchaseLine."Direct Unit Cost";
                    if _tempBuf."Decimal 03" = 0 then
                        _tempBuf."Decimal 03" := 0.01;  // UnitPrice tag must not be empty in shpt XML - wkshop Tue 25 Oct 2022
                    _tempBuf."Integer 01" := _KorberShptEntry."Document Line No.";
                    _tempBuf."BigInteger 01" := _KorberShptEntry."Entry No.";
                    _tempBuf."Text 01" := CopyStr(KorberMgt.GetStripText(_PurchaseLine.Description),1,MaxStrLen(_tempBuf."Text 01"));
                    _tempBuf."Date 01" := _PurchaseHeader."Order Date";
                    _tempBuf.Insert();
                end;
            until _KorberShptEntry.Next() = 0;
    end;

    local procedure SendEntryDocLinesSales(
        var _KorberShptEntry: Record "ARC Korber Shpt. Entry"; 
        var _tempBuf: Record "ARC Buffer" temporary;
        var _SalesHeader: Record "Sales Header")
    var
        _SalesLine: Record "Sales Line";
        _entryNo: BigInteger;
    begin
        if _KorberShptEntry.FindSet(false) then
            repeat
                if _SalesHeader."No." = '' then
                    _SalesHeader.Get(_KorberShptEntry."Document Type",_KorberShptEntry."Document No.");
                if not _SalesLine.Get(_KorberShptEntry."Document Type",_KorberShptEntry."Document No.",_KorberShptEntry."Document Line No.") then begin
                    WriteDiagText(StrSubstNo('failed to retrieve sales line no %1',_KorberShptEntry."Document Line No."));
                    WriteLog(KorberSetup."Log Level"::Error,_KorberShptEntry."Entry No.",0,'',StrSubstNo('failed to retrieve sales line no %1',_KorberShptEntry."Document Line No."));
                end else begin
                    _entryNo += 1;
                    _tempBuf."Entry No." := _entryNo;
                    _tempBuf."Code 01" := CopyStr(KorberMgt.GetStripText(_KorberShptEntry."Item No."),1,MaxStrLen(_tempBuf."Code 01"));
                    _tempBuf."Code 02" := CopyStr(KorberMgt.GetStripText(_KorberShptEntry."Location Code"),1,MaxStrLen(_tempBuf."Code 02"));
                    _tempBuf."Code 04" := CopyStr(KorberMgt.GetStripText(_KorberShptEntry."Unit of Measure Code"),1,MaxStrLen(_tempBuf."Code 04"));
                    _tempBuf."Decimal 01" := _KorberShptEntry."Quantity (Base)";
                    _tempBuf."Decimal 02" := _SalesLine."Outstanding Qty. (Base)";
                    _tempBuf."Decimal 03" := _SalesLine."Unit Price";
                    if _tempBuf."Decimal 03" = 0 then
                        _tempBuf."Decimal 03" := 0.01;  // UnitPrice tag must not be empty in shpt XML - wkshop Tue 25 Oct 2022
                    _tempBuf."Integer 01" := _KorberShptEntry."Document Line No.";
                    _tempBuf."BigInteger 01" := _KorberShptEntry."Entry No.";
                    _tempBuf."Text 01" := CopyStr(KorberMgt.GetStripText(_SalesLine.Description),1,MaxStrLen(_tempBuf."Text 01"));
                    //_tempBuf."Date 01" := _PurchaseLine."Expected Receipt Date";
                    _tempBuf.Insert();
                end;
            until _KorberShptEntry.Next() = 0;
    end;

    local procedure SendEntryDocLinesTransfers(
        var _KorberShptEntry: Record "ARC Korber Shpt. Entry"; 
        var _tempBuf: Record "ARC Buffer" temporary;
        var _TransferHeader: Record "Transfer Header")
    var
        _TransferLine: Record "Transfer Line";
        _entryNo: BigInteger;
    begin
        if _KorberShptEntry.FindSet(false) then
            repeat
                if _TransferHeader."No." = '' then
                    _TransferHeader.Get(_KorberShptEntry."Document No.");
                if not _TransferLine.Get(_KorberShptEntry."Document No.",_KorberShptEntry."Document Line No.") then begin
                    WriteDiagText(StrSubstNo('failed to retrieve transfer line no %1',_KorberShptEntry."Document Line No."));
                    WriteLog(KorberSetup."Log Level"::Error,_KorberShptEntry."Entry No.",0,'',StrSubstNo('failed to retrieve transfer line no %1',_KorberShptEntry."Document Line No."));
                end else begin
                    _entryNo += 1;
                    _tempBuf."Entry No." := _entryNo;
                    _tempBuf."Code 01" := CopyStr(KorberMgt.GetStripText(_KorberShptEntry."Item No."),1,MaxStrLen(_tempBuf."Code 01"));
                    _tempBuf."Code 02" := CopyStr(KorberMgt.GetStripText(_KorberShptEntry."Location Code"),1,MaxStrLen(_tempBuf."Code 02"));
                    _tempBuf."Code 04" := CopyStr(KorberMgt.GetStripText(_KorberShptEntry."Unit of Measure Code"),1,MaxStrLen(_tempBuf."Code 04"));
                    _tempBuf."Decimal 01" := _KorberShptEntry."Quantity (Base)";
                    _tempBuf."Decimal 02" := _TransferLine."Quantity (Base)" - _TransferLine."Qty. Shipped (Base)";
                    _tempBuf."Decimal 03" := 0.01;  // UnitPrice tag must not be empty in shpt XML - wkshop Tue 25 Oct 2022
                    _tempBuf."Integer 01" := _KorberShptEntry."Document Line No.";
                    _tempBuf."BigInteger 01" := _KorberShptEntry."Entry No.";
                    _tempBuf."Text 01" := CopyStr(KorberMgt.GetStripText(_TransferLine.Description),1,MaxStrLen(_tempBuf."Text 01"));
                    //_tempBuf."Date 01" := _TransferLine."Expected Receipt Date";
                    _tempBuf.Insert();
                end;
            until _KorberShptEntry.Next() = 0;
    end;

    procedure SetEntryNoToAnalyze(_EntryNoToAnalyze: BigInteger)
    begin
        EntryNoToAnalyze := _EntryNoToAnalyze;
    end;

    procedure SetEntryNoToProcess(_EntryNoToProcess: BigInteger)
    begin
        EntryNoToProcess := _EntryNoToProcess;
    end;

    procedure SetEntryNoToSend(_EntryNoToSend: BigInteger)
    begin
        EntryNoToSend := _EntryNoToSend;
    end;

    procedure ShowDocument(_KorberShptEntry: Record "ARC Korber Shpt. Entry")
    var
        _PurchaseHeader: Record "Purchase Header";
        _PurchRetShptHeader: Record "Return Shipment Header";
        _SalesHeader: Record "Sales Header";
        _SalesInvHeader: Record "Sales Invoice Header";
        _TransferHeader: Record "Transfer Header";
        _TransferShptHeader: Record "Transfer Shipment Header";
    begin
        case _KorberShptEntry."Document Area" of
            _KorberShptEntry."Document Area"::Purchases:
                begin
                    if _PurchaseHeader.Get(_KorberShptEntry."Document Type",_KorberShptEntry."Document No.") then begin
                        _PurchaseHeader.SetRecFilter();
                        Page.Run(Page::"Purchase Return Order",_PurchaseHeader);
                        exit;
                    end;
                    _PurchRetShptHeader.SetCurrentKey("Return Order No.");
                    _PurchRetShptHeader.SetRange("Return Order No.",_KorberShptEntry."Document No.");
                    Page.Run(Page::"Posted Return Shipments",_PurchRetShptHeader);
                end;
            _KorberShptEntry."Document Area"::Sales:
                begin
                    if _SalesHeader.Get(_KorberShptEntry."Document Type",_KorberShptEntry."Document No.") then begin
                        _SalesHeader.SetRecFilter();
                        Page.Run(Page::"Sales Order",_SalesHeader);
                        exit;
                    end;
                    _SalesInvHeader.SetCurrentKey("Order No.");
                    _SalesInvHeader.SetRange("Order No.",_KorberShptEntry."Document No.");
                    Page.Run(Page::"Posted Sales Invoices",_SalesInvHeader);
                end;
            _KorberShptEntry."Document Area"::Transfers:
                begin
                    if _TransferHeader.Get(_KorberShptEntry."Document No.") then begin
                        _TransferHeader.SetRecFilter();
                        Page.Run(Page::"Transfer Order",_TransferHeader);
                        exit;
                    end;
                    _TransferShptHeader.SetRange("Transfer Order No.",_KorberShptEntry."Document No.");
                    Page.Run(Page::"Posted Transfer Shipments",_TransferShptHeader);
                end;
        end;
    end;

    procedure ShowEntity(_KorberShptEntry: Record "ARC Korber Shpt. Entry")
    var
        _Customer: Record Customer;
    begin
        case _KorberShptEntry."Document Area" of
            _KorberShptEntry."Document Area"::Purchases:;
            _KorberShptEntry."Document Area"::Sales:
                begin
                    _Customer.Get(_KorberShptEntry."Sell-to/Buy-from Entity No.");
                    Page.Run(Page::"Customer Card",_Customer);
                end;
            _KorberShptEntry."Document Area"::Transfers:;
        end;
    end;

    procedure ShowImportEntry(_KorberShptEntry: Record "ARC Korber Shpt. Entry")
    var
        _ImportEntry: Record "ARC Korber Import Entry";
    begin
        _KorberShptEntry.TestField("Import Entry No.");
        _ImportEntry.SetRange("Entry No.",_KorberShptEntry."Import Entry No.");
        Page.Run(Page::"ARC Korber Import Entries",_ImportEntry);
    end;

    procedure ShowItem(_KorberShptEntry: Record "ARC Korber Shpt. Entry")
    var
        _Item: Record Item;
    begin
        _Item.Get(_KorberShptEntry."Item No.");
        Page.Run(Page::"Item Card",_Item);
    end;

    procedure ShowLocation(_KorberShptEntry: Record "ARC Korber Shpt. Entry")
    var
        _Location: Record Location;
    begin
        _Location.Get(_KorberShptEntry."Location Code");
        Page.Run(Page::"Location Card",_Location);
    end;

    procedure ShowShptEntriesFromSales(_SalesHeader: Record "Sales Header")
    var
        _KorberShptEntry: Record "ARC Korber Shpt. Entry";
    begin
        _KorberShptEntry.SetCurrentKey("Document Area","Document Type","Document No.");
        _KorberShptEntry.SetRange("Document Area",_KorberShptEntry."Document Area"::Sales);
        _KorberShptEntry.SetRange("Document Type",_SalesHeader."Document Type");
        _KorberShptEntry.SetRange("Document No.",_SalesHeader."No.");
        Page.Run(Page::"ARC Korber Shpt. Entries",_KorberShptEntry);
    end;

    procedure ShowShptEntriesUsingSalesOrderNo(_DocNo: Code[20])
    var
        _KorberShptEntry: Record "ARC Korber Shpt. Entry";
    begin
        _KorberShptEntry.SetCurrentKey("Document Area","Document Type","Document No.");
        _KorberShptEntry.SetRange("Document Area",_KorberShptEntry."Document Area"::Sales);
        _KorberShptEntry.SetRange("Document Type",_KorberShptEntry."Document Type"::Order);
        _KorberShptEntry.SetRange("Document No.",_DocNo);
        Page.Run(Page::"ARC Korber Shpt. Entries",_KorberShptEntry);
    end;

    local procedure WriteDiagText(_diagtext: Text)
    var
        _datetimetext: Text;
        _textline: Text;
        _Text000Lbl: Label '%1 -- %2';
    begin
        _datetimetext := CopyStr(Format(CurrentDateTime(),0,9),1,MaxStrLen(_datetimetext));
        _textline := CopyStr(StrSubstNo(_Text000Lbl,_datetimetext,_diagtext) + CRNL,1,MaxStrLen(_textline));
        DiagText.AddText(_textline);
    end;

    local procedure WriteLog(_logLevel: Integer; _relatedEntryNo: BigInteger; _relatedDataEntryNo: BigInteger; _msg: Text; _err: Text)
    var
        _KorberMgt: Codeunit "ARC KorberMgt";
    begin
        _KorberMgt.WriteLog(_logLevel,Codeunit::"ARC KorberShptMgt",DiagLabel,_relatedEntryNo,_relatedDataEntryNo,_msg,_err);
    end;
}
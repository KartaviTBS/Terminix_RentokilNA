codeunit 50104 "ARC KorberRcptMgt"
{
    // SOW11 Körber Edge WMS Integration

    Permissions = tabledata "ARC Korber Rcpt. Entry" = rim;

    trigger OnRun();
    begin
        Initialize();
        if not KorberSetup."Process Queue Enabled" then
            exit;
        if not KorberSetup."Send Receipts" then
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
        Override: Boolean;
        CRNL: Text;
        DiagLabel: Label 'KORRCPMGT';

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
        _KorberRcptEntry: Record "ARC Korber Rcpt. Entry";
        _KorberRcptEntry2: Record "ARC Korber Rcpt. Entry";
        _KorberRcptMgt: Codeunit "ARC KorberRcptMgt";
        _result: Boolean;
        _entriesProcessed: Integer;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Msg: Label 'KorberRcptMgt, entries analyzed: %1';
    begin
        _KorberRcptEntry.SetCurrentKey(Analyze,Analyzed);
        _KorberRcptEntry.SetRange(Analyze,true);
        _KorberRcptEntry.SetRange(Analyzed,0);
        if _KorberRcptEntry.FindSet(false) then
            repeat
                _timeBegin := Time();
                Clear(_KorberRcptMgt);
                _KorberRcptMgt.SetEntryNoToAnalyze(_KorberRcptEntry."Entry No.");
                Commit();
                _result := _KorberRcptMgt.Run();
                if not _result then begin
                    Clear(_KorberRcptEntry2);
                    _KorberRcptEntry2.Reset();
                    _KorberRcptEntry2.LockTable();
                    if _KorberRcptEntry2.Get(_KorberRcptEntry."Entry No.") then begin
                        _timeEnd := Time();
                        _KorberRcptEntry2."Analyzed at DateTime" := CreateDateTime(Today(),_timeEnd);
                        _KorberRcptEntry2."Analyzed Duration" := _timeEnd - _timeBegin;
                        _KorberRcptEntry2."Analyzed No. of Attempts" := _KorberRcptEntry2."Analyzed No. of Attempts" + 1;
                        _KorberRcptEntry2."Analyzed Error Text" := CopyStr(GetLastErrorText(),1,MaxStrLen(_KorberRcptEntry2."Analyzed Error Text"));
                        if _KorberRcptEntry2."Analyzed No. of Attempts" >= KorberSetup."Maximum No. of Attempts" then
                            _KorberRcptEntry2.Analyzed := -1;
                        _KorberRcptEntry2.Modify();
                    end;
                end;
                _entriesProcessed += 1;
            until (_KorberRcptEntry.Next() = 0) or (_entriesProcessed >= KorberSetup."Process Queue No. Entries");
        if _entriesProcessed > 0 then
            WriteLog(KorberSetup."Log Level"::Verbose,0,0,StrSubstNo(_Text000Msg,_entriesProcessed),'');
    end;

    local procedure AnalyzeEntry()
    var
        _KorberRcptEntry: Record "ARC Korber Rcpt. Entry";
    begin
        _KorberRcptEntry.Get(EntryNoToAnalyze);
        case _KorberRcptEntry."Document Area" of
            _KorberRcptEntry."Document Area"::Purchases:
                AnalyzeEntryPurchases(_KorberRcptEntry);
            _KorberRcptEntry."Document Area"::Sales:
                AnalyzeEntrySales(_KorberRcptEntry);
            _KorberRcptEntry."Document Area"::Transfers:
                AnalyzeEntryTransfers(_KorberRcptEntry);
        end;
    end;

    local procedure AnalyzeEntryPurchases(_KorberRcptEntry: Record "ARC Korber Rcpt. Entry")
    var
        _KorberRcptEntry2: Record "ARC Korber Rcpt. Entry";
        _Location: Record Location;
        _PurchaseHeader: Record "Purchase Header";
        _PurchaseLine: Record "Purchase Line";
        _continue: Boolean;
        _timeBegin: Time;
        _timeEnd: Time;
    begin
        _timeBegin := Time();
        _PurchaseHeader.Get(_KorberRcptEntry."Document Type",_KorberRcptEntry."Document No.");
        _PurchaseLine.SetRange("Document Type",_PurchaseHeader."Document Type");
        _PurchaseLine.SetRange("Document No.",_PurchaseHeader."No.");
        _PurchaseLine.SetRange(Type,_PurchaseLine.Type::Item);
        _PurchaseLine.SetFilter("No.",'<>%1','');
        _PurchaseLine.SetFilter(Quantity,'<>0');  // per Cody Weeks sent Tue 2023-01-17 1206pm Eastern
        if _PurchaseLine.FindSet(false) then
            repeat
                _continue := true;
                if not AnalyzeDropShipPurchases(_PurchaseLine) then
                    _continue := false;
                if not KorberMgt.GetLocation(_PurchaseLine."Location Code",_Location) then
                    _continue := false;
                if _continue then
                    if IsAlreadySent(_KorberRcptEntry,_PurchaseLine."Line No.",_PurchaseLine."No.",_PurchaseLine.Quantity) then
                        _continue := false;
                if _continue then begin
                    Clear(_KorberRcptEntry2);
                    _KorberRcptEntry2.Reset();
                    _KorberRcptEntry2 := _KorberRcptEntry;
                    _KorberRcptEntry2."Entry No." := 0;
                    _KorberRcptEntry2."Document Line No." := _PurchaseLine."Line No.";
                    _KorberRcptEntry2."Item No." := CopyStr(_PurchaseLine."No.",1,MaxStrLen(_KorberRcptEntry2."Item No."));
                    _KorberRcptEntry2."Unit of Measure Code" := CopyStr(_PurchaseLine."Unit of Measure Code",1,MaxStrLen(_KorberRcptEntry2."Unit of Measure Code"));
                    _KorberRcptEntry2."Location Code" := CopyStr(_PurchaseLine."Location Code",1,MaxStrLen(_KorberRcptEntry2."Location Code"));
                    _KorberRcptEntry2.Quantity := _PurchaseLine.Quantity;  // per Cody Weeks sent Tue 2023-01-17 1206pm Eastern
                    _KorberRcptEntry2."Qty. per Unit of Measure" := _PurchaseLine."Qty. per Unit of Measure";
                    _KorberRcptEntry2."Quantity (Base)" := _PurchaseLine."Quantity (Base)";  // per Cody Weeks sent Tue 2023-01-17 1206pm Eastern
                    _KorberRcptEntry2.Analyze := false;
                    _KorberRcptEntry2.Analyzed := 0;
                    _KorberRcptEntry2."Analyzed at DateTime" := 0DT;
                    _KorberRcptEntry2."Analyzed Duration" := 0;
                    _KorberRcptEntry2."Analyzed Error Text" := '';
                    _KorberRcptEntry2."Analyzed No. of Attempts" := 0;
                    _KorberRcptEntry2."Send to WMS" := true;
                    _KorberRcptEntry2.Insert(false);
                end;
            until _PurchaseLine.Next() = 0;
        _timeEnd := Time();
        Clear(_KorberRcptEntry2);
        _KorberRcptEntry2.Reset();
        _KorberRcptEntry2.LockTable();
        _KorberRcptEntry2.Get(_KorberRcptEntry."Entry No.");
        _KorberRcptEntry2."Analyzed at DateTime" := CreateDateTime(Today(),_timeEnd);
        _KorberRcptEntry2."Analyzed No. of Attempts" := _KorberRcptEntry2."Analyzed No. of Attempts" + 1;
        _KorberRcptEntry2."Analyzed Duration" := _timeEnd - _timeBegin;
        _KorberRcptEntry2.Analyzed := 1;
        _KorberRcptEntry2.Modify(false);
    end;

    local procedure AnalyzeEntrySales(_KorberRcptEntry: Record "ARC Korber Rcpt. Entry")
    var
        _KorberRcptEntry2: Record "ARC Korber Rcpt. Entry";
        _Location: Record Location;
        _SalesHeader: Record "Sales Header";
        _SalesLine: Record "Sales Line";
        _continue: Boolean;
        _timeBegin: Time;
        _timeEnd: Time;
    begin
        _timeBegin := Time();
        _SalesHeader.Get(_KorberRcptEntry."Document Type",_KorberRcptEntry."Document No.");
        _SalesLine.SetRange("Document Type",_SalesHeader."Document Type");
        _SalesLine.SetRange("Document No.",_SalesHeader."No.");
        _SalesLine.SetRange(Type,_SalesLine.Type::Item);
        _SalesLine.SetFilter("No.",'<>%1','');
        _SalesLine.SetFilter(Quantity,'<>0');  // per Cody Weeks sent Tue 2023-01-17 1206pm Eastern
        if _SalesLine.FindSet(false) then
            repeat
                _continue := true;
                if not AnalyzeDropShipSales(_SalesLine) then
                    _continue := false;
                if not KorberMgt.GetLocation(_SalesLine."Location Code",_Location) then
                    _continue := false;
                if _continue then
                    if IsAlreadySent(_KorberRcptEntry,_SalesLine."Line No.",_SalesLine."No.",_SalesLine.Quantity) then
                        _continue := false;
                if _continue then begin
                    Clear(_KorberRcptEntry2);
                    _KorberRcptEntry2.Reset();
                    _KorberRcptEntry2 := _KorberRcptEntry;
                    _KorberRcptEntry2."Entry No." := 0;
                    _KorberRcptEntry2."Document Line No." := _SalesLine."Line No.";
                    _KorberRcptEntry2."Item No." := CopyStr(_SalesLine."No.",1,MaxStrLen(_KorberRcptEntry2."Item No."));
                    _KorberRcptEntry2."Unit of Measure Code" := CopyStr(_SalesLine."Unit of Measure Code",1,MaxStrLen(_KorberRcptEntry2."Unit of Measure Code"));
                    _KorberRcptEntry2."Location Code" := CopyStr(_SalesLine."Location Code",1,MaxStrLen(_KorberRcptEntry2."Location Code"));
                    _KorberRcptEntry2.Quantity := _SalesLine.Quantity;  // per Cody Weeks sent Tue 2023-01-17 1206pm Eastern
                    _KorberRcptEntry2."Qty. per Unit of Measure" := _SalesLine."Qty. per Unit of Measure";
                    _KorberRcptEntry2."Quantity (Base)" := _SalesLine."Quantity (Base)";  // per Cody Weeks sent Tue 2023-01-17 1206pm Eastern
                    _KorberRcptEntry2.Analyze := false;
                    _KorberRcptEntry2.Analyzed := 0;
                    _KorberRcptEntry2."Analyzed at DateTime" := 0DT;
                    _KorberRcptEntry2."Analyzed Duration" := 0;
                    _KorberRcptEntry2."Analyzed Error Text" := '';
                    _KorberRcptEntry2."Analyzed No. of Attempts" := 0;
                    _KorberRcptEntry2."Send to WMS" := true;
                    _KorberRcptEntry2.Insert(false);
                end;
            until _SalesLine.Next() = 0;
        _timeEnd := Time();
        Clear(_KorberRcptEntry2);
        _KorberRcptEntry2.Reset();
        _KorberRcptEntry2.LockTable();
        _KorberRcptEntry2.Get(_KorberRcptEntry."Entry No.");
        _KorberRcptEntry2."Analyzed at DateTime" := CreateDateTime(Today(),_timeEnd);
        _KorberRcptEntry2."Analyzed No. of Attempts" := _KorberRcptEntry2."Analyzed No. of Attempts" + 1;
        _KorberRcptEntry2."Analyzed Duration" := _timeEnd - _timeBegin;
        _KorberRcptEntry2.Analyzed := 1;
        _KorberRcptEntry2.Modify(false);
    end;

    local procedure AnalyzeEntryTransfers(_KorberRcptEntry: Record "ARC Korber Rcpt. Entry")
    var
        _KorberRcptEntry2: Record "ARC Korber Rcpt. Entry";
        _Location: Record Location;
        _TransferHeader: Record "Transfer Header";
        _TransferLine: Record "Transfer Line";
        _continue: Boolean;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Err: Label 'Transfer-to Location %1 is not Korber-enabled, so Korber Edge will not be alerted to receive Transfer Order %2.';
        //_Text001Err: Label 'Re: transfer %1 from Korber-managed loc %2 TO Korber-managed loc %3: do NOT send PO per Robin; ref concall Wed 31 Aug 2022 at 3pm EDT';
    begin
        _timeBegin := Time();
        _TransferHeader.Get(_KorberRcptEntry."Document No.");
        /*
        ** confirmations for transfers outbound have drastically different XML than confirmations for sales order shpts
        ** per Mark Burke of Korber Edge (concall Tue 1 Nov 2022), use sales orders instead; this requires sending the PO.
        ** see also: email sent Mon 31 Oct 2022 at 237pm Eastern
        **
        if (KorberMgt.GetLocation(_TransferHeader."Transfer-from Code",_Location)) and (KorberMgt.GetLocation(_TransferHeader."Transfer-to Code",_Location)) then begin
            // WriteLog(KorberSetup."Log Level"::Error,_KorberRcptEntry."Entry No.",0,'',
            //     StrSubstNo(_Text001Err,_TransferHeader."No.",_TransferHeader."Transfer-from Code",_TransferHeader."Transfer-to Code"));
            // exit;
			Error(_Text001Err,_TransferHeader."No.",_TransferHeader."Transfer-from Code",_TransferHeader."Transfer-to Code");
        end;
        */
        if not KorberMgt.GetLocation(_TransferHeader."Transfer-to Code",_Location) then begin
            // WriteLog(KorberSetup."Log Level"::Error,_KorberRcptEntry."Entry No.",0,'',
            //     StrSubstNo(_Text000Err,_TransferHeader."Transfer-to Code",_KorberRcptEntry."Document No."));
            // exit;
			Error(_Text000Err,_TransferHeader."Transfer-to Code",_KorberRcptEntry."Document No.");
        end;
        _TransferLine.SetRange("Document No.",_TransferHeader."No.");
        _TransferLine.SetRange("Derived From Line No.",0);
        _TransferLine.SetFilter("Outstanding Qty. (Base)",'<>0');
        if _TransferLine.FindSet(false) then
            repeat
                _continue := true;
                if _continue then
                    if IsAlreadySent(_KorberRcptEntry,_TransferLine."Line No.",_TransferLine."Item No.",_TransferLine.Quantity) then
                        _continue := false;
                if _continue then begin
                    Clear(_KorberRcptEntry2);
                    _KorberRcptEntry2.Reset();
                    _KorberRcptEntry2 := _KorberRcptEntry;
                    _KorberRcptEntry2."Entry No." := 0;
                    _KorberRcptEntry2."Document Line No." := _TransferLine."Line No.";
                    _KorberRcptEntry2."Item No." := CopyStr(_TransferLine."Item No.",1,MaxStrLen(_KorberRcptEntry2."Item No."));
                    _KorberRcptEntry2."Unit of Measure Code" := CopyStr(_TransferLine."Unit of Measure Code",1,MaxStrLen(_KorberRcptEntry2."Unit of Measure Code"));
                    _KorberRcptEntry2."Location Code" := CopyStr(_TransferHeader."Transfer-to Code",1,MaxStrLen(_KorberRcptEntry2."Location Code"));
                    _KorberRcptEntry2.Quantity := _TransferLine.Quantity;
                    _KorberRcptEntry2."Qty. per Unit of Measure" := _TransferLine."Qty. per Unit of Measure";
                    _KorberRcptEntry2."Quantity (Base)" := _TransferLine."Quantity (Base)";
                    _KorberRcptEntry2.Analyze := false;
                    _KorberRcptEntry2.Analyzed := 0;
                    _KorberRcptEntry2."Analyzed at DateTime" := 0DT;
                    _KorberRcptEntry2."Analyzed Duration" := 0;
                    _KorberRcptEntry2."Analyzed Error Text" := '';
                    _KorberRcptEntry2."Analyzed No. of Attempts" := 0;
                    _KorberRcptEntry2."Send to WMS" := true;
                    _KorberRcptEntry2.Insert(false);
                end;
            until _TransferLine.Next() = 0;
        _timeEnd := Time();
        Clear(_KorberRcptEntry2);
        _KorberRcptEntry2.Reset();
        _KorberRcptEntry2.LockTable();
        _KorberRcptEntry2.Get(_KorberRcptEntry."Entry No.");
        _KorberRcptEntry2."Analyzed at DateTime" := CreateDateTime(Today(),_timeEnd);
        _KorberRcptEntry2."Analyzed No. of Attempts" := _KorberRcptEntry2."Analyzed No. of Attempts" + 1;
        _KorberRcptEntry2."Analyzed Duration" := _timeEnd - _timeBegin;
        _KorberRcptEntry2.Analyzed := 1;
        _KorberRcptEntry2.Modify(false);
    end;

    procedure CreateProcessEntry(var _tempBuf: Record "ARC Buffer" temporary)
    var
        _RcptEntry: Record "ARC Korber Rcpt. Entry";
        _RcptEntry2: Record "ARC Korber Rcpt. Entry";
        _continue: Boolean;
        _time: Time;
    begin
        // designed to be called from codeunit 50102 "ARC KorberMgt" when XML is imported
        _time := Time();
        _RcptEntry.Get(_tempBuf."BigInteger 01");
        _RcptEntry2 := _RcptEntry;
        _RcptEntry2."Entry No." := 0;
        if _tempBuf."Integer 01" <> 0 then
            _RcptEntry2."Document Line No." := _tempBuf."Integer 01";
        if _tempBuf."Code 01" <> '' then
            _RcptEntry2."Item No." := CopyStr(_tempBuf."Code 01",1,MaxStrLen(_RcptEntry2."Item No."));
        if _tempBuf."Code 02" <> '' then
            _RcptEntry2."Location Code" := CopyStr(_tempBuf."Code 02",1,MaxStrLen(_RcptEntry2."Location Code"));
        if _tempBuf."Decimal 01" <> 0 then begin
            /* qtys per UOM always base according to Erik - scenario tested Mon 24 Oct 2022
            **   concall re [RENT] SOW11 Körber Edge WMS Integration -- Session 1: End to End workshop for UAT/ WMS - Paola Montgomery
            _RcptEntry2.Quantity := _tempBuf."Decimal 01";
            _RcptEntry2."Quantity (Base)" := _RcptEntry2.Quantity * _RcptEntry2."Qty. per Unit of Measure";
            */
            _RcptEntry2."Quantity (Base)" := _tempBuf."Decimal 01";
            if _RcptEntry2."Qty. per Unit of Measure" <> 0 then
                _RcptEntry2.Quantity := _tempBuf."Decimal 01" / _RcptEntry2."Qty. per Unit of Measure";
        end;
        _RcptEntry2."Created by" := CopyStr(UserId(),1,MaxStrLen(_RcptEntry2."Created by"));
        _RcptEntry2."Created at Date" := Today();
        _RcptEntry2."Created at DateTime" := CreateDateTime(Today(),_time);
        _RcptEntry2."Created at Time" := _time;
        _RcptEntry2.Analyze := false;
        _RcptEntry2.Analyzed := 0;
        _RcptEntry2."Analyzed at DateTime" := 0DT;
        _RcptEntry2."Analyzed Duration" := 0;
        _RcptEntry2."Analyzed Error Text" := '';
        _RcptEntry2."Analyzed No. of Attempts" := 0;
        _RcptEntry2."Send to WMS" := false;
        _RcptEntry2."Sent to WMS" := 0;
        _RcptEntry2."Sent to WMS at DateTime" := 0DT;
        _RcptEntry2."Sent to WMS Data Entry No." := 0;
        _RcptEntry2."Sent to WMS Duration" := 0;
        _RcptEntry2."Sent to WMS Error Text" := '';
        _RcptEntry2."Sent to WMS No. of Attempts" := 0;
        _RcptEntry2.Process := true;
        _RcptEntry2."Import Entry No." := _tempBuf."BigInteger 02";
        _RcptEntry2.Insert();
    end;

    procedure GetDiagText(var _diagText: BigText)
    begin
        _diagText := DiagText;
    end;

    local procedure GetEarliestExpectedRcptDate(_PurchaseHeader: Record "Purchase Header") _earliestDate : Date
    var
        _PurchaseLine: Record "Purchase Line";
    begin
        _earliestDate := _PurchaseHeader."Expected Receipt Date";
        if _earliestDate < Today() then
            _earliestDate := CalcDate('+1Y',Today());
        _PurchaseLine.SetRange("Document Type",_PurchaseHeader."Document Type");
        _PurchaseLine.SetRange("Document No.",_PurchaseHeader."No.");
        _PurchaseLine.SetRange(Type,_PurchaseLine.Type::Item);
        _PurchaseLine.SetFilter("Outstanding Quantity",'<>0');
        if _PurchaseLine.FindSet(false) then
            repeat
                if _PurchaseLine."Expected Receipt Date" >= Today() then
                    if _PurchaseLine."Expected Receipt Date" < _earliestDate then
                        _earliestDate := _PurchaseLine."Expected Receipt Date";
            until _PurchaseLine.Next() = 0;
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

    local procedure IsAlreadySent(_KorberRcptEntry: Record "ARC Korber Rcpt. Entry"; _LineNo: Integer; _ItemNo: Code[20]; _Qty: Decimal): Boolean
    var
        _KorberRcptEntry2: Record "ARC Korber Rcpt. Entry";
    begin
        _KorberRcptEntry2.SetCurrentKey("Document Area","Document Type","Document No.","Document Line No.");
        _KorberRcptEntry2.SetRange("Document Area",_KorberRcptEntry."Document Area");
        _KorberRcptEntry2.SetRange("Document Type",_KorberRcptEntry."Document Type");
        _KorberRcptEntry2.SetRange("Document No.",_KorberRcptEntry."Document No.");
        _KorberRcptEntry2.SetRange("Document Line No.",_LineNo);
        _KorberRcptEntry2.SetRange("Item No.",_ItemNo);
        _KorberRcptEntry2.SetRange(Quantity,_Qty);
        _KorberRcptEntry2.SetRange("Unit of Measure Code",_KorberRcptEntry."Unit of Measure Code");
        _KorberRcptEntry2.SetRange("Sent to WMS",1);
        exit(not _KorberRcptEntry2.IsEmpty());
    end;

    procedure OnAfterReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; LinesWereModified: Boolean)
    var
        _KorberRcptEntry: Record "ARC Korber Rcpt. Entry";
    begin
        Initialize();
        if not Override then
            if not KorberSetup."Send Receipts" then
                exit;
        if not Override then
            if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then
                exit;
        // if outstanding receipts must be posted for this purchase order, do not transmit
        if not Override then begin
            _KorberRcptEntry.SetCurrentKey(Process,Processed);
            _KorberRcptEntry.SetRange(Process,true);
            _KorberRcptEntry.SetRange(Processed,0);
            _KorberRcptEntry.SetRange("Document No.",PurchaseHeader."No.");
            if not _KorberRcptEntry.IsEmpty() then
                exit;
        end;
        // prepare for transmit
        _KorberRcptEntry.SetCurrentKey("Document Area","Document Type","Document No.","Document Line No.");
        _KorberRcptEntry.SetRange("Document Area",_KorberRcptEntry."Document Area"::Purchases);
        _KorberRcptEntry.SetRange("Document Type",PurchaseHeader."Document Type");
        _KorberRcptEntry.SetRange("Document No.",CopyStr(PurchaseHeader."No.",1,MaxStrLen(_KorberRcptEntry."Document No.")));
        _KorberRcptEntry.SetRange(Analyze,true);
        _KorberRcptEntry.SetRange(Analyzed,0);
        if _KorberRcptEntry.IsEmpty() then begin
            _KorberRcptEntry."Entry No." := 0;
            _KorberRcptEntry."Document Area" := _KorberRcptEntry."Document Area"::Purchases;
            _KorberRcptEntry."Document Type" := PurchaseHeader."Document Type";
            _KorberRcptEntry."Document No." := CopyStr(PurchaseHeader."No.",1,MaxStrLen(_KorberRcptEntry."Document No."));
            _KorberRcptEntry.Analyze := true;
            _KorberRcptEntry."Sell-to/Buy-from Entity No." := CopyStr(PurchaseHeader."Buy-from Vendor No.",1,MaxStrLen(_KorberRcptEntry."Sell-to/Buy-from Entity No."));
            _KorberRcptEntry.Insert();
        end;
    end;

    procedure OnAfterReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; LinesWereModified: Boolean)
    var
        _KorberRcptEntry: Record "ARC Korber Rcpt. Entry";
    begin
        Initialize();
        if not KorberSetup."Send Receipts" then
            exit;
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::"Return Order" then
            exit;
        _KorberRcptEntry.SetCurrentKey("Document Area","Document Type","Document No.","Document Line No.");
        _KorberRcptEntry.SetRange("Document Area",_KorberRcptEntry."Document Area"::Sales);
        _KorberRcptEntry.SetRange("Document Type",SalesHeader."Document Type");
        _KorberRcptEntry.SetRange("Document No.",CopyStr(SalesHeader."No.",1,MaxStrLen(_KorberRcptEntry."Document No.")));
        _KorberRcptEntry.SetRange(Analyze,true);
        _KorberRcptEntry.SetRange(Analyzed,0);
        if _KorberRcptEntry.IsEmpty() then begin
            _KorberRcptEntry."Entry No." := 0;
            _KorberRcptEntry."Document Area" := _KorberRcptEntry."Document Area"::Sales;
            _KorberRcptEntry."Document Type" := SalesHeader."Document Type";
            _KorberRcptEntry."Document No." := CopyStr(SalesHeader."No.",1,MaxStrLen(_KorberRcptEntry."Document No."));
            _KorberRcptEntry.Analyze := true;
            _KorberRcptEntry."Sell-to/Buy-from Entity No." := CopyStr(SalesHeader."Sell-to Customer No.",1,MaxStrLen(_KorberRcptEntry."Sell-to/Buy-from Entity No."));
            _KorberRcptEntry.Insert();
        end;
    end;

    procedure OnAfterReleaseTransferDoc(var TransferHeader: Record "Transfer Header")
    var
        _KorberRcptEntry: Record "ARC Korber Rcpt. Entry";
        _Text000Lbl: Label 'OnAfterReleaseTransferDoc(): analyze %1';
    begin
        Initialize();
        if not KorberSetup."Send Receipts" then
            exit;
        _KorberRcptEntry.SetCurrentKey("Document Area","Document Type","Document No.","Document Line No.");
        _KorberRcptEntry.SetRange("Document Area",_KorberRcptEntry."Document Area"::Transfers);
        _KorberRcptEntry.SetRange("Document Type",_KorberRcptEntry."Document Type"::Order);
        _KorberRcptEntry.SetRange("Document No.",CopyStr(TransferHeader."No.",1,MaxStrLen(_KorberRcptEntry."Document No.")));
        _KorberRcptEntry.SetRange(Analyze,true);
        _KorberRcptEntry.SetRange(Analyzed,0);
        if _KorberRcptEntry.IsEmpty() then begin
            _KorberRcptEntry."Entry No." := 0;
            _KorberRcptEntry."Document Area" := _KorberRcptEntry."Document Area"::Transfers;
            _KorberRcptEntry."Document Type" := _KorberRcptEntry."Document Type"::Order;
            _KorberRcptEntry."Document No." := CopyStr(TransferHeader."No.",1,MaxStrLen(_KorberRcptEntry."Document No."));
            _KorberRcptEntry.Analyze := true;
            _KorberRcptEntry."Sell-to/Buy-from Entity No." := CopyStr(TransferHeader."Transfer-to Code",1,MaxStrLen(_KorberRcptEntry."Sell-to/Buy-from Entity No."));
            _KorberRcptEntry.Insert();
        end;
    end;

    procedure OnBeforeInsertRcptEntry(var Rec: Record "ARC Korber Rcpt. Entry"; RunTrigger: Boolean)
    var
        _time: Time;
    begin
        _time := Time();
        Rec."Created by" := CopyStr(UserId(),1,MaxStrLen(Rec."Created by"));
        Rec."Created at Date" := Today();
        Rec."Created at DateTime" := CreateDateTime(Today(),_time);
        Rec."Created at Time" := _time;
    end;

    procedure OnBeforeReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    begin
        if PurchaseHeader."Expected Receipt Date" <> 0D then
            exit;
        PurchaseHeader."Expected Receipt Date" := PurchaseHeader."Posting Date";
    end;

    local procedure ProcessEntries()
    var
        _KorberRcptEntry: Record "ARC Korber Rcpt. Entry";
        _KorberRcptEntry2: Record "ARC Korber Rcpt. Entry";
        _DataMgt: Codeunit "ARC DataMgt";
        _KorberRcptMgt: Codeunit "ARC KorberRcptMgt";
        _currEntryNo: BigInteger;
        _ImportEntryNo: BigInteger;
        _result: Boolean;
        _entriesProcessed: Integer;
        _NoOfAttempts: Integer;
        _docNo: Text;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Msg: Label 'KorberRcptMgt, document groups processed: %1';
        _Text001Err: Label 'EntryNo: %1, Err: %2';
        _Text002Lbl: Label 'Diagnostic text captured during process attempt';
        _Text099Lbl: Label 'Method ProcessEntries(): %1';
    begin
        _KorberRcptEntry.SetCurrentKey(Process,Processed,"Import Entry No.");
        _KorberRcptEntry.SetRange(Process,true);
        _KorberRcptEntry.SetRange(Processed,0);
        if _KorberRcptEntry.FindSet(false) then
            repeat
                if _ImportEntryNo <> _KorberRcptEntry."Import Entry No." then begin
                    _timeBegin := Time();
                    _currEntryNo := _KorberRcptEntry."Entry No.";
                    _ImportEntryNo := _KorberRcptEntry."Import Entry No.";
                    Clear(_KorberRcptMgt);
                    _KorberRcptMgt.SetEntryNoToProcess(_KorberRcptEntry."Entry No.");
                    Commit();
                    _result := _KorberRcptMgt.Run();
                    if not _result then begin
                        Clear(_KorberRcptEntry2);
                        _KorberRcptEntry2.Reset();
                        _KorberRcptEntry2.SetCurrentKey(Process,Processed,"Import Entry No.");
                        _KorberRcptEntry2.SetRange(Process,true);
                        _KorberRcptEntry2.SetRange(Processed,0);
                        _KorberRcptEntry2.SetRange("Import Entry No.",_ImportEntryNo);
                        if _KorberRcptEntry2.FindSet(true) then begin
                            _KorberRcptMgt.GetDiagText(DiagText);
                            _timeEnd := Time();
                            _KorberRcptEntry2.ModifyAll("Processed Data Entry No.",_DataMgt.NewDataEntry(DiagLabel,_Text002Lbl,DiagText));
                            _KorberRcptEntry2.ModifyAll("Processed at DateTime",CreateDateTime(Today(),_timeEnd));
                            _KorberRcptEntry2.ModifyAll("Processed No. of Attempts",_KorberRcptEntry."Processed No. of Attempts" + 1);
                            _KorberRcptEntry2.ModifyAll("Processed Error Text",CopyStr(StrSubstNo(_Text001Err,_currEntryNo,GetLastErrorText()),1,250));
                            _KorberRcptEntry2.ModifyAll("Processed Duration",_timeEnd - _timeBegin);
                            if _KorberRcptEntry."Processed No. of Attempts" + 1 > KorberSetup."Maximum No. of Attempts" then
                                _KorberRcptEntry2.ModifyAll(Processed,-1);
                            _KorberRcptEntry2.Reset();
                            WriteDiagText(StrSubstNo(_Text099Lbl,GetLastErrorText()));
                        end;
                    end;
                    _entriesProcessed += 1;
                end;
            until (_KorberRcptEntry.Next() = 0) or (_entriesProcessed > KorberSetup."Process Queue No. Entries");
        if _entriesProcessed > 0 then
            WriteDiagText(StrSubstNo(_Text099Lbl,StrSubstNo(_Text000Msg,_entriesProcessed)));
    end;

    local procedure ProcessEntry()
    var
        _KorberRcptEntry: Record "ARC Korber Rcpt. Entry";
        _KorberRcptEntry2: Record "ARC Korber Rcpt. Entry";
        _DataMgt: Codeunit "ARC DataMgt";
        _NoOfAttempts: Integer;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Lbl: Label 'Diagnostic text captured during process attempt';
        _Text099Lbl: Label 'Method ProcessEntry(): %1';
    begin
        _timeBegin := Time();
        WriteDiagText(StrSubstNo(_Text099Lbl,StrSubstNo('begin - EntryNo %1',EntryNoToProcess)));
        _KorberRcptEntry.Get(EntryNoToProcess);
        _KorberRcptEntry.TestField("Import Entry No.");
        _KorberRcptEntry.SetCurrentKey(Process,Processed,"Import Entry No.");
        _KorberRcptEntry.SetRange(Process,true);
        _KorberRcptEntry.SetRange(Processed,0);
        _KorberRcptEntry.SetRange("Import Entry No.",_KorberRcptEntry."Import Entry No.");
        _KorberRcptEntry.FindSet(false);
        _NoOfAttempts := _KorberRcptEntry."Processed No. of Attempts" + 1;
        case _KorberRcptEntry."Document Area" of
            _KorberRcptEntry."Document Area"::Purchases: ProcessEntryPurchases(_KorberRcptEntry);
            _KorberRcptEntry."Document Area"::Sales: ProcessEntrySales(_KorberRcptEntry);
            _KorberRcptEntry."Document Area"::Transfers: ProcessEntryTransfers(_KorberRcptEntry);
        end;
        _KorberRcptEntry2.SetCurrentKey(Process,Processed,"Import Entry No.");
        _KorberRcptEntry2.SetRange(Process,true);
        _KorberRcptEntry2.SetRange(Processed,0);
        _KorberRcptEntry2.SetRange("Import Entry No.",_KorberRcptEntry."Import Entry No.");
        _KorberRcptEntry2.FindSet(true);
        _timeEnd := Time();
        _KorberRcptEntry2.ModifyAll("Processed No. of Attempts",_NoOfAttempts);
        _KorberRcptEntry2.ModifyAll("Processed at DateTime",CreateDateTime(Today(),_timeEnd));
        _KorberRcptEntry2.ModifyAll("Processed Duration",_timeEnd - _timeBegin);
        _KorberRcptEntry2.ModifyAll("Processed Data Entry No.",_DataMgt.NewDataEntry(DiagLabel,_Text000Lbl,DiagText));
        _KorberRcptEntry2.ModifyAll(Processed,1);
        WriteDiagText(StrSubstNo(_Text099Lbl,'end'));
    end;

    local procedure ProcessEntryPurchases(var _KorberRcptEntry: Record "ARC Korber Rcpt. Entry")
    var
        _ItemUom: Record "Item Unit of Measure";
        _PurchaseHeader: Record "Purchase Header";
        _PurchaseLine: Record "Purchase Line";
        _PurchPost: codeunit "Purch.-Post";
        _ReleasePurchaseDoc: Codeunit "Release Purchase Document";
        _Text000Err: Label 'Qty. per Unit of Measure must NOT be zero';
        _Text099Lbl: Label 'Method ProcessEntry(): %1';
    begin
        WriteDiagText(StrSubstNo(_Text099Lbl,'begin'));
        _PurchaseHeader.SetHideValidationDialog(true);
        _PurchaseHeader.LockTable();
        _PurchaseHeader.Get(_KorberRcptEntry."Document Type",_KorberRcptEntry."Document No.");
        WriteDiagText(StrSubstNo(_Text099Lbl,'preparing to reopen, update posting date, set Receive + Invoice'));
        _ReleasePurchaseDoc.Reopen(_PurchaseHeader);
        _PurchaseHeader.Validate("Posting Date",Today());
        _PurchaseHeader.Receive := KorberSetup."Post Receipt";
        _PurchaseHeader.Invoice := KorberSetup."Post Invoice for Inb. Rcpts.";
        _PurchaseHeader.Modify(true);
        _PurchaseHeader.Reset();
        // prepare for partial rcpts; initialize qty. to receive and qty. to invoice to zero for all lines
        WriteDiagText(StrSubstNo(_Text099Lbl,'preparing to reset QtyToRecv, QtyToInvc to zero for all lines'));
        _PurchaseLine.SetRange("Document Type",_KorberRcptEntry."Document Type");
        _PurchaseLine.SetRange("Document No.",_KorberRcptEntry."Document No.");
        _PurchaseLine.SetFilter("Outstanding Quantity",'<>0');
        if _PurchaseLine.FindSet(true) then
            repeat
                _PurchaseLine.Validate("Qty. to Receive",0);
                _PurchaseLine.Validate("Qty. to Invoice",0);
                _PurchaseLine.Modify(true);
            until _PurchaseLine.Next() = 0;
        // set qtys to receive [and invoice]
        WriteDiagText(StrSubstNo(_Text099Lbl,'preparing to set QtyToRecv, QtyToInvc'));
        if _KorberRcptEntry.FindSet(false) then
            repeat
                Clear(_PurchaseLine);
                _PurchaseLine.Reset();
                _PurchaseLine.LockTable();
                _PurchaseLine.Get(_KorberRcptEntry."Document Type",_KorberRcptEntry."Document No.",_KorberRcptEntry."Document Line No.");
                if _PurchaseLine."Qty. per Unit of Measure" = 0 then
                    Error(_Text000Err);
                /* qtys per UOM always base according to Erik - scenario tested Mon 24 Oct 2022
                **   concall re [RENT] SOW11 Körber Edge WMS Integration -- Session 1: End to End workshop for UAT/ WMS - Paola Montgomery
                _PurchaseLine.Validate("Qty. to Receive",_KorberRcptEntry.Quantity / _PurchaseLine."Qty. per Unit of Measure");
                if KorberSetup."Post Invoice for Inb. Rcpts." then
                    _PurchaseLine.Validate("Qty. to Invoice",_KorberRcptEntry.Quantity / _PurchaseLine."Qty. per Unit of Measure");
                */
                _PurchaseLine.Validate("Qty. to Receive",_KorberRcptEntry."Quantity (Base)" / _PurchaseLine."Qty. per Unit of Measure");
                if KorberSetup."Post Invoice for Inb. Rcpts." then
                    _PurchaseLine.Validate("Qty. to Invoice",_KorberRcptEntry."Quantity (Base)" / _PurchaseLine."Qty. per Unit of Measure");
                _PurchaseLine.Modify(true);
            until _KorberRcptEntry.Next() = 0;
        // release lock
        _PurchaseLine.Reset();
        Clear(_PurchaseLine);
        // release document
        WriteDiagText(StrSubstNo(_Text099Lbl,'preparing to release'));
        Clear(_PurchaseHeader);
        _PurchaseHeader.SetHideValidationDialog(true);
        _PurchaseHeader.LockTable();
        _PurchaseHeader.Get(_KorberRcptEntry."Document Type",_KorberRcptEntry."Document No.");
        _ReleasePurchaseDoc.Run(_PurchaseHeader);
        // post document
        WriteDiagText(StrSubstNo(_Text099Lbl,'preparing to post'));
        if KorberSetup."Post Receipt" then
            _PurchPost.Run(_PurchaseHeader);
        // force a re-transmit of remaining quantities to Korber Edge
        // Override := true;
        // OnAfterReleasePurchaseDoc(_PurchaseHeader,false,false);
        // release lock
        _PurchaseHeader.Reset();
        Clear(_PurchaseHeader);
        WriteDiagText(StrSubstNo(_Text099Lbl,'end'));
    end;

    local procedure ProcessEntrySales(var _KorberRcptEntry: Record "ARC Korber Rcpt. Entry")
    var
        _SalesHeader: Record "Sales Header";
        _SalesLine: Record "Sales Line";
        _ReleaseSalesDoc: Codeunit "Release Sales Document";
        _SalesPost: Codeunit "Sales-Post";
        _Text000Err: Label 'Qty. per Unit of Measure must NOT be zero';
        _Text099Lbl: Label 'Method ProcessEntry(): %1';
    begin
        WriteDiagText(StrSubstNo(_Text099Lbl,'begin'));
        WriteDiagText(StrSubstNo(_Text099Lbl,'preparing to reopen'));
        _SalesHeader.SetHideValidationDialog(true);
        _SalesHeader.LockTable();
        _SalesHeader.Get(_KorberRcptEntry."Document Type",_KorberRcptEntry."Document No.");
        _ReleaseSalesDoc.Reopen(_SalesHeader);
        _SalesHeader.Validate("Posting Date",Today());
        _SalesHeader.Receive := KorberSetup."Post Receipt";
        _SalesHeader.Invoice := KorberSetup."Post Invoice for Inb. Rcpts.";
        _SalesHeader.Modify(true);
        _SalesHeader.Reset();
        // prepare for partial rcpts; initialize return qty. to receive and qty. to invoice to zero for all lines
        WriteDiagText(StrSubstNo(_Text099Lbl,'preparing to reset ReturnQtyToRecv, QtyToInvc to zero for all lines'));
        _SalesLine.SetRange("Document Type",_KorberRcptEntry."Document Type");
        _SalesLine.SetRange("Document No.",_KorberRcptEntry."Document No.");
        _SalesLine.SetFilter("Outstanding Qty. (Base)",'<>0');
        if _SalesLine.FindSet(true) then
            repeat
                _SalesLine.Validate("Return Qty. to Receive",0);
                _SalesLine.Validate("Qty. to Invoice",0);
                _SalesLine.Modify(true);
            until _SalesLine.Next() = 0;
        // set qtys to receive [and invoice]
        WriteDiagText(StrSubstNo(_Text099Lbl,'preparing to set ReturnQtyToRecv, QtyToInvc'));
        if _KorberRcptEntry.FindSet(false) then
            repeat
                Clear(_SalesLine);
                _SalesLine.Reset();
                _SalesLine.LockTable();
                _SalesLine.Get(_KorberRcptEntry."Document Type",_KorberRcptEntry."Document No.",_KorberRcptEntry."Document Line No.");
                // according to Korber and Rentokil-NA/Target teams, QuantityReceived will always be in the item base unit of measure
                if _SalesLine."Qty. per Unit of Measure" = 0 then
                    Error(_Text000Err);
                /* qtys per UOM always base according to Erik - scenario tested Mon 24 Oct 2022
                **   concall re [RENT] SOW11 Körber Edge WMS Integration -- Session 1: End to End workshop for UAT/ WMS - Paola Montgomery
                _SalesLine.Validate("Return Qty. to Receive",_KorberRcptEntry.Quantity / _SalesLine."Qty. per Unit of Measure");
                if KorberSetup."Post Invoice for Inb. Rcpts." then
                    _SalesLine.Validate("Qty. to Invoice",_KorberRcptEntry.Quantity / _SalesLine."Qty. per Unit of Measure");
                */
                _SalesLine.Validate("Return Qty. to Receive",_KorberRcptEntry."Quantity (Base)" / _SalesLine."Qty. per Unit of Measure");
                if KorberSetup."Post Invoice for Inb. Rcpts." then
                    _SalesLine.Validate("Qty. to Invoice",_KorberRcptEntry."Quantity (Base)" / _SalesLine."Qty. per Unit of Measure");
                _SalesLine.Modify(true);
            until _KorberRcptEntry.Next() = 0;
        // release lock
        _SalesLine.Reset();
        Clear(_SalesLine);
        // release document
        WriteDiagText(StrSubstNo(_Text099Lbl,'preparing to release'));
        Clear(_SalesHeader);
        _SalesHeader.SetHideValidationDialog(true);
        _SalesHeader.LockTable();
        _SalesHeader.Get(_KorberRcptEntry."Document Type",_KorberRcptEntry."Document No.");
        _ReleaseSalesDoc.Run(_SalesHeader);
        // post document
        WriteDiagText(StrSubstNo(_Text099Lbl,'preparing to post'));
        if KorberSetup."Post Receipt" then
            _SalesPost.Run(_SalesHeader);
        _SalesHeader.Reset();
        Clear(_SalesHeader);
        WriteDiagText(StrSubstNo(_Text099Lbl,'end'));
    end;

    local procedure ProcessEntryTransfers(var _KorberRcptEntry: Record "ARC Korber Rcpt. Entry")
    var
        _TransferHeader: Record "Transfer Header";
        _TransferLine: Record "Transfer Line";
        _TransferPost: Codeunit "TransferOrder-Post Receipt";
        _TransferRelease: Codeunit "Release Transfer Document";
        _Text000Err: Label 'Qty. per Unit of Measure must NOT be zero: line %1, item %2';
        _Text001Lbl: Label 'Transfer Line Filters: %1';
        _Text002Lbl: Label 'Found Transfer Line No. %1 with Item %2, Derived-from Line No. %3, and Outstanding Qty. (Base) %4';
        _Text099Lbl: Label 'Method ProcessEntry(): %1';
    begin
        WriteDiagText(StrSubstNo(_Text099Lbl,'begin'));
        WriteDiagText(StrSubstNo(_Text099Lbl,'preparing to reopen and set posting date to Today()'));
        _TransferHeader.SetHideValidationDialog(true);
        _TransferHeader.LockTable();
        _TransferHeader.Get(_KorberRcptEntry."Document No.");
        _TransferRelease.Reopen(_TransferHeader);
        _TransferHeader.Validate("Posting Date",Today());
        _TransferHeader.Modify(true);
        _TransferHeader.Reset();
        // prepare for partial Rcpts; initialize qty. to receive to zero for all lines
        /*   commented out Fri 11 Nov 2022 - if validating Qty to Receive:
        **     on the rec where Derived-from Line No. is zero, results in error, Base Qty to Receive must be zero
        **     on the rec where Derived-from Line no. is not zero, results in error, No items are currently in Transit
        **   so, skip
        WriteDiagText(StrSubstNo(_Text099Lbl,'preparing to reset QtyToRecv to zero for all lines'));
        _TransferLine.SetRange("Document No.",_TransferHeader."No.");
        _TransferLine.FindSet(true);
        repeat
            _TransferLine.Validate("Qty. to Receive",0);
            _TransferLine.Modify(true);
        until _TransferLine.Next() = 0;
        */
        // set qtys to receive
        /*   commented out Fri 11 Nov 2022 - if validating Qty to Receive:
        **     on the rec where Derived-from Line No. is zero, results in error, Base Qty to Receive must be zero
        **     on the rec where Derived-from Line no. is not zero, results in error, No items are currently in Transit
        **   so, skip
        WriteDiagText(StrSubstNo(_Text099Lbl,'preparing to set QtyToRecv for all lines'));
        if _KorberRcptEntry.FindSet(false) then
            repeat
                Clear(_TransferLine);
                _TransferLine.Reset();
                _TransferLine.LockTable();
                // reworked Tue 8 Nov 2022 - must set QtyToRecv on derived lines
                //_TransferLine.Get(_KorberRcptEntry."Document No.",_KorberRcptEntry."Document Line No.");
                _TransferLine.SetRange("Document No.",_KorberRcptEntry."Document No.");
                _TransferLine.SetRange("Derived From Line No.",_KorberRcptEntry."Document Line No.");
                WriteDiagText(StrSubstNo(_Text099Lbl,StrSubstNo(_Text001Lbl,_TransferLine.GetFilters())));
                _TransferLine.FindFirst();
                WriteDiagText(StrSubstNo(_Text099Lbl,StrSubstNo(_Text002Lbl,_TransferLine."Line No.",_TransferLine."Item No.",
                    _TransferLine."Derived From Line No.",_TransferLine."Outstanding Qty. (Base)")));
                if _TransferLine."Qty. per Unit of Measure" = 0 then
                    Error(_Text000Err,_TransferLine."Line No.",_TransferLine."Item No.");
                /* qtys per UOM always base according to Erik - scenario tested Mon 24 Oct 2022
                **   concall re [RENT] SOW11 Körber Edge WMS Integration -- Session 1: End to End workshop for UAT/ WMS - Paola Montgomery
                _TransferLine.Validate("Qty. to Receive",_KorberRcptEntry.Quantity / _TransferLine."Qty. per Unit of Measure");
                **
                _TransferLine.Validate("Qty. to Receive",_KorberRcptEntry."Quantity (Base)" / _TransferLine."Qty. per Unit of Measure");
                _TransferLine.Modify(true);
            until _KorberRcptEntry.Next() = 0;
        _TransferLine.Reset();
        Clear(_TransferLine);
        */
        // release
        WriteDiagText(StrSubstNo(_Text099Lbl,'preparing to release'));
        Clear(_TransferHeader);
        _TransferHeader.Reset();
        _TransferHeader.LockTable();
        _TransferHeader.Get(_KorberRcptEntry."Document No.");
        _TransferRelease.Run(_TransferHeader);
        _TransferHeader.Modify(true);
        // post
        WriteDiagText(StrSubstNo(_Text099Lbl,'preparing to post (if Post Receipt is yes in Korber Setup)'));
        if KorberSetup."Post Receipt" then
            _TransferPost.Run(_TransferHeader);
        _TransferHeader.Reset();
        Clear(_TransferHeader);
        WriteDiagText(StrSubstNo(_Text099Lbl,'end'));
    end;

    procedure ResetEntry(var _KorberRcptEntry: Record "ARC Korber Rcpt. Entry")
    var
        _KorberRcptEntry2: Record "ARC Korber Rcpt. Entry";
        _KorberRcptEntry3: Record "ARC Korber Rcpt. Entry";
        _choice: Integer;
        _count: Integer;
        _SetOfFields: Text;
        _Text001Msg: Label '*** RESET *** Korber Receipt Entry No. %1, Item %2, set of fields: %3';
        _Text002Qst: Label 'Analyzed,Sent to WMS,Processed,Mark all sent as failed';
        _Text003Qst: Label 'Record count: %1; choose which set of fields to reset';
        _Text004Lbl: Label 'Manually marked as sent failed by user %1';
    begin
        Initialize();
        _count := _KorberRcptEntry.Count();
        _choice := StrMenu(_Text002Qst,0,StrSubstNo(_Text003Qst,_count));
        if _choice = 0 then
            exit;
        if _choice = 4 then begin
            _KorberRcptEntry3 := _KorberRcptEntry;
            Clear(_KorberRcptEntry);
            _KorberRcptEntry.Reset();
            _KorberRcptEntry.SetCurrentKey("Send to WMS","Sent to WMS","Document Area","Document Type","Document No.");
            _KorberRcptEntry.SetRange("Send to WMS",true);
            _KorberRcptEntry.SetRange("Sent to WMS",1);
            _KorberRcptEntry.SetRange("Document Area",_KorberRcptEntry3."Document Area");
            _KorberRcptEntry.SetRange("Document Type",_KorberRcptEntry3."Document Type");
            _KorberRcptEntry.SetRange("Document No.",_KorberRcptEntry3."Document No.");
        end;
        if _KorberRcptEntry.FindSet(false) then
            repeat
                Clear(_KorberRcptEntry2);
                _KorberRcptEntry2.Reset();
                _KorberRcptEntry2.LockTable();
                _KorberRcptEntry2.Get(_KorberRcptEntry."Entry No.");
                case _choice of
                    1:
                        begin
                            _KorberRcptEntry2.Analyzed := 0;
                            _KorberRcptEntry2."Analyzed at DateTime" := 0DT;
                            _KorberRcptEntry2."Analyzed Duration" := 0;
                            _KorberRcptEntry2."Analyzed Error Text" := '';
                            _KorberRcptEntry2."Analyzed No. of Attempts" := 0;
                            _SetOfFields := CopyStr('Analyzed',1,MaxStrLen(_SetOfFields));
                        end;
                    2:
                        begin
                            _KorberRcptEntry2."Sent to WMS" := 0;
                            _KorberRcptEntry2."Sent to WMS at DateTime" := 0DT;
                            _KorberRcptEntry2."Sent to WMS Data Entry No." := 0;
                            _KorberRcptEntry2."Sent to WMS Duration" := 0;
                            _KorberRcptEntry2."Sent to WMS Error Text" := '';
                            _KorberRcptEntry2."Sent to WMS No. of Attempts" := 0;
                            _SetOfFields := CopyStr('Sent to WMS',1,MaxStrLen(_SetOfFields));
                        end;
                    3:
                        begin
                            _KorberRcptEntry2.Processed := 0;
                            _KorberRcptEntry2."Processed at DateTime" := 0DT;
                            _KorberRcptEntry2."Processed Data Entry No." := 0;
                            _KorberRcptEntry2."Processed Duration" := 0;
                            _KorberRcptEntry2."Processed Error Text" := '';
                            _KorberRcptEntry2."Processed No. of Attempts" := 0;
                            _SetOfFields := CopyStr('Processed',1,MaxStrLen(_SetOfFields));
                        end;
                    4:
                        begin
                            _KorberRcptEntry2."Sent to WMS" := -1;
                            _KorberRcptEntry2."Sent to WMS Error Text" := CopyStr(StrSubstNo(_Text004Lbl,UserId()),1,MaxStrLen(_KorberRcptEntry2."Sent to WMS Error Text"));
                            _SetOfFields := CopyStr('Sent to WMS',1,MaxStrLen(_SetOfFields));
                        end;
                end;
                _KorberRcptEntry2.Modify();
                WriteLog(KorberSetup."Log Level"::Normal,_KorberRcptEntry."Entry No.",0,
                    StrSubstNo(_Text001Msg,_KorberRcptEntry."Entry No.",_KorberRcptEntry."Item No.",_SetOfFields),'');
            until _KorberRcptEntry.Next() = 0;
        _KorberRcptEntry.ClearMarks();
        _KorberRcptEntry.Reset();
        if _KorberRcptEntry.FindLast() then;
        _KorberRcptEntry.Ascending(false);
    end;

    local procedure SendEntries()
    var
        _KorberRcptEntry: Record "ARC Korber Rcpt. Entry";
        _KorberRcptEntry2: Record "ARC Korber Rcpt. Entry";
        _KorberRcptMgt: Codeunit "ARC KorberRcptMgt";
        _result: Boolean;
        _entriesProcessed: Integer;
        _NoOfAttempts: Integer;
        _docNo: Text;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Msg: Label 'KorberRcptMgt, document groups transmitted: %1';
    begin
        _KorberRcptEntry.SetCurrentKey("Send to WMS","Sent to WMS");
        _KorberRcptEntry.SetRange("Send to WMS",true);
        _KorberRcptEntry.SetRange("Sent to WMS",0);
        if _KorberRcptEntry.FindSet(false) then
            repeat
                if _docNo <> _KorberRcptEntry."Document No." then begin
                    _docNo := CopyStr(_KorberRcptEntry."Document No.",1,MaxStrLen(_docNo));
                    _timeBegin := Time();
                    Clear(_KorberRcptMgt);
                    _KorberRcptMgt.SetEntryNoToSend(_KorberRcptEntry."Entry No.");
                    Commit();
                    _result := _KorberRcptMgt.Run();
                    if not _result then begin
                        _NoOfAttempts += 1;
                        Clear(_KorberRcptEntry2);
                        _KorberRcptEntry2.Reset();
                        _KorberRcptEntry2.SetCurrentKey("Send to WMS","Sent to WMS","Document Area","Document Type","Document No.");
                        _KorberRcptEntry2.SetRange("Send to WMS",true);
                        _KorberRcptEntry2.SetRange("Sent to WMS",0);
                        _KorberRcptEntry2.SetRange("Document Area",_KorberRcptEntry."Document Area");
                        _KorberRcptEntry2.SetRange("Document Type",_KorberRcptEntry."Document Type");
                        _KorberRcptEntry2.SetRange("Document No.",_KorberRcptEntry."Document No.");
                        _KorberRcptEntry2.FindSet(true);
                        _timeEnd := Time();
                        _KorberRcptEntry2.ModifyAll("Sent to WMS at DateTime",CreateDateTime(Today(),_timeEnd));
                        _KorberRcptEntry2.ModifyAll("Sent to WMS Duration",_timeEnd - _timeBegin);
                        _KorberRcptEntry2.ModifyAll("Sent to WMS No. of Attempts",_NoOfAttempts);
                        _KorberRcptEntry2.ModifyAll("Sent to WMS Error Text",CopyStr(GetLastErrorText(),1,MaxStrLen(_KorberRcptEntry2."Sent to WMS Error Text")));
                        if _NoOfAttempts >= KorberSetup."Maximum No. of Attempts" then
                            _KorberRcptEntry2.ModifyAll("Sent to WMS",-1);
                    end;
                    _entriesProcessed += 1;
                end;
            until (_KorberRcptEntry.Next() = 0) or (_entriesProcessed >= KorberSetup."Process Queue No. Entries");
        if _entriesProcessed > 0 then
            WriteLog(KorberSetup."Log Level"::Verbose,0,0,StrSubstNo(_Text000Msg,_entriesProcessed),'');
    end;

    local procedure SendEntry()
    var
        _KorberRcptEntry: Record "ARC Korber Rcpt. Entry";
        _KorberRcptEntry2: Record "ARC Korber Rcpt. Entry";
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
        _KorberRcptXmlport: XmlPort "ARC KorberRcpt";
        _Text000Lbl: Label 'Rcpt. Entry %1, doc. %2, filename %3, outbound to WMS';
        _Text001Err: Label 'No XML was generated using XmlPort "ARC KorberRcpt"';
        _Text002Err: Label 'Full outbound filename is empty, check Korber Setup; source filename: %1';
    begin
        _timeBegin := Time();
        // create the temporary recordset containing the sales lines
        _tempBuf.DeleteAll();
        _KorberRcptEntry.Get(EntryNoToSend);
        _NoOfAttempts := _KorberRcptEntry."Sent to WMS No. of Attempts";
        _KorberRcptEntry.SetCurrentKey("Send to WMS","Sent to WMS","Document Area","Document Type","Document No.");
        _KorberRcptEntry.SetRange("Send to WMS",true);
        _KorberRcptEntry.SetRange("Sent to WMS",0);
        _KorberRcptEntry.SetRange("Document Area",_KorberRcptEntry."Document Area");
        _KorberRcptEntry.SetRange("Document Type",_KorberRcptEntry."Document Type");
        _KorberRcptEntry.SetRange("Document No.",_KorberRcptEntry."Document No.");
        case _KorberRcptEntry."Document Area" of
            _KorberRcptEntry."Document Area"::Purchases: SendEntryDocLinesPurchases(_KorberRcptEntry,_tempBuf,_PurchaseHeader);
            _KorberRcptEntry."Document Area"::Sales: SendEntryDocLinesSales(_KorberRcptEntry,_tempBuf,_SalesHeader);
            _KorberRcptEntry."Document Area"::Transfers: SendEntryDocLinesTransfers(_KorberRcptEntry,_tempBuf,_TransferHeader);
        end;
        // prep the tempBlob to store the Xml
        _tempBlob.DeleteAll();
        _tempBlob.Init();
        _tempBlob.Blob.CreateOutStream(_os);
        // call the Xmlport
        _KorberRcptXmlport.LoadRecordset(_tempBuf);
        case _KorberRcptEntry."Document Area" of
            _KorberRcptEntry."Document Area"::Purchases: _KorberRcptXmlport.SetPurchaseOrder(_PurchaseHeader);
            _KorberRcptEntry."Document Area"::Sales: _KorberRcptXmlport.SetSalesOrder(_SalesHeader);
            _KorberRcptEntry."Document Area"::Transfers: _KorberRcptXmlport.SetTransferOrder(_TransferHeader);
        end;
        _KorberRcptXmlport.SetDestination(_os);
        _KorberRcptXmlport.Export();
        // store the Xml generated
        _tempBlob.Insert();
        _tempBlob.CalcFields(Blob);
        // build text strings
        _filename := CopyStr(_KorberRcptXmlport.GetContainerBatchRefHeader(),1,MaxStrLen(_filename));
        _fullFilename := CopyStr(KorberMgt.GetFullOutboundPathInclFilename(_filename),1,MaxStrLen(_fullFilename));
        _desc := CopyStr(StrSubstNo(_Text000Lbl,_KorberRcptEntry."Entry No.",_KorberRcptEntry."Document No.",_filename),1,MaxStrLen(_desc));
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
        Clear(_KorberRcptEntry2);
        _KorberRcptEntry2.Reset();
        _KorberRcptEntry2.SetCurrentKey("Send to WMS","Sent to WMS","Document Area","Document Type","Document No.");
        _KorberRcptEntry2.SetRange("Send to WMS",true);
        _KorberRcptEntry2.SetRange("Sent to WMS",0);
        _KorberRcptEntry2.SetRange("Document Area",_KorberRcptEntry."Document Area");
        _KorberRcptEntry2.SetRange("Document Type",_KorberRcptEntry."Document Type");
        _KorberRcptEntry2.SetRange("Document No.",_KorberRcptEntry."Document No.");
        _KorberRcptEntry2.FindSet(true);
        _timeEnd := Time();
        _KorberRcptEntry2.ModifyAll("Sent to WMS at DateTime",CreateDateTime(Today(),_timeEnd));
        _KorberRcptEntry2.ModifyAll("Sent to WMS Duration",_timeEnd - _timeBegin);
        _KorberRcptEntry2.ModifyAll("Sent to WMS No. of Attempts",_NoOfAttempts);
        _KorberRcptEntry2.ModifyAll("Sent to WMS Data Entry No.",_DataMgt.NewDataEntryUsingTempBlob('KORRCPMGT',_desc,_tempBlob));
        _KorberRcptEntry2.ModifyAll("Sent to WMS",1);
    end;

    local procedure SendEntryDocLinesPurchases(
        var _KorberRcptEntry: Record "ARC Korber Rcpt. Entry"; 
        var _tempBuf: Record "ARC Buffer" temporary;
        var _PurchaseHeader: Record "Purchase Header")
    var
        _PurchaseLine: Record "Purchase Line";
        _entryNo: BigInteger;
        _expectedRcptDate: Date;
    begin
        if _KorberRcptEntry.FindSet(false) then
            repeat
                if _PurchaseHeader."No." = '' then begin
                    _PurchaseHeader.Get(_KorberRcptEntry."Document Type",_KorberRcptEntry."Document No.");
                    _expectedRcptDate := GetEarliestExpectedRcptDate(_PurchaseHeader);
                end;
                if not _PurchaseLine.Get(_KorberRcptEntry."Document Type",_KorberRcptEntry."Document No.",_KorberRcptEntry."Document Line No.") then begin
                    WriteDiagText(StrSubstNo('failed to retrieve purchase line no %1',_KorberRcptEntry."Document Line No."));
                    WriteLog(KorberSetup."Log Level"::Error,_KorberRcptEntry."Entry No.",0,'',StrSubstNo('failed to retrieve purchase line no %1',_KorberRcptEntry."Document Line No."));
                end else begin
                    _entryNo += 1;
                    _tempBuf."Entry No." := _entryNo;
                    _tempBuf."Code 01" := CopyStr(KorberMgt.GetStripText(_KorberRcptEntry."Item No."),1,MaxStrLen(_tempBuf."Code 01"));
                    _tempBuf."Code 02" := CopyStr(KorberMgt.GetStripText(_KorberRcptEntry."Location Code"),1,MaxStrLen(_tempBuf."Code 02"));
                    _tempBuf."Code 04" := CopyStr(KorberMgt.GetStripText(_KorberRcptEntry."Unit of Measure Code"),1,MaxStrLen(_tempBuf."Code 04"));
                    _tempBuf."Decimal 01" := _KorberRcptEntry."Quantity (Base)";
                    _tempBuf."Decimal 02" := _PurchaseLine."Outstanding Qty. (Base)";
                    _tempBuf."Integer 01" := _KorberRcptEntry."Document Line No.";
                    _tempBuf."BigInteger 01" := _KorberRcptEntry."Entry No.";
                    _tempBuf."Text 01" := CopyStr(KorberMgt.GetStripText(_PurchaseLine.Description),1,MaxStrLen(_tempBuf."Text 01"));
                    _tempBuf."Date 01" := _expectedRcptDate;
                    _tempBuf.Insert();
                end;
            until _KorberRcptEntry.Next() = 0;
    end;

    local procedure SendEntryDocLinesSales(
        var _KorberRcptEntry: Record "ARC Korber Rcpt. Entry"; 
        var _tempBuf: Record "ARC Buffer" temporary;
        var _SalesHeader: Record "Sales Header")
    var
        _SalesLine: Record "Sales Line";
        _entryNo: BigInteger;
    begin
        if _KorberRcptEntry.FindSet(false) then
            repeat
                if _SalesHeader."No." = '' then
                    _SalesHeader.Get(_KorberRcptEntry."Document Type",_KorberRcptEntry."Document No.");
                if not _SalesLine.Get(_KorberRcptEntry."Document Type",_KorberRcptEntry."Document No.",_KorberRcptEntry."Document Line No.") then begin
                    WriteDiagText(StrSubstNo('failed to retrieve sales line no %1',_KorberRcptEntry."Document Line No."));
                    WriteLog(KorberSetup."Log Level"::Error,_KorberRcptEntry."Entry No.",0,'',StrSubstNo('failed to retrieve sales line no %1',_KorberRcptEntry."Document Line No."));
                end else begin
                    _entryNo += 1;
                    _tempBuf."Entry No." := _entryNo;
                    _tempBuf."Code 01" := CopyStr(KorberMgt.GetStripText(_KorberRcptEntry."Item No."),1,MaxStrLen(_tempBuf."Code 01"));
                    _tempBuf."Code 02" := CopyStr(KorberMgt.GetStripText(_KorberRcptEntry."Location Code"),1,MaxStrLen(_tempBuf."Code 02"));
                    _tempBuf."Code 04" := CopyStr(KorberMgt.GetStripText(_KorberRcptEntry."Unit of Measure Code"),1,MaxStrLen(_tempBuf."Code 04"));
                    _tempBuf."Decimal 01" := _KorberRcptEntry."Quantity (Base)";
                    _tempBuf."Decimal 02" := _SalesLine."Outstanding Qty. (Base)";
                    _tempBuf."Integer 01" := _KorberRcptEntry."Document Line No.";
                    _tempBuf."BigInteger 01" := _KorberRcptEntry."Entry No.";
                    _tempBuf."Text 01" := CopyStr(KorberMgt.GetStripText(_SalesLine.Description),1,MaxStrLen(_tempBuf."Text 01"));
                    //_tempBuf."Date 01" := _PurchaseLine."Expected Receipt Date";
                    _tempBuf."Date 01" := Today();  // see email sent to Erik Holmberg Thu 1 Sep 2022 at 1242pm Eastern
                    _tempBuf.Insert();
                end;
            until _KorberRcptEntry.Next() = 0;
    end;

    local procedure SendEntryDocLinesTransfers(
        var _KorberRcptEntry: Record "ARC Korber Rcpt. Entry"; 
        var _tempBuf: Record "ARC Buffer" temporary;
        var _TransferHeader: Record "Transfer Header")
    var
        _TransferLine: Record "Transfer Line";
        _entryNo: BigInteger;
    begin
        if _KorberRcptEntry.FindSet(false) then
            repeat
                if _TransferHeader."No." = '' then
                    _TransferHeader.Get(_KorberRcptEntry."Document No.");
                if not _TransferLine.Get(_KorberRcptEntry."Document No.",_KorberRcptEntry."Document Line No.") then begin
                    WriteDiagText(StrSubstNo('failed to retrieve transfer line no %1',_KorberRcptEntry."Document Line No."));
                    WriteLog(KorberSetup."Log Level"::Error,_KorberRcptEntry."Entry No.",0,'',StrSubstNo('failed to retrieve transfer line no %1',_KorberRcptEntry."Document Line No."));
                end else begin
                    _entryNo += 1;
                    _tempBuf."Entry No." := _entryNo;
                    _tempBuf."Code 01" := CopyStr(KorberMgt.GetStripText(_KorberRcptEntry."Item No."),1,MaxStrLen(_tempBuf."Code 01"));
                    _tempBuf."Code 02" := CopyStr(KorberMgt.GetStripText(_KorberRcptEntry."Location Code"),1,MaxStrLen(_tempBuf."Code 02"));
                    _tempBuf."Code 04" := CopyStr(KorberMgt.GetStripText(_KorberRcptEntry."Unit of Measure Code"),1,MaxStrLen(_tempBuf."Code 04"));
                    _tempBuf."Decimal 01" := _KorberRcptEntry."Quantity (Base)";
                    _tempBuf."Decimal 02" := _TransferLine."Quantity (Base)" - _TransferLine."Qty. Received (Base)";
                    _tempBuf."Integer 01" := _KorberRcptEntry."Document Line No.";
                    _tempBuf."BigInteger 01" := _KorberRcptEntry."Entry No.";
                    _tempBuf."Text 01" := CopyStr(KorberMgt.GetStripText(_TransferLine.Description),1,MaxStrLen(_tempBuf."Text 01"));
                    _tempBuf."Date 01" := _TransferHeader."Posting Date";
                    if _tempBuf."Date 01" < Today() then
                        _tempBuf."Date 01" := Today();
                    _tempBuf."Date 01" := CalcDate('+5D',_tempBuf."Date 01");  // concall Tue 20 Sep 2022 at 9am - [RENT] SOW11 Körber Edge WMS Integration -- Working Discussion #8 ( Outbound Start) - Erica Miller
                    _tempBuf.Insert();
                end;
            until _KorberRcptEntry.Next() = 0;
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

    procedure ShowDocument(_KorberRcptEntry: Record "ARC Korber Rcpt. Entry")
    var
        _PurchaseHeader: Record "Purchase Header";
        _PurchRcptHeader: Record "Purch. Rcpt. Header";
        _SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        _SalesHeader: Record "Sales Header";
        _TransferHeader: Record "Transfer Header";
        _TransferRcptHeader: Record "Transfer Receipt Header";
    begin
        case _KorberRcptEntry."Document Area" of
            _KorberRcptEntry."Document Area"::Purchases:
                begin
                    if _PurchaseHeader.Get(_KorberRcptEntry."Document Type",_KorberRcptEntry."Document No.") then begin
                        _PurchaseHeader.SetRecFilter();
                        Page.Run(Page::"Purchase Order",_PurchaseHeader);
                        exit;
                    end;
                    _PurchRcptHeader.SetCurrentKey("Order No.");
                    _PurchRcptHeader.SetRange("Order No.",_KorberRcptEntry."Document No.");
                    Page.Run(Page::"Posted Purchase Receipts",_PurchRcptHeader);
                end;
            _KorberRcptEntry."Document Area"::Sales:
                begin
                    if _SalesHeader.Get(_KorberRcptEntry."Document Type",_KorberRcptEntry."Document No.") then begin
                        _SalesHeader.SetRecFilter();
                        Page.Run(Page::"Sales Return Order",_SalesHeader);
                        exit;
                    end;
                    _SalesCrMemoHeader.SetCurrentKey("Pre-Assigned No.");
                    _SalesCrMemoHeader.SetRange("Pre-Assigned No.",_KorberRcptEntry."Document No.");
                    Page.Run(Page::"Posted Sales Credit Memos",_SalesCrMemoHeader);
                end;
            _KorberRcptEntry."Document Area"::Transfers:
                begin
                    if _TransferHeader.Get(_KorberRcptEntry."Document No.") then begin
                        _TransferHeader.SetRecFilter();
                        Page.Run(Page::"Transfer Order",_TransferHeader);
                        exit;
                    end;
                    _TransferRcptHeader.SetRange("Transfer Order No.",_KorberRcptEntry."Document No.");
                    Page.Run(Page::"Posted Transfer Receipts",_TransferRcptHeader);
                end;
        end;
    end;

    procedure ShowEntity(_KorberRcptEntry: Record "ARC Korber Rcpt. Entry")
    var
        _Customer: Record Customer;
        _Vendor: Record Vendor;
    begin
        _KorberRcptEntry.TestField("Sell-to/Buy-from Entity No.");
        case _KorberRcptEntry."Document Area" of
            _KorberRcptEntry."Document Area"::Purchases:
                begin
                    _Vendor.Get(_KorberRcptEntry."Sell-to/Buy-from Entity No.");
                    Page.Run(Page::"Vendor Card",_Vendor);
                end;
            _KorberRcptEntry."Document Area"::Sales:
                begin
                    _Customer.Get(_KorberRcptEntry."Sell-to/Buy-from Entity No.");
                    Page.Run(Page::"Customer Card",_Customer);
                end;
            _KorberRcptEntry."Document Area"::Transfers:;
        end;
    end;

    procedure ShowImportEntry(_KorberRcptEntry: Record "ARC Korber Rcpt. Entry")
    var
        _ImportEntry: Record "ARC Korber Import Entry";
    begin
        _KorberRcptEntry.TestField("Import Entry No.");
        _ImportEntry.SetRange("Entry No.",_KorberRcptEntry."Import Entry No.");
        Page.Run(Page::"ARC Korber Import Entries",_ImportEntry);
    end;

    procedure ShowItem(_KorberRcptEntry: Record "ARC Korber Rcpt. Entry")
    var
        _Item: Record Item;
    begin
        _KorberRcptEntry.TestField("Item No.");
        _Item.Get(_KorberRcptEntry."Item No.");
        Page.Run(Page::"Item Card",_Item);
    end;

    procedure ShowLocation(_KorberRcptEntry: Record "ARC Korber Rcpt. Entry")
    var
        _Location: Record Location;
    begin
        _KorberRcptEntry.TestField("Location Code");
        _Location.Get(_KorberRcptEntry."Location Code");
        Page.Run(Page::"Location Card",_Location);
    end;

    procedure ShowRcptEntriesFromSales(_SalesHeader: Record "Sales Header")
    var
        _KorberRcptEntry: Record "ARC Korber Rcpt. Entry";
    begin
        _KorberRcptEntry.SetCurrentKey("Document Area","Document Type","Document No.");
        _KorberRcptEntry.SetRange("Document Area",_KorberRcptEntry."Document Area"::Sales);
        _KorberRcptEntry.SetRange("Document Type",_SalesHeader."Document Type");
        _KorberRcptEntry.SetRange("Document No.",_SalesHeader."No.");
        Page.Run(Page::"ARC Korber Rcpt. Entries",_KorberRcptEntry);
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
    begin
        KorberMgt.WriteLog(_logLevel,Codeunit::"ARC KorberRcptMgt",DiagLabel,_relatedEntryNo,_relatedDataEntryNo,_msg,_err);
    end;
}
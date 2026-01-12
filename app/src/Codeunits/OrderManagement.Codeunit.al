codeunit 50078 "ARC OrderManagement"
{
    Permissions = tabledata "ARC Event Log Entry" = ri,
                  tabledata "ARC Order Translation Entry" = rim,
                  tabledata "ARC RNA Setup" = r;

    trigger OnRun();
    begin
        Initialize();
        if EntryNoToAnalyze <> 0 then begin
            AnalyzeEntry();
            exit;
        end;
        if EntryNoToRelease <> 0 then begin
            ReleaseEntry();
            exit;
        end;
        AnalyzeEntries();
        ReleaseEntries();
    end;

    var
        KorberSetup: Record "ARC Korber Setup";
        RNASetup: Record "ARC RNA Setup";
        EntryNoToAnalyze: BigInteger;
        EntryNoToRelease: BigInteger;
        Initialized: Boolean;
        CRNL: Text;
        EventLogLabel: Label 'ORDERMGT';

    local procedure AnalyzeEntries()
    var
        _OrderTranslationEntry: Record "ARC Order Translation Entry";
        _OrderTranslationEntry2: Record "ARC Order Translation Entry";
        _OrderMgt: Codeunit "ARC OrderManagement";
        _result: Boolean;
        _entriesProcessed: Integer;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Msg: Label 'Entries processed: %1';
    begin
        _timeBegin := Time();
        if not RNASetup."Order Management Active" then
            exit;
        _OrderTranslationEntry.SetCurrentKey(Analyze);
        _OrderTranslationEntry.SetRange(Analyze,true);
        _OrderTranslationEntry.SetRange(Analyzed,0);
        if _OrderTranslationEntry.FindSet(false) then
            repeat
                Clear(_OrderMgt);
                _OrderMgt.SetEntryNoToAnalyze(_OrderTranslationEntry."Entry No.");
                Commit();
                _result := _OrderMgt.Run();
                if not _result then begin
                    _timeEnd := Time();
                    Clear(_OrderTranslationEntry2);
                    _OrderTranslationEntry2.Reset();
                    _OrderTranslationEntry2.LockTable();
                    if _OrderTranslationEntry2.Get(_OrderTranslationEntry."Entry No.") then begin
                        _OrderTranslationEntry2."Analyzed at DateTime" := CreateDateTime(Today(),_timeEnd);
                        _OrderTranslationEntry2."Analyzed Duration" := _timeEnd - _timeBegin;
                        _OrderTranslationEntry2."Analyzed Error Text" := CopyStr(GetLastErrorText(),1,MaxStrLen(_OrderTranslationEntry2."Analyzed Error Text"));
                        _OrderTranslationEntry2."Analyzed No. of Attempts" := _OrderTranslationEntry2."Analyzed No. of Attempts" + 1;
                        if _OrderTranslationEntry2."Analyzed No. of Attempts" > KorberSetup."Maximum No. of Attempts" then
                            _OrderTranslationEntry2.Analyzed := -1;
                        _OrderTranslationEntry2.Modify();
                    end;
                end;
                _entriesProcessed += 1;
            until (_OrderTranslationEntry.Next() = 0) or (_entriesProcessed >= KorberSetup."Process Queue No. Entries");
        if _entriesProcessed > 0 then
            WriteLog(RNASetup."Order Mgt. Log Level"::Verbose,0,0,StrSubstNo(_Text000Msg,_entriesProcessed),'');
    end;

    local procedure AnalyzeEntry()
    var
        _OrderTranslationEntry: Record "ARC Order Translation Entry";
        _OrderTranslationEntry2: Record "ARC Order Translation Entry";
        _SalesHeaderOrig: Record "Sales Header";
        _ArchiveMgt: Codeunit ArchiveManagement;
        _DataMgt: Codeunit "ARC DataMgt";
        _logText: BigText;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Lbl: Label 'Text recorded during analytical process';
    begin
        _timeBegin := Time();
        RNASetup.TestField("Order Translation No. Series");
        _OrderTranslationEntry.Get(EntryNoToAnalyze);
        _SalesHeaderOrig.Get(_OrderTranslationEntry."Document Type",_OrderTranslationEntry."Document No.");
        _SalesHeaderOrig.SetRecFilter();
        Split(_OrderTranslationEntry,_SalesHeaderOrig,_logText);
        _ArchiveMgt.ArchSalesDocumentNoConfirm(_SalesHeaderOrig);
        _SalesHeaderOrig.SetHideValidationDialog(true);
        _SalesHeaderOrig.Delete(true);
        _timeEnd := Time();
        _OrderTranslationEntry2.LockTable();
        _OrderTranslationEntry2.Get(_OrderTranslationEntry."Entry No.");
        _OrderTranslationEntry2."Analyzed at DateTime" := CreateDateTime(Today(),_timeEnd);
        _OrderTranslationEntry2."Analyzed Duration" := _timeEnd - _timeBegin;
        _OrderTranslationEntry2."Analyzed No. of Attempts" := _OrderTranslationEntry2."Analyzed No. of Attempts" + 1;
        _OrderTranslationEntry2."Analyzed Data Entry No." := _DataMgt.NewDataEntry(EventLogLabel,_Text000Lbl,_logText);
        _OrderTranslationEntry2.Analyzed := 1;
        _OrderTranslationEntry2.Modify();
    end;

    procedure ConfirmOrderMgtDisable() : Boolean
    var
        _Text000Qst: Label 'Disabling Order Management would cause the system to begin ignoring Agency and Location validation!  Are you ABSOLUTELY CERTAIN you want to disable Order Management?';
    begin
        if not GuiAllowed() then
            exit(false);
        exit(Confirm(_Text000Qst,false));
    end;

    local procedure eCommerceOrigin(
        SalesHeader: Record "Sales Header";
        var _logText: BigText): Boolean
    var
        SalesLine: Record "Sales Line";
        text000Lbl: Label 'Sales Line record contains eCommerce Entry No.: %1 %2 line %3, eCommerce Entry %4 (exit true)';
        text001Lbl: Label 'Sales Header %1, %2 ExtDocNo %3';
        text099Lbl: Label 'Method eCommerceOrigin(): %1';
    begin
        // credit card orders sourced by Adobe Commerce must not be split - email fr Jennifer Gunter dated Tue 23 Apr 2024 at 1430 Eastern
        _logText.AddText(StrSubstNo(text099Lbl,StrSubstNo(text001Lbl,SalesHeader."Document Type",SalesHeader."No.", SalesHeader."External Document No.")) + CRNL);
        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        SalesLine.SetFilter("ARC eCommerce Entry No.",'<>0');
        _logText.AddText(StrSubstNo(text099Lbl,'Sales Line Filters: ' + SalesLine.GetFilters()) + CRNL);
        if SalesLine.FindFirst() then begin
            _logText.AddText(StrSubstNo(text099Lbl,StrSubstNo(text000Lbl,SalesLine."Document Type",
                SalesLine."Document No.",SalesLine."Line No.",SalesLine."ARC eCommerce Entry No.")) + CRNL);
            exit(true);
        end else
            exit(false);
    end;

    local procedure existEFTTransForOrder(
        SalesHeader: Record "Sales Header";
        var _logText: BigText): Boolean
    var
        EFTTrans: Record "EFT Transaction -CL-";
        text001Lbl: Label 'Sales Header %1, %2 ExtDocNo %3';
        text099Lbl: Label 'Method existEFTTransForOrder(): %1';
    begin
        // credit card orders sourced by Adobe Commerce must not be split - email fr Jennifer Gunter dated Tue 23 Apr 2024 at 1430 Eastern
        _logText.AddText(StrSubstNo(text099Lbl,StrSubstNo(text001Lbl,SalesHeader."Document Type",SalesHeader."No.", SalesHeader."External Document No.")) + CRNL);
        EFTTrans.SetCurrentKey("Document Type","Document No.","Method Code");
        EFTTrans.SetRange("Document Type",EFTTrans."Document Type"::Order);
        EFTTrans.SetRange("Document No.",SalesHeader."No.");
        _logText.AddText(StrSubstNo(text099Lbl,'EFT Transaction Filters: ' + EFTTrans.GetFilters()) + CRNL);
        if EFTTrans.FindFirst() then begin
            _logText.AddText(StrSubstNo(text099Lbl,'EFT Transaction found (exit true)') + CRNL);
            exit(true);
        end else
            exit(false);
    end;

    procedure Initialize()
    var
        _KorberMgt: Codeunit "ARC KorberMgt";
    begin
        if Initialized then
            exit;
        CRNL := CopyStr(_KorberMgt.GetCRNL(),1,MaxStrLen(CRNL));
        Initialized := RNASetup.Get();
        if not KorberSetup.Get() then
            KorberSetup.Init();
    end;

    procedure InitializeOrderSourceForSalesHeader(var _SalesHeader: Record "Sales Header")
    var
        _OrderSource: Record "ARC Order Source";
    begin
        if _SalesHeader."ARC Order Source Code" <> '' then
            exit;
        _OrderSource.SetRange(Default,true);
        if not _OrderSource.FindFirst() then
            exit;
        _SalesHeader."ARC Order Source Code" := CopyStr(_OrderSource.Code,1,MaxStrLen(_SalesHeader."ARC Order Source Code"));
    end;

    procedure JobQueueEntryActive(_codeunitID: Integer) : Boolean
    var
        _JobQueueEntry: Record "Job Queue Entry";
    begin
        _JobQueueEntry.SetRange("Object Type to Run",_JobQueueEntry."Object Type to Run"::Codeunit);
        _JobQueueEntry.SetRange("Object ID to Run",_codeunitID);
        if not _JobQueueEntry.FindFirst() then
            exit(false);
        exit(_JobQueueEntry.Status <> _JobQueueEntry.Status::"On Hold");
    end;

    procedure NewSalesOrder()
    var
        _SalesHeader: Record "Sales Header";
        _SalesSetup: Record "Sales & Receivables Setup";
        _NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if not GuiAllowed() then
            exit;
        _SalesSetup.Get();
        _SalesSetup.TestField("Order Nos.");
        _SalesHeader."Document Type" := _SalesHeader."Document Type"::Order;
        _SalesHeader."No." := CopyStr(_NoSeriesMgt.GetNextNo(_SalesSetup."Order Nos.",WorkDate(),true),1,MaxStrLen(_SalesHeader."No."));
        _SalesHeader.Insert(true);
        _SalesHeader.SetRecFilter();
        Page.Run(Page::"Sales Order",_SalesHeader);
    end;

    procedure OnAfterReleaseSalesDoc(SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    var
        APLMgt: Codeunit "ARC APL Management";
        SalesHeader2: Record "Sales Header";
    begin
        APLMgt.EntryReviewPartTwoSales(SalesHeader,PreviewMode);
        If SalesHeader."ARC AR Hold" then begin 
            SalesHeader2.Get(SalesHeader."Document Type",SalesHeader."No.");
            SalesHeader2."ARC AR Hold" := false;
            SalesHeader2.Modify;
        end;
    end;

    procedure OnBeforeInsertSalesHeader(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        _NoSeries: Record "No. Series";
        _SalesSetup: Record "Sales & Receivables Setup";
        _Text000Err: Label 'Order Management is active in RNA Setup; Release Permitted must be No in No. Series %1';
    begin
        Initialize();
        if Rec."Document Type" <> Rec."Document Type"::Order then
            exit;
        if not RNASetup."Order Management Active" then
            exit;
        _SalesSetup.Get();
        _SalesSetup.TestField("Order Nos.");
        if Rec."No. Series" = '' then
            Rec."No. Series" := CopyStr(_SalesSetup."Order Nos.",1,MaxStrLen(Rec."No. Series"));
        _NoSeries.Get(Rec."No. Series");
        // sales orders are created containing all the lines to be shipped to customer
        // sales orders are created using a no. series that does *not* permit release
        // when that sales order is "released," the lines are split into as many child orders as needed, and the 
        //   original sales order is archived - these child orders are created with a no. series that *does* permit release
        //   reasons for split include but are not limited to: agency code, agency payment terms, location priority, etc.
        // for more information, see:
        //   _Clients\Rentokil\docs\proposal - RENT - Koerber WMS Integration - CO4 Order Mgt_v1_0.pdf
        if Rec."On Hold" <> 'N' then
            if _NoSeries."Release Permitted" then
                Error(_Text000Err,Rec."No. Series");
    end;

    procedure OnBeforeReleaseSalesDocCustom(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean)
    var
        _OrderTranslationEntry: Record "ARC Order Translation Entry";
        _NoSeries: Record "No. Series";
        DataMgt: Codeunit "ARC DataMgt";
        eCommerceOriginBoo: Boolean;
        existEFTTrans: Boolean;
        logText: BigText;
        _time: Time;
        text000Lbl: Label 'diagnostic text related to order split, eCommerceOrigin, and EFTTransaction(Versapay/ChargeLogic)';
        text099Lbl: Label 'Method OnBeforeReleaseSalesDocCustom(): %1';
    begin
        Initialize();
        PreflightRoutinesBeforeRelease(SalesHeader, PreviewMode);
        if PreviewMode then
            exit;
        if SalesHeader.Status = SalesHeader.Status::Released then
            exit;
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;
        if not RNASetup."Order Management Active" then
            exit;
        if RNASetup."Order Mgt. Handle EFT Txs." then begin
            // credit card orders sourced by Adobe Commerce must not be split - email fr Jennifer Gunter dated Tue 23 Apr 2024 at 1430 Eastern
            logText.AddText(StrSubstNo(text099Lbl,'Order Mgt. Handle EFT Txs. is Yes in RNA Setup, evaluating eCommerceOrigin and attachedEFTTrans to bypass split') + CRNL);
            eCommerceOriginBoo := eCommerceOrigin(SalesHeader,logText);
            logText.AddText(StrSubstNo(text099Lbl,'eCommerce Origin: ' + Format(eCommerceOriginBoo)) + CRNL);
            existEFTTrans := existEFTTransForOrder(SalesHeader,logText);
            logText.AddText(StrSubstNo(text099Lbl,'EFT Transaction attached to order: ' + Format(existEFTTrans)) + CRNL);
            if eCommerceOriginBoo and existEFTTrans then begin
                logText.AddText(StrSubstNo(text099Lbl,'both conditions evaluated to true/yes ... bypass Order Split / allow order to release') + CRNL);
                DataMgt.NewDataEntry(EventLogLabel,text000Lbl,logText);
                exit;
            end;
        end;
        TestItems(SalesHeader);
        SalesHeader.TestField("No. Series");
        _NoSeries.Get(SalesHeader."No. Series");
        if _NoSeries."Release Permitted" then
            exit;
        _time := Time();
        _OrderTranslationEntry.Init();
        _OrderTranslationEntry."Entry No." := 0;
        _OrderTranslationEntry."Document Area" := _OrderTranslationEntry."Document Area"::Sales;
        _OrderTranslationEntry."Document Type" := SalesHeader."Document Type";
        _OrderTranslationEntry."Document No." := SalesHeader."No.";
        _OrderTranslationEntry."Sell-to Customer No." := CopyStr(SalesHeader."Sell-to Customer No.",1,MaxStrLen(_OrderTranslationEntry."Sell-to Customer No."));
        _OrderTranslationEntry."Location Code" := CopyStr(SalesHeader."Location Code",1,MaxStrLen(_OrderTranslationEntry."Location Code"));
        _OrderTranslationEntry."External Document No." := CopyStr(SalesHeader."External Document No.",1,MaxStrLen(_OrderTranslationEntry."External Document No."));
        _OrderTranslationEntry.Analyze := true;
        _OrderTranslationEntry."Created by" := CopyStr(UserId(),1,MaxStrLen(_OrderTranslationEntry."Created by"));
        _OrderTranslationEntry."Created at Date" := Today();
        _OrderTranslationEntry."Created at DateTime" := CreateDateTime(Today(),_time);
        _OrderTranslationEntry."Created at Time" := _time;
        _OrderTranslationEntry.Insert();
        SalesHeader."ARC Order Mgt. Status" := SalesHeader."ARC Order Mgt. Status"::Queued;
        SalesHeader.Modify();
        IsHandled := true;
    end;

    procedure OnBeforeReopenSalesDocCustom(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    var
        _JobQueueEntry: Record "Job Queue Entry";
        _OrderTranslationEntry: Record "ARC Order Translation Entry";
        _OrderTranslationEntries: Page "ARC Order Translation Entries";
        _Text000Msg: Label 'Order Management is active, so document will be analyzed soon ... would you like to see Order Translation Entries?';
    begin
        Initialize();
        if not RNASetup."Order Management Active" then
            exit;
        if SalesHeader.Status = SalesHeader.Status::Open then
            exit;
        if SalesHeader."ARC Order Mgt. Status" <> SalesHeader."ARC Order Mgt. Status"::Queued then
            exit;
        if not GuiAllowed() then begin
            IsHandled := true;
            exit;
        end;
        if JobQueueEntryActive(Codeunit::"ARC OrderManagement") then
            if Confirm(_Text000Msg,true) then begin
                _OrderTranslationEntries.SetDoc(_OrderTranslationEntry."Document Area"::Sales,
                    _OrderTranslationEntry."Document Type"::Order,SalesHeader."No.");
                _OrderTranslationEntries.Run();
                exit;
            end;
        SalesHeader."ARC Order Mgt. Status" := SalesHeader."ARC Order Mgt. Status"::" ";
    end;

    procedure OnValidateOrderMgtActive(var _RNASetup: Record "ARC RNA Setup")
    var
        _Text000Err: Label 'The update was interrupted to respect the warning.';
        _Text001Msg: Label 'Order Management in RNA Setup was %1.';
    begin
        Initialize();
        if not _RNASetup."Order Management Active" then
            if not ConfirmOrderMgtDisable() then
                Error(_Text000Err);
        _RNASetup.TestField("Order Translation No. Series");
        if _RNASetup."Order Management Active" then
            WriteLog(RNASetup."Order Mgt. Log Level"::Normal,0,0,StrSubstNo(_Text001Msg,'enabled'),'')
        else
            WriteLog(RNASetup."Order Mgt. Log Level"::Normal,0,0,StrSubstNo(_Text001Msg,'disabled'),'');
    end;

    procedure OnValidateOrderTranslationNoSeries(var _RNASetup: Record "ARC RNA Setup")
    var
        _NoSeries: Record "No. Series";
        _Text000Err: Label 'The update was interrupted to respect the warning.';
        _Text001Msg: Label 'Order Translation No. Series in RNA Setup was updated to %1.';
    begin
        Initialize();
        _NoSeries.Get(_RNASetup."Order Translation No. Series");
        _NoSeries.TestField("Release Permitted");
        WriteLog(RNASetup."Order Mgt. Log Level"::Normal,0,0,StrSubstNo(_Text001Msg,_RNASetup."Order Translation No. Series"),'');
        if _RNASetup."Order Translation No. Series" <> '' then
            exit;
        if not ConfirmOrderMgtDisable() then
            Error(_Text000Err);
    end;

    procedure OnValidateOrderMgtLogLevel(var _RNASetup: Record "ARC RNA Setup")
    var
        _Text000Msg: Label 'Order Mgt. Log Level in RNA Setup was updated to %1.';
    begin
        Initialize();
        WriteLog(RNASetup."Order Mgt. Log Level"::Normal,0,0,StrSubstNo(_Text000Msg,_RNASetup."Order Mgt. Log Level"),'');
    end;

    local procedure PreflightRoutinesBeforeRelease(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    var
        _NoSeries: Record "No. Series";
        SalesLine: Record "Sales Line";
        APLMgt: Codeunit "ARC APL Management";
        LOBLiftMgt: Codeunit "ARC LOBLiftMgt";
        ARCSalesMgt: Codeunit ARCSalesMgt;
        PriceMgt: Codeunit "ARC Price Management";
        RegulatoryMgt: Codeunit "ARC Regulatory Management";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        if RNASetup."Order Management Active" then
            if _NoSeries.Get(SalesHeader."No. Series") then
                if _NoSeries."Release Permitted" then
                    exit;  // do not go through these routines if DERIVED (split) order is being released
        If SalesHeader."Web Order" then begin 
            SalesLine.Reset;
            SalesLine.SetRange("Document No.",SalesHeader."No.");
            SalesLine.SetRange(Type,SalesLine.Type::Item);
            SalesLine.SetFilter("Outstanding Quantity",'>%1',0);
            SalesLine.SetRange("ARC Price Entry No.",0);
            If SalesLine.FindSet then 
                repeat
                    PriceMgt.CreatePriceReviewEntry(SalesLine);
                until SalesLine.Next = 0;
        end;
        ARCSalesMgt.CheckCOILocation(SalesHeader);
        RegulatoryMgt.TestRestriction(SalesHeader,false);
        PriceMgt.CheckPendingPriceReviewEntries(SalesHeader);
        //LOBLiftMgt.OnBeforeReleaseSalesDoc(SalesHeader,PreviewMode);
        ARCSalesMgt.CheckCustCrLimitBalanceDue(SalesHeader);
        SalesHeader.TestField("ARC Regulatory Hold",false);
        If SalesHeader."ARC AR Hold" then begin 
            If ApprovalsMgmt.IsSalesApprovalsWorkflowEnabled(SalesHeader) then begin 
                If not ApprovalsMgmt.HasOpenOrPendingApprovalEntries(SalesHeader.RecordId) then begin 
                    ApprovalsMgmt.OnSendSalesDocForApproval(SalesHeader);
                    Commit;
                    Error('');
                end;
            end;    
        end;
        //SalesHeader.TestField("ARC AR Hold",false);
        If SalesHeader."Document Type"  IN [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice] then
            ARCSalesMgt.CreateSupplementalChargeLines(SalesHeader);
    end;

    local procedure ReleaseEntries()
    var
        _OrderTranslationEntry: Record "ARC Order Translation Entry";
        _OrderTranslationEntry2: Record "ARC Order Translation Entry";
        _OrderMgt: Codeunit "ARC OrderManagement";
        _KorberShptMgt: Codeunit "ARC KorberShptMgt";
        _result: Boolean;
        _updDocNo: Code[20];
        _entriesProcessed: Integer;
        _NoOfAttempts: Integer;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Msg: Label 'updated documents released: %1';
    begin
        _OrderTranslationEntry.SetCurrentKey(Release,Released);
        _OrderTranslationEntry.SetRange(Release,true);
        _OrderTranslationEntry.SetRange(Released,0);
        if _OrderTranslationEntry.FindSet(false) then
            repeat
                if (_OrderTranslationEntry."Updated Document No." <> _updDocNo) and
                   (_OrderTranslationEntry.Released = 0) and _OrderTranslationEntry.Release // expect findset recset to be cached
                then begin
                    // only one release per updated document no.
                    _timeBegin := Time();
                    _NoOfAttempts := _OrderTranslationEntry."Released No. of Attempts";
                    _updDocNo := CopyStr(_OrderTranslationEntry."Updated Document No.",1,MaxStrLen(_updDocNo));
                    Clear(_OrderMgt);
                    _OrderMgt.SetEntryNoToRelease(_OrderTranslationEntry."Entry No.");
                    Commit();
                    _result := _OrderMgt.Run();
                    if not _result then begin
                        Clear(_OrderTranslationEntry2);
                        _OrderTranslationEntry2.Reset();
                        _OrderTranslationEntry2.SetCurrentKey("Updated Document No.");
                        _OrderTranslationEntry2.SetRange("Updated Document No.",_updDocNo);
                        _OrderTranslationEntry2.SetRange(Release,true);
                        _OrderTranslationEntry2.SetRange(Released,0);
                        _OrderTranslationEntry2.SetAutoCalcFields("Updated Status");
                        if _OrderTranslationEntry2.FindSet(true) then begin
                            _OrderTranslationEntry2.ModifyAll("Released No. of Attempts",_NoOfAttempts + 1);
                            _OrderTranslationEntry2.ModifyAll("Released Error Text",CopyStr(GetLastErrorText(),1,MaxStrLen(_OrderTranslationEntry2."Released Error Text")));
                            _timeEnd := Time();
                            _OrderTranslationEntry2.ModifyAll("Released at DateTime",CreateDateTime(Today(),_timeEnd));
                            _OrderTranslationEntry2.ModifyAll("Released Duration (new)",_timeEnd - _timeBegin);
                            if _OrderTranslationEntry2."Updated Status" = _OrderTranslationEntry2."Updated Status"::Released then begin
                                _OrderTranslationEntry2.ModifyAll(Released,1);
                                _KorberShptMgt.OnAfterReleaseSalesDocNo(_updDocNo);
                            end else
                            if _NoOfAttempts >= KorberSetup."Maximum No. of Attempts" then
                                _OrderTranslationEntry2.ModifyAll(Released,-1);
                        end;
                        _OrderTranslationEntry2.Reset();  // clear table lock
                    end;
                    _entriesProcessed += 1;
                end;
            until (_OrderTranslationEntry.Next() = 0) or (_entriesProcessed >= KorberSetup."Process Queue No. Entries");
        if _entriesProcessed > 0 then
            WriteLog(RNASetup."Order Mgt. Log Level"::Verbose,0,0,StrSubstNo(_Text000Msg,_entriesProcessed),'');
    end;

    local procedure ReleaseEntry()
    var
        _OrderTranslationEntry: Record "ARC Order Translation Entry";
        _OrderTranslationEntry2: Record "ARC Order Translation Entry";
        _SalesHeader: Record "Sales Header";
        _KorberShptMgt: Codeunit "ARC KorberShptMgt";
        _ReleaseSalesDocument: Codeunit "Release Sales Document";
        _timeBegin: Time;
        _timeEnd: Time;
    begin
        _OrderTranslationEntry.Get(EntryNoToRelease);
        _OrderTranslationEntry.CalcFields("Updated Status");
        if _OrderTranslationEntry."Updated Status" <> _OrderTranslationEntry."Updated Status"::Open then
            exit;
        _SalesHeader.LockTable();
        _SalesHeader.Get(_SalesHeader."Document Type"::Order,_OrderTranslationEntry."Updated Document No.");
        _ReleaseSalesDocument.Run(_SalesHeader);
        _KorberShptMgt.OnAfterReleaseSalesDoc(_SalesHeader,false,false);  // extra check to ensure record queued for transmission
        Clear(_OrderTranslationEntry2);
        _OrderTranslationEntry2.Reset();
        _OrderTranslationEntry2.SetCurrentKey("Updated Document No.");
        _OrderTranslationEntry2.SetRange("Updated Document No.",_OrderTranslationEntry."Updated Document No.");
        _OrderTranslationEntry2.SetRange(Release,true);
        _OrderTranslationEntry2.SetRange(Released,0);
        if _OrderTranslationEntry2.FindSet(true) then begin
            _OrderTranslationEntry2.ModifyAll("Released No. of Attempts",_OrderTranslationEntry2."Released No. of Attempts" + 1);
            _timeEnd := Time();
            _OrderTranslationEntry2.ModifyAll("Released at DateTime",CreateDateTime(Today(),_timeEnd));
            _OrderTranslationEntry2.ModifyAll("Released Duration (new)",_timeEnd - _timeBegin);
            _OrderTranslationEntry2.ModifyAll(Released,1);
        end;
        _OrderTranslationEntry2.Reset();  // clear table lock
    end;

    procedure SetEntryNoToAnalyze(_EntryNoToAnalyze: BigInteger)
    begin
        EntryNoToAnalyze := _EntryNoToAnalyze;
    end;

    procedure SetEntryNoToRelease(_EntryNoToRelease: BigInteger)
    begin
        EntryNoToRelease := _EntryNoToRelease;
    end;

    procedure ShowDocument(_Rec: Record "ARC Order Translation Entry")
    var
        _SalesHeader: Record "Sales Header";
        _SalesHeaderArchive: Record "Sales Header Archive";
        _Text000Err: Label 'The original document was not found (searched open sales header and sales header archive records).';
    begin
        if _SalesHeader.Get(_Rec."Document Type",_Rec."Document No.") then begin
            Page.Run(Page::"Sales Order",_SalesHeader);
            exit;
        end;
        _SalesHeaderArchive.SetRange("Document Type",_Rec."Document Type");
        _SalesHeaderArchive.SetRange("No.",_Rec."Document No.");
        if _SalesHeaderArchive.FindLast() then begin
            Page.Run(Page::"Sales Order Archive",_SalesHeaderArchive);
            exit;
        end;
        Error(_Text000Err);
    end;

    procedure ShowEventLog()
    var
        _EventLogEntry: Record "ARC Event Log Entry";
    begin
        _EventLogEntry.SetCurrentKey(Code);
        _EventLogEntry.SetRange(Code,EventLogLabel);
        _EventLogEntry.Ascending(false);
        Page.Run(Page::"ARC Event Log Entries",_EventLogEntry);
    end;

    procedure ShowJobQueue()
    var
        _JobQueueEntry: Record "Job Queue Entry";
    begin
        _JobQueueEntry.SetRange("Object Type to Run",_JobQueueEntry."Object Type to Run"::Codeunit);
        _JobQueueEntry.SetRange("Object ID to Run",Codeunit::"ARC OrderManagement");
        Page.Run(Page::"Job Queue Entries",_JobQueueEntry);
    end;

    procedure ShowKorberShptEntries(_OrderTranslationEntry: Record "ARC Order Translation Entry")
    var
        _Location: Record Location;
        _KorberMgt: Codeunit "ARC KorberMgt";
        _KorberShptMgt: Codeunit "ARC KorberShptMgt";
        _Text000Err: Label '%1 is No for Location %2';
    begin
        if not _KorberMgt.GetLocation(_OrderTranslationEntry."Updated Location Code",_Location) then
            Error(_Text000Err,_Location.FieldCaption("ARC Enable Korber WMS"),_OrderTranslationEntry."Updated Location Code");
        _KorberShptMgt.ShowShptEntriesUsingSalesOrderNo(_OrderTranslationEntry."Updated Document No.");
    end;

    procedure ShowLocation(_LocCode: Code[10])
    var
        _Location: Record Location;
    begin
        _Location.Get(_LocCode);
        _Location.SetRecFilter();
        Page.Run(Page::"Location Card",_Location);
    end;

    procedure ShowOrderList(Rec: Record "ARC Order Translation Entry")
    var
        _SalesHeader: Record "Sales Header";
    begin
        _SalesHeader.SetRange("Document Type",Rec."Document Type");
        _SalesHeader.SetRange("No.",Rec."Updated Document No.");
        if not _SalesHeader.FindFirst() then begin
            _SalesHeader.SetRange("No.");
            if _SalesHeader.FindLast() then;
        end;
        _SalesHeader.SetRange("No.");
        _SalesHeader.Ascending(false);
        Page.Run(Page::"Sales Order List",_SalesHeader);
    end;

    procedure ShowNo(Rec: Record "ARC Order Translation Entry")
    var
        _FixedAsset: Record "Fixed Asset";
        _Item: Record Item;
        _Resource: Record Resource;
        _GLAcc: Record "G/L Account";
    begin
        Rec.TestField("No.");
        case Rec.Type of
            Rec.Type::"Fixed Asset":
                begin
                    _FixedAsset.Get(Rec."No.");
                    Page.Run(Page::"Fixed Asset Card",_FixedAsset);
                end;
            Rec.Type::"G/L Account":
                begin
                    _GLAcc.Get(Rec."No.");
                    Page.Run(Page::"G/L Account Card",_GLAcc);
                end;
            Rec.Type::Item:
                begin
                    _Item.Get(Rec."No.");
                    Page.Run(Page::"Item Card",_Item);
                end;
            Rec.Type::Resource:
                begin
                    _Resource.Get(Rec."No.");
                    Page.Run(Page::"Resource Card",_Resource);
                end;
        end;
    end;

    procedure ShowUpdatedDocument(_Rec: Record "ARC Order Translation Entry")
    var
        _SalesHeader: Record "Sales Header";
    begin
        if _SalesHeader.Get(_SalesHeader."Document Type"::Order,_Rec."Updated Document No.") then begin
            _SalesHeader.SetRecFilter();
            Page.Run(Page::"Sales Order",_SalesHeader);
            exit;
        end;
        ShowUpdatedDocumentPostedInvcs(_Rec);
    end;

    procedure ShowUpdatedDocumentPostedInvcs(_Rec: Record "ARC Order Translation Entry")
    var
        _SalesInvHeader: Record "Sales Invoice Header";
    begin
        _SalesInvHeader.SetCurrentKey("Order No.");
        _SalesInvHeader.SetRange("Order No.",_Rec."Updated Document No.");
        Page.Run(Page::"Posted Sales Invoices",_SalesInvHeader);
    end;

    procedure ShowUpdatedDocumentPostedShpts(_Rec: Record "ARC Order Translation Entry")
    var
        _SalesShptHeader: Record "Sales Shipment Header";
    begin
        _SalesShptHeader.SetCurrentKey("Order No.");
        _SalesShptHeader.SetRange("Order No.",_Rec."Updated Document No.");
        Page.Run(Page::"Posted Sales Shipments",_SalesShptHeader);
    end;

    local procedure Split(
        _OrderTranslationEntry: Record "ARC Order Translation Entry"; 
        var _SalesHeaderOrig: Record "Sales Header";
        var _logText: BigText)
    var
        _Item: Record Item;
        _SalesLineOrig: Record "Sales Line";
        _tempBufGroup: Record "ARC Buffer" temporary;
        _entryNo: BigInteger;
        _Text000Lbl: Label 'codeunit 50078 "ARC OrderManagement": Split() ******************** ';
        _Text001Lbl: Label '  for more information about split criteria, see document: "proposal - RENT - Koerber WMS Integration - CO4 Order Mgt_v1_0.pdf"';
        _Text002Lbl: Label '  Note: Use Location Priority is Yes in %1, but the Ranking Code of an item *may* disqualify it from an override from Location Priority';
   begin
        // SOW11 Körber Edge WMS - CO4 Order Management"
        _logText.AddText(CRNL + _Text000Lbl + CRNL);
        _logText.AddText(_Text001Lbl + CRNL);
        if KorberSetup."Location Priority Active" then
            _logText.AddText(StrSubstNo(_Text002Lbl,KorberSetup.TableCaption) + CRNL);
        // STEP ONE: derive unique groups into which order lines will fall
        SplitDeriveGroups(_SalesHeaderOrig,_SalesLineOrig,_tempBufGroup,_entryNo,_logText);
        // STEP TWO: allow Sales Line records to tumble into one of the pre-existing unique groups
        SplitLines(_OrderTranslationEntry,_SalesHeaderOrig,_SalesLineOrig,_tempBufGroup,_logText);
    end;

    local procedure SplitDeriveGroups(
        var _SalesHeaderOrig: Record "Sales Header";
        var _SalesLineOrig: Record "Sales Line"; 
        var _tempBuf: Record "ARC Buffer" temporary;
        var _entryNo: BigInteger;
        var _logText: Bigtext)
    var
        _AgencyItem: Boolean;
        _HazmatItem: Boolean;
        _KorberEnabled: Boolean;
        _AgencyCode: Code[20];
        _PmtTermsCode: Code[20];
        _newLoc: Code[10];
        _Text000Lbl: Label 'codeunit 50078 "ARC OrderManagement": SplitDeriveUniqueGroups() **********';
        _Text001Lbl: Label '***** GROUP %1 *************************';
        _Text002Lbl: Label ' > %1 : %2';
    begin
        Clear(_tempBuf);
        _tempBuf.DeleteAll();
        _logText.AddText(CRNL + _Text000Lbl + CRNL);
        _SalesLineOrig.SetRange("Document Type",_SalesHeaderOrig."Document Type");
        _SalesLineOrig.SetRange("Document No.",_SalesHeaderOrig."No.");
        if _SalesLineOrig.FindSet(false) then
            repeat
                if _SalesLineOrig.Description <> '' then begin
                    SplitDeriveParams(_SalesHeaderOrig,_SalesLineOrig,_AgencyItem,_KorberEnabled,_HazmatItem,_AgencyCode,_PmtTermsCode,_newLoc,_logText);
                    _tempBuf.Reset();
                    _tempBuf.SetRange("Boolean 01",_AgencyItem);
                    _tempBuf.SetRange("Boolean 02",_KorberEnabled);
                    _tempBuf.SetRange("Boolean 03",_HazmatItem);
                    _tempBuf.SetRange("Code 01",_AgencyCode);
                    _tempBuf.SetRange("Code 02",_PmtTermsCode);
                    _tempBuf.SetRange("Code 03",_newLoc);
                    if _tempBuf.IsEmpty() then begin
                        _entryNo += 1;
                        _tempBuf.Init();
                        _tempBuf."Entry No." := _entryNo;
                        _tempBuf."Boolean 01" := _AgencyItem;
                        _tempBuf."Boolean 02" := _KorberEnabled;
                        _tempBuf."Boolean 03" := _HazmatItem;
                        _tempBuf."Code 01" := CopyStr(_AgencyCode,1,MaxStrLen(_tempBuf."Code 01"));
                        _tempBuf."Code 02" := CopyStr(_PmtTermsCode,1,MaxStrLen(_tempBuf."Code 02"));
                        _tempBuf."Code 03" := CopyStr(_newLoc,1,MaxStrLen(_tempBuf."Code 03"));
                        _tempBuf.Insert();
                        _logText.AddText(CRNL + StrSubstNo(_Text001Lbl,_entryNo) + CRNL);
                        _logText.AddText(StrSubstNo(_Text002Lbl,' Korber Location',_KorberEnabled) + CRNL);
                        _logText.AddText(StrSubstNo(_Text002Lbl,'     Agency Item',_AgencyItem) + CRNL);
                        _logText.AddText(StrSubstNo(_Text002Lbl,'     Agency Code',_AgencyCode) + CRNL);
                        _logText.AddText(StrSubstNo(_Text002Lbl,'     Hazmat Item',_HazmatItem) + CRNL);
                        _logText.AddText(StrSubstNo(_Text002Lbl,'   Payment Terms',_PmtTermsCode) + CRNL);
                        _logText.AddText(StrSubstNo(_Text002Lbl,'   Location Code',_newLoc) + CRNL);
                    end;
                end;
            until _SalesLineOrig.Next() = 0;
        _tempBuf.Reset();
    end;

    local procedure SplitDeriveParams(
        _SalesHeader: Record "Sales Header";
        _SalesLine: Record "Sales Line"; 
        var _boo1: Boolean;      // "Boolean 01" = _AgencyItem
        var _boo2: Boolean;      // "Boolean 02" = _KorberEnabled
        var _boo3: Boolean;      // "Boolean 03" = _HazmatItem
        var _cod1: Code[20];     // "Code 01"    = _AgencyCode
        var _cod2: Code[20];     // "Code 02"    = _PmtTermsCode
        var _cod3: Code[10];     // "Code 03"    = _newLoc
        var _logText: BigText)
    var
        _BOL: Record "ARC NAPC BOL";
        _Item: Record Item;
        _Location: Record Location;
        _RankingCode: Record "ARC Ranking Code";
        _SDS: Record "ARC SDS Product";
        _LocPriorityMgt: Codeunit "ARC LocationPriorityMgt";
        _RankingOptInLocPri: Boolean;
        _PlacardCodeExist: Boolean;
    begin
        Clear(_boo1);
        Clear(_cod1);
        // step ONE for Payment Terms Code - may be defined on the line if origination is DVP N2N
        _RankingOptInLocPri := KorberSetup."Location Priority Active";
        _cod2 := CopyStr(_SalesLine."ARC Payment Terms Code",1,MaxStrLen(_cod2));
        _cod3 := CopyStr(_SalesLine."Location Code",1,MaxStrLen(_cod3));
        if not _Location.Get(_cod3) then
            Clear(_Location);
        _boo2 := _Location."ARC Enable Korber WMS";
        if _SalesLine.Type = _SalesLine.Type::Item then begin
            _Item.Get(_SalesLine."No.");
            // the Ranking Code of an Item may disqualify that item from Location Priority override
            if _RankingOptInLocPri then
                if _Item."ARC Ranking Code" <> '' then
                    if _RankingCode.Get(_Item."ARC Ranking Code") then
                        _RankingOptInLocPri := _RankingCode."Use Location Priority";
            // Hazmat determination
            if _SDS.Get(_Item."ARC SDS Product Code") then begin
                if _BOL.Get(_SDS."BOL/UN/Ground Code") then
                    _PlacardCodeExist := _PlacardCodeExist or (_BOL."Placard Code" <> '');
                /* refer to conversation Tue 18 Oct 2022 at 3p Eastern - and email fr Cody Weeks sent Wed 19 Oct at 725am Eastern
                if _BOL.Get(_SDS."BOL/UN/Air Code") then
                    _PlacardCodeExist := _PlacardCodeExist or (_BOL."Placard Code" <> '');
                if _BOL.Get(_SDS."BOL/UN/Water Code") then
                    _PlacardCodeExist := _PlacardCodeExist or (_BOL."Placard Code" <> '');
                */
            end;
            _boo3 := _PlacardCodeExist;
            // agency item
            _boo1 := _Item."ARC Agency Item";
            _cod1 := CopyStr(_Item."ARC Agency Code",1,MaxStrLen(_cod1));
            _Item.CalcFields("ARC Agency Payment Terms");
            // step TWO for Payment Terms Code - if item is Agency then use Agency Payment Terms
            if _cod2 = '' then
                if _boo1 then
                    _cod2 := CopyStr(_Item."ARC Agency Payment Terms",1,MaxStrLen(_cod2));
            // if qualified, see if the Location Code on the Sales Line will be overridden
            if _RankingOptInLocPri then
                _LocPriorityMgt.CalculateLocationForSalesLine(_SalesLine,_cod3,_boo2,_logText);
        end;
        // step THREE for Payment Terms Code - if undefined then use Sales Header Payment Terms Code
        if _cod2 = '' then
            _cod2 := CopyStr(_SalesHeader."Payment Terms Code",1,MaxStrLen(_cod2));
    end;

    local procedure SplitLines(
        _OrderTranslationEntry: Record "ARC Order Translation Entry";
        _SalesHeaderOrig: Record "Sales Header";
        _SalesLineOrig: Record "Sales Line"; 
        var _tempBufGroup: Record "ARC Buffer" temporary;
        var _logText: BigText)
    var
        _Location: Record Location;
        _OrderTranslationEntry2: Record "ARC Order Translation Entry";
        _SalesHeaderForRelease: Record "Sales Header";
        _SalesLineForComments: Record "Sales Line";
        _SalesLineForRelease: Record "Sales Line";
        _Item: Record Item;
        _NoSeriesMgt: Codeunit NoSeriesManagement;
        _AgencyItem: Boolean;
        _HazmatItem: Boolean;
        _KorberEnabled: Boolean;
        _SalesCommentsForHeaderCopied: Boolean;
        _SalesHeaderLocDimsAligned: Boolean;
        _AgencyCode: Code[20];
        _PmtTermsCode: Code[20];
        _newLoc: Code[10];
        _linesReassigned: Integer;
        _textDesc: Text;
        _Text000Lbl: Label 'codeunit 50078 "ARC OrderManagement": SplitLines() ********** ';
        _Text001Lbl: Label '***** GROUP %1 *************************';
        _Text002Lbl: Label ' > %1 : %2';
        _Text003Lbl: Label 'line no. %1, location %2, type %3, no. %4, qty %5, desc %6';
        _Text004Lbl: Label 'Lines Reassigned: %1';
    begin
        _logText.AddText(CRNL + _Text000Lbl + CRNL);
        if _tempBufGroup.FindSet(false) then
            repeat
                _logText.AddText(CRNL + StrSubstNo(_Text001Lbl,_tempBufGroup."Entry No.") + CRNL);
                // for each unique group, create a sales header from original
                _SalesHeaderForRelease := _SalesHeaderOrig;
                _SalesHeaderForRelease.SetHideValidationDialog(true);
                _SalesHeaderForRelease."No." := _NoSeriesMgt.GetNextNo(RNASetup."Order Translation No. Series",Today(),true);
                _SalesHeaderForRelease."On Hold" := 'N';
                _SalesHeaderForRelease.Insert();
                _SalesHeaderForRelease."On Hold" := '';
                _SalesHeaderForRelease."No. Series" := CopyStr(RNASetup."Order Translation No. Series",1,MaxStrLen(_SalesHeaderForRelease."No. Series"));
                _SalesHeaderForRelease."ARC Order Mgt. Status" := _SalesHeaderForRelease."ARC Order Mgt. Status"::Analyzed;
                if _tempBufGroup."Code 02" <> '' then
                    if _SalesHeaderForRelease."Payment Terms Code" <> _tempBufGroup."Code 02" then
                        _SalesHeaderForRelease.Validate("Payment Terms Code",_tempBufGroup."Code 02");
                _logText.AddText(StrSubstNo(_Text002Lbl,'  New Sales Order',_SalesHeaderForRelease."No.") + CRNL);
                _logText.AddText(StrSubstNo(_Text002Lbl,'     (a) Location',_SalesHeaderForRelease."Location Code") + CRNL);
                _logText.AddText(StrSubstNo(_Text002Lbl,'     (a)    Dim 1',_SalesHeaderForRelease."Shortcut Dimension 1 Code") + CRNL);
                _logText.AddText(StrSubstNo(_Text002Lbl,'     (a)    Dim 2',_SalesHeaderForRelease."Shortcut Dimension 2 Code") + CRNL);
                // now assign matching lines to the order
                _SalesLineOrig.Reset();
                _SalesLineOrig.SetRange("Document Type",_SalesHeaderOrig."Document Type");
                _SalesLineOrig.SetRange("Document No.",_SalesHeaderOrig."No.");
                _SalesLineOrig.SetRange("Attached to Line No.",0);
                if _SalesLineOrig.FindSet(false) then
                    repeat
                        // "Boolean 01" = _AgencyItem
                        // "Boolean 02" = _KorberEnabled
                        // "Boolean 03" = _HazmatItem
                        // "Code 01"    = _AgencyCode
                        // "Code 02"    = _AgencyPmtTermsCode
                        // "Code 03"    = _newLoc
                        SplitDeriveParams(_SalesHeaderOrig,_SalesLineOrig,_AgencyItem,_KorberEnabled,_HazmatItem,_AgencyCode,_PmtTermsCode,_newLoc,_logText);
                        if (_AgencyItem = _tempBufGroup."Boolean 01") and
                           (_KorberEnabled = _tempBufGroup."Boolean 02") and
                           (_HazmatItem = _tempBufGroup."Boolean 03") and
                           (_AgencyCode = _tempBufGroup."Code 01") and
                           (_PmtTermsCode = _tempBufGroup."Code 02") and
                           (_newLoc = _tempBufGroup."Code 03")
                        then begin
                            // LocationFreightBilling
                            if not _SalesHeaderLocDimsAligned then begin
                                if _SalesHeaderForRelease."Location Code" <> _newLoc then begin
                                    _SalesHeaderForRelease.Validate("Location Code",_newLoc);
                                    _logText.AddText(StrSubstNo(_Text002Lbl,'     (b) Location',_SalesHeaderForRelease."Location Code") + CRNL);
                                    _logText.AddText(StrSubstNo(_Text002Lbl,'     (b)    Dim 1',_SalesHeaderForRelease."Shortcut Dimension 1 Code") + CRNL);
                                    _logText.AddText(StrSubstNo(_Text002Lbl,'     (b)    Dim 2',_SalesHeaderForRelease."Shortcut Dimension 2 Code") + CRNL);
                                end;
                                _SalesHeaderLocDimsAligned := true;
                            end;
                            // copy sales line record
                            _SalesLineForRelease := _SalesLineOrig;
                            _SalesLineForRelease."Document No." := _SalesHeaderForRelease."No.";
                            _SalesLineForRelease.Insert();
                            if _SalesLineForRelease."Location Code" <> _newLoc then begin
                                _SalesLineForRelease.Validate("Location Code",_newLoc);
                                _SalesLineForRelease.Modify();
                            end;
                            SplitOrderLineComments(_SalesLineForRelease,_SalesLineOrig);
                            if not _SalesCommentsForHeaderCopied then begin
                                _SalesLineForComments := _SalesLineOrig;
                                _SalesLineForComments."Line No." := 0;
                                SplitOrderLineComments(_SalesLineForRelease,_SalesLineForComments);
                                _SalesCommentsForHeaderCopied := true;
                            end;
                            SplitLinesAttached(_SalesLineForRelease,_SalesLineOrig);
                            _textDesc := StrSubstNo(_Text003Lbl,_SalesLineForRelease."Line No.",_SalesLineForRelease."Location Code",
                                _SalesLineForRelease.Type,_SalesLineForRelease."No.",_SalesLineForRelease.Quantity,_SalesLineForRelease.Description);
                            _logText.AddText(StrSubstNo(_Text002Lbl,'  Line Reassigned',_textDesc) + CRNL);
                            _OrderTranslationEntry2 := _OrderTranslationEntry;
                            _OrderTranslationEntry2."Entry No." := 0;
                            _OrderTranslationEntry2."Document Line No." := _SalesLineForRelease."Line No.";
                            _OrderTranslationEntry2."Location Code" := CopyStr(_SalesLineOrig."Location Code",1,MaxStrLen(_OrderTranslationEntry2."Location Code"));
                            _OrderTranslationEntry2."Updated Document No." := CopyStr(_SalesHeaderForRelease."No.",1,MaxStrLen(_OrderTranslationEntry2."Updated Document No."));
                            _OrderTranslationEntry2."Updated Document Line No." := _SalesLineForRelease."Line No.";
                            _OrderTranslationEntry2."Updated Location Code" := CopyStr(_SalesLineForRelease."Location Code",1,MaxStrLen(_OrderTranslationEntry2."Updated Location Code"));
                            _OrderTranslationEntry2.Type := _SalesLineForRelease.Type;
                            _OrderTranslationEntry2."No." := CopyStr(_SalesLineForRelease."No.",1,MaxStrLen(_OrderTranslationEntry2."No."));
                            if _Item.Get(_SalesLineForRelease."No.") then
                                _OrderTranslationEntry2."ARC Ranking Code" := _Item."ARC Ranking Code";
                            _OrderTranslationEntry2.Quantity := _SalesLineForRelease.Quantity;
                            _OrderTranslationEntry2."Quantity (Base)" := _SalesLineForRelease."Quantity (Base)";
                            _OrderTranslationEntry2."Qty. per Unit of Measure" := _SalesLineForRelease."Qty. per Unit of Measure";
                            _OrderTranslationEntry2."Unit of Measure Code" := CopyStr(_SalesLineForRelease."Unit of Measure Code",1,MaxStrLen(_OrderTranslationEntry2."Unit of Measure Code"));
                            _OrderTranslationEntry2."Payment Terms Code" := CopyStr(_PmtTermsCode,1,MaxStrLen(_OrderTranslationEntry2."Payment Terms Code"));
                            _OrderTranslationEntry2."Sell-to Customer No." := CopyStr(_SalesLineForRelease."Sell-to Customer No.",1,MaxStrLen(_OrderTranslationEntry2."Sell-to Customer No."));
                            _OrderTranslationEntry2.Analyze := false;
                            _OrderTranslationEntry2.Analyzed := 0;
                            _OrderTranslationEntry2."Analyzed at DateTime" := 0DT;
                            _OrderTranslationEntry2."Analyzed Data Entry No." := 0;
                            _OrderTranslationEntry2."Analyzed Duration" := 0;
                            _OrderTranslationEntry2."Analyzed Error Text" := CopyStr('',1,MaxStrLen(_OrderTranslationEntry2."Analyzed Error Text"));
                            _OrderTranslationEntry2."Analyzed No. of Attempts" := 0;
                            _OrderTranslationEntry2.Release := true;
                            _OrderTranslationEntry2.Insert();
                            _linesReassigned += 1;
                        end;
                    until _SalesLineOrig.Next() = 0;
                // if Hazmat items are present on order, override Shipment Method Code
                if _tempBufGroup."Boolean 03" then
                    if KorberSetup."Hazmat Shpt. Method Code" <> '' then begin
                        _SalesHeaderForRelease.Validate("Shipment Method Code",KorberSetup."Hazmat Shpt. Method Code");
                        _logText.AddText(StrSubstNo(_Text002Lbl,'  New Shpt. Method fr. Korber Setup',KorberSetup."Hazmat Shpt. Method Code") + CRNL);
                    end;
                // side effect of bypassing E-Ship functionality - if Korber WMS location is in header, order needs help to get released automatically
                if _Location.Get(_SalesHeaderForRelease."Location Code") then
                    if _Location."ARC Korber Order Hdr. Code" <> '' then begin
                        _SalesHeaderForRelease.Validate("Location Code",CopyStr(_Location."ARC Korber Order Hdr. Code",1,MaxStrLen(_SalesHeaderForRelease."Location Code")));
                        _logText.AddText(StrSubstNo(_Text002Lbl,'  New Hdr. Loc. Code fr. Location Rec.',_Location."ARC Korber Order Hdr. Code") + CRNL);
                    end;
                _SalesCommentsForHeaderCopied := false;
                _SalesHeaderLocDimsAligned := false;  // LocationFreightBilling - Cody Weeks email dated Thu 18 May 2023 at 1003am Eastern
                _SalesHeaderForRelease.Modify();
            until _tempBufGroup.Next() = 0;
        _logText.AddText(CRNL + StrSubstNo(_Text004Lbl,_linesReassigned) + CRNL);
    end;

    local procedure SplitLinesAttached(_SalesLineForRelease: Record "Sales Line"; _SalesLineOrig: Record "Sales Line")
    var
        _SalesLineAttached: Record "Sales Line";
        _SalesLineNew: Record "Sales Line";
    begin
        _SalesLineAttached.SetRange("Document Type",_SalesLineOrig."Document Type");
        _SalesLineAttached.SetRange("Document No.",_SalesLineOrig."Document No.");
        _SalesLineAttached.SetRange("Attached to Line No.",_SalesLineOrig."Line No.");
        if _SalesLineAttached.FindSet(false) then
            repeat
                _SalesLineNew := _SalesLineAttached;
                _SalesLineNew."Document No." := CopyStr(_SalesLineForRelease."Document No.",1,MaxStrLen(_SalesLineNew."Document No."));
                _SalesLineNew.Insert();
                SplitOrderLineComments(_SalesLineNew,_SalesLineAttached);
            until _SalesLineAttached.Next() = 0;
    end;

    local procedure SplitOrderLineComments(_SalesLineNew: Record "Sales Line"; _SalesLineOrig: Record "Sales Line")
    var
        _SalesCommentLineNew: Record "Sales Comment Line";
        _SalesCommentLineOrig: Record "Sales Comment Line";
    begin
        _SalesCommentLineOrig.SetRange("Document Type",_SalesLineOrig."Document Type");
        _SalesCommentLineOrig.SetRange("No.",_SalesLineOrig."Document No.");
        _SalesCommentLineOrig.SetRange("Document Line No.",_SalesLineOrig."Line No.");
        if _SalesCommentLineOrig.FindSet(false) then
            repeat
                Clear(_SalesCommentLineNew);
                _SalesCommentLineNew.Reset();
                _SalesCommentLineNew := _SalesCommentLineOrig;
                _SalesCommentLineNew."No." := CopyStr(_SalesLineNew."Document No.",1,MaxStrLen(_SalesCommentLineNew."No."));
                _SalesCommentLineNew.Insert();
            until _SalesCommentLineOrig.Next() = 0;
    end;

    local procedure TestItems(_SalesHeader: Record "Sales Header")
    var
        _SalesLine: Record "Sales Line";
    begin
        _SalesLine.SetRange("Document Type",_SalesHeader."Document Type");
        _SalesLine.SetRange("Document No.",_SalesHeader."No.");
        _SalesLine.SetRange(Type,_SalesLine.Type::Item);
        if _SalesLine.FindSet(false) then
            repeat
                _SalesLine.TestField("No.");
                _SalesLine.TestField(Quantity);
            until _SalesLine.Next() = 0;
    end;

    local procedure WriteLog(_logLevel: Integer; _relatedEntryNo: BigInteger; _relatedDataEntryNo: BigInteger; _msg: Text; _err: Text)
    var
        _EventLogEntry: Record "ARC Event Log Entry";
        _status: Integer;
    begin
        if _err <> '' then
            _status := _EventLogEntry.Status::Error
        else
            _status := _EventLogEntry.Status::Message;
        _EventLogEntry.NewEventLogEntry(EventLogLabel,_EventLogEntry."Object Type"::Codeunit,Codeunit::"ARC OrderManagement",
            _status,_relatedEntryNo,_msg,_err,false,'');
    end;
}
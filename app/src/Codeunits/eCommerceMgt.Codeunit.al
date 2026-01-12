codeunit 50083 "ARC eCommerceMgt"
{
    // SOW13 Adobe eCommerce to CSM to NAV 2018

    Permissions = tabledata "ARC Inventory Balance Entry" = rimd;

    trigger OnRun();
    begin
        Initialize();
        if EntryNoToProcess <> 0 then begin
            ProcessEntry();
            exit;
        end;
        if EntryNoToRelease <> 0 then begin
            ReleaseEntry();
            exit;
        end;
        ProcessEntries();
    end;

    var
        KorberSetup: Record "ARC Korber Setup";
        RNASetup: Record "ARC RNA Setup";
        EntryNoProcessing: BigInteger;
        EntryNoToProcess: BigInteger;
        EntryNoToRelease: BigInteger;
        DiagText: BigText;
        DiagCode: Code[20];
        OrderNos: Code[20];
        MaxNoOfAttempts: Integer;
        ProcessQueueEntries: Integer;
        CRNL: Text;
        DiagDesc: Text;

    local procedure AppendText(_diagtext: Text)
    var
        datetimetext: Text;
        textline: Text;
        text000Lbl: Label '%1 -- %2';
    begin
        datetimetext := CopyStr(Format(CurrentDateTime(),0,9),1,MaxStrLen(datetimetext));
        textline := CopyStr(StrSubstNo(text000Lbl,datetimetext,_diagtext) + CRNL,1,MaxStrLen(textline));
        DiagText.AddText(textline);
    end;

    procedure GetDiagText(var _DiagText: BigText)
    var
        _text: Text;
    begin
        if DiagText.Length() <= 0 then
            exit;
        DiagText.GetSubText(_text,1);
        _DiagText.AddText(_text);
    end;

    procedure GetEntryNoProcessing(): BigInteger
    begin
        exit(EntryNoProcessing);
    end;

    local procedure Initialize()
    var
        NoSeries: Record "No. Series";
        SalesSetup: Record "Sales & Receivables Setup";
        KorberMgt: Codeunit "ARC KorberMgt";
        text099Lbl: Label 'Method Initialize(): %1';
    begin
        CRNL := CopyStr(KorberMgt.GetCRNL(),1,MaxStrLen(CRNL));
        DiagCode := CopyStr('ECOM_MGT',1,MaxStrLen(DiagCode));
        DiagDesc := CopyStr('eCommerce diagnostic text',1,MaxStrLen(DiagDesc));
        if not KorberSetup.Get() then
            KorberSetup.Init();
        if not RNASetup.Get() then
            RNASetup.Init();
        if RNASetup."eCommerce Order Nos." <> '' then begin
            OrderNos := CopyStr(RNASetup."eCommerce Order Nos.",1,MaxStrLen(OrderNos));
            NoSeries.Get(OrderNos);
            NoSeries.TestField("Default Nos.",true);
            AppendText(StrSubstNo(text099Lbl,'eCommerce Order Nos. found in RNA Setup: ' + OrderNos));
        end else
        if SalesSetup.Get() then begin
            OrderNos := CopyStr(SalesSetup."Order Nos.",1,MaxStrLen(OrderNos));
            NoSeries.Get(OrderNos);
            NoSeries.TestField("Default Nos.",true);
            AppendText(StrSubstNo(text099Lbl,'eCommerce Order Nos. found in Sales & Receivables Setup, Order Nos: ' + OrderNos));
        end;
        MaxNoOfAttempts := RNASetup."eCommerce Max. No. of Attempts";
        if (not (MaxNoOfAttempts in [1..99])) then
            MaxNoOfAttempts := 10;
        AppendText(StrSubstNo(text099Lbl,'MaxNoOfAttempts: ' + Format(MaxNoOfAttempts)));
        ProcessQueueEntries := RNASetup."eCommerce Process No. Entries";
        if (not (ProcessQueueEntries in [1..500])) then
            ProcessQueueEntries := 100;
        AppendText(StrSubstNo(text099Lbl,'ProcessQueueEntries: ' + Format(ProcessQueueEntries)));
    end;

    local procedure InsertNewInvBalanceEntry(ItemLedgEntry: Record "Item Ledger Entry"; RunTrigger: Boolean)
    var
        InvBalanceEntry: Record "ARC Inventory Balance Entry";
        _time: Time;
    begin
        if ItemLedgEntry.Quantity = 0 then
            exit;
        _time := Time();
        InvBalanceEntry.Init();
        InvBalanceEntry."Entry No." := 0;
        InvBalanceEntry."Item No." := CopyStr(ItemLedgEntry."Item No.",1,MaxStrLen(InvBalanceEntry."Item No."));
        InvBalanceEntry."Posting Date" := ItemLedgEntry."Posting Date";
        InvBalanceEntry."Document No." := CopyStr(ItemLedgEntry."Document No.",1,MaxStrLen(InvBalanceEntry."Document No."));
        InvBalanceEntry."Location Code" := CopyStr(ItemLedgEntry."Location Code",1,MaxStrLen(InvBalanceEntry."Location Code"));
        InvBalanceEntry."Item Ledger Entry No." := ItemLedgEntry."Entry No.";
        InvBalanceEntry."Created by" := CopyStr(UserId(),1,MaxStrLen(InvBalanceEntry."Created by"));
        InvBalanceEntry."Created at Date" := Today();
        InvBalanceEntry."Created at DateTime" := CreateDateTime(Today(),_time);
        InvBalanceEntry."Created at Time" := _time;
        InvBalanceEntry.Insert();
    end;

    local procedure InsertSalesComment(SalesHeader: Record "Sales Header"; CommentText: Text)
    var
        SalesCommentLine: Record "Sales Comment Line";
        lineNo: Integer;
        text000Lbl: Label 'Sales Comment Line record inserted: %1, %2, %3, %4, %5';
        text099Lbl: Label 'Method InsertSalesComment(): %1';
    begin
        AppendText(StrSubstNo(text099Lbl,'begin'));
        if CommentText = '' then begin
            AppendText(StrSubstNo(text099Lbl,'CommentText is empty (exit)'));
            exit;
        end;
        SalesCommentLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesCommentLine.SetRange("No.",SalesHeader."No.");
        SalesCommentLine.SetRange("Document Line No.",0);
        if SalesCommentLine.FindLast() then
            lineNo := SalesCommentLine."Line No.";
        lineNo += 10000;
        SalesCommentLine.Init();
        SalesCommentLine."Document Type" := SalesHeader."Document Type";
        SalesCommentLine."No." := CopyStr(SalesHeader."No.",1,MaxStrLen(SalesCommentLine."No."));
        SalesCommentLine."Document Line No." := 0;
        SalesCommentLine."Line No." := lineNo;
        SalesCommentLine.Comment := CopyStr(CommentText,1,MaxStrLen(SalesCommentLine.Comment));
        SalesCommentLine."Print On Invoice" := true;
        SalesCommentLine."Print On Shipment" := true;
        SalesCommentLine.Insert();
        AppendText(StrSubstNo(text099Lbl,StrSubstNo(text000Lbl,SalesCommentLine."Document Type",SalesCommentLine."No.",
            SalesCommentLine."Document Line No.",SalesCommentLine."Line No.",SalesCommentLine.Comment)));
        AppendText(StrSubstNo(text099Lbl,'end'));
    end;

    procedure MarkAsFailed(var eCommerceEntry: Record "ARC eCommerce Entry")
    var
        eCommerceEntry2: Record "ARC eCommerce Entry";
        recCount: Integer;
        timeMark: Time;
    begin
        if not eCommerceEntry.FindSet(false) then
            exit;
        recCount := eCommerceEntry.Count();
        if GuiAllowed() then
            if not Confirm('Mark records as failed, count: %1.  Continue?',false) then
                exit;
        timeMark := Time();
        repeat
            Clear(eCommerceEntry2);
            eCommerceEntry2.Reset();
            eCommerceEntry2.LockTable();
            eCommerceEntry2.Get(eCommerceEntry."Entry No.");
            eCommerceEntry2.Processed := -10;
            eCommerceEntry2."Processed at Date" := Today();
            eCommerceEntry2."Processed at DateTime" := CreateDateTime(Today(),timeMark);
            eCommerceEntry2."Processed at Time" := timeMark;
            eCommerceEntry2.Modify();
        until eCommerceEntry.Next() = 0;
    end;

    procedure OnBeforeInserteCommerceEntry(var Rec: Record "ARC eCommerce Entry"; RunTrigger: Boolean)
    var
        RNASetup: Record "ARC RNA Setup";
        _time: Time;
    begin
        if not RNASetup.Get() then
            RNASetup.Init();
        _time := Time();
        Rec."Created by" := CopyStr(UserId(),1,MaxStrLen(Rec."Created by"));
        Rec."Created at Date" := Today();
        Rec."Created at DateTime" := CreateDateTime(Today(),_time);
        Rec."Created at Time" := _time;
        Rec."eCom Bypass Price/Promo" := RNASetup."eCommerce Bypass Price/Promotion";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Ledger Entry", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertItemLedgEntry(var Rec: Record "Item Ledger Entry"; RunTrigger: Boolean)
    begin
        InsertNewInvBalanceEntry(Rec, RunTrigger);
    end;

    local procedure ProcessEntries()
    var
        eCommerceEntry: Record "ARC eCommerce Entry";
        eCommerceEntry2: Record "ARC eCommerce Entry";
        DataMgt: Codeunit "ARC DataMgt";
        eCommerceMgt: Codeunit "ARC eCommerceMgt";
        result: Boolean;
        currOrderId: Code[20];
        entriesProcessed: Integer;
        noOfAttempts: Integer;
        errorText: Text;
        timeBegin: Time;
        timeEnd: Time;
        text000Err: Label 'Processing Entry %1: %2';
        text099Lbl: Label 'Method ProcessEntries(): %1';
    begin
        AppendText(StrSubstNo(text099Lbl,'begin'));
        timeBegin := Time();
        eCommerceEntry.SetCurrentKey(Processed);
        eCommerceEntry.SetRange(Processed,0);
        if eCommerceEntry.FindSet(false) then
            repeat
                Clear(DiagText);
                Initialize();
                if eCommerceEntry."eCom Order ID" <> currOrderId then begin
                    currOrderId := CopyStr(eCommerceEntry."eCom Order ID",1,MaxStrLen(currOrderId));
                    AppendText(StrSubstNo(text099Lbl,'processing Entry No. ' + Format(eCommerceEntry."Entry No.") + ', Order ID: ' + currOrderId));
                    noOfAttempts := eCommerceEntry."Processed No. of Attempts" + 1;
                    Clear(eCommerceMgt);
                    eCommerceMgt.SetEntryNoToProcess(eCommerceEntry."Entry No.");
                    Commit();
                    result := eCommerceMgt.Run();
                    if not result then begin
                        timeEnd := Time();
                        EntryNoProcessing := eCommerceMgt.GetEntryNoProcessing();
                        errorText := CopyStr(StrSubstNo(text000Err,EntryNoProcessing,GetLastErrorText()),1,MaxStrLen(errorText));
                        AppendText('--------------------------- RECURSIVE CALL --------------------------------------------------------------');
                        eCommerceMgt.GetDiagText(DiagText);
                        AppendText('---------------------------------------------------------------------------------------------------------');
                        Clear(eCommerceEntry2);
                        eCommerceEntry2.Reset();
                        eCommerceEntry2.SetCurrentKey("eCom Order ID");
                        eCommerceEntry2.SetRange("eCom Order ID",eCommerceEntry."eCom Order ID");
                        eCommerceEntry2.SetRange(Processed,0);
                        eCommerceEntry2.ModifyAll("Processed at Date",Today());
                        eCommerceEntry2.ModifyAll("Processed at DateTime",CreateDateTime(Today(),timeEnd));
                        eCommerceEntry2.ModifyAll("Processed at Time",timeEnd);
                        eCommerceEntry2.ModifyAll("Processed Duration",timeEnd - timeBegin);
                        eCommerceEntry2.ModifyAll("Processed No. of Attempts",noOfAttempts);
                        eCommerceEntry2.ModifyAll("Processed Data Entry No.",DataMgt.NewDataEntry(DiagCode,DiagDesc,DiagText));
                        eCommerceEntry2.ModifyAll("Processed Error Text",CopyStr(errorText,1,MaxStrLen(eCommerceEntry2."Processed Error Text")));
                        if noOfAttempts >= MaxNoOfAttempts then
                            eCommerceEntry2.ModifyAll(Processed,-1);
                    end else 
                    if not RNASetup."eCommerce Auto-Release" then
                        AppendText('eCommerce Auto-Release is No in RNA Setup')
                    else begin
                        Clear(eCommerceEntry2);
                        eCommerceEntry2.Reset();
                        eCommerceEntry2.Get(eCommerceEntry."Entry No.");
                        if eCommerceEntry2."Document No." = '' then
                            AppendText('failed attempt to release, Document No. is empty')
                        else begin
                            Clear(eCommerceMgt);
                            eCommerceMgt.SetEntryNoToRelease(eCommerceEntry."Entry No.");
                            Commit();
                            result := eCommerceMgt.Run();
                            AppendText(StrSubstNo(text099Lbl,'Document created; was release attempt successful? ' + Format(result)));
                            if not result then begin
                                AppendText(StrSubstNo(text099Lbl,'Error text: ' + GetLastErrorText()));
                                if RNASetup."Order Mgt. Log Level" = RNASetup."Order Mgt. Log Level"::Verbose then
                                    DataMgt.NewDataEntry(DiagCode,DiagDesc,DiagText);
                            end;
                        end;
                    end;
                end;
                entriesProcessed += 1;
            until (eCommerceEntry.Next() = 0) or (entriesProcessed >= ProcessQueueEntries);
        AppendText(StrSubstNo(text099Lbl,'entries processed: ' + Format(entriesProcessed)));
        AppendText(StrSubstNo(text099Lbl,'end'));
        if KorberSetup."Log Level" in [KorberSetup."Log Level"::Verbose] then
            DataMgt.NewDataEntry(DiagCode,DiagDesc,DiagText);
    end;

    local procedure ProcessEntry()
    var
        eCommerceEntry: Record "ARC eCommerce Entry";
        eCommerceEntry2: Record "ARC eCommerce Entry";
        OrderSource: Record "ARC Order Source";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        mismatchExists: Boolean;
        diffAmt: Decimal;
        lineNo: Integer;
        linesCreated: Integer;
        timeBegin: Time;
        timeEnd: Time;
        text099Lbl: Label 'Method ProcessEntry(): %1';
    begin
        AppendText(StrSubstNo(text099Lbl,'begin'));
        timeBegin := Time();
        eCommerceEntry.Get(EntryNoToProcess);
        eCommerceEntry.TestField("eCom Order ID");
        eCommerceEntry.TestField("eCom Customer No.");
        eCommerceEntry.SetCurrentKey("eCom Order ID");
        eCommerceEntry.SetRange("eCom Order ID",eCommerceEntry."eCom Order ID");
        eCommerceEntry.SetRange(Processed,0);
        if eCommerceEntry.Count() <> eCommerceEntry."eCom Group Count" then begin
            AppendText(StrSubstNo(text099Lbl, StrSubstNo('Record count %1 does not equal eCom Group Count %2 in eCommerce Entry (exit)',eCommerceEntry.Count(),eCommerceEntry."eCom Group Count")));
            exit;
        end;
        if eCommerceEntry.FindSet(false) then begin
            EntryNoProcessing := eCommerceEntry."Entry No.";
            AppendText(StrSubstNo(text099Lbl,'processing eCommerce Entry No. ' + Format(EntryNoProcessing)));
            SalesHeader.Init();
            SalesHeader.SetHideValidationDialog(true);
            SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
            SalesHeader."No." := NoSeriesMgt.GetNextNo(OrderNos,WorkDate(),true);
            AppendText(StrSubstNo(text099Lbl,'assigned Sales Header No. ' + SalesHeader."No."));
            SalesHeader.Insert(true);
            SalesHeader.Validate("Sell-to Customer No.",eCommerceEntry."eCom Customer No.");
            if eCommerceEntry."eCom Payment Method Code" <> '' then
                SalesHeader.Validate("Payment Method Code",eCommerceEntry."eCom Payment Method Code");
            if eCommerceEntry."eCom Ship-to Code" <> '' then begin
                SalesHeader.Validate("Ship-to Code",CopyStr(eCommerceEntry."eCom Ship-to Code",1,MaxStrLen(SalesHeader."Ship-to Code")));
                AppendText(StrSubstNo(text099Lbl,'validated Ship-to Code: ' + eCommerceEntry."eCom Ship-to Code"));
            end else begin
                SalesHeader."Ship-to Name" := CopyStr(eCommerceEntry."eCom Ship-to Name",1,MaxStrLen(SalesHeader."Ship-to Name"));
                SalesHeader."Ship-to Name 2" := CopyStr(eCommerceEntry."eCom Ship-to Name 2",1,MaxStrLen(SalesHeader."Ship-to Name 2"));
                SalesHeader."Ship-to Address" := CopyStr(eCommerceEntry."eCom Ship-to Address",1,MaxStrLen(SalesHeader."Ship-to Address"));
                SalesHeader."Ship-to Address 2" := CopyStr(eCommerceEntry."eCom Ship-to Address 2",1,MaxStrLen(SalesHeader."Ship-to Address 2"));
                SalesHeader."Ship-to City" := CopyStr(eCommerceEntry."eCom Ship-to City",1,MaxStrLen(SalesHeader."Ship-to City"));
                SalesHeader."Ship-to County" := CopyStr(eCommerceEntry."eCom Ship-to County",1,MaxStrLen(SalesHeader."Ship-to County"));
                SalesHeader."Ship-to Post Code" := CopyStr(eCommerceEntry."eCom Ship-to Post Code",1,MaxStrLen(SalesHeader."Ship-to Post Code"));
                SalesHeader."Ship-to Country/Region Code" := CopyStr(eCommerceEntry."eCom Ship-to Country",1,MaxStrLen(SalesHeader."Ship-to Country/Region Code"));
                AppendText(StrSubstNo(text099Lbl,'simply set the Ship-to fields like Name, Address, ...'));
            end;
            if eCommerceEntry."eCom Shipping Agent Code" <> '' then
                SalesHeader.Validate("Shipping Agent Code",eCommerceEntry."eCom Shipping Agent Code");
            SalesHeader."External Document No." := CopyStr(eCommerceEntry."eCom Order ID",1,MaxStrLen(SalesHeader."External Document No."));
            if eCommerceEntry."eCom Your Reference" <> '' then
                SalesHeader.Validate("Your Reference",eCommerceEntry."eCom Your Reference");
            if eCommerceEntry."eCom Shipment Method Code" <> '' then
                SalesHeader.Validate("Shipment Method Code",CopyStr(eCommerceEntry."eCom Shipment Method Code",1,MaxStrLen(SalesHeader."Shipment Method Code")));
            if OrderSource.Get('ADOBE') then
                SalesHeader."ARC Order Source Code" := CopyStr('ADOBE',1,MaxStrLen(SalesHeader."ARC Order Source Code"));
            InsertSalesComment(SalesHeader,eCommerceEntry."eCom Customer PO No.");
            SalesHeader.Modify(true);
            repeat
                Clear(mismatchExists);
                EntryNoProcessing := eCommerceEntry."Entry No.";
                AppendText(StrSubstNo(text099Lbl,'processing (line) eCommerce Entry No. ' + Format(EntryNoProcessing)));
                lineNo += 10000;
                SalesLine.Init();
                SalesLine.SetHideValidationDialog(true);
                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := CopyStr(SalesHeader."No.",1,MaxStrLen(SalesLine."Document No."));
                SalesLine."Line No." := lineNo;
                SalesLine.Insert(true);
                linesCreated += 1;
                if Evaluate(SalesLine.Type,eCommerceEntry."eCom Type") then
                    SalesLine.Validate(Type)
                else
                    Error('Entry No. %1: could not evaluate Type %2',eCommerceEntry."Entry No.",eCommerceEntry."eCom Type");
                SalesLine."ARC eCommerce Entry No." := eCommerceEntry."Entry No.";
                SalesLine.Validate("No.",CopyStr(eCommerceEntry."eCom No.",1,MaxStrLen(SalesLine."No.")));
                SalesLine.Validate("Unit of Measure Code",CopyStr(eCommerceEntry."eCom Unit of Measure Code",1,MaxStrLen(SalesLine."Unit of Measure Code")));
                SalesLine.Validate(Quantity,eCommerceEntry."eCom Quantity");
                SalesLine.Validate("Unit Price",eCommerceEntry."eCom Unit Price");
                if eCommerceEntry."eCom Line Discount Amount" <> 0 then
                    SalesLine.Validate("Line Discount Amount",eCommerceEntry."eCom Line Discount Amount");
                SalesLine.Modify(true);
                if SalesLine.Amount <> eCommerceEntry."eCom Amount" then begin
                    diffAmt := SalesLine.Amount - eCommerceEntry."eCom Amount";
                    mismatchExists := true;
                    AppendText(StrSubstNo(text099Lbl,'Amount mismatch (NAV2018 to D365BC): ' + Format(SalesLine.Amount) + ' <> ' + 
                        Format(eCommerceEntry."eCom Amount") + ', difference: ' + Format(diffAmt)));
                end;
                if timeEnd = 0T then
                    timeEnd := Time();
                Clear(eCommerceEntry2);
                eCommerceEntry2.Reset();
                eCommerceEntry2.LockTable();
                eCommerceEntry2.Get(eCommerceEntry."Entry No.");
                eCommerceEntry2."Document No." := CopyStr(SalesLine."Document No.",1,MaxStrLen(eCommerceEntry2."Document No."));
                eCommerceEntry2."Document Line No." := SalesLine."Line No.";
                eCommerceEntry2.Processed := 1;
                eCommerceEntry2."Processed at Date" := Today();
                eCommerceEntry2."Processed at DateTime" := CreateDateTime(Today(),timeEnd);
                eCommerceEntry2."Processed at Time" := timeEnd;
                eCommerceEntry2."Processed Duration" := timeEnd - timeBegin;
                eCommerceEntry2."Processed No. of Attempts" := eCommerceEntry2."Processed No. of Attempts" + 1;
                eCommerceEntry2."eCom Amount Mismatch" := mismatchExists;
                eCommerceEntry2.Modify();
                SalesLine.Reset();
                Clear(SalesLine);
            until eCommerceEntry.Next() = 0;
            SalesHeader.Reset();
            Clear(SalesHeader);
        end;
        AppendText(StrSubstNo(text099Lbl,'lines created: ' + Format(linesCreated) + ', Group Count: ' + Format(eCommerceEntry."eCom Group Count")));
        AppendText(StrSubstNo(text099Lbl,'end'));
    end;

    local procedure ReleaseEntry()
    var
        eCommerceEntry: Record "ARC eCommerce Entry";
        SalesHeader: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        eCommerceEntry.Get(EntryNoToRelease);
        eCommerceEntry.TestField("Document No.");
        SalesHeader.LockTable();
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Get(SalesHeader."Document Type"::Order,eCommerceEntry."Document No.");
        ReleaseSalesDoc.Run(SalesHeader);
    end;

    procedure ResetEntry(var eCommerceEntry: Record "ARC eCommerce Entry")
    var
        eCommerceEntry2: Record "ARC eCommerce Entry";
        recCount: Integer;
        timeMark: Time;
    begin
        if not eCommerceEntry.FindSet(false) then
            exit;
        recCount := eCommerceEntry.Count();
        if GuiAllowed() then
            if not Confirm('Reset records: %1.  Continue?',false,recCount) then
                exit;
        timeMark := Time();
        repeat
            Clear(eCommerceEntry2);
            eCommerceEntry2.Reset();
            eCommerceEntry2.LockTable();
            eCommerceEntry2.Get(eCommerceEntry."Entry No.");
            eCommerceEntry2.Processed := 0;
            eCommerceEntry2."Processed at Date" := Today();
            eCommerceEntry2."Processed at DateTime" := CreateDateTime(Today(),timeMark);
            eCommerceEntry2."Processed at Time" := timeMark;
            eCommerceEntry2."Processed Duration" := 0;
            eCommerceEntry2."Processed Data Entry No." := 0;
            eCommerceEntry2."Processed No. of Attempts" := 0;
            eCommerceEntry2."Processed Error Text" := '';
            eCommerceEntry2.Modify();
        until eCommerceEntry.Next() = 0;
    end;

    procedure SetEntryNoToProcess(_EntryNoToProcess: BigInteger)
    begin
        EntryNoToProcess := _EntryNoToProcess;
    end;

    procedure SetEntryNoToRelease(_EntryNoToRelease: BigInteger)
    begin
        EntryNoToRelease := _EntryNoToRelease;
    end;

    procedure ShowCustomer(eCommerceEntry: Record "ARC eCommerce Entry")
    var
        Customer: Record Customer;
    begin
        eCommerceEntry.TestField("eCom Customer No.");
        Customer.Get(eCommerceEntry."eCom Customer No.");
        Page.Run(Page::"Customer Card",Customer);
    end;

    procedure ShowDocument(eCommerceEntry: Record "ARC eCommerce Entry")
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        eCommerceEntry.TestField("Document No.");
        if SalesHeader.Get(SalesHeader."Document Type"::Order,eCommerceEntry."Document No.") then begin
            Page.Run(Page::"Sales Order",SalesHeader);
            exit;
        end;
        SalesInvHeader.SetCurrentKey("Order No.");
        SalesInvHeader.SetRange("Order No.",eCommerceEntry."Document No.");
        Page.Run(Page::"Posted Sales Invoices",SalesInvHeader);
    end;

    procedure ShoweCommerceEntriesFrOrdTranslEntries(OrdTranslEntry: Record "ARC Order Translation Entry")
    var
        eCommerceEntry: Record "ARC eCommerce Entry";
    begin
        if OrdTranslEntry."External Document No." <> '' then begin
            eCommerceEntry.SetCurrentKey("eCom Order ID");
            eCommerceEntry.SetRange("eCom Order ID",OrdTranslEntry."External Document No.");
            if eCommerceEntry.FindSet(false) then begin
                eCommerceEntry.Ascending(false);
                Page.Run(Page::"ARC eCommerce Entries",eCommerceEntry);
                exit;
            end;
        end;
        Page.Run(Page::"ARC eCommerce Entries");
    end;

    procedure ShowJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run",JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run",Codeunit::"ARC eCommerceMgt");
        if JobQueueEntry.FindFirst() then;
        Page.Run(Page::"Job Queue Entries",JobQueueEntry);
    end;

    procedure ShowNo(eCommerceEntry: Record "ARC eCommerce Entry")
    var
        GLAcc: Record "G/L Account";
        Item: Record Item;
        Resource: Record Resource;
        text000Lbl: Label '';
    begin
        eCommerceEntry.TestField("eCom No.");
        case eCommerceEntry."eCom Type" of
            'G/L Account':
                begin
                    GLAcc.Get(eCommerceEntry."eCom No.");
                    Page.Run(Page::"G/L Account Card",GLAcc);
                end;
            'Item':
                begin
                    Item.Get(eCommerceEntry."eCom No.");
                    Page.Run(Page::"Item Card",Item);
                end;
            'Resource':
                begin
                    Resource.Get(eCommerceEntry."eCom No.");
                    Page.Run(Page::"Resource Card",Resource);
                end;
            else
                Error('Unsupported; Type must be G/L Account, Item or Resource');
        end;
    end;

    procedure ShowOrdTranslEntriesFreCommerceEntries(eCommerceEntry: Record "ARC eCommerce Entry")
    var
        OrdTranslEntry: Record "ARC Order Translation Entry";
    begin
        if eCommerceEntry."eCom Order ID" <> '' then begin
            OrdTranslEntry.SetCurrentKey("External Document No.");
            OrdTranslEntry.SetRange("External Document No.",eCommerceEntry."eCom Order ID");
            if OrdTranslEntry.FindSet(false) then begin
                OrdTranslEntry.Ascending(false);
                Page.Run(Page::"ARC Order Translation Entries",OrdTranslEntry);
                exit;
            end;
        end;
        Page.Run(Page::"ARC Order Translation Entries");
    end;

    procedure ShowWebService()
    var
        WebService: Record "Tenant Web Service";
    begin
        WebService.SetRange("Object Type",WebService."Object Type"::Codeunit);
        WebService.SetRange("Object ID",Page::"ARC eCommerce Entries");
        if WebService.FindFirst() then;
        Page.Run(Page::"Web Services",WebService);
    end;

    procedure ToggleBypassPricePromotion(var eCommerceEntry: Record "ARC eCommerce Entry")
    var
        grpCount: Integer;
        text000Qst: Label 'Records found: %1.  Are you sure you want to toggle the Bypass Price/Promotion flag?';
        text001Msg: Label 'Done; you may now RESET these entries for re-processing';
        text002Lbl: Label 'Bypass Price/Promotion toggled to %1 on eCommerce Order ID %2';
    begin
        grpCount := eCommerceEntry.Count();
        if grpCount = 0 then
            exit;
        if GuiAllowed() then
            if not Confirm(text000Qst,false,grpCount) then
                exit;
        eCommerceEntry.FindSet(true);
        WriteLog(eCommerceEntry."Entry No.",0,StrSubstNo(text002Lbl,not eCommerceEntry."eCom Bypass Price/Promo",eCommerceEntry."eCom Order ID"),'');
        eCommerceEntry.ModifyAll("eCom Bypass Price/Promo",not eCommerceEntry."eCom Bypass Price/Promo");
        if GuiAllowed() then
            Message(text001Msg);
    end;

    local procedure WriteLog(_relatedEntryNo: BigInteger; _relatedDataEntryNo: BigInteger; _msg: Text; _err: Text)
    var
        _EventLogEntry: Record "ARC Event Log Entry";
        _status: Integer;
    begin
        if _err <> '' then
            _status := _EventLogEntry.Status::Error
        else
            _status := _EventLogEntry.Status::Message;
        _EventLogEntry.NewEventLogEntry(DiagCode,_EventLogEntry."Object Type"::Codeunit,Codeunit::"ARC eCommerceMgt",
            _status,_relatedEntryNo,_msg,_err,false,'');
    end;

    [EventSubscriber(ObjectType::Table, Database::"ARC eCommerce Entry", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInserteComEntry(var Rec: Record "ARC eCommerce Entry"; RunTrigger: Boolean)
    begin
        OnBeforeInserteCommerceEntry(Rec,RunTrigger);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnValidateNoOnCopyFromTempSalesLine', '', false, false)]
    local procedure OnValidateNoOnCopyFromTempSalesLine(var SalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line" temporary)
    begin
        SalesLine."ARC eCommerce Entry No." := TempSalesLine."ARC eCommerce Entry No.";
    end;
}
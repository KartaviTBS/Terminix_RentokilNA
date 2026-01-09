codeunit 50026 "ARC ReOrderMgt"
{
    Permissions = tabledata "Sales Header" = im, tabledata "Sales Line" = im, tabledata "ARC ReOrder Entry" = m, tabledata "Job Queue Entry" = m;

    trigger OnRun()
    begin
        Initialize();
        if EntryNoToProcess <> 0 then begin
            ProcessEntry();
            exit;
        end;
        if EntryNoToNotify <> 0 then begin
            SendNotifEntry();
            exit;
        end;
        ProcessEntries();
        SendNotifEntries();
    end;

    var
        ReOrderSetup: Record "ARC Reorder Setup";
        EventLogCode: Code[10];
        EntryNoToNotify: BigInteger;
        EntryNoToProcess: BigInteger;
        MaxEntriesToProcess: Integer;

    procedure DeleteEntry(EntryNo: Integer)
    var
        _ReOrderEntry: Record "ARC ReOrder Entry";
        _count: Integer;
        _Text000Qst: TextConst ENU='Unprocessed records found: %1.  Delete?';
        _Text001Err: TextConst ENU='No unprocessed records were found.';
        _Text002Err: TextConst ENU='Not allowed via web service.';
        _Text003Msg: Label 'Done.';
    begin
        if not GuiAllowed() then
            Error(_Text002Err);
        _ReOrderEntry.Get(EntryNo);
        _ReOrderEntry.SetCurrentKey("ReOrder ID");
        _ReOrderEntry.SetRange("ReOrder ID", _ReOrderEntry."ReOrder ID");
        _ReOrderEntry.SetRange("NAV Processed", 0);
        _count := _ReOrderEntry.Count();
        if _count <= 0 then
            Error(_Text001Err);
        if Confirm(_Text000Qst,false,_count) then
            _ReOrderEntry.DeleteAll();
        Message(_Text003Msg);
    end;

    procedure GetNavSalesOrderByEntryNo(EntryNo: BigInteger; var NavSalesOrderNo: text[250]; var NavSalesOrderLineNo: Integer)
    var
        ReOrderEntry: Record "ARC ReOrder Entry";
        Text000Msg: TextConst ENU='Not found using Entry No. %1.';
    begin
        Clear(NavSalesOrderNo);
        Clear(NavSalesOrderLineNo);
        if EntryNo <= 0 then begin
            NavSalesOrderNo := CopyStr(StrSubstNo(Text000Msg, EntryNo),1,MaxStrLen(NavSalesOrderNo));
            exit;
        end;
        if not ReOrderEntry.Get(EntryNo) then begin
            NavSalesOrderNo := CopyStr(StrSubstNo(Text000Msg, EntryNo),1,MaxStrLen(NavSalesOrderNo));
            exit;
        end;
        NavSalesOrderNo := ReOrderEntry."NAV Sales Order No.";
        NavSalesOrderLineNo := ReOrderEntry."NAV Sales Order Line No.";
    end;

    procedure GetNavSalesOrderByReOrderID(ReOrderID: text[50]; var NavSalesOrderNo: text[250])
    var
        ReOrderEntry: Record "ARC ReOrder Entry";
        Text000Msg: TextConst ENU='Not found using ReOrderID %1.';
    begin
        Clear(NavSalesOrderNo);
        ReOrderID := ReOrderID.Trim();
        if ReOrderID = '' then
            exit;
        ReOrderEntry.SetCurrentKey("ReOrder ID");
        ReOrderEntry.SetFilter("ReOrder ID", ReOrderID);
        if ReOrderEntry.FindFirst() then
            NavSalesOrderNo := ReOrderEntry."NAV Sales Order No."
        else
            NavSalesOrderNo := CopyStr(StrSubstNo(Text000Msg, ReOrderID),1,MaxStrLen(NavSalesOrderNo));
    end;

    procedure GetResultByEntryNo(EntryNo: BigInteger; var Result: Integer; var ProcessedDateTime: DateTime; var ErrorText: Text[250])
    var
        ReOrderEntry: Record "ARC ReOrder Entry";
    begin
        Clear(Result);
        Clear(ErrorText);
        if EntryNo <= 0 then
            exit;
        if not ReOrderEntry.Get(EntryNo) then
            exit;
        Result := ReOrderEntry."NAV Processed";
        ProcessedDateTime := ReOrderEntry."NAV Processed at DateTime";
        ErrorText := ReOrderEntry."NAV Processed Error Text";
    end;

    procedure GetResultByReOrderID(ReOrderID: Text[50]; var Result: Integer; var ProcessedDateTime: DateTime; var ErrorText: Text[250])
    var
        ReOrderEntry: Record "ARC ReOrder Entry";
    begin
        Clear(ReOrderID);
        ReOrderID := ReOrderID.Trim();
        if ReOrderID = '' then
            exit;
        ReOrderEntry.SetCurrentKey("ReOrder ID");
        ReOrderEntry.SetRange("ReOrder ID", ReOrderID);
        if ReOrderEntry.FindFirst() then begin
            Result := ReOrderEntry."NAV Processed";
            ProcessedDateTime := ReOrderEntry."NAV Processed at DateTime";
            ErrorText := ReOrderEntry."NAV Processed Error Text";
        end;
    end;

    local procedure Initialize()
    begin
        ReOrderSetup.Get();
        ReOrderSetup.TestField("Order Nos.");
        if ReOrderSetup."Max Entries to Process" > 0 then
            MaxEntriesToProcess := ReOrderSetup."Max Entries to Process"
        else
            MaxEntriesToProcess := 10;
        EventLogCode := CopyStr('REORDERMGT',1,MaxStrLen(EventLogCode));
    end;

    procedure InstallReOrder()
    var
        JobQueue: Record "Job Queue Entry";
        TenantWebSvc: Record "Tenant Web Service";
    begin
        JobQueue.SetRange("Object Type to Run", JobQueue."Object Type to Run"::Codeunit);
        JobQueue.SetRange("Object ID to Run", Codeunit::"ARC ReOrderMgt");
        if JobQueue.IsEmpty() then begin
            JobQueue.Init();
            JobQueue."Object Type to Run" := JobQueue."Object Type to Run"::Codeunit;
            JobQueue."Object ID to Run" := Codeunit::"ARC ReOrderMgt";
            JobQueue.Insert(true);
            JobQueue.Validate("Object ID to Run");
            JobQueue."Run on Mondays" := true;
            JobQueue."Run on Tuesdays" := true;
            JobQueue."Run on Wednesdays" := true;
            JobQueue."Run on Thursdays" := true;
            JobQueue."Run on Fridays" := true;
            JobQueue."Run on Saturdays" := true;
            JobQueue."Run on Sundays" := true;
            JobQueue."Recurring Job" := true;
            JobQueue."Earliest Start Date/Time" := CurrentDateTime;
            JobQueue."Starting Time" := 010000T;
            JobQueue."Ending Time" := 235900T;
            JobQueue."No. of Minutes between Runs" := 1;
            JobQueue.Modify(true);
            JobQueue.SetStatus(JobQueue.Status::Ready);
        end;
        TenantWebSvc.SetRange("Object Type", TenantWebSvc."Object Type"::Codeunit);
        TenantWebSvc.SetRange("Object ID", Codeunit::"ARC ReOrderMgt");
        TenantWebSvc.SetRange("Service Name", 'ReOrderMgt');
        if TenantWebSvc.IsEmpty() then begin
            TenantWebSvc.Init();
            TenantWebSvc."Object Type" := TenantWebSvc."Object Type"::Codeunit;
            TenantWebSvc."Object ID" := Codeunit::"ARC ReOrderMgt";
            TenantWebSvc."Service Name" := 'ReOrderMgt';
            TenantWebSvc.Insert();
            TenantWebSvc.Validate(Published, true);
            TenantWebSvc.Modify();
        end;
        Clear(TenantWebSvc);
        TenantWebSvc.Reset();
        TenantWebSvc.SetRange("Object Type", TenantWebSvc."Object Type"::Page);
        TenantWebSvc.SetRange("Object ID", Page::"ARC ReOrder Entries");
        TenantWebSvc.SetRange("Service Name", 'ReOrderEntries');
        if TenantWebSvc.IsEmpty() then begin
            TenantWebSvc.Init();
            TenantWebSvc."Object Type" := TenantWebSvc."Object Type"::Page;
            TenantWebSvc."Object ID" := Page::"ARC ReOrder Entries";
            TenantWebSvc."Service Name" := 'ReOrderEntries';
            TenantWebSvc.Insert;
            TenantWebSvc.Validate(Published, true);
            TenantWebSvc.Modify();
        end;
    end;

    local procedure ProcessEntries()
    var
        ReOrderEntry: Record "ARC ReOrder Entry";
        ReOrderEntry2: Record "ARC ReOrder Entry";
        ReOrderMgt: Codeunit "ARC ReOrderMgt";
        result: Boolean;
        NoOfAttempts: Integer;
        NoOfOrdersProcessed: Integer;
        errorText: Text[250];
        ReOrderID: Text[50];
        TimeBegin: Time;
        TimeEnd: Time;
    begin
        ReOrderEntry.SetCurrentKey("NAV Processed");
        ReOrderEntry.SetRange("NAV Processed", 0);
        if not ReOrderEntry.FindSet(false) then
            exit;
        repeat
            if ReOrderEntry."ReOrder ID" <> ReOrderID then begin
                ReOrderID := CopyStr(ReOrderEntry."ReOrder ID",1,MaxStrLen(ReOrderID));
                // compare the no. of records to the line count before processing
                Clear(ReOrderEntry2);
                ReOrderEntry2.Reset();
                ReOrderEntry2.SetCurrentKey("ReOrder ID");
                ReOrderEntry2.SetRange("ReOrder ID",ReOrderID);
                ReOrderEntry2.SetRange("NAV Processed",0);
                if ReOrderEntry2.Count() = ReOrderEntry."ReOrder ID Line Count" then begin
                    NoOfAttempts := ReOrderEntry."NAV No. of Attempts" + 1;
                    Clear(errorText);
                    Clear(ReOrderMgt);
                    TimeBegin := Time();
                    ReOrderMgt.SetEntryNoToProcess(ReOrderEntry."Entry No.");
                    Commit();
                    result := ReOrderMgt.Run();
                    if not result then begin
                        errorText := CopyStr(GetLastErrorText(), 1, MaxStrLen(errorText));
                        Clear(ReOrderEntry2);
                        ReOrderEntry2.Reset();
                        ReOrderEntry2.SetCurrentKey("ReOrder ID");
                        ReOrderEntry2.SetRange("ReOrder ID", ReOrderID);
                        ReOrderEntry2.SetRange("NAV Processed", 0);
                        ReOrderEntry2.ModifyAll("NAV No. of Attempts", NoOfAttempts);
                        ReOrderEntry2.ModifyAll("NAV Processed at DateTime", CurrentDateTime());
                        ReOrderEntry2.ModifyAll("NAV Processed Error Text", CopyStr(errorText, 1, MaxStrLen(ReOrderEntry2."NAV Processed Error Text")));
                        TimeEnd := Time();
                        ReOrderEntry2.ModifyAll("NAV Processed Duration", TimeEnd - TimeBegin);
                        if NoOfAttempts >= 10 then
                            ReOrderEntry2.ModifyAll("NAV Processed", -1);
                        WriteLog(ReOrderEntry."Entry No.",'',errorText);
                    end;
                    NoOfOrdersProcessed += 1;
                end;
            end;
        until (ReOrderEntry.Next() = 0) or (NoOfOrdersProcessed >= MaxEntriesToProcess);
    end;

    local procedure ProcessEntry()
    var
        ReOrderEntry: Record "ARC ReOrder Entry";
        ReOrderEntry2: Record "ARC ReOrder Entry";
        SalesCommentLine: Record "Sales Comment Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        StandardText: Record "Standard Text";
        TempBuf: Record "ARC Buffer" temporary;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        _TempBufEntryNo: BigInteger;
        SalesHeaderInserted: Boolean;
        SalesLineInserted: Boolean;
        NavSalesOrderNo: Code[20];
        _dt: DateTime;
        LineNo: Integer;
        NavNoOfAttempts: Integer;
        NavSalesOrderLineNo: Integer;
        SalesHeaderInsertAttempts: Integer;
        SalesLineInsertAttempts: Integer;
        ReOrderID: Text[50];
        TimeEnd: Time;
        TimeBegin: Time;
        _Text000Err: Label 'Multiple attempts to insert a Sales Header record failed.  DocType %1, DocNo %2';
        _Text001Err: Label 'Multiple attempts to insert a Sales Line record failed.  DocType %1, DocNo %2, DocLineNo %3, Item %4, ReOrder Entry %5';
    begin
        TempBuf.DeleteAll();
        if EntryNoToProcess = 0 then
            exit;
        ReOrderEntry.Get(EntryNoToProcess);
        ReOrderEntry.TestField(SellToCustNo);
        ReOrderEntry.SetCurrentKey("ReOrder ID");
        ReOrderEntry.SetRange("ReOrder ID", ReOrderEntry."ReOrder ID");
        ReOrderEntry.SetRange("NAV Processed", 0);
        if ReOrderEntry.FindSet(false) then begin
            ReOrderID := CopyStr(ReOrderEntry."ReOrder ID",1,MaxStrLen(ReOrderID));
            NavNoOfAttempts := ReOrderEntry."NAV No. of Attempts" + 1;
            repeat
                TimeBegin := Time();
                TrimReOrderRec(ReOrderEntry);
                if NavSalesOrderNo = '' then begin
                    repeat
                        Clear(ReOrderSetup);
                        ReOrderSetup.Reset();
                        ReOrderSetup.LockTable();
                        ReOrderSetup.Get();
                        NavSalesOrderNo := IncStr(ReOrderSetup."Order Nos.");
                        ReOrderSetup."Order Nos." := CopyStr(NavSalesOrderNo,1,MaxStrLen(ReOrderSetup."Order Nos."));
                        ReOrderSetup.Modify(false);
                        ReOrderSetup.Reset();
                        NavSalesOrderLineNo := 10000;
                        Clear(SalesHeader);
                        SalesHeader.Reset();
                        SalesHeader.SetHideValidationDialog(true);
                        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                        SalesHeader."No." := NavSalesOrderNo;
                        SalesHeaderInserted := SalesHeader.Insert(true);
                        SalesHeaderInsertAttempts += 1;
                    until (SalesHeaderInserted) or (SalesHeaderInsertAttempts > 10);
                    if not SalesHeaderInserted then
                        Error(_Text000Err,SalesHeader."Document Type",SalesHeader."No.");
                    SalesHeader.Validate("Sell-to Customer No.",CopyStr(ReOrderEntry.SellToCustNo,1,MaxStrLen(SalesHeader."Sell-to Customer No.")));
                    if (ReOrderEntry.BillToCustNo <> '') and (ReOrderEntry.BillToCustNo <> ReOrderEntry.SellToCustNo) then
                        SalesHeader.Validate("Bill-to Customer No.",CopyStr(ReOrderEntry.BillToCustNo,1,MaxStrLen(SalesHeader."Bill-to Customer No.")));
                    if ReOrderEntry.LocationCode <> '' then
                        SalesHeader.Validate("Location Code",CopyStr(ReOrderEntry.LocationCode,1,MaxStrLen(SalesHeader."Location Code")));
                    if ReOrderEntry.ShipToCode <> '' then
                        SalesHeader.Validate("Ship-to Code",CopyStr(ReOrderEntry.ShipToCode,1,MaxStrLen(SalesHeader."Ship-to Code")));
                    if ReOrderEntry.RequestedDeliveryDate <> 0D then
                        SalesHeader.Validate("Requested Delivery Date", ReOrderEntry.RequestedDeliveryDate);
                    if ReOrderEntry."Shipment Method Code" <> '' then 
                       SalesHeader.Validate("Shipment Method Code",CopyStr(ReOrderEntry."Shipment Method Code",1,MaxStrLen(SalesHeader."Shipment Method Code")));
                    SalesHeader."External Document No." := CopyStr(ReOrderEntry."ReOrder ID",1,MaxStrLen(SalesHeader."External Document No."));
                    if ReOrderSetup."Order Source" <> '' then
                        SalesHeader."ARC Order Source Code" := CopyStr(ReOrderSetup."Order Source",1,MaxStrLen(SalesHeader."ARC Order Source Code"));
                    SalesHeader.Modify(true);
                    if ReOrderEntry.Comment <> '' then begin 
                        Clear(SalesLineInserted);
                        repeat
                            NavSalesOrderLineNo := Round(NavSalesOrderLineNo + 10000,10000,'>');
                            Clear(SalesLine);
                            SalesLine.Reset();
                            SalesLine.SetHideValidationDialog(true);
                            SalesLine."Document Type" := SalesLine."Document Type"::Order;
                            SalesLine."Document No." := CopyStr(NavSalesOrderNo,1,MaxStrLen(SalesLine."Document No."));
                            SalesLine."Line No." := NavSalesOrderLineNo;
                            SalesLineInserted := SalesLine.Insert(true);
                            SalesLineInsertAttempts += 1;
                        until SalesLineInserted or (SalesLineInsertAttempts > 10);
                        if not SalesLineInserted then
                            Error(_Text001Err,SalesLine."Document Type",SalesLine."Document No.",SalesLine."Line No.");
                        SalesLine.Validate(Type,SalesLine.Type::" ");
                        SalesLine.Description := CopyStr(ReOrderEntry.Comment,1,MaxStrLen(SalesLine.Description));
                        if Strlen(ReOrderEntry.Comment) > MaxStrLen(SalesLine.Description) then  
                            SalesLine."Description 2" := CopyStr(ReOrderEntry.Comment,50,30);
                        SalesLine.Modify(true);
                        NavSalesOrderLineNo += 10000;
                    end;
                end;
                Clear(SalesLineInserted);
                Clear(SalesLineInsertAttempts);
                repeat
                    NavSalesOrderLineNo := Round(NavSalesOrderLineNo + 10000,10000,'>');
                    Clear(SalesLine);
                    SalesLine.Reset();
                    SalesLine.SetHideValidationDialog(true);
                    SalesLine."Document Type" := SalesLine."Document Type"::Order;
                    SalesLine."Document No." := CopyStr(NavSalesOrderNo,1,MaxStrLen(SalesLine."Document No."));
                    SalesLine."Line No." := NavSalesOrderLineNo;
                    SalesLineInserted := SalesLine.Insert(true);
                    SalesLineInsertAttempts += 1;
                until SalesLineInserted or (SalesLineInsertAttempts > 10);
                if not SalesLineInserted then
                    Error(_Text001Err,SalesLine."Document Type",SalesLine."Document No.",SalesLine."Line No.",ReOrderEntry.ItemNo,ReOrderEntry."Entry No.");
                SalesLine.Validate(Type, SalesLine.Type::Item);
                SalesLine.Validate("No.", CopyStr(ReOrderEntry.ItemNo,1,MaxStrLen(SalesLine."No.")));
                if ReOrderEntry.ItemVariant <> '' then
                    SalesLine.Validate("Variant Code", CopyStr(ReOrderEntry.ItemVariant,1,MaxStrLen(SalesLine."Variant Code")));
                if ReOrderEntry.ItemUnitOfMeasure <> '' then
                    SalesLine.Validate("Unit of Measure Code", CopyStr(ReOrderEntry.ItemUnitOfMeasure,1,MaxStrLen(SalesLine."Unit of Measure Code")));
                SalesLine.Validate(Quantity, ReOrderEntry.Quantity);
                if ReOrderEntry.UnitPrice <> 0 then
                    SalesLine.Validate("Unit Price", ReOrderEntry.UnitPrice);
                SalesLine.Validate("Requested Delivery Date", ReOrderEntry.RequestedDeliveryDate);
                SalesLine.Modify(true);
                _TempBufEntryNo += 1;
                TempBuf."Entry No." := _TempBufEntryNo;
                TempBuf."BigInteger 01" := ReOrderEntry."Entry No.";
                TempBuf."Code 01" := CopyStr(NavSalesOrderNo,1,MaxStrLen(TempBuf."Code 01"));
                TempBuf."Integer 01" := NavSalesOrderLineNo;
                TempBuf.Insert(false);
            until ReOrderEntry.Next() = 0;
            _dt := CurrentDateTime();
            TimeEnd := Time();
            if TempBuf.FindSet(false) then
                repeat
                    ReOrderEntry2.LockTable();
                    ReOrderEntry2.Get(TempBuf."BigInteger 01");
                    ReOrderEntry2."NAV Processed Duration" := TimeEnd - TimeBegin;
                    ReOrderEntry2."NAV Processed at DateTime" := _dt;
                    ReOrderEntry2."NAV No. of Attempts" := NavNoOfAttempts;
                    ReOrderEntry2."NAV Sales Order No." := CopyStr(TempBuf."Code 01",1,MaxStrLen(ReOrderEntry2."NAV Sales Order No."));
                    ReOrderEntry2."NAV Sales Order Line No." := TempBuf."Integer 01";
                    ReOrderEntry2."NAV Processed" := 1;
                    ReOrderEntry2.Modify(false);
                    ReOrderEntry2.Reset();
                    Clear(ReOrderEntry2);
                until TempBuf.Next() = 0;
        end;
    end;

    local procedure SendNotifEntries()
    var
        _EventLogEntry: Record "ARC Event Log Entry";
        _EventLogEntry2: Record "ARC Event Log Entry";
        _ReOrderMgt: Codeunit "ARC ReOrderMgt";
        _result: Boolean;
        _entriesProcessed: Integer;
    begin
        _EventLogEntry.SetCurrentKey(Code,"Notification to be Sent");
        _EventLogEntry.SetRange(Code,EventLogCode);
        _EventLogEntry.SetRange("Notification to be Sent",true);
        _EventLogEntry.SetRange("Notification Sent",0);
        if _EventLogEntry.FindSet(false) then
            repeat
                Clear(_ReOrderMgt);
                _ReOrderMgt.SetEntryNoToNotify(_EventLogEntry."Entry No.");
                Commit();
                _result := _ReOrderMgt.Run();
                if not _result then begin
                    Clear(_EventLogEntry2);
                    _EventLogEntry2.Reset();
                    _EventLogEntry2.LockTable();
                    _EventLogEntry2.Get(_EventLogEntry."Entry No.");
                    _EventLogEntry2."Notification Sent" := -1;
                    _EventLogEntry2."Notification Error Text" := CopyStr(GetLastErrorText(),1,MaxStrLen(_EventLogEntry2."Notification Error Text"));
                    _EventLogEntry2."Notification Sent at DateTime" := CurrentDateTime();
                    _EventLogEntry2.Modify(false);
                end;
                _entriesProcessed += 1;
            until (_EventLogEntry.Next() = 0) or (_entriesProcessed > MaxEntriesToProcess);
    end;

    local procedure SendNotifEntry()
    var
        _EventLogEntry: Record "ARC Event Log Entry";
        _SmtpSetup: Record "SMTP Mail Setup";
        _SmtpMail: Codeunit "SMTP Mail";
        _CR: Char;
        _NL: Char;
        _addrTo: Text;
        _bodyText: Text;
        _CRNL: Text;
        _subjText: Text;
        _defaultSubj: Label 'Business Central Error Notification: ReOrder';
        _defaultBody1: Label 'Error Text: %1';
        _defaultBody2: Label 'Message Text: %1';
        _defaultBody3: Label 'Code: %1';
        _defaultBody4: Label 'User: %1';
        _defaultBody5: Label 'DateTime: %1';
        _defaultBody6: Label 'Obj. Type: %1';
        _defaultBody7: Label 'Obj. ID: %1';
        _defaultBody8: Label 'Related EntryNo: %1';
    begin
        _CR := 13;
        _NL := 10;
        _CRNL := CopyStr(Format(_CR) + Format(_NL),1,MaxStrLen(_CRNL));
        _EventLogEntry.Get(EntryNoToNotify);
        if _EventLogEntry.Status <> _EventLogEntry.Status::Error then
            exit;
        _SmtpSetup.Get();
        _SmtpSetup.TestField("User ID");
        _SmtpSetup.TestField("SMTP Server");
        ReOrderSetup.TestField("SMTP Errors Notif. Email From");
        ReOrderSetup.TestField("SMTP Errors Notif. Email To");
        if ReOrderSetup."SMTP Errors Notif. Email Subj." = '' then
            _subjText := CopyStr(_defaultSubj,1,MaxStrLen(_subjText))
        else
            _subjText := CopyStr(ReOrderSetup."SMTP Errors Notif. Email Subj.",1,MaxStrLen(_subjText));
        _addrTo := CopyStr(_EventLogEntry."Notification E-Mail Addresses",1,MaxStrLen(_addrTo));
        if _addrTo = '' then
            _addrTo := CopyStr(ReOrderSetup."SMTP Errors Notif. Email To",1,MaxStrLen(_addrTo));
        _bodyText := CopyStr(StrSubstNo(_defaultBody1,_EventLogEntry."Error Text"),1,MaxStrLen(_bodyText));
        _bodyText := CopyStr(_bodyText + _CRNL + StrSubstNo(_defaultBody2,_EventLogEntry."Message Text"),1,MaxStrLen(_bodyText));
        _bodyText := CopyStr(_bodyText + _CRNL + StrSubstNo(_defaultBody3,_EventLogEntry.Code),1,MaxStrLen(_bodyText));
        _bodyText := CopyStr(_bodyText + _CRNL + StrSubstNo(_defaultBody4,_EventLogEntry."Created by"),1,MaxStrLen(_bodyText));
        _bodyText := CopyStr(_bodyText + _CRNL + StrSubstNo(_defaultBody5,_EventLogEntry."Created at DateTime"),1,MaxStrLen(_bodyText));
        _bodyText := CopyStr(_bodyText + _CRNL + StrSubstNo(_defaultBody6,_EventLogEntry."Object Type"),1,MaxStrLen(_bodyText));
        _bodyText := CopyStr(_bodyText + _CRNL + StrSubstNo(_defaultBody7,_EventLogEntry."Object ID"),1,MaxStrLen(_bodyText));
        _bodyText := CopyStr(_bodyText + _CRNL + StrSubstNo(_defaultBody8,_EventLogEntry."Related Entry No.") + _CRNL + _CRNL,1,MaxStrLen(_bodyText));
        _SmtpMail.CreateMessage(UserId(),ReOrderSetup."SMTP Errors Notif. Email From",_addrTo,_subjText,_bodyText,false);
        _SmtpMail.Send();
    end;

    procedure SetEntryNoToNotify(_EntryNoToNotify: BigInteger)
    begin
        EntryNoToNotify := _EntryNoToNotify;
    end;

    procedure SetEntryNoToProcess(_newEntryNoToProcess: BigInteger)
    begin
        EntryNoToProcess := _newEntryNoToProcess;
    end;
    
    procedure SetJobQueueEntryOnHold(): Text
    var
        JobQueue: Record "Job Queue Entry";
        Text000Msg: TextConst ENU='Status is %1. Earliest Start Date/Time is %2.';
    begin
        JobQueue.SetRange("Object Type to Run", JobQueue."Object Type to Run"::Codeunit);
        JobQueue.SetRange("Object ID to Run", Codeunit::"ARC ReOrderMgt");
        if not JobQueue.FindFirst() then
            exit;
        JobQueue.SetStatus(JobQueue.Status::"On Hold");
        exit(StrSubstNo(Text000Msg,JobQueue.Status,JobQueue."Earliest Start Date/Time"));
    end;

    procedure SetJobQueueEntryReady(): Text
    var
        JobQueue: Record "Job Queue Entry";
        Text000Msg: TextConst ENU='Status is %1. Earliest Start Date/Time is %2.';
    begin
        JobQueue.SetRange("Object Type to Run", JobQueue."Object Type to Run"::Codeunit);
        JobQueue.SetRange("Object ID to Run", Codeunit::"ARC ReOrderMgt");
        if not JobQueue.FindFirst() then
            exit;
        JobQueue.SetStatus(JobQueue.Status::Ready);
        exit(StrSubstNo(Text000Msg,JobQueue.Status,JobQueue."Earliest Start Date/Time"));
    end;

    procedure ShowJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        Text000Err: TextConst ENU='Not allowed via web service.';
    begin
        if not GuiAllowed() then
            Error(Text000Err);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"ARC ReOrderMgt");
        Page.Run(Page::"Job Queue Entries", JobQueueEntry);
    end;

    procedure ShowSalesOrder(ReOrderEntry: Record "ARC ReOrder Entry")
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        Text000Err: TextConst ENU = 'No sales order or posted sales invoice documents were found.';
        Text001Err: TextConst ENU = 'Not allowed via web service.';
    begin
        if not GuiAllowed() then
            Error(Text001Err);
        ReOrderEntry.TestField("NAV Sales Order No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", ReOrderEntry."NAV Sales Order No.");
        if SalesHeader.FindFirst() then begin
            Page.Run(Page::"Sales Order", SalesHeader);
            exit;
        end;
        SalesInvHeader.SetCurrentKey("Order No.");
        SalesInvHeader.SetRange("Order No.", ReOrderEntry."NAV Sales Order No.");
        if not SalesInvHeader.FindSet(false) then
            Error(Text000Err);
        Page.Run(Page::"Posted Sales Invoices", SalesInvHeader);
    end;

    procedure TestReOrderAppln(): Text[50]
    var
        Customer: Record Customer;
        ReOrderEntry: Record "ARC ReOrder Entry";
        _guid: Guid;
        _guidText: Text;
        Text000Err: TextConst ENU='Not allowed via web service.';
    begin
        _guid := CreateGuid();
        _guidText := DelChr(Format(_guid),'<>','{}');
        if not GuiAllowed() then
            Error(Text000Err);
        Customer.Get('5013722');
        ReOrderEntry.Init();
        ReOrderEntry."Entry No." := 0;
        ReOrderEntry."ReOrder ID" := CopyStr(_guidText,1,MaxStrLen(ReOrderEntry."ReOrder ID"));
        ReOrderEntry.SellToCustNo := CopyStr(Customer."No.",1,MaxStrLen(ReOrderEntry.SellToCustNo));
        ReOrderEntry.ItemNo := CopyStr('I503317',1,MaxStrLen(ReOrderEntry.ItemNo));
        ReOrderEntry.Quantity := 2;
        ReOrderEntry.RequestedDeliveryDate := CalcDate('1W',Today());
        ReOrderEntry.Insert(true);
        ReOrderEntry."Entry No." := 0;
        ReOrderEntry.ItemNo := CopyStr('I503586',1,MaxStrLen(ReOrderEntry.ItemNo));
        ReOrderEntry.Quantity := 1;
        ReOrderEntry.Insert(true);
        ReOrderEntry."Entry No." := 0;
        ReOrderEntry.ItemNo := CopyStr('I504081',1,MaxStrLen(ReOrderEntry.ItemNo));
        ReOrderEntry.Quantity := 5;
        ReOrderEntry.Insert(true);
        ReOrderEntry."Entry No." := 0;
        ReOrderEntry.ItemNo := CopyStr('I504273',1,MaxStrLen(ReOrderEntry.ItemNo));
        ReOrderEntry.Quantity := 3;
        ReOrderEntry.Insert(true);
        ReOrderEntry."Entry No." := 0;
        ReOrderEntry.ItemNo := CopyStr('I504984',1,MaxStrLen(ReOrderEntry.ItemNo));
        ReOrderEntry.Quantity := 4;
        ReOrderEntry.Insert(true);
        ReOrderEntry."Entry No." := 0;
        ReOrderEntry.ItemNo := CopyStr('I504988',1,MaxStrLen(ReOrderEntry.ItemNo));
        ReOrderEntry.Quantity := 2;
        ReOrderEntry.Insert(true);
        ReOrderEntry."Entry No." := 0;
        ReOrderEntry.ItemNo := CopyStr('I505805',1,MaxStrLen(ReOrderEntry.ItemNo));
        ReOrderEntry.Quantity := 1;
        ReOrderEntry.Insert(true);
        ReOrderEntry."Entry No." := 0;
        ReOrderEntry.ItemNo := CopyStr('I505806',1,MaxStrLen(ReOrderEntry.ItemNo));
        ReOrderEntry.Quantity := 5;
        ReOrderEntry.Insert(true);
        ReOrderEntry."Entry No." := 0;
        ReOrderEntry.ItemNo := CopyStr('I506109',1,MaxStrLen(ReOrderEntry.ItemNo));
        ReOrderEntry.Quantity := 3;
        ReOrderEntry.Insert(true);
        ReOrderEntry."Entry No." := 0;
        ReOrderEntry.ItemNo := CopyStr('I506561',1,MaxStrLen(ReOrderEntry.ItemNo));
        ReOrderEntry.Quantity := 4;
        ReOrderEntry.Insert(true);
        ReOrderEntry."Entry No." := 0;
        ReOrderEntry.ItemNo := CopyStr('I509005',1,MaxStrLen(ReOrderEntry.ItemNo));
        ReOrderEntry.Quantity := 2;
        ReOrderEntry.Insert(true);
        ReOrderEntry."Entry No." := 0;
        ReOrderEntry.ItemNo := CopyStr('I509084',1,MaxStrLen(ReOrderEntry.ItemNo));
        ReOrderEntry.Quantity := 1;
        ReOrderEntry.Insert(true);
        ReOrderEntry."Entry No." := 0;
        ReOrderEntry.ItemNo := CopyStr('I512413',1,MaxStrLen(ReOrderEntry.ItemNo));
        ReOrderEntry.Quantity := 5;
        ReOrderEntry.Insert(true);
        ReOrderEntry."Entry No." := 0;
        ReOrderEntry.ItemNo := CopyStr('I512444',1,MaxStrLen(ReOrderEntry.ItemNo));
        ReOrderEntry.Quantity := 3;
        ReOrderEntry.Insert(true);
        ReOrderEntry."Entry No." := 0;
        ReOrderEntry.ItemNo := CopyStr('I513231',1,MaxStrLen(ReOrderEntry.ItemNo));
        ReOrderEntry.Quantity := 4;
        ReOrderEntry.Insert(true);
        exit(_guidText);
    end;

    local procedure TrimReOrderRec(var ReOrderEntry: Record "ARC ReOrder Entry")
    begin
        ReOrderEntry."ReOrder ID" := ReOrderEntry."ReOrder ID".Trim();
        ReOrderEntry.SellToCustNo := ReOrderEntry.SellToCustNo.Trim();
        ReOrderEntry.BillToCustNo := ReOrderEntry.BillToCustNo.Trim();
        ReOrderEntry.ShipToCode := ReOrderEntry.ShipToCode.Trim();
        ReOrderEntry.LocationCode := ReOrderEntry.LocationCode.Trim();
        ReOrderEntry.ItemNo := ReOrderEntry.ItemNo.Trim();
        ReOrderEntry.ItemVariant := ReOrderEntry.ItemVariant.Trim();
        ReOrderEntry.ItemUnitOfMeasure := ReOrderEntry.ItemUnitOfMeasure.Trim();
        ReOrderEntry.Comment := ReOrderEntry.Comment.Trim();
    end;

    local procedure WriteLog(_relatedEntryNo: BigInteger; _msgText: Text; _errText: Text)
    var
        _EventLogEntry: Record "ARC Event Log Entry";
        _ReOrderSetup: Record "ARC Reorder Setup";
        _sendNotif: Boolean;
        _status: Integer;
        _emailAddr: Text;
    begin
        if _errText <> '' then begin
            _status := _EventLogEntry.Status::Error;
            if _ReOrderSetup.Get() then
                if _ReOrderSetup."SMTP Errors Notif. Email To" <> '' then begin
                    _sendNotif := true;
                    _emailAddr := CopyStr(_ReOrderSetup."SMTP Errors Notif. Email To",1,MaxStrLen(_emailAddr));
                end;
        end else
            _status := _EventLogEntry.Status::Message;
        _EventLogEntry.NewEventLogEntry(EventLogCode,_EventLogEntry."Object Type"::Codeunit,Codeunit::"ARC ReOrderMgt",_status,_relatedEntryNo,_msgText,_errText,_sendNotif,_emailAddr);
    end;
}
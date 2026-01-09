codeunit 50042 "ARC APL Management"
{
    Permissions = tabledata 50042=rim;

    trigger OnRun();
    begin
        if MaxEntriesToProcess = 0 then
            MaxEntriesToProcess := 50;
        if MaxNoOfAttempts = 0 then
            MaxNoOfAttempts := 5;
        if EntryNoToProcess <> 0 then begin
            ProcessEntry;
            exit;
        end;
        ProcessEntries;
    end;

    procedure ApproveRejectReviewEntry(_APLReviewEntry: Record "ARC APL Review Entry"; _Approve: Boolean; _Doc: Boolean)
    var
        _APLReviewEntry2: Record "ARC APL Review Entry";
        _GenConfDialog: Page "General Confirmation Dialog";
        _RejectText: Text[250];
        _Text000Msg: TextConst ENU='Enter reason for rejection';
        _Text001Msg: TextConst ENU='Rejected by %1';
        _Text002Err: TextConst ENU='Rejection reason required.';
        _Text003Msg: TextConst ENU='Enter reason for rejection:';
    begin
        if not _Approve then begin
            _RejectText := CopyStr(StrSubstNo(_Text001Msg,UserId()),1,MaxStrLen(_RejectText));
            _GenConfDialog.SetInstructionalText(_Text003Msg);
            _GenConfDialog.SetWindowTitle(_Text000Msg);
            _GenConfDialog.SetTextValue(_RejectText);
            _GenConfDialog.SetTextVisible;
            if _GenConfDialog.RunModal in ["Action"::LookupOK,"Action"::OK,"Action"::Yes] then begin
                _RejectText := CopyStr(_GenConfDialog.GetTextValue,1,MaxStrLen(_RejectText));
                _RejectText := _RejectText.Trim();
                if _RejectText = '' then
                    Error(_Text002Err);
            end else
                exit;
        end;
        if not _Doc then begin
            _APLReviewEntry2.SetRange("Entry No.",_APLReviewEntry."Entry No.");
        end else begin
            _APLReviewEntry2.SetRange("Document Area",_APLReviewEntry."Document Area");
            _APLReviewEntry2.SetRange("Document Type",_APLReviewEntry."Document Type");
            _APLReviewEntry2.SetRange("Document No.",_APLReviewEntry."Document No.");
        end;
        _APLReviewEntry2.LockTable();
        _APLReviewEntry2.ModifyAll("Reviewed at DateTime",CurrentDateTime);
        _APLReviewEntry2.ModifyAll("Reviewed by",UserId());
        if _Approve then begin
            _APLReviewEntry2.ModifyAll(Reviewed,1);
        end else begin
            _APLReviewEntry2.ModifyAll(Reviewed,-1);
            _APLReviewEntry2.modifyall("Reviewed Error Text",_RejectText);
        end;
    end;

    local procedure CheckInsReviewEntrySales(_SalesHeader: Record "Sales Header"; _SalesLine: Record "Sales Line")
    var
        _APLReviewEntry: Record "ARC APL Review Entry";
    begin
        _APLReviewEntry.SetCurrentKey("Document Area");
        _APLReviewEntry.SetRange("Document Area",_APLReviewEntry."Document Area"::Sales);
        _APLReviewEntry.SetRange("Document Type",_SalesHeader."Document Type");
        _APLReviewEntry.SetRange("Document No.",_SalesHeader."No.");
        _APLReviewEntry.SetRange("Document Line No.",_SalesLine."Line No.");
        if not _APLReviewEntry.IsEmpty then
            exit;
        _APLReviewEntry.Init;
        _APLReviewEntry."Entry No." := 0;
        _APLReviewEntry."Document Area" := _APLReviewEntry."Document Area"::Sales;
        _APLReviewEntry."Document Type" := _SalesHeader."Document Type";
        _APLReviewEntry."Document No." := _SalesHeader."No.";
        _APLReviewEntry."Document Line No." := _SalesLine."Line No.";
        _APLReviewEntry."Sell-to Customer No." := _SalesHeader."Sell-to Customer No.";
        _APLReviewEntry."Sell-to Customer Name" := _SalesHeader."Sell-to Customer Name";
        _APLReviewEntry."Sell-to Customer Name 2" := _SalesHeader."Sell-to Customer Name 2";
        _APLReviewEntry."Sell-to Address" := _SalesHeader."Sell-to Address";
        _APLReviewEntry."Sell-to Address 2" := _SalesHeader."Sell-to Address 2";
        _APLReviewEntry."Sell-to City" := _SalesHeader."Sell-to City";
        _APLReviewEntry."Sell-to County" := _SalesHeader."Sell-to County";
        _APLReviewEntry."Sell-to Post Code" := _SalesHeader."Sell-to Post Code";
        _APLReviewEntry."Bill-to Customer No." := _SalesHeader."Bill-to Customer No.";
        _APLReviewEntry."Bill-to Customer Name" := _SalesHeader."Bill-to Name";
        _APLReviewEntry."Bill-to Customer Name 2" := _SalesHeader."Bill-to Name 2";
        _APLReviewEntry."Bill-to Address" := _SalesHeader."Bill-to Address";
        _APLReviewEntry."Bill-to Address 2" := _SalesHeader."Bill-to Address 2";
        _APLReviewEntry."Bill-to City" := _SalesHeader."Bill-to City";
        _APLReviewEntry."Bill-to County" := _SalesHeader."Bill-to County";
        _APLReviewEntry."Bill-to Post Code" := _SalesHeader."Bill-to Post Code";
        _APLReviewEntry."Ship-to Post Code" := _SalesHeader."Ship-to Code";
        _APLReviewEntry."Ship-to Name" := _SalesHeader."Ship-to Name";
        _APLReviewEntry."Ship-to Address" := _SalesHeader."Ship-to Address";
        _APLReviewEntry."Ship-to Address 2" := _SalesHeader."Ship-to Address 2";
        _APLReviewEntry."Ship-to City" := _SalesHeader."Ship-to City";
        _APLReviewEntry."Ship-to County" := _SalesHeader."Ship-to County";
        _APLReviewEntry."Ship-to Post Code" := _SalesHeader."Ship-to Post Code";
        _APLReviewEntry."Item No." := _SalesLine."No.";
        _APLReviewEntry.Description := _SalesLine.Description;
        _APLReviewEntry.Quantity := _SalesLine.Quantity;
        _APLReviewEntry."Unit Price" := _SalesLine."Unit Price";
        _APLReviewEntry."Line Amount" := _SalesLine."Line Amount";
        _APLReviewEntry.Insert(true);
        // TO-DO: notification entry
    end;

    procedure ClearAPL()
    var
        _Item: Record Item;
        _Text000Qst: TextConst ENU='Clear APL flag on ALL item records.  Are you SURE?';
        _Text001Msg: TextConst ENU='Done.';
    begin
        if Confirm(_Text000Qst) then begin
            _Item.ModifyAll("ARC APL",false);
            Message(_Text001Msg);
        end;
    end;

    procedure DeleteEntry(_APLEntry: Record "ARC APL Entry")
    var
        _Text000Qst: TextConst ENU='Delete entry?';
        _Text001Msg: TextConst ENU='Done.';
    begin
        if Confirm(_Text000Qst,false) then begin
            _APLEntry.Delete;
            Message(_Text001Msg);
        end;
    end;

    procedure DeleteAllEntries(_APLEntry: Record "ARC APL Entry")
    var
        _Text000Qst: TextConst ENU='Are you sure you want to delete ALL entries?';
        _Text001Msg: TextConst ENU='Done.';
    begin
        if Confirm(_Text000Qst,false) then begin
            _APLEntry.DeleteAll;
            Message(_Text001Msg);
        end;
    end;

    procedure EntryReviewPartOneSales(_SalesHeader: Record "Sales Header"; _PreviewMode: Boolean)
    var
        _CustomerBillTo: Record Customer;
        _CustomerSellTo: Record Customer;
        _Item: Record Item;
        _SalesLine: Record "Sales Line";
    begin
        if _PreviewMode then
            exit;
        if not _CustomerBillTo.Get(_SalesHeader."Bill-to Customer No.") then
            exit;
        if not _CustomerSellTo.Get(_SalesHeader."Sell-to Customer No.") then
            exit;
        if (not _CustomerBillTo."ARC Internal Customer") and (not _CustomerSellTo."ARC Internal Customer") then
            exit;
        _SalesLine.SetRange("Document Type",_SalesHeader."Document Type");
        _SalesLine.SetRange("Document No.",_SalesHeader."No.");
        _SalesLine.SetRange(Type,_SalesLine.Type::Item);
        _SalesLine.SetFilter("Outstanding Qty. (Base)",'<>0');
        if _SalesLine.FindSet(false) then
            repeat
                if _Item.Get(_SalesLine."No.") then
                    if not _Item."ARC APL" then begin
                        CheckInsReviewEntrySales(_SalesHeader,_SalesLine);
                    end;
            until _SalesLine.Next = 0;
    end;

    procedure EntryReviewPartTwoSales(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    var
        _APLReviewEntry: Record "ARC APL Review Entry";
        _ReleaseSalesDoc: Codeunit "Release Sales Document";
        _MyNotification: Notification;
        _Text000Msg: TextConst ENU='One or more non-approved products were detected for an internal customer.  Please review.  Document is not released.';
    begin
        _APLReviewEntry.SetCurrentKey("Document Area");
        _APLReviewEntry.SetRange("Document Area",_APLReviewEntry."Document Area"::Sales);
        _APLReviewEntry.SetRange("Document Type",SalesHeader."Document Type");
        _APLReviewEntry.SetRange("Document No.",SalesHeader."No.");
        _APLReviewEntry.SetRange(Reviewed,-1,0);
        if not _APLReviewEntry.IsEmpty then begin
            _ReleaseSalesDoc.Reopen(SalesHeader);
            _MyNotification.Message(_Text000Msg);
            _MyNotification.Scope := _MyNotification.Scope::LocalScope;
            _MyNotification.Send;
        end;
    end;

    procedure InstallAPL()
    var
        _JobQueue: Record "Job Queue Entry";
        _TenantWebSvc: Record "Tenant Web Service";
    begin
        _JobQueue.SetRange("Object Type to Run", _JobQueue."Object Type to Run"::Codeunit);
        _JobQueue.SetRange("Object ID to Run", Codeunit::"ARC APL Management");
        if _JobQueue.IsEmpty() then begin
            _JobQueue.Init();
            _JobQueue."Object Type to Run" := _JobQueue."Object Type to Run"::Codeunit;
            _JobQueue."Object ID to Run" := Codeunit::"ARC APL Management";
            _JobQueue.Insert(true);
            _JobQueue.Validate("Object ID to Run");
            _JobQueue."Run on Mondays" := true;
            _JobQueue."Run on Tuesdays" := true;
            _JobQueue."Run on Wednesdays" := true;
            _JobQueue."Run on Thursdays" := true;
            _JobQueue."Run on Fridays" := true;
            _JobQueue."Run on Saturdays" := true;
            _JobQueue."Run on Sundays" := true;
            _JobQueue."Recurring Job" := true;
            _JobQueue."Earliest Start Date/Time" := CurrentDateTime;
            _JobQueue."Starting Time" := 010000T;
            _JobQueue."Ending Time" := 235900T;
            _JobQueue."No. of Minutes between Runs" := 1;
            _JobQueue.Modify(true);
            _JobQueue.SetStatus(_JobQueue.Status::Ready);
        end;
        _TenantWebSvc.SetRange("Object Type", _TenantWebSvc."Object Type"::Page);
        _TenantWebSvc.SetRange("Object ID", Page::"ARC APL Entries");
        _TenantWebSvc.SetRange("Service Name", 'PageAPLEntries');
        if _TenantWebSvc.IsEmpty() then begin
            _TenantWebSvc.Init();
            _TenantWebSvc."Object Type" := _TenantWebSvc."Object Type"::Page;
            _TenantWebSvc."Object ID" := Page::"ARC APL Entries";
            _TenantWebSvc."Service Name" := 'PageAPLEntries';
            _TenantWebSvc.Insert();
            _TenantWebSvc.Validate(Published, true);
            _TenantWebSvc.Modify();
        end;
        Clear(_TenantWebSvc);
        _TenantWebSvc.Reset();
        _TenantWebSvc.SetRange("Object Type", _TenantWebSvc."Object Type"::Query);
        _TenantWebSvc.SetRange("Object ID", Query::"ARC APL Entries");
        _TenantWebSvc.SetRange("Service Name", 'QueryAPLEntries');
        if _TenantWebSvc.IsEmpty() then begin
            _TenantWebSvc.Init();
            _TenantWebSvc."Object Type" := _TenantWebSvc."Object Type"::Query;
            _TenantWebSvc."Object ID" := Query::"ARC APL Entries";
            _TenantWebSvc."Service Name" := 'QueryAPLEntries';
            _TenantWebSvc.Insert;
            _TenantWebSvc.Validate(Published, true);
            _TenantWebSvc.Modify();
        end;
    end;

    procedure OnAfterValidateCustPostGrpOnCustomerAPL(var Rec: Record Customer)
    var
        _CustPostingGroup: Record "Customer Posting Group";
    begin
        if _CustPostingGroup.Get(Rec."Customer Posting Group") then begin
            if  _CustPostingGroup."ARC Internal Customer" then
                Rec."ARC Internal Customer" := true
            else
                Rec."ARC Internal Customer" := false;
        end;
    end;

    local procedure ProcessEntries()
    var
        _APLEntry: Record "ARC APL Entry";
        _APLEntry2: Record "ARC APL Entry";
        _APLManagement: Codeunit "ARC APL Management";
        _result: Boolean;
        _EntriesProcessed: Integer;
        _NoOfAttempts: Integer;
        _timeBegin: Time;
        _timeEnd: Time;
    begin
        _APLEntry.SetCurrentKey("NAV Processed");
        _APLEntry.SetRange("NAV Processed",0);
        if _APLEntry.FindSet(false) then
            repeat
                _timeBegin := Time();
                Clear(_APLManagement);
                Clear(_NoOfAttempts);
                _APLManagement.SetEntryNoToProcess(_APLEntry."Entry No.");
                Commit;
                _result := _APLManagement.Run;
                _timeEnd := Time();
                Clear(_APLEntry2);
                _APLEntry2.LockTable;
                _APLEntry2.Get(_APLEntry."Entry No.");
                if _result then 
                    _APLEntry2."NAV Processed" := 1
                else begin
                    _APLEntry2."NAV Processed Error Text" := CopyStr(GetLastErrorText,1,MaxStrLen(_APLEntry2."NAV Processed Error Text"));
                    _APLEntry2."NAV No. of Attempts" := _APLEntry2."NAV No. of Attempts" + 1;
                    if _APLEntry2."NAV No. of Attempts" >= MaxNoOfAttempts then
                        _APLEntry2."NAV Processed" := -1;
                end;
                _APLEntry2."NAV Processed at DateTime" := CurrentDateTime;
                _APLEntry2."NAV Processed Duration" := _timeEnd - _timeBegin;
                _APLEntry2.Modify();
                _EntriesProcessed += 1;
            until (_APLEntry.Next = 0) or (_EntriesProcessed >= MaxEntriesToProcess);
    end;

    local procedure ProcessEntry()
    var
        _APLEntry: Record "ARC APL Entry";
        _Item: Record Item;
    begin
        if EntryNoToProcess = 0 then
            exit;
        _APLEntry.Get(EntryNoToProcess);
        _Item.LockTable;
        _Item.Get(_APLEntry."Item No.");
        _Item."ARC APL" := true;
        _Item.Modify;
    end;

    procedure SetEntryNoToProcess(_EntryNoToProcess: Integer)
    begin
        EntryNoToProcess := _EntryNoToProcess;
    end;

    procedure SetMaxEntriesToProcess(_MaxEntriesToProcess: Integer)
    begin
        MaxEntriesToProcess := _MaxEntriesToProcess;
    end;

    procedure ShowDocument(_APLReviewEntry: Record "ARC APL Review Entry")
    var
        _SalesHeader: Record "Sales Header";
    begin
        case _APLReviewEntry."Document Area" of
          _APLReviewEntry."Document Area"::Sales:
            begin
                _SalesHeader.Get(_APLReviewEntry."Document Type",_APLReviewEntry."Document No.");
                _SalesHeader.SetRecFilter;
                case _SalesHeader."Document Type" of
                    _SalesHeader."Document Type"::Quote:  Page.Run(Page::"Sales Quote",_SalesHeader);
                    _SalesHeader."Document Type"::Order:  Page.Run(Page::"Sales Order",_SalesHeader);
                end;
            end;
        end;
    end;

    procedure ShowItemRec(_APLEntry: Record "ARC APL Entry")
    var
        _Item: Record Item;
    begin
        _Item.Get(_APLEntry."Item No.");
        _Item.SetRecFilter;
        Page.Run(Page::"Item Card",_Item);
    end;

    procedure ShowRecordsRelatedToItem(_Item: Record Item)
    var
        _APLEntry: Record "ARC APL Entry";
    begin
        _APLEntry.SetRange("Item No.",_Item."No.");
        Page.Run(Page::"ARC APL Entries",_APLEntry);
    end;

    procedure ShowSubstItemRec(_APLEntry: Record "ARC APL Entry")
    var
        _Item: Record Item;
    begin
        _Item.Get(_APLEntry."Substitution No.");
        _Item.SetRecFilter;
        Page.Run(Page::"Item Card",_Item);
    end;

    procedure TestAPL()
    var
        _APLEntry: Record "ARC APL Entry";
        _Item: Record Item;
        _Text000Qst: TextConst ENU='Submit test entry?';
    begin
        if GuiAllowed then
            if not Confirm(_Text000Qst,false) then
                exit;
        _Item.SetRange(Blocked,false);
        _Item.FindFirst;
        _APLEntry.Init;
        _APLEntry."Entry No." := 0;
        _APLEntry."Item No." := _Item."No.";
        _APLEntry."Unit of Measure Code" := _Item."Base Unit of Measure";
        _Item.Next;
        _APLEntry."Substitution No." := _Item."No.";
        _APLEntry.Ranking := 100;
        _APLEntry."Cost per Application" := 1;
        _APLEntry."Applications per UOM" := 100;
        _APLEntry.Insert(true);
    end;
    
    var
        EntryNoToProcess : Integer;
        MaxEntriesToProcess: Integer;
        MaxNoOfAttempts: Integer;
}
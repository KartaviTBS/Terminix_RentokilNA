codeunit 50044 "ARC VFM Management"
{
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

    procedure DeleteEntry(_VFMEntry: Record "ARC VFM Entry")
    var
        _Text000Qst: TextConst ENU='Delete entry?';
        _Text001Msg: TextConst ENU='Done.';
    begin
        if Confirm(_Text000Qst,false) then begin
            _VFMEntry.Delete;
            Message(_Text001Msg);
        end;
    end;

    procedure DeleteAllEntries(_VFMEntry: Record "ARC VFM Entry")
    var
        _Text000Qst: TextConst ENU='Are you sure you want to delete ALL entries?';
        _Text001Msg: TextConst ENU='Done.';
    begin
        if Confirm(_Text000Qst,false) then begin
            _VFMEntry.DeleteAll;
            Message(_Text001Msg);
        end;
    end;

    procedure InstallVFM()
    var
        _TenantWebSvc: Record "Tenant Web Service";
    begin
        _TenantWebSvc.SetRange("Object Type", _TenantWebSvc."Object Type"::Page);
        _TenantWebSvc.SetRange("Object ID", Page::"ARC VFM Entries");
        _TenantWebSvc.SetRange("Service Name", 'PageVFMEntries');
        if _TenantWebSvc.IsEmpty() then begin
            _TenantWebSvc.Init();
            _TenantWebSvc."Object Type" := _TenantWebSvc."Object Type"::Page;
            _TenantWebSvc."Object ID" := Page::"ARC VFM Entries";
            _TenantWebSvc."Service Name" := 'PageVFMEntries';
            _TenantWebSvc.Insert();
            _TenantWebSvc.Validate(Published, true);
            _TenantWebSvc.Modify();
        end;
        Clear(_TenantWebSvc);
        _TenantWebSvc.Reset();
        _TenantWebSvc.SetRange("Object Type", _TenantWebSvc."Object Type"::Query);
        _TenantWebSvc.SetRange("Object ID", Query::"ARC VFM Entries");
        _TenantWebSvc.SetRange("Service Name", 'QueryVFMEntries');
        if _TenantWebSvc.IsEmpty() then begin
            _TenantWebSvc.Init();
            _TenantWebSvc."Object Type" := _TenantWebSvc."Object Type"::Query;
            _TenantWebSvc."Object ID" := Query::"ARC VFM Entries";
            _TenantWebSvc."Service Name" := 'QueryVFMEntries';
            _TenantWebSvc.Insert;
            _TenantWebSvc.Validate(Published, true);
            _TenantWebSvc.Modify();
        end;
    end;

    local procedure ProcessEntries()
    var
        _VFMEntry: Record "ARC VFM Entry";
        _VFMEntry2: Record "ARC VFM Entry";
        _VFMManagement: Codeunit "ARC VFM Management";
        _result: Boolean;
        _EntriesProcessed: Integer;
        _NoOfAttempts: Integer;
        _timeBegin: Time;
        _timeEnd: Time;
    begin
        _VFMEntry.SetCurrentKey("NAV Processed");
        _VFMEntry.SetRange("NAV Processed",0);
        if _VFMEntry.FindSet(false) then
            repeat
                _timeBegin := Time();
                Clear(_VFMManagement);
                Clear(_NoOfAttempts);
                _VFMManagement.SetEntryNoToProcess(_VFMEntry."Entry No.");
                Commit;
                _result := _VFMManagement.Run;
                _timeEnd := Time();
                Clear(_VFMEntry2);
                _VFMEntry2.LockTable;
                _VFMEntry2.Get(_VFMEntry."Entry No.");
                if _result then 
                    _VFMEntry2."NAV Processed" := 1
                else begin
                    _VFMEntry2."NAV Processed Error Text" := CopyStr(GetLastErrorText,1,MaxStrLen(_VFMEntry2."NAV Processed Error Text"));
                    _VFMEntry2."NAV No. of Attempts" := _VFMEntry2."NAV No. of Attempts" + 1;
                    if _VFMEntry2."NAV No. of Attempts" >= MaxNoOfAttempts then
                        _VFMEntry2."NAV Processed" := -1;
                end;
                _VFMEntry2."NAV Processed at DateTime" := CurrentDateTime;
                _VFMEntry2."NAV Processed Duration" := _timeEnd - _timeBegin;
                _VFMEntry2.Modify();
                _EntriesProcessed += 1;
            until (_VFMEntry.Next = 0) or (_EntriesProcessed >= MaxEntriesToProcess);
    end;

    local procedure ProcessEntry()
    begin
        if EntryNoToProcess = 0 then
            exit;
    end;

    procedure SetEntryNoToProcess(_EntryNoToProcess: Integer)
    begin
        EntryNoToProcess := _EntryNoToProcess;
    end;

    procedure ShowItemRec(_VFMEntry: Record "ARC VFM Entry")
    var
        _Item: Record Item;
    begin
        _Item.Get(_VFMEntry."Item No.");
        _Item.SetRecFilter;
        Page.Run(Page::"Item Card",_Item);
    end;
 
    procedure ShowRecordsRelatedToItem(_Item: Record Item)
    var
        _VFMEntry: Record "ARC VFM Entry";
    begin
        _VFMEntry.SetRange("Item No.",_Item."No.");
        Page.Run(Page::"ARC VFM Entries",_VFMEntry);
    end;

    procedure ShowSubstItemRec(_VFMEntry: Record "ARC VFM Entry")
    var
        _Item: Record Item;
    begin
        _Item.Get(_VFMEntry."Substitution No.");
        _Item.SetRecFilter;
        Page.Run(Page::"Item Card",_Item);
    end;

    procedure TestVFM()
    var
        _VFMEntry: Record "ARC VFM Entry";
        _Item: Record Item;
        _Text000Qst: TextConst ENU='Submit test entry?';
    begin
        if GuiAllowed then
            if not Confirm(_Text000Qst,false) then
                exit;
        _Item.SetRange(Blocked,false);
        _Item.FindFirst;
        _VFMEntry.Init;
        _VFMEntry."Entry No." := 0;
        _VFMEntry."Item No." := _Item."No.";
        _VFMEntry."Unit of Measure Code" := _Item."Base Unit of Measure";
        _Item.Next;
        _VFMEntry."Substitution No." := _Item."No.";
        _VFMEntry.Ranking := 100;
        _VFMEntry."Cost per Application" := 1;
        _VFMEntry."Applications per UOM" := 100;
        _VFMEntry.Insert(true);
    end;

    var
        EntryNoToProcess : Integer;
        MaxEntriesToProcess: Integer;
        MaxNoOfAttempts: Integer;
}
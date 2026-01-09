codeunit 50045 "ARC SystemMappingMgt"
{
    trigger OnRun();
    begin
    end;

    procedure InstallSystemMapping()
    var
        _TenantWebSvc: Record "Tenant Web Service";
    begin
        _TenantWebSvc.SetRange("Object Type", _TenantWebSvc."Object Type"::Page);
        _TenantWebSvc.SetRange("Object ID", Page::"ARC System Mappings");
        _TenantWebSvc.SetRange("Service Name", 'PageSystemMappings');
        if _TenantWebSvc.IsEmpty() then begin
            _TenantWebSvc.Init();
            _TenantWebSvc."Object Type" := _TenantWebSvc."Object Type"::Page;
            _TenantWebSvc."Object ID" := Page::"ARC System Mappings";
            _TenantWebSvc."Service Name" := 'PageSystemMappings';
            _TenantWebSvc.Insert();
            _TenantWebSvc.Validate(Published, true);
            _TenantWebSvc.Modify();
        end;
        Clear(_TenantWebSvc);
        _TenantWebSvc.Reset();
        _TenantWebSvc.SetRange("Object Type", _TenantWebSvc."Object Type"::Query);
        _TenantWebSvc.SetRange("Object ID", Query::"ARC System Mappings");
        _TenantWebSvc.SetRange("Service Name", 'QuerySystemMappings');
        if _TenantWebSvc.IsEmpty() then begin
            _TenantWebSvc.Init();
            _TenantWebSvc."Object Type" := _TenantWebSvc."Object Type"::Query;
            _TenantWebSvc."Object ID" := Query::"ARC System Mappings";
            _TenantWebSvc."Service Name" := 'QuerySystemMappings';
            _TenantWebSvc.Insert;
            _TenantWebSvc.Validate(Published, true);
            _TenantWebSvc.Modify();
        end;
    end;

    procedure DeleteSystemMapping(_SystemMapping: Record "ARC System Mapping")
    var
        _Text000Qst: TextConst ENU='Delete record?';
    begin
        _SystemMapping.Delete;
    end;

    procedure PurgeSystemMappings()
    var
        _AccessControl: Record "Access Control";
        _SystemMapping: Record "ARC System Mapping";
        _Text000Err: TextConst ENU='The current user must be a member of the SUPER security role to execute this function.';
        _Text001Qst: TextConst ENU='Are you SURE you want to wipe the entire table (delete ALL records)?';
        _Text002Msg: TextConst ENU='Done.';
    begin
        _AccessControl.SetRange("User Name",UserId);
        _AccessControl.SetRange("Role ID",'SUPER');
        if not _AccessControl.FindFirst then
            Error(_Text000Err);
        if not Confirm(_Text001Qst,false) then
            exit;
        _SystemMapping.DeleteAll;
        Message(_Text002Msg);
    end;

    procedure ShowCard(_SystemMapping: Record "ARC System Mapping")
    var
        _Customer: Record Customer;
        _Item: Record Item;
        _Vendor: Record Vendor;
        Location: Record Location;
        SalesPerson: Record "Salesperson/Purchaser";
    begin
        case _SystemMapping."Source Type" of
            _SystemMapping."Source Type"::Customer:
                begin
                    _Customer.Get(_SystemMapping."Destination No.");
                    Page.Run(Page::"Customer Card",_Customer);
                end;
            _SystemMapping."Source Type"::Item:
                begin
                    _Item.Get(_SystemMapping."Destination No.");
                    Page.Run(Page::"Item Card",_Item);
                end;
            _SystemMapping."Source Type"::Vendor:
                begin
                    _Vendor.Get(_SystemMapping."Destination No.");
                    Page.Run(Page::"Vendor Card",_Vendor)
                end;
            _SystemMapping."Source Type"::Location:
            begin
                Location.Get(_SystemMapping."Destination No.");
                Page.Run(Page::"Location Card",Location)
            end;
             _SystemMapping."Source Type"::SalesPerson:
            begin
                SalesPerson.Get(_SystemMapping."Destination No.");
                Page.Run(Page::"Salesperson/Purchaser Card",SalesPerson);
            end;
        end;
    end;

    procedure Test()
    var
        _Customer: Record Customer;
        _Item: Record Item;
        _SysMapping: Record "ARC System Mapping";
        _Vendor: Record Vendor;
        Location: Record Location;
        SalesPerson: Record "Salesperson/Purchaser";
        _Text000Qst: TextConst ENU='Create test record(s)?';
    begin
        if GuiAllowed() then
            if not Confirm(_Text000Qst) then
                exit;
        _Customer.SetRange(Blocked,_Customer.Blocked::" ");
        if not _Customer.FindFirst() then
            Clear(_Customer);
        _Item.SetRange(Blocked,false);
        if not _Item.FindFirst() then
            Clear(_Item);
        _Vendor.SetRange(Blocked,_Vendor.Blocked::" ");
        if not _Vendor.FindFirst() then
            Clear(_Vendor);
        if not Location.FindFirst then
            Clear(Location);    
        if not SalesPerson.FindFirst then
            Clear(SalesPerson);
        if _Customer."No." <> '' then begin
            Clear(_SysMapping);
            _SysMapping.Reset;
            _SysMapping.Init;
            _SysMapping."Entry No." := 0;
            _SysMapping."Source System" := _SysMapping."Source System"::NAV2009;
            _SysMapping."Source Type" := _SysMapping."Source Type"::Customer;
            _SysMapping."Source No." := '12345';
            _SysMapping."Destination No." := _Customer."No.";
            _SysMapping."Created by" := UserId;
            _SysMapping."Created at DateTime" := CurrentDateTime;
            _SysMapping.Insert;
        end;
        if _Item."No." <> '' then begin
            Clear(_SysMapping);
            _SysMapping.Reset;
            _SysMapping.Init;
            _SysMapping."Entry No." := 0;
            _SysMapping."Source System" := _SysMapping."Source System"::GreatPlains;
            _SysMapping."Source Type" := _SysMapping."Source Type"::Item;
            _SysMapping."Source No." := '12345';
            _SysMapping."Destination No." := _Item."No.";
            _SysMapping."Created by" := UserId;
            _SysMapping."Created at DateTime" := CurrentDateTime;
            _SysMapping.Insert;
        end;
        if _Vendor."No." <> '' then begin
            Clear(_SysMapping);
            _SysMapping.Reset;
            _SysMapping.Init;
            _SysMapping."Entry No." := 0;
            _SysMapping."Source System" := _SysMapping."Source System"::NAV2009;
            _SysMapping."Source Type" := _SysMapping."Source Type"::Vendor;
            _SysMapping."Source No." := '12345';
            _SysMapping."Destination No." := _Vendor."No.";
            _SysMapping."Created by" := UserId;
            _SysMapping."Created at DateTime" := CurrentDateTime;
            _SysMapping.Insert;
        end;
        if Location.Code <> '' then begin
            Clear(_SysMapping);
            _SysMapping.Reset;
            _SysMapping.Init;
            _SysMapping."Entry No." := 0;
            _SysMapping."Source System" := _SysMapping."Source System"::NAV2009;
            _SysMapping."Source Type" := _SysMapping."Source Type"::Location;
            _SysMapping."Source No." := '12345';
            _SysMapping."Destination No." := Location.Code;
            _SysMapping."Created by" := UserId;
            _SysMapping."Created at DateTime" := CurrentDateTime;
            _SysMapping.Insert;
        end;

        if SalesPerson.Code <> '' then begin
            Clear(_SysMapping);
            _SysMapping.Reset;
            _SysMapping.Init;
            _SysMapping."Entry No." := 0;
            _SysMapping."Source System" := _SysMapping."Source System"::NAV2009;
            _SysMapping."Source Type" := _SysMapping."Source Type"::SalesPerson;
            _SysMapping."Source No." := '12345';
            _SysMapping."Destination No." := SalesPerson.Code;
            _SysMapping."Created by" := UserId;
            _SysMapping."Created at DateTime" := CurrentDateTime;
            _SysMapping.Insert;
        end;
        //Sage
        if _Customer."No." <> '' then begin
            Clear(_SysMapping);
            _SysMapping.Reset;
            _SysMapping.Init;
            _SysMapping."Entry No." := 0;
            _SysMapping."Source System" := _SysMapping."Source System"::Sage;
            _SysMapping."Source Type" := _SysMapping."Source Type"::Customer;
            _SysMapping."Source No." := '12345';
            _SysMapping."Destination No." := _Customer."No.";
            _SysMapping."Created by" := UserId;
            _SysMapping."Created at DateTime" := CurrentDateTime;
            _SysMapping.Insert;
        end;
        if _Item."No." <> '' then begin
            Clear(_SysMapping);
            _SysMapping.Reset;
            _SysMapping.Init;
            _SysMapping."Entry No." := 0;
            _SysMapping."Source System" := _SysMapping."Source System"::Sage;
            _SysMapping."Source Type" := _SysMapping."Source Type"::Item;
            _SysMapping."Source No." := '12345';
            _SysMapping."Destination No." := _Item."No.";
            _SysMapping."Created by" := UserId;
            _SysMapping."Created at DateTime" := CurrentDateTime;
            _SysMapping.Insert;
        end;
        if _Vendor."No." <> '' then begin
            Clear(_SysMapping);
            _SysMapping.Reset;
            _SysMapping.Init;
            _SysMapping."Entry No." := 0;
            _SysMapping."Source System" := _SysMapping."Source System"::Sage;
            _SysMapping."Source Type" := _SysMapping."Source Type"::Vendor;
            _SysMapping."Source No." := '12345';
            _SysMapping."Destination No." := _Vendor."No.";
            _SysMapping."Created by" := UserId;
            _SysMapping."Created at DateTime" := CurrentDateTime;
            _SysMapping.Insert;
        end;
        if SalesPerson.Code <> '' then begin
            Clear(_SysMapping);
            _SysMapping.Reset;
            _SysMapping.Init;
            _SysMapping."Entry No." := 0;
            _SysMapping."Source System" := _SysMapping."Source System"::Sage;
            _SysMapping."Source Type" := _SysMapping."Source Type"::SalesPerson;
            _SysMapping."Source No." := '12345';
            _SysMapping."Destination No." := SalesPerson.Code;
            _SysMapping."Created by" := UserId;
            _SysMapping."Created at DateTime" := CurrentDateTime;
            _SysMapping.Insert;
        end;
        
    end;
    
    var
        myInt : Integer;
}
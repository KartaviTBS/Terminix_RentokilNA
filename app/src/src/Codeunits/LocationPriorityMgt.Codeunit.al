codeunit 50077 "ARC LocationPriorityMgt"
{
    // SOW11 Körber Edge WMS Integration / RDCs (Regional Distribution Centers) located in Charlotte, NC and Salt Lake City, UT
    //   agreement between ArcherPoint and Rentokil-NA executed 29 Mar 2022
    //   reference:
    //     Case 109188 Sales Order Item Routing
    //     CO1 Sales Order Item Routing - Reqmnt 1 Loc Priority
    //     CO4 Order Management
    // table 50077 "ARC Location Priority" marked obsolete b/c of fields/PK/destructiveSchemaChange - Tue 11 Oct 2022
    // table 50079 "ARC Location Pri. Ver.20221011" will be leveraged going forward - Tue 11 Oct 2022

    Permissions = tabledata "ARC Event Log Entry" = ri,
                  tabledata "ARC Korber Setup" = r,
                  tabledata "ARC Location Priority" = r;

    trigger OnRun();
    begin
    end;

    procedure CalculateLocationForSalesLine(var _SalesLine: Record "Sales Line"; var _newLocationCode: Code[10]; var _KorberEnabled: Boolean; var _logText: Bigtext)
    var
        _KorberSetup: Record "ARC Korber Setup";
        _Location: Record Location;
        _LocationPriority: Record "ARC Location Pri. Ver.20221011";
        _continue: Boolean;
    begin
        // this method called from codeunit 50078 "ARC OrderManagement", method SplitDeriveParams
        _SalesLine.SetHideValidationDialog(true);
        if _SalesLine.Type <> _SalesLine.Type::Item then
            exit;
        if not _KorberSetup.Get() then
            exit;
        if not _KorberSetup."Location Priority Active" then
            exit;
        // search for records in order of priority
        _LocationPriority.SetRange("Sales Line Location Code",_SalesLine."Location Code");
        CalculateLocation(_KorberSetup,_LocationPriority,_SalesLine,_newLocationCode,_logText);
        if _newLocationCode = '' then
            _newLocationCode := CopyStr(_SalesLine."Location Code",1,MaxStrLen(_newLocationCode));
        if _Location.Get(_newLocationCode) then
            _KorberEnabled := _Location."ARC Enable Korber WMS";
    end;

    local procedure CalculateLocation(
        _KorberSetup: Record "ARC Korber Setup";
        var _LocationPriority: Record "ARC Location Pri. Ver.20221011"; 
        _SalesLine: Record "Sales Line"; 
        var _newLocationCode: Code[10];
        var _logText: Bigtext): Boolean
    var
        _Item: Record Item;
        _KorberMgt: Codeunit "ARC KorberMgt";
        _msgLogText: Text;
        _Text000Msg: Label 'codeunit 50077 "ARC LocationPriorityMgt", method CalculateLocation(): SL (DocNo %1 Cust %2 Item %3 Qty %4), LocPri (Loc %5 Pri %6), Item (Invt %7), newLoc %8';
        _Text001Msg: Label 'Location Priority record with Sales Line Location %1, priority %2 has an empty override';
    begin
        Clear(_newLocationCode);
        if not _Item.Get(_SalesLine."No.") then
            exit(false);
        if not _LocationPriority.FindSet(false) then
            exit(false);
        repeat
            if _LocationPriority."Override Location Code" = '' then
                _logText.AddText(StrSubstNo(_Text001Msg,_LocationPriority."Sales Line Location Code",_LocationPriority.Priority) + _KorberMgt.GetCRNL())
            else begin
                _Item.SetFilter("Location Filter",_LocationPriority."Override Location Code");
                _Item.CalcFields(Inventory);
                if _SalesLine.Quantity <> 0 then
                    if _Item.Inventory >= _SalesLine.Quantity then begin
                        _newLocationCode := CopyStr(_LocationPriority."Override Location Code",1,MaxStrLen(_newLocationCode));
                        _msgLogText := CopyStr(StrSubstNo(_Text000Msg,_SalesLine."Document No.",_SalesLine."Sell-to Customer No.",_SalesLine."No.",_SalesLine.Quantity,
                            _LocationPriority."Sales Line Location Code",_LocationPriority.Priority,_Item.Inventory,_newLocationCode),1,MaxStrLen(_msgLogText));
                        _logText.AddText(_msgLogText + _KorberMgt.GetCRNL());
                        exit(true);
                    end;
                if _SalesLine.Quantity = 0 then
                    if _Item.Inventory > 0 then begin
                        _newLocationCode := CopyStr(_LocationPriority."Override Location Code",1,MaxStrLen(_newLocationCode));
                        _msgLogText := CopyStr(StrSubstNo(_Text000Msg,_SalesLine."Document No.",_SalesLine."Sell-to Customer No.",_SalesLine."No.",_SalesLine.Quantity,
                            _LocationPriority."Sales Line Location Code",_LocationPriority.Priority,_Item.Inventory,_newLocationCode),1,MaxStrLen(_msgLogText));
                        _logText.AddText(_msgLogText + _KorberMgt.GetCRNL());
                        exit(true);
                    end;
            end;
        until _LocationPriority.Next() = 0;
        exit(false);
    end;

    procedure OpenPageFromLocationCard(_Location: Record Location)
    var
        _LocationPriorities: Page "ARC Location Priorities";
    begin
        _LocationPriorities.Run();
    end;

    procedure ShowLocation(_Code: Code[10])
    var
        _Location: Record Location;
    begin
        _Location.Get(_Code);
        _Location.SetRecFilter();
        Page.Run(Page::"Location Card",_Location);
    end;
}
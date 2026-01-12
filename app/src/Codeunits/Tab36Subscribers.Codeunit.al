codeunit 50005 "ARC Table 36 Subscribers"
{
    var
    quoteExpired: Label 'Sales Quote %1 is expired. Please contact system administrator';

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertSalesHeader(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        _OrderMgt: Codeunit "ARC OrderManagement";
    begin
        _OrderMgt.OnBeforeInsertSalesHeader(Rec,RunTrigger);  // SOW11 Körber Edge WMS - CO4 Order Management
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr', '', false, false)]
    local procedure OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr(var SalesHeader: Record "Sales Header"; ShipToAddress: Record "Ship-to Address");
    begin
        SalesHeader."ARC Locality Code" := CopyStr(ShipToAddress."ARC Locality Code",1,MaxStrLen(SalesHeader."ARC Locality Code"));
        SalesHeader."ARC Business Type Code" := CopyStr(ShipToAddress."ARC Business Type Code",1,MaxStrLen(SalesHeader."ARC Business Type Code"));
    end;


    [EventSubscriber(ObjectType::Table, 36, 'OnAfterValidateEvent', 'Ship-to Post Code', false, false)]
    local procedure OnAfterValidateShipToPostCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer);
    var
        Locality: Record "ARC Locality";
    begin
        Locality.Reset;
        Locality.SetRange("Country/Region Code", Rec."Ship-to Country/Region Code");
        Locality.SetRange(County, Rec."Ship-to County");
        Locality.SetRange("Post Code", Rec."Ship-to Post Code");
        if Locality.FindFirst then
            Rec.Validate("ARC Locality Code", Locality.Code)
        else
            Rec.Validate("ARC Locality Code", '');
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Ship-to Post Code', false, false)]
    local procedure OnBeforeValidateShipToPostCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer);
    begin
        Rec.TestField(Status, Rec.Status::Open);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Ship-to Code', false, false)]
    local procedure OnBeforeValidateShipToCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer);
    begin
        Rec.TestField(Status, Rec.Status::Open);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Ship-to City', false, false)]
    local procedure OnBeforeValidateShipToCity(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer);
    begin
        Rec.TestField(Status, Rec.Status::Open);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Ship-to Address', false, false)]
    local procedure OnBeforeValidateShipToAddress(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer);
    begin
        Rec.TestField(Status, Rec.Status::Open);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Ship-to Address 2', false, false)]
    local procedure OnBeforeValidateShipToAddress2(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer);
    begin
        Rec.TestField(Status, Rec.Status::Open);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterInitRecord', '', false, false)]
    local procedure OnAfterInit(var SalesHeader: Record "Sales Header")
    var
        RNASetup: Record "ARC RNA Setup";
    begin
               
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Quote then begin
            RNASetup.Get;
            RNASetup.TestField("Quote Expiration Calculation");
            SalesHeader."ARC Expiration Date" := CalcDate(RNASetup."Quote Expiration Calculation", WorkDate);
        end;
        SalesHeader."ARC Created By" := CopyStr(UserId,1,MaxStrLen(SalesHeader."ARC Created By"));
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModify(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
          exit;
        CheckQuoteExpiration(Rec);
    end;
    
    [EventSubscriber(ObjectType::Table, 36, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModify(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var NAPCBOLHeader: Record "ARC NAPC BOL Header";
    begin
        if not RunTrigger then
          exit;
        if rec."Document Type" = rec."Document Type"::Order then begin
            rec.CalcFields("ARC NAPC Bill of Lading No.");
          if rec."ARC NAPC Bill of Lading No." <> '' then begin
            NAPCBOLHeader.Get(rec."ARC NAPC Bill of Lading No.");  
            NAPCBOLHeader.Delete;
          end;
        end; 
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnCheckSalesPostRestrictions', '', false, false)]
    local procedure OnCheckSalesPostRestrictions(var Sender: Record "Sales Header")
    begin
        CheckQuoteExpiration(Sender);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeSalesLineInsert', '', false, false)]
    local procedure OnBeforeSalesLineInsert(var SalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line")
    begin
        SalesLine.Validate("Unit Price",TempSalesLine."Unit Price");
        SalesLine."ARC Price Entry No." := TempSalesLine."ARC Price Entry No.";
        SalesLine."ARC Promotion Code" := CopyStr(TempSalesLine."ARC Promotion Code",1,MaxStrLen(SalesLine."ARC Promotion Code"));
        SalesLine."ARC Promotion Entry No." := TempSalesLine."ARC Promotion Entry No.";
        SalesLine."ARC Margin %" := TempSalesLine."ARC Margin %";        
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterValidateEvent', 'Ship-to Code', false, false)]
    local procedure OnAfterValidateShipToCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer);
    var
        ShiptoAddress: Record "Ship-to Address";
        Location: Record Location;
    begin
        if (rec."Ship-to Code" <> xRec."Ship-to Code") then begin 
            if ShiptoAddress.GET(Rec."Sell-to Customer No.",Rec."Ship-to Code") then begin 
                if (ShiptoAddress."ARC Salesperson Code" <> '') and (ShiptoAddress."ARC Salesperson Code" <> Rec."Salesperson Code") then
                    Rec.Validate("Salesperson Code",ShiptoAddress."ARC Salesperson Code");
            end;   
        end; 
    end;

    procedure CheckQuoteExpiration(SalesHeader: Record "Sales Header");
    begin
        If SalesHeader."Document Type" <> SalesHeader."Document Type"::Quote then
            exit;
        if SalesHeader."ARC Expiration Date" < WorkDate then
            Error(quoteExpired,SalesHeader."No.");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeValidateEvent', 'Location Code', false, false)]
    local procedure OnBeforeValidateLocationCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer);
    var
        Location: Record Location;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        GLSetup: Record "General Ledger Setup";
        oldDimID: Integer;
    begin
        GLSetup.Get;
        if Location.Get(Rec."Location Code") then begin 
            oldDimID := Rec."Dimension Set ID";
            DimMgt.GetDimensionSet(TempDimSetEntry, Rec."Dimension Set ID");
            if Location."Shortcut Dimension 1 Code" <> '' then begin 
                UpdateDimSet(Rec,TempDimSetEntry,GLSetup."Global Dimension 1 Code",Location."Shortcut Dimension 1 Code");
                Rec."Shortcut Dimension 1 Code" := CopyStr(Location."Shortcut Dimension 1 Code",1,MaxStrLen(Rec."Shortcut Dimension 1 Code"));
            end;  
            if Location."Shortcut Dimension 2 Code" <> '' then begin 
                UpdateDimSet(Rec,TempDimSetEntry,GLSetup."Global Dimension 1 Code",Location."Shortcut Dimension 1 Code");
                Rec."Shortcut Dimension 2 Code" := CopyStr(Location."Shortcut Dimension 2 Code",1,MaxStrLen(Rec."Shortcut Dimension 2 Code"));
            end;  
            Rec."Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
            if oldDimID <> Rec."Dimension Set ID" then begin 
                if Rec.SalesLinesExist then begin 
                    Rec.UpdateAllLineDim(Rec."Dimension Set ID",oldDimID);
                end;
            end;
            Rec.UpdateSalesLines(Rec.FieldName("Location Code"),false);
            rec."ARC COI Location Code" := CopyStr(Location."ARC COI Location Code",1,MaxStrLen(rec."ARC COI Location Code"));
        end;
    end;   

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterValidateEvent', 'Shipping Agent Code', false, false)]    
    procedure OnAfterValidateShippingAgentCode(VAR Rec : Record "Sales Header";VAR xRec : Record "Sales Header");
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        if ShippingAgent.GET(Rec."Shipping Agent Code") then
          if ShippingAgent."ARC Use Location Ship-to" then
            Rec.Validate("ARC Use Location Address",TRUE);
    end;   

    local procedure UpdateDimSet(var SalesHeader: Record "Sales Header";var TempDimSetEntry: Record "Dimension Set Entry" temporary; DimCode: Code[20]; DimValueCode: Code[20])
    begin
        if DimCode = '' then
            exit;
        if TempDimSetEntry.Get(SalesHeader."Dimension Set ID", DimCode) then
            TempDimSetEntry.Delete;
        if DimValueCode <> '' then begin
            DimVal.Get(DimCode, DimValueCode);
            TempDimSetEntry.Init;
            TempDimSetEntry."Dimension Set ID" := SalesHeader."Dimension Set ID";
            TempDimSetEntry."Dimension Code" := DimCode;
            TempDimSetEntry."Dimension Value Code" := DimValueCode;
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.Insert;
        end;
    end;

    var 
        DimVal: Record "Dimension Value";
        DimMgt: Codeunit DimensionManagement;
}
codeunit 50006 "ARC Table 37 Subscribers"
{
    var
        priceCannotbeChanged: Label 'For agency items, price cannot be changed';
        UnitCostZero: Label 'Unit cost for item %1 is zero, please contact purchase department';
        MCPpriceCannotbeChanged: Label 'For MCP items, price cannot be lower then contract price';

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterAssignHeaderValues', '', false, false)]
    local procedure OnAfterAssignHeaderValues(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header");
    begin
        SalesLine."ARC Business Type Code" := SalesHeader."ARC Business Type Code";
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Shortcut Dimension 1 Code', false, false)]
    local procedure OnAfterValidateShortcutDim1Code(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer);
    begin
        CheckforTargetLOB(Rec,xRec);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure OnAfterValidateNo(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer);
    var
        ARCSalesMgt: Codeunit ARCSalesMgt;
        Item: Record Item;
        ItemSupplCharge: Record "ARC Item Supplemental Charge";
        SalesHeader: Record "Sales Header";

    begin
        if(Rec.Type = Rec.Type::Item) and (Rec."No." <> xRec."No.") then begin
            Item.Get(Rec."No.");
            If (not ARCSalesMgt.IsCOILocation(Rec."Location Code")) then begin 
                if not (item."ARC Free Item") then begin 
                    Item.TestField("Unit Cost");
                    Item.TestField("ARC Minimum Price");
                    Item.TestField("ARC Sales Cost");
                end;
            end;
            Rec.Validate("ARC Sales Cost",Item."ARC Sales Cost");
            ItemSupplCharge.SetRange("Item No.",Rec."No.");
            If ItemSupplCharge.FindFirst then
                Rec.Validate("ARC Supplemental Charge Code",ItemSupplCharge.Code);
        end;
        If (Rec."No." <> xRec."No.") then
            CheckforTargetLOB(Rec,xRec); 
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModify(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        SalesHeader: Record "Sales Header";
        Table36Subscribers: Codeunit "ARC Table 36 Subscribers";
    begin
        if not RunTrigger then
            exit;
        SalesHeader.Get(Rec."Document Type", Rec."Document No.");
        Table36Subscribers.CheckQuoteExpiration(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Unit Price', false, false)]
    local procedure OnAfterValidateUnitPrice(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer);
    var
        eCommerceEntry: Record "ARC eCommerce Entry";
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        PriceMgt: Codeunit "ARC Price Management";
        PricingWS: Codeunit "ARC Pricing WebService";
        PromoMgt: Codeunit "ARC Promotion Management";
        SalesMgt: Codeunit ARCSalesMgt;
        UOMCost: Decimal;
        NetPrice: Decimal;
        PricingEntryNo: Integer;
    begin
        if(Rec.Type = Rec.Type::Item) and (CurrFieldNo = Rec.FieldNo("Unit Price")) then begin
            Item.Get(Rec."No.");
            UOMCost := Item."ARC Sales Cost" * Rec."Qty. per Unit of Measure";
            if Rec."Unit Price" <> 0 then   
                Rec."ARC Margin %" := Round(((Rec."Unit Price"- UOMCost)/ Rec."Unit Price") * 100,0.01,'=')
            else
                Rec."ARC Margin %" := 0;
            if Rec."ARC eCommerce Entry No." <> 0 then
                if eCommerceEntry.Get(Rec."ARC eCommerce Entry No.") then
                    if eCommerceEntry."eCom Bypass Price/Promo" then
                        exit;
            If(Rec."Unit Price" <> xRec."Unit Price") then begin
                SalesHeader.Get(Rec."Document Type",Rec."Document No.");
                if Item."ARC Agency Item" then
                    if not SalesMgt.IsCOILocation(Rec."Location Code") then
                        Error(priceCannotbeChanged);
                if item."ARC MCP" then begin 
                    PricingWS.SetSalesLine(Rec);  // SOW11 Körber Edge WMS - CO3 MCP Pricing
                    NetPrice := PricingWS.GetItemNetPrice(SalesHeader."Sell-to Customer No.",Item."No.",Rec.Quantity,Rec."Unit of Measure Code",Rec."Variant Code",
                    Rec."Customer Price Group",SalesHeader."Customer Posting Group",SalesHeader."Currency Code",Format(SalesHeader."Order Date", 0, '<Year4><Month,2><Day,2>'),PricingEntryNo);
                    If Rec."Unit Price" < NetPrice then
                        if not SalesMgt.IsCOILocation(Rec."Location Code") then
                            Error(MCPpriceCannotbeChanged);
                end;
                If Rec."ARC Promotion Entry No." <> 0 then begin 
                    SalesHeader.Get(Rec."Document Type",Rec."Document No.");
                    PromoMgt.ApplyPromotion(SalesHeader,Rec,CurrFieldNo);
                end;
                PriceMgt.CreatePriceReviewEntry(Rec);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDelete(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        PriceMgt: Codeunit "ARC Price Management";
    begin
        if not RunTrigger then
            exit;
        PriceMgt.DeletePriceReviewEntry(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeValidateEvent', 'Location Code', false, false)]
    local procedure OnBeforeValidateLocationCode(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer);
    var
        Location: Record Location;
    begin
        if rec."Location Code" <> xRec."Location Code" then begin 
            if Location.Get(Rec."Location Code") then begin 
                UpdateLocationDims(Rec,Location);
            end;
        end;
    end;

    local procedure UpdateLocationDims(var SalesLine: Record "Sales Line"; Location: Record Location);
    begin
        if Location."Shortcut Dimension 1 Code" <> '' then
            SalesLine.Validate("Shortcut Dimension 1 Code",Location."Shortcut Dimension 1 Code");
        if Location."Shortcut Dimension 2 Code" <> '' then
            SalesLine.Validate("Shortcut Dimension 2 Code",Location."Shortcut Dimension 2 Code");
    end;

    local procedure CheckforTargetLOB(var Rec: Record "Sales Line"; xRec: Record "Sales Line");
    var
        Item : Record "Item";
        DimMgt: Codeunit DimensionManagement;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimVal: Record "Dimension Value";
        GLSetup: Record "General Ledger Setup";
        TargetLOB: Code[20];
    begin
        GLSetup.Get;
        If (Rec.Type = Rec.Type::Item) and (Item.Get(Rec."No.")) then begin 
            DimMgt.GetDimensionSet(TempDimSetEntry,Rec."Dimension Set ID");
            If Rec."Shortcut Dimension 1 Code" <> '' then begin 
                if (DimVal.Get(GLSetup."Shortcut Dimension 1 Code",Rec."Shortcut Dimension 1 Code"))
                    and (DimVal."ARC Target Branch") then begin
                    if Item."ARC Target LOB" <> '' then 
                        TargetLOB := Item."ARC Target LOB"
                    else begin 
                        GLSetup.TestField("ARC Default Target LOB Code");
                        TargetLOB := GLSetup."ARC Default Target LOB Code";
                    end;   
                   
                    if TempDimSetEntry.Get(Rec."Dimension Set ID", GLSetup."Shortcut Dimension 3 Code") then
                        TempDimSetEntry.Delete;
                    DimVal.Get(GLSetup."Shortcut Dimension 3 Code", TargetLOB);
                    TempDimSetEntry.Init;
                    TempDimSetEntry."Dimension Set ID" := Rec."Dimension Set ID";
                    TempDimSetEntry."Dimension Code" := GLSetup."Shortcut Dimension 3 Code";
                    TempDimSetEntry."Dimension Value Code" := DimVal.Code;
                    TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
                    TempDimSetEntry.Insert;
                    Rec."Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
                    Rec."ARC Target LOB" := TargetLOB;
                end;
            end;
        end else begin 
            If (Rec.Type = Rec.Type::"G/L Account") and (Rec."No." = GLSetup."ARC LOB Lift G/L Account") then begin 
                DimMgt.GetDimensionSet(TempDimSetEntry,Rec."Dimension Set ID");
            
                GLSetup.TestField("ARC Default Target LOB Code");
                TargetLOB := GLSetup."ARC Default Target LOB Code";
                    
                if TempDimSetEntry.Get(Rec."Dimension Set ID", GLSetup."Shortcut Dimension 3 Code") then
                    TempDimSetEntry.Delete;
                DimVal.Get(GLSetup."Shortcut Dimension 3 Code", TargetLOB);
                TempDimSetEntry.Init;
                TempDimSetEntry."Dimension Set ID" := Rec."Dimension Set ID";
                TempDimSetEntry."Dimension Code" := GLSetup."Shortcut Dimension 3 Code";
                TempDimSetEntry."Dimension Value Code" := DimVal.Code;
                TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
                TempDimSetEntry.Insert;
                Rec."Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
            end;
        end;      
    end;
}
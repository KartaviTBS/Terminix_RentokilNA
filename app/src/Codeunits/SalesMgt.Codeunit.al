codeunit 50061 ARCSalesMgt
{
    trigger OnRun();
    begin
    end;

    procedure CheckCOILocation(var SalesHeader: Record "Sales Header");
    begin
        if SalesHeader."ARC COI Order" then
            SalesHeader.TestField("ARC COI Location Code");
    end;

    procedure CreateCOIEntryLine(var SalesShipmentLine: Record "Sales Shipment Line"; SalesLine: Record "Sales Line");
    var
        SalesHeader: Record "Sales Header";
        ItemJnlLine: Record "Item Journal Line";
        RNASetup: Record "ARC RNA Setup";
        Location: Record Location;
        ItemJnlTemplate: Record "Item Journal Template";
        WhseJnlLine: Record "Warehouse Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        WMSMgmt: Codeunit "WMS Management";
        WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line";
        Bin: Record Bin;
        LineNo: Integer;
        WhseJnlPost: Boolean;
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        if not SalesHeader."ARC COI Order" then
            exit;
        if SalesLine.Type <> SalesLine.Type::Item then
            exit;
        if SalesShipmentLine.Quantity = 0 then
            exit;
        RNASetup.Get();
        RNASetup.TestField("COI Journal Template Name");
        RNASetup.TestField("COI Journal Batch Name");
        ItemJnlTemplate.Get(RNASetup."COI Journal Template Name");
        SourceCodeSetup.Get();

        if not Bin.Get(SalesHeader."ARC COI Location Code", SalesHeader."Sell-to Customer No.") then begin
            Bin.Init();
            Bin.Code := SalesHeader."Sell-to Customer No.";
            Bin.Description := CopyStr(SalesHeader."Sell-to Customer Name", 1, MaxStrLen(Bin.Description));
            Bin."Location Code" := SalesHeader."ARC COI Location Code";
            Bin.Insert(true);
        end;

        ItemJnlLine.Reset();
        ItemJnlLine.SetRange("Journal Template Name", RNASetup."COI Journal Template Name");
        ItemJnlLine.SetRange("Journal Batch Name", RNASetup."COI Journal Batch Name");
        if ItemJnlLine.FindLast() then
            LineNo := ItemJnlLine."Line No." + 10000
        else
            LineNo := 10000;

        ItemJnlLine.Init();
        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Positive Adjmt.";
        ItemJnlLine.Validate("Item No.", SalesShipmentLine."No.");
        ItemJnlLine."Posting Date" := SalesShipmentLine."Posting Date";
        ItemJnlLine."Document No." := SalesShipmentLine."Document No.";
        ItemJnlLine."Document Line No." := LineNo;
        ItemJnlLine."Gen. Bus. Posting Group" := SalesShipmentLine."Gen. Bus. Posting Group";
        ItemJnlLine."Gen. Prod. Posting Group" := SalesShipmentLine."Gen. Prod. Posting Group";
        ItemJnlLine.Validate("Location Code", SalesHeader."ARC COI Location Code");
        ItemJnlLine."Source Code" := SourceCodeSetup.Sales;
        ItemJnlLine."Variant Code" := SalesShipmentLine."Variant Code";
        ItemJnlLine."Bin Code" := SalesHeader."Sell-to Customer No.";
        ItemJnlLine."Document Date" := SalesHeader."Document Date";
        ItemJnlLine.Validate(Quantity, SalesShipmentLine.Quantity);
        ItemJnlLine.Validate("Unit Cost", 0);
        Location.Get(SalesHeader."ARC COI Location Code");
        if Location."Bin Mandatory" then begin
            if WMSMgmt.CreateWhseJnlLine(ItemJnlLine, ItemJnlTemplate.Type, WhseJnlLine, false) then begin
                WMSMgmt.CheckWhseJnlLine(WhseJnlLine, 1, 0, false);
                WhseJnlPost := true;
            end;
        end;

        ItemJnlPostLine.Run(ItemJnlLine);
        if WhseJnlPost then
            WhseJnlPostLine.Run(WhseJnlLine);
    end;

    procedure IsCOILocation(LocationCode: Code[20]): Boolean;
    var
        Location: Record Location;
    begin
        Location.Reset();
        Location.SetRange("ARC COI Location Code", LocationCode);
        if not location.IsEmpty() then
            exit(true);
    end;

    procedure UpdateMarginPercent(var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line"; CurrFieldNo: Integer);
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        UOMCost: Decimal;
        PriceMgt: Codeunit "ARC Price Management";
        PromoMgt: Codeunit "ARC Promotion Management";
        NetPrice: Decimal;
        PricingWS: Codeunit "ARC Pricing WebService";
        PricingEntryNo: Integer;
    begin
        if SalesLine.Type <> SalesLine.Type::Item then
            exit;
        Item.Get(SalesLine."No.");
        if(SalesLine."ARC Margin %" <> xSalesLine."ARC Margin %") and(CurrFieldNo = SalesLine.FieldNo("ARC Margin %")) then begin
            if Item."ARC Agency Item" then
                Error(priceCannotbeChanged);
            if item."ARC MCP" then begin
                SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
                NetPrice := PricingWS.GetItemNetPrice(SalesHeader."Sell-to Customer No.", Item."No.", SalesLine.Quantity, SalesLine."Unit of Measure Code", SalesLine."Variant Code",
                SalesLine."Customer Price Group", SalesHeader."Customer Posting Group", SalesHeader."Currency Code", Format(SalesHeader."Order Date", 0, '<Year4><Month,2><Day,2>'), PricingEntryNo);
                if SalesLine."Unit Price" < NetPrice then
                    Error(MCPpriceCannotbeChanged);
            end;
        end;
        if SalesLine."ARC Sales Cost" = 0 then
            SalesLine."ARC Sales Cost" := Item."ARC Sales Cost" * SalesLine."Qty. per Unit of Measure";
        UOMCost := Item."ARC Sales Cost" * SalesLine."Qty. per Unit of Measure";
        if SalesLine."ARC Margin %" <> 0 then begin
            SalesLine.Validate("Unit Price", Round((SalesLine."ARC Sales Cost" / (100 - SalesLine."ARC Margin %")) * 100, 0.01, '='));
            if(Item."ARC MCP") and(SalesLine."ARC Margin %" <> xSalesLine."ARC Margin %") and(CurrFieldNo = SalesLine.FieldNo("ARC Margin %")) then begin
                SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
                NetPrice := PricingWS.GetItemNetPrice(SalesHeader."Sell-to Customer No.", Item."No.", SalesLine.Quantity, SalesLine."Unit of Measure Code", SalesLine."Variant Code",
                SalesLine."Customer Price Group", SalesHeader."Customer Posting Group", SalesHeader."Currency Code", Format(SalesHeader."Order Date", 0, '<Year4><Month,2><Day,2>'), PricingEntryNo);
                if SalesLine."Unit Price" < NetPrice then
                    Error(MCPpriceCannotbeChanged);
            end;
        end else
            SalesLine.Validate("Unit Price", 0);
        if SalesLine."ARC Promotion Entry No." <> 0 then begin
            SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
            PromoMgt.ApplyPromotion(SalesHeader, SalesLine, SalesLine.FieldNo("ARC Margin %"));
        end;
        PriceMgt.CreatePriceReviewEntry(SalesLine);
    end;

    procedure CreateSupplementalChargeLines(var SalesHeader: Record "Sales Header");
    var
        ItemSupplCharge: Record "ARC Item Supplemental Charge";
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        CreateChargeLine: Boolean;
        SavePack: Boolean;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        //SalesLine.SetFilter("Outstanding Quantity",'<>%1',0);
        SalesLine.SetFilter("Quantity Shipped", '%1', 0); //only if not shipped already
        SalesLine.SetFilter("ARC Supplemental Charge Code", '<>%1', '');
        if SalesLine.FindSet() then begin
            repeat
                CreateChargeLine := true;
                if ItemSupplCharge.Get(SalesLine."No.", SalesLine."ARC Supplemental Charge Code") then
                    if(ItemSupplCharge."Ship-to County" <> '') and
                            (SalesHeader."Ship-to County" <> ItemSupplCharge."Ship-to County") then
                        CreateChargeLine := false;
                if CreateChargeLine then begin
                    SalesLine2.Reset();
                    SalesLine2.SetRange("Document Type", SalesLine."Document Type");
                    SalesLine2.SetRange("Document No.", SalesLine."Document No.");
                    SalesLine2.SetRange("Attached to Line No.", SalesLine."Line No.");
                    if not SalesLine2.FindFirst() then begin
                        Clear(SalesLine2);
                        SalesLine2."Document Type" := SalesLine."Document Type";
                        SalesLine2."Document No." := SalesLine."Document No.";
                        SalesLine2."Line No." := SalesLine."Line No." + 1;
                        SalesLine2.Validate(Quantity, 1);
                        SavePack := False;
                        SalesLine2.Insert(true);
                    end else
                        SavePack := SalesLine2.Pack;
                    IF SalesLine2."Quantity Invoiced" = 0 then begin //only update if not invoiced already
                        SalesLine2.Type := SalesLine2.Type::Resource;
                        SalesLine2.Validate("No.", ItemSupplCharge."Resource No.");
                        SalesLine2.Validate("Location Code", SalesLine."Location Code");
                        SalesLine2.Validate(Quantity, 1);
                        if SalesLine."ARC Supplemental Charge Rate" <> 0 then
                            SalesLine2.Validate("Unit Price", ((SalesLine."ARC Supplemental Charge Rate" / 100) * SalesLine."Line Amount"))
                        else if SalesLine."ARC Supplemental Fixed Amount" <> 0 then
                                SalesLine2.Validate("Unit Price", SalesLine."ARC Supplemental Fixed Amount");
                        SalesLine2."Attached to Line No." := SalesLine."Line No.";
                        SalesLine2.Pack := SavePack;
                        SalesLine2.Modify(true);
                    end;

                end else begin
                    SalesLine2.Reset();
                    SalesLine2.SetRange("Document Type", SalesLine."Document Type");
                    SalesLine2.SetRange("Document No.", SalesLine."Document No.");
                    SalesLine2.SetRange("Attached to Line No.", SalesLine."Line No.");
                    SalesLine2.SetFilter("Quantity Shipped", '%1', 0); //delete line if not shipped already
                    if SalesLine2.FindFirst() then
                        SalesLine2.Delete()
                end;
            until SalesLine.Next = 0;
        end;
    end;

    procedure CheckCustCrLimitBalanceDue(var SalesHeader: Record "Sales Header");
    var
        CheckCrLimit: Page "Check Credit Limit";
        OrderAmtInclVAT: Decimal;
        ARHoldLogEntry: Record "ARC AR Hold Log Entry";
        RNASetup: Record "ARC RNA Setup";
        Customer: Record Customer;
        Workflow: Record Workflow;
        OverDueAmt: Decimal;
    begin
        RNASetup.Get;
        If RNASetup."AR Workflow Code" <> '' then begin 
            if Workflow.Get(RNASetup."AR Workflow Code") then
                exit;
        end;
        ARHoldLogEntry.Reset;
        ARHoldLogEntry.SetRange("Sales Order No.", SalesHeader."No.");
        ARHoldLogEntry.SetRange(Status, ARHoldLogEntry.Status::Open);
        if ARHoldLogEntry.FindLast then
            exit;
        ARHoldLogEntry.SetRange(Status, ARHoldLogEntry.Status::Approved);

        OrderAmtInclVAT := GetSalesOrderAmt(SalesHeader);
        if ARHoldLogEntry.FindLast then begin
            if(OrderAmtInclVAT) <= (RNASetup."Cr. Limit Threshold Amount" + ARHoldLogEntry."Order Amount") then
                exit;
        end;
        Customer.Get(SalesHeader."Bill-to Customer No.");
        OverDueAmt := Customer.CalcOverdueBalance;
        if(CheckCrLimit.SalesHeaderShowWarning(SalesHeader)) or(OverDueAmt <> 0) then begin
            SalesHeader."ARC AR Hold" := true;
            SalesHeader.Modify;
            CreateARHoldLogEntry(SalesHeader, OrderAmtInclVAT, OverDueAmt);
            Commit;
        end;
    end;

    procedure CreateARHoldLogEntry(SalesHeader: Record "Sales Header"; OrderAmount: Decimal; OverDueAmt: Decimal): Boolean
    var
        ARHoldLogEntry: Record "ARC AR Hold Log Entry";
        Customer: Record Customer;
    begin
        With ARHoldLogEntry do
        begin
            Customer.Get(SalesHeader."Bill-to Customer No.");
            Init;
            "Entry No." := 0;
            "Customer No." := SalesHeader."Bill-to Customer No.";
            "Customer Name" := SalesHeader."Bill-to Name";
            "Credit Limit Amount" := Customer."Credit Limit (LCY)";
            "Sales Order No." := SalesHeader."No.";
            "Order Amount" := OrderAmount;
            Status := Status::Open;
            "Balance Due Amount" := OverDueAmt;
            If "Balance Due Amount" <> 0 then
                "Balance Due" := true;
            Insert(true);
        end;
    end;

    procedure UpdateARHoldStatus(SalesHeader: Record "Sales Header"; Status: Integer);
    var
        ARHoldLogEntry: Record "ARC AR Hold Log Entry";
    begin
        ARHoldLogEntry.Reset;
        ARHoldLogEntry.SetRange("Sales Order No.", SalesHeader."No.");
        ARHoldLogEntry.SetRange(Status, ARHoldLogEntry.Status::Open);
        if ARHoldLogEntry.FindFirst then
            repeat
                ARHoldLogEntry.Status := Status;
                if ARHoldLogEntry.Status = ARHoldLogEntry.Status::Approved then begin 
                    ARHoldLogEntry."Approved On" := CurrentDateTime;
                    ARHoldLogEntry."Approved By" := UserId;
                end;
                ARHoldLogEntry.Modify(true);
            until ARHoldLogEntry.Next = 0;
    end;

    local procedure Pct(Numerator: Decimal; Denominator: Decimal): Decimal
    begin
        if Denominator = 0 then
            exit(0);
        exit(Round(Numerator / Denominator * 10000, 1));
    end;

    local procedure ClearObjects(var SalesLine: Record "Sales Line"; var TotalSalesLine: array[3] of Record "Sales Line"; var TotalSalesLineLCY: array[3] of Record "Sales Line"; BreakdownAmt: array[3, 4] of Decimal)
    begin
        Clear(SalesLine);
        Clear(TotalSalesLine);
        Clear(TotalSalesLineLCY);
        Clear(BreakdownAmt);
    end;

    procedure GetSalesOrderAmt(SalesHeader: Record "Sales Header"): Decimal;
    var
        NewSalesLine: Record "Sales Line";
        NewSalesLineLCY: Record "Sales Line";
        TempSalesLine: Record "Sales Line" temporary;
        TempSalesTaxAmountLine: Record "Sales Tax Amount Line" temporary;
        TempSalesTaxAmtLine: Record "Sales Tax Amount Line" temporary;
        SalesPost: Codeunit "Sales-Post";
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
        TotalSalesLine: Record "Sales Line";
        TotalSalesLineLCY: Record "Sales Line";
        SalesTaxAmountLine: Record "Sales Tax Amount Line" temporary;
        SalesLine: Record "Sales Line";
        QtyType: Option General, Invoicing, Shipping;
        VATAmount: Decimal;
        VATAmountText: Text[30];
        ProfitLCY: Decimal;
        ProfitPct: Decimal;
        TotalAdjCostLCY: Decimal;
        IsHandled: Boolean;
    begin
        SalesPost.SumSalesLines(
            SalesHeader, 0, TotalSalesLine, TotalSalesLineLCY,
            VATAmount, VATAmountText, ProfitLCY, ProfitPct, TotalAdjCostLCY);

        SalesTaxAmountLine.DeleteAll;
        IF SalesHeader."Tax Area Code" <> '' then begin
            SalesTaxCalculate.StartSalesTaxCalculation;
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.Find('-') then
                repeat
                    if SalesLine.Type <> 0 then
                        SalesTaxCalculate.AddSalesLine(SalesLine);
                until SalesLine.Next = 0;
            SalesTaxCalculate.EndSalesTaxCalculation(SalesHeader."Posting Date");
            SalesTaxCalculate.GetSalesTaxAmountLineTable(SalesTaxAmountLine);
            TotalSalesLine."Amount Including VAT" := TotalSalesLine."Amount Including VAT" + SalesTaxAmountLine.GetTotalTaxAmount;
        END;
        EXIT(TotalSalesLine."Amount Including VAT");
    end;

    var
        ARCAgencyCodeMismatch: Label 'You are not allowed to add item %1 because the agency code %2 does not match the other lines %3.';
        ARCAgencyItemMismatch: Label 'You cannot mix Agency Items with non-Agency Items on the same order';
        ARCAgencyCodePaymentTermsMismatch: Label 'Cannot Release order because Payment Terms (%1) on the order header does not match the Agency Item Payment Terms on the lines (%2)';
        priceCannotbeChanged: Label 'For agency items, price cannot be changed';
        MCPpriceCannotbeChanged: Label 'For MCP items, price cannot be lower then contract price';
}



codeunit 50056 "ARC Source Doc Mgt."
{
    // Copied the code from EFT Source Doc Mgt. All Credit to ChargeLogic, Copied so that it gives flexibility to moidfy 
    // without modifying the EFT functionality

    trigger OnRun()
    begin
    end;

    [Scope('Internal')]
    procedure GetSalesAmounts(var SalesHeader: Record "Sales Header"; AmountType: Option Outstanding,Invoice,Shipment,Prepayment,"Prepayment Invoiced"): Decimal
    begin
        exit(GetSalesAmountsForCombineShip(SalesHeader, AmountType, 0, ''));
    end;

    [Scope('Internal')]
    procedure GetSalesAmountsForCombineShip(var SalesHeader: Record "Sales Header"; AmountType: Option Outstanding,Invoice,Shipment,Prepayment,"Prepayment Invoiced"; CombineShipmentFilterType: Option "None","No Shipment No.","Shipment No."; UnpostedDocumentNo: Code[20]): Decimal
    begin
        exit(GetSalesAmountsForCombineShipAndPrepayment(SalesHeader, AmountType, CombineShipmentFilterType, UnpostedDocumentNo, false));
    end;

    [Scope('Internal')]
    procedure GetSalesAmountsForPrepayment(var SalesHeader: Record "Sales Header"; AmountType: Option Outstanding,Invoice,Shipment,Prepayment,"Prepayment Invoiced"; ExcludePrepaymentLines: Boolean): Decimal
    begin
        exit(GetSalesAmountsForCombineShipAndPrepayment(SalesHeader, AmountType, 0, '', ExcludePrepaymentLines));
    end;

    [Scope('Internal')]
    procedure GetSalesAmountsForCombineShipAndPrepayment(var SalesHeader: Record "Sales Header"; AmountType: Option Outstanding,Invoice,Shipment,Prepayment,"Prepayment Invoiced"; CombineShipmentFilterType: Option "None","No Shipment No.","Shipment No."; UnpostedDocumentNo: Code[20]; ExcludePrepaymentLines: Boolean): Decimal
    var
        SalesLine: Record "Sales Line";
        TempSalesLine: Record "Sales Line" temporary;
        SalesPostPrepmt: Codeunit "Sales-Post Prepayments";
        TempSalesTaxAmtLine: Record "Sales Tax Amount Line" temporary;
        TotalSalesLine: array[3] of Record "Sales Line";
        TotalSalesLineLCY: array[3] of Record "Sales Line";
        TempSalesTaxLine1: Record "Sales Tax Amount Line" temporary;
        TempSalesTaxLine2: Record "Sales Tax Amount Line" temporary;
        TempSalesTaxLine3: Record "Sales Tax Amount Line" temporary;
        TempSalesTaxLine4: Record "Sales Tax Amount Line";
        TempVATAmountLine1: Record "VAT Amount Line" temporary;
        TempVATAmountLine2: Record "VAT Amount Line" temporary;
        TempVATAmountLine3: Record "VAT Amount Line" temporary;
        TempVATAmountLine4: Record "VAT Amount Line" temporary;
        SalesSetup: Record "Sales & Receivables Setup";
        SalesTaxDifference: Record "Sales Tax Amount Difference";
        TaxArea: Record "Tax Area";
        SalesAmountCalcMgt: Codeunit "ARC Sales Amt. Calc. Mgt.";
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
        TotalAmount1: array[3] of Decimal;
        TotalAmount2: array[3] of Decimal;
        VATAmount: array[3] of Decimal;
        PrepmtTotalAmount: Decimal;
        PrepmtVATAmount: Decimal;
        PrepmtTotalAmount2: Decimal;
        ProfitLCY: array[3] of Decimal;
        ProfitPct: array[3] of Decimal;
        AdjProfitLCY: array[3] of Decimal;
        AdjProfitPct: array[3] of Decimal;
        TotalAdjCostLCY: array[3] of Decimal;
        CreditLimitLCYExpendedPct: Decimal;
        ExchangeFactor: Decimal;
        PrepmtInvPct: Decimal;
        PrepmtDeductedPct: Decimal;
        i: Integer;
        AllowInvDisc: Boolean;
        CustInvDisc: Record "Cust. Invoice Disc.";
        AllowVATDifference: Boolean;
        VATAmountText: array[3] of Text[30];
        PrepmtVATAmountText: Text[30];
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesTax: Boolean;
        AllObj: Record AllObj;
        AmtInclVAT: Decimal;
        AvaInstalled: Record "Sales Line";
    begin
        if AmountType in [AmountType::Prepayment, AmountType::"Prepayment Invoiced"] then begin
            SalesPostPrepmt.GetSalesLines(SalesHeader, 0, TempSalesLine);
            if CombineShipmentFilterType = CombineShipmentFilterType::"No Shipment No." then begin
                TempSalesLine.SetFilter("Shipment No.", '<>%1', '');
                TempSalesLine.DeleteAll;
                TempSalesLine.SetRange("Shipment No.");
            end else
                if CombineShipmentFilterType = CombineShipmentFilterType::"Shipment No." then begin
                    if TempSalesLine.FindSet then
                        repeat
                            if (TempSalesLine."Shipment No." <> '') and SalesShipmentHeader.Get(TempSalesLine."Shipment No.") then begin
                                if SalesShipmentHeader."Order No." <> UnpostedDocumentNo then
                                    TempSalesLine.Delete;
                            end else
                                TempSalesLine.Delete;
                        until TempSalesLine.Next = 0;
                end;
            if AmountType = AmountType::"Prepayment Invoiced" then begin
                if TempSalesLine.FindSet then
                    repeat
                        PrepmtTotalAmount += TempSalesLine."Prepmt. Amount Inv. Incl. VAT";
                    until TempSalesLine.Next = 0;
                exit(PrepmtTotalAmount);
            end else begin
                SalesPostPrepmt.SumPrepmt(SalesHeader, TempSalesLine, TempVATAmountLine4, PrepmtTotalAmount, PrepmtVATAmount, PrepmtVATAmountText);
                if SalesHeader."Prices Including VAT" then begin
                    exit(PrepmtTotalAmount);
                end else
                    exit(PrepmtTotalAmount + PrepmtVATAmount);
            end;
        end;
        if not AllObj.Get(AllObj."Object Type"::Codeunit, 14073349) then
            if AllObj.Get(AllObj."Object Type"::Codeunit, 70004900) then;
        if AllObj."Object ID" > 0 then begin
            AvaInstalled."Document Type" := SalesHeader."Document Type";
            AvaInstalled."Document No." := SalesHeader."No.";
            CODEUNIT.Run(AllObj."Object ID", AvaInstalled);
            if AvaInstalled."Tax Liable" then begin
                TempSalesLine.Reset;
                TempSalesLine.DeleteAll;
                Clear(TempSalesLine);
                Clear(SalesAmountCalcMgt);
                SalesAmountCalcMgt.GetSalesLines(SalesHeader, TempSalesLine, AmountType);
                Clear(SalesAmountCalcMgt);
                if CombineShipmentFilterType = CombineShipmentFilterType::"No Shipment No." then begin
                    TempSalesLine.SetFilter("Shipment No.", '<>%1', '');
                    TempSalesLine.DeleteAll;
                    TempSalesLine.SetRange("Shipment No.");
                end else
                    if CombineShipmentFilterType = CombineShipmentFilterType::"Shipment No." then begin
                        if TempSalesLine.FindSet then
                            repeat
                                if (TempSalesLine."Shipment No." <> '') and SalesShipmentHeader.Get(TempSalesLine."Shipment No.") then begin
                                    if SalesShipmentHeader."Order No." <> UnpostedDocumentNo then
                                        TempSalesLine.Delete;
                                end else
                                    TempSalesLine.Delete;
                            until TempSalesLine.Next = 0;
                    end;
                if ExcludePrepaymentLines then begin
                    TempSalesLine.FilterGroup(-1);
                    TempSalesLine.SetFilter("Prepayment %", '>0');
                    TempSalesLine.SetRange("Special Order", true);
                    TempSalesLine.DeleteAll;
                    TempSalesLine.SetRange("Prepayment %");
                    TempSalesLine.SetRange("Special Order");
                end;
                if AllObj."Object ID" = 14073349 then begin
                    CODEUNIT.Run(14073350, SalesHeader);
                end else begin
                    CODEUNIT.Run(70004901, SalesHeader);
                end;
                if TempSalesLine.FindFirst then
                    repeat
                        if AllObj."Object ID" = 14073349 then
                            CODEUNIT.Run(14073351, TempSalesLine)
                        else
                            CODEUNIT.Run(70004902, TempSalesLine);
                        AmtInclVAT += TempSalesLine."Amount Including VAT";
                    until TempSalesLine.Next = 0;
                exit(AmtInclVAT);
            end;
        end;

        SalesTax := SalesHeader."Tax Area Code" <> '';
        SalesSetup.Get;
        CustInvDisc.SetRange(Code, SalesHeader."Invoice Disc. Code");
        AllowInvDisc := not (SalesSetup."Calc. Inv. Discount" and CustInvDisc.FindFirst);
        AllowVATDifference :=
          SalesSetup."Allow VAT Difference" and
          not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Quote, SalesHeader."Document Type"::"Blanket Order"]);
        if SalesTax then begin
            TaxArea.Get(SalesHeader."Tax Area Code");
            if SalesHeader."Currency Factor" = 0 then
                ExchangeFactor := 1
            else
                ExchangeFactor := SalesHeader."Currency Factor";
        end;

        Clear(SalesLine);
        Clear(TotalSalesLine);
        Clear(TotalSalesLineLCY);

        SalesLine.Reset;

        for i := 1 to 3 do begin
            TempSalesLine.Reset;
            TempSalesLine.DeleteAll;
            Clear(TempSalesLine);
            Clear(SalesAmountCalcMgt);
            SalesAmountCalcMgt.GetSalesLines(SalesHeader, TempSalesLine, i - 1);
            Clear(SalesAmountCalcMgt);
            if CombineShipmentFilterType = CombineShipmentFilterType::"No Shipment No." then begin
                TempSalesLine.SetFilter("Shipment No.", '<>%1', '');
                TempSalesLine.DeleteAll;
                TempSalesLine.SetRange("Shipment No.");
            end else
                if CombineShipmentFilterType = CombineShipmentFilterType::"Shipment No." then begin
                    if TempSalesLine.FindSet then
                        repeat
                            if (TempSalesLine."Shipment No." <> '') and SalesShipmentHeader.Get(TempSalesLine."Shipment No.") then begin
                                if SalesShipmentHeader."Order No." <> UnpostedDocumentNo then
                                    TempSalesLine.Delete;
                            end else
                                TempSalesLine.Delete;
                        until TempSalesLine.Next = 0;
                end;
            if ExcludePrepaymentLines then begin
                TempSalesLine.FilterGroup(-1);
                TempSalesLine.SetFilter("Prepayment %", '>0');
                TempSalesLine.SetRange("Special Order", true);
                TempSalesLine.DeleteAll;
                TempSalesLine.SetRange("Prepayment %");
                TempSalesLine.SetRange("Special Order");
            end;
            if SalesTax then begin
                SalesTaxCalculate.StartSalesTaxCalculation;
                if not TaxArea."Use External Tax Engine" then begin
                    TempSalesLine.SetFilter(Type, '>0');
                    TempSalesLine.SetFilter(Quantity, '<>0');
                    if TempSalesLine.Find('-') then
                        repeat
                            SalesTaxCalculate.AddSalesLine(TempSalesLine);
                        until TempSalesLine.Next = 0;
                end;
                TempSalesLine.Reset;
                case i of
                    1:
                        begin
                            TempSalesTaxLine1.DeleteAll;
                            if TaxArea."Use External Tax Engine" then
                                SalesTaxCalculate.CallExternalTaxEngineForSales(SalesHeader, true)
                            else
                                SalesTaxCalculate.EndSalesTaxCalculation(SalesHeader."Posting Date");
                            SalesTaxCalculate.GetSalesTaxAmountLineTable(TempSalesTaxLine1);
                        end;
                    2:
                        begin
                            TempSalesTaxLine2.DeleteAll;
                            if TaxArea."Use External Tax Engine" then
                                SalesTaxCalculate.CallExternalTaxEngineForSales(SalesHeader, true)
                            else
                                SalesTaxCalculate.EndSalesTaxCalculation(SalesHeader."Posting Date");
                            SalesTaxCalculate.GetSalesTaxAmountLineTable(TempSalesTaxLine2);
                        end;
                    3:
                        begin
                            TempSalesTaxLine3.DeleteAll;
                            if TaxArea."Use External Tax Engine" then
                                SalesTaxCalculate.CallExternalTaxEngineForSales(SalesHeader, true)
                            else
                                SalesTaxCalculate.EndSalesTaxCalculation(SalesHeader."Posting Date");
                            SalesTaxCalculate.GetSalesTaxAmountLineTable(TempSalesTaxLine3);
                        end;
                end;

                if SalesHeader.Status = SalesHeader.Status::Open then
                    SalesTaxCalculate.DistTaxOverSalesLines(TempSalesLine);
            end else begin
                case i of
                    1:
                        SalesLine.CalcVATAmountLines(0, SalesHeader, TempSalesLine, TempVATAmountLine1);
                    2:
                        SalesLine.CalcVATAmountLines(0, SalesHeader, TempSalesLine, TempVATAmountLine2);
                    3:
                        SalesLine.CalcVATAmountLines(0, SalesHeader, TempSalesLine, TempVATAmountLine3);
                end;
            end;
            SalesAmountCalcMgt.SumSalesLinesTemp(
              SalesHeader, TempSalesLine, i - 1, TotalSalesLine[i], TotalSalesLineLCY[i],
              VATAmount[i], VATAmountText[i], ProfitLCY[i], ProfitPct[i], TotalAdjCostLCY[i]);
            if i = 3 then
                TotalAdjCostLCY[i] := TotalSalesLineLCY[i]."Unit Cost (LCY)";

            AdjProfitLCY[i] := TotalSalesLineLCY[i].Amount - TotalAdjCostLCY[i];
            if TotalSalesLineLCY[i].Amount <> 0 then
                AdjProfitPct[i] := Round(AdjProfitLCY[i] / TotalSalesLineLCY[i].Amount * 100, 0.1);

            if not SalesTax then begin
                if SalesHeader."Prices Including VAT" then begin
                    TotalAmount2[i] := TotalSalesLine[i].Amount;
                    TotalAmount1[i] := TotalAmount2[i] + VATAmount[i];
                    TotalSalesLine[i]."Line Amount" := TotalAmount1[i] + TotalSalesLine[i]."Inv. Discount Amount";
                end else begin
                    TotalAmount1[i] := TotalSalesLine[i].Amount;
                    TotalAmount2[i] := TotalSalesLine[i]."Amount Including VAT";
                end;
            end else begin
                TotalAmount1[i] := TotalSalesLine[i].Amount;
                TotalAmount2[i] := TotalAmount1[i];
                VATAmount[i] := 0;

                SalesTaxCalculate.GetSummarizedSalesTaxTable(TempSalesTaxAmtLine);
                with TempSalesTaxAmtLine do begin
                    Reset;
                    SetCurrentKey("Print Order", "Tax Area Code for Key", "Tax Jurisdiction Code");
                    if Find('-') then
                        repeat
                            VATAmount[i] := VATAmount[i] + "Tax Amount";
                        until Next = 0;
                    TotalAmount2[i] := TotalAmount2[i] + VATAmount[i];
                end;
            end;
        end;
        exit(TotalAmount2[AmountType + 1]);
    end;

    local procedure Pct(Numerator: Decimal; Denominator: Decimal): Decimal
    begin
        if Denominator = 0 then
            exit(0);
        exit(Round(Numerator / Denominator * 10000, 1));
    end;
}


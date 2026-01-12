codeunit 50057 "ARC Sales Amt. Calc. Mgt."
{

    // Copied the code from EFT  Salex Tax Amt Mgt. All Credit to ChargeLogic, Copied so that it gives flexibility to moidfy 
    // without modifying the EFT functionality
    trigger OnRun()
    begin
    end;

    var
        SalesHeader: Record "Sales Header";
        TempPrepaymentSalesLine: Record "Sales Line" temporary;
        Currency: Record Currency;
        Text016: Label 'Tax Amount';
        Text017: Label '%1% Tax';
        Text047: Label 'cannot be more than %1.';
        Text048: Label 'must be at least %1.';
        TotalSalesLine: Record "Sales Line";
        TotalSalesLineLCY: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";
        RoundingLineInserted: Boolean;
        SalesLine: Record "Sales Line";
        CostCalcMgt: Codeunit "Cost Calculation Management";
        TempSalesLine: Record "Sales Line";
        LastLineRetrieved: Boolean;
        GLSetupRead: Boolean;
        GLSetup: Record "General Ledger Setup";
        Text050: Label 'The total %1 cannot be more than %2.';
        Text051: Label 'The total %1 must be at least %2.';
        TempPrepmtDeductLCYSalesLine: Record "Sales Line" temporary;
        RoundingLineNo: Integer;
        TempSalesLineForSalesTax: Record "Sales Line" temporary;
        TempSalesLineForSpread: Record "Sales Line" temporary;
        SalesLineACY: Record "Sales Line";
        UseDate: Date;

    [Scope('Internal')]
    procedure GetSalesLines(var NewSalesHeader: Record "Sales Header"; var NewSalesLine: Record "Sales Line"; QtyType: Option General,Invoicing,Shipping)
    var
        OldSalesLine: Record "Sales Line";
        MergedSalesLines: Record "Sales Line" temporary;
        TotalAdjCostLCY: Decimal;
    begin
        SalesHeader := NewSalesHeader;
        CreatePrepaymentLines(SalesHeader, TempPrepaymentSalesLine, false);
        MergeSaleslines(SalesHeader, OldSalesLine, TempPrepaymentSalesLine, MergedSalesLines);
        SumSalesLines2(NewSalesLine, MergedSalesLines, QtyType, true, false, TotalAdjCostLCY);
    end;

    local procedure CreatePrepaymentLines(SalesHeader: Record "Sales Header"; var TempPrepmtSalesLine: Record "Sales Line"; CompleteFunctionality: Boolean)
    var
        GLAcc: Record "G/L Account";
        SalesLine: Record "Sales Line";
        TempExtTextLine: Record "Extended Text Line" temporary;
        GenPostingSetup: Record "General Posting Setup";
        TransferExtText: Codeunit "Transfer Extended Text";
        NextLineNo: Integer;
        Fraction: Decimal;
        VATDifference: Decimal;
        TempLineFound: Boolean;
        PrePmtTestRun: Boolean;
        PrepmtAmtToDeduct: Decimal;
    begin
        GetGLSetup;
        with SalesLine do begin
            SetRange("Document Type", SalesHeader."Document Type");
            SetRange("Document No.", SalesHeader."No.");
            if not Find('+') then
                exit;
            NextLineNo := "Line No." + 10000;
            SetFilter(Quantity, '>0');
            SetFilter("Qty. to Invoice", '>0');
            TempPrepmtSalesLine.SetHasBeenShown;
            if Find('-') then
                repeat
                    if CompleteFunctionality then
                        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Invoice then begin
                            if not SalesHeader.Ship and ("Qty. to Invoice" = Quantity - "Quantity Invoiced") then
                                if "Qty. Shipped Not Invoiced" < "Qty. to Invoice" then
                                    Validate("Qty. to Invoice", "Qty. Shipped Not Invoiced");
                            Fraction := ("Qty. to Invoice" + "Quantity Invoiced") / Quantity;

                            if "Prepayment %" <> 100 then
                                case true of
                                    ("Prepmt Amt to Deduct" <> 0) and
                                  ("Prepmt Amt to Deduct" > Round(Fraction * "Line Amount", Currency."Amount Rounding Precision")):
                                        FieldError(
                                          "Prepmt Amt to Deduct",
                                          StrSubstNo(Text047,
                                            Round(Fraction * "Line Amount", Currency."Amount Rounding Precision")));
                                    ("Prepmt. Amt. Inv." <> 0) and
                                  (Round((1 - Fraction) * "Line Amount", Currency."Amount Rounding Precision") <
                                   Round(
                                     Round(
                                       Round("Unit Price" * (Quantity - "Quantity Invoiced" - "Qty. to Invoice"), Currency."Amount Rounding Precision") *
                                       (1 - ("Line Discount %" / 100)), Currency."Amount Rounding Precision") *
                                     "Prepayment %" / 100, Currency."Amount Rounding Precision")):
                                        FieldError(
                                          "Prepmt Amt to Deduct",
                                          StrSubstNo(Text048,
                                            Round(
                                              "Prepmt. Amt. Inv." - "Prepmt Amt Deducted" - (1 - Fraction) * "Line Amount",
                                              Currency."Amount Rounding Precision")));
                                end;
                        end else
                            if not PrePmtTestRun then begin
                                TestGetShipmentPPmtAmtToDeduct(SalesHeader);
                                PrePmtTestRun := true;
                            end;
                    if "Prepmt Amt to Deduct" <> 0 then begin
                        if ("Gen. Bus. Posting Group" <> GenPostingSetup."Gen. Bus. Posting Group") or
                           ("Gen. Prod. Posting Group" <> GenPostingSetup."Gen. Prod. Posting Group")
                        then begin
                            GenPostingSetup.Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");
                            GenPostingSetup.TestField("Sales Prepayments Account");
                        end;
                        GLAcc.Get(GenPostingSetup."Sales Prepayments Account");
                        TempLineFound := false;
                        if SalesHeader."Compress Prepayment" then begin
                            TempPrepmtSalesLine.SetRange("No.", GLAcc."No.");
                            TempPrepmtSalesLine.SetRange("Dimension Set ID", "Dimension Set ID");
                            TempLineFound := TempPrepmtSalesLine.FindFirst;
                        end;
                        if TempLineFound then begin
                            PrepmtAmtToDeduct :=
                              TempPrepmtSalesLine."Prepmt Amt to Deduct" +
                              InsertedPrepmtVATBaseToDeduct(SalesLine, TempPrepmtSalesLine."Line No.", TempPrepmtSalesLine."Unit Price");
                            VATDifference := TempPrepmtSalesLine."VAT Difference";
                            if SalesHeader."Prepmt. Include Tax" then
                                TempPrepmtSalesLine.Validate(
                                  "Unit Price",
                                  TempPrepmtSalesLine."Unit Price" + "Prepmt Amt to Deduct" * (1 + "VAT %" / 100))
                            else
                                TempPrepmtSalesLine.Validate(
                                  "Unit Price", TempPrepmtSalesLine."Unit Price" + "Prepmt Amt to Deduct");
                            TempPrepmtSalesLine.Validate("VAT Difference", VATDifference - "Prepmt VAT Diff. to Deduct");
                            if SalesHeader."Prepmt. Include Tax" then
                                TempPrepmtSalesLine."Prepmt Amt to Deduct" += CalcAmountIncludingTax("Prepmt Amt to Deduct")
                            else
                                TempPrepmtSalesLine."Prepmt Amt to Deduct" := PrepmtAmtToDeduct;
                            if "Prepayment %" < TempPrepmtSalesLine."Prepayment %" then
                                TempPrepmtSalesLine."Prepayment %" := "Prepayment %";
                            TempPrepmtSalesLine.Modify;
                        end else begin
                            TempPrepmtSalesLine.Init;
                            TempPrepmtSalesLine."Document Type" := SalesHeader."Document Type";
                            TempPrepmtSalesLine."Document No." := SalesHeader."No.";
                            TempPrepmtSalesLine."Line No." := 0;
                            TempPrepmtSalesLine."System-Created Entry" := true;
                            if CompleteFunctionality then
                                TempPrepmtSalesLine.Validate(Type, TempPrepmtSalesLine.Type::"G/L Account")
                            else
                                TempPrepmtSalesLine.Type := TempPrepmtSalesLine.Type::"G/L Account";
                            TempPrepmtSalesLine.Validate("No.", GenPostingSetup."Sales Prepayments Account");
                            TempPrepmtSalesLine.Validate(Quantity, -1);
                            TempPrepmtSalesLine."Qty. to Ship" := TempPrepmtSalesLine.Quantity;
                            TempPrepmtSalesLine."Qty. to Invoice" := TempPrepmtSalesLine.Quantity;
                            PrepmtAmtToDeduct := InsertedPrepmtVATBaseToDeduct(SalesLine, NextLineNo, 0);
                            if SalesHeader."Prepmt. Include Tax" then
                                TempPrepmtSalesLine.Validate("Unit Price", "Prepmt Amt to Deduct" * (1 + "VAT %" / 100))
                            else
                                TempPrepmtSalesLine.Validate("Unit Price", "Prepmt Amt to Deduct");
                            TempPrepmtSalesLine.Validate("VAT Difference", -"Prepmt VAT Diff. to Deduct");
                            if SalesHeader."Prepmt. Include Tax" then
                                TempPrepmtSalesLine."Prepmt Amt to Deduct" := CalcAmountIncludingTax("Prepmt Amt to Deduct")
                            else
                                TempPrepmtSalesLine."Prepmt Amt to Deduct" := PrepmtAmtToDeduct;
                            TempPrepmtSalesLine."Prepayment %" := "Prepayment %";
                            TempPrepmtSalesLine."Prepayment Line" := true;
                            TempPrepmtSalesLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
                            TempPrepmtSalesLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
                            TempPrepmtSalesLine."Dimension Set ID" := "Dimension Set ID";
                            TempPrepmtSalesLine."Line No." := NextLineNo;
                            NextLineNo := NextLineNo + 10000;
                            TempPrepmtSalesLine.Insert;

                            TransferExtText.PrepmtGetAnyExtText(
                              TempPrepmtSalesLine."No.", DATABASE::"Sales Invoice Line",
                              SalesHeader."Document Date", SalesHeader."Language Code", TempExtTextLine);
                            if TempExtTextLine.Find('-') then
                                repeat
                                    TempPrepmtSalesLine.Init;
                                    TempPrepmtSalesLine.Description := TempExtTextLine.Text;
                                    TempPrepmtSalesLine."System-Created Entry" := true;
                                    TempPrepmtSalesLine."Prepayment Line" := true;
                                    TempPrepmtSalesLine."Line No." := NextLineNo;
                                    NextLineNo := NextLineNo + 10000;
                                    TempPrepmtSalesLine.Insert;
                                until TempExtTextLine.Next = 0;
                        end;
                    end;
                until Next = 0
        end;
        DividePrepmtAmountLCY(TempPrepmtSalesLine, SalesHeader);

        if Is100PctPrepmtInvoice(TempPrepmtSalesLine) then
            TotalSalesLineLCY."Prepayment %" := 100;
    end;

    local procedure SumSalesLines2(var NewSalesLine: Record "Sales Line"; var OldSalesLine: Record "Sales Line"; QtyType: Option General,Invoicing,Shipping; InsertSalesLine: Boolean; CalcAdCostLCY: Boolean; var TotalAdjCostLCY: Decimal)
    var
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        TempVATAmountLineRemainder: Record "VAT Amount Line" temporary;
        SalesLineQty: Decimal;
        AdjCostLCY: Decimal;
        BiggestLineNo: Integer;
    begin
        TotalAdjCostLCY := 0;
        TempVATAmountLineRemainder.DeleteAll;
        OldSalesLine.CalcVATAmountLines(QtyType, SalesHeader, OldSalesLine, TempVATAmountLine);
        with SalesHeader do begin
            GetGLSetup;
            SalesSetup.Get;
            GetCurrency;
            OldSalesLine.SetRange("Document Type", "Document Type");
            OldSalesLine.SetRange("Document No.", "No.");
            RoundingLineInserted := false;
            if OldSalesLine.FindSet then
                repeat
                    if not RoundingLineInserted then
                        SalesLine := OldSalesLine;
                    case QtyType of
                        QtyType::General:
                            begin
                                SalesLineQty := SalesLine.Quantity - SalesLine."Quantity Invoiced";
                                SalesLine."Quantity Invoiced" := 0;
                            end;
                        QtyType::Invoicing:
                            case "Document Type" of
                                "Document Type"::Order:
                                    begin
                                        if Ship and Invoice then begin
                                            if SalesLine."Qty. to Invoice" < SalesLine."Qty. to Ship" + SalesLine."Quantity Shipped" then
                                                SalesLineQty := SalesLine."Qty. to Invoice"
                                            else
                                                SalesLineQty := SalesLine."Qty. to Ship" + SalesLine."Quantity Shipped";
                                        end else
                                            if Invoice then begin
                                                if SalesLine."Qty. to Invoice" < SalesLine."Quantity Shipped" then
                                                    SalesLineQty := SalesLine."Qty. to Invoice"
                                                else
                                                    SalesLineQty := SalesLine."Quantity Shipped";
                                            end else
                                                SalesLineQty := SalesLine."Qty. to Invoice";
                                    end;
                                "Document Type"::"Return Order":
                                    begin
                                        if Receive and Invoice then begin
                                            if SalesLine."Qty. to Invoice" < SalesLine."Return Qty. to Receive" + SalesLine."Return Qty. Received" then
                                                SalesLineQty := SalesLine."Qty. to Invoice"
                                            else
                                                SalesLineQty := SalesLine."Return Qty. to Receive" + SalesLine."Return Qty. Received";
                                        end else
                                            if Invoice then begin
                                                if SalesLine."Qty. to Invoice" < SalesLine."Return Qty. Received" then
                                                    SalesLineQty := SalesLine."Qty. to Invoice"
                                                else
                                                    SalesLineQty := SalesLine."Return Qty. Received";
                                            end else
                                                SalesLineQty := SalesLine."Qty. to Invoice";
                                    end;
                                else
                                    SalesLineQty := SalesLine."Qty. to Invoice";
                            end;
                        QtyType::Shipping:
                            begin
                                if "Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"] then
                                    SalesLineQty := SalesLine."Return Qty. to Receive"
                                else
                                    SalesLineQty := SalesLine."Qty. to Ship";
                            end;
                    end;
                    DivideAmount(QtyType, SalesLineQty, TempVATAmountLine, TempVATAmountLineRemainder);
                    SalesLine.Quantity := SalesLineQty;
                    if SalesLineQty <> 0 then begin
                        if (SalesLine.Amount <> 0) and not RoundingLineInserted then
                            if TotalSalesLine.Amount = 0 then
                                TotalSalesLine."VAT %" := SalesLine."VAT %"
                            else
                                if TotalSalesLine."VAT %" <> SalesLine."VAT %" then
                                    TotalSalesLine."VAT %" := 0;
                        RoundAmount(SalesLineQty);

                        if (QtyType in [QtyType::General, QtyType::Invoicing]) and
                           not InsertSalesLine and CalcAdCostLCY
                        then begin
                            AdjCostLCY := CostCalcMgt.CalcSalesLineCostLCY(SalesLine, QtyType);
                            TotalAdjCostLCY := TotalAdjCostLCY + GetSalesLineAdjCostLCY(SalesLine, QtyType, AdjCostLCY);
                        end;

                        SalesLine := TempSalesLine;
                    end;
                    if InsertSalesLine then begin
                        NewSalesLine := SalesLine;
                        NewSalesLine.Insert;
                    end;
                    if RoundingLineInserted then
                        LastLineRetrieved := true
                    else begin
                        BiggestLineNo := MAX(BiggestLineNo, OldSalesLine."Line No.");
                        LastLineRetrieved := OldSalesLine.Next = 0;
                        if LastLineRetrieved and SalesSetup."Invoice Rounding" then
                            InvoiceRounding(true, BiggestLineNo);
                    end;
                until LastLineRetrieved;
        end;
    end;

    local procedure MergeSaleslines(SalesHeader: Record "Sales Header"; var Salesline: Record "Sales Line"; var Salesline2: Record "Sales Line"; var MergedSalesline: Record "Sales Line")
    begin
        with Salesline do begin
            SetRange("Document Type", SalesHeader."Document Type");
            SetRange("Document No.", SalesHeader."No.");
            if Find('-') then
                repeat
                    MergedSalesline := Salesline;
                    MergedSalesline.Insert;
                until Next = 0;
        end;
        with Salesline2 do begin
            SetRange("Document Type", SalesHeader."Document Type");
            SetRange("Document No.", SalesHeader."No.");
            if Find('-') then
                repeat
                    MergedSalesline := Salesline2;
                    MergedSalesline.Insert;
                until Next = 0;
        end;
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then
            GLSetup.Get;
        GLSetupRead := true;
    end;

    local procedure TestGetShipmentPPmtAmtToDeduct(var SalesHeader: Record "Sales Header")
    var
        SalesLine2: Record "Sales Line";
        TempSalesLine3: Record "Sales Line" temporary;
        TempTotalSalesLine: Record "Sales Line" temporary;
        TempSalesShptLine: Record "Sales Shipment Line" temporary;
        SalesShptLine: Record "Sales Shipment Line";
        MaxAmtToDeduct: Decimal;
    begin
        SalesLine2.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine2.SetRange("Document No.", SalesHeader."No.");
        SalesLine2.SetFilter(Quantity, '>0');
        SalesLine2.SetFilter("Qty. to Invoice", '>0');
        SalesLine2.SetFilter("Shipment No.", '<>%1', '');
        SalesLine2.SetFilter("Prepmt Amt to Deduct", '<>0');
        if SalesLine2.IsEmpty then
            exit;
        SalesLine2.SetRange("Prepmt Amt to Deduct");

        if SalesLine2.FindSet then
            repeat
                if SalesShptLine.Get(SalesLine2."Shipment No.", SalesLine2."Shipment Line No.") then begin
                    TempSalesLine3 := SalesLine2;
                    TempSalesLine3.Insert;
                    TempSalesShptLine := SalesShptLine;
                    if TempSalesShptLine.Insert then;

                    if not TempTotalSalesLine.Get(SalesLine2."Document Type"::Order, SalesShptLine."Order No.", SalesShptLine."Order Line No.") then begin
                        TempTotalSalesLine.Init;
                        TempTotalSalesLine."Document Type" := SalesLine2."Document Type"::Order;
                        TempTotalSalesLine."Document No." := SalesShptLine."Order No.";
                        TempTotalSalesLine."Line No." := SalesShptLine."Order Line No.";
                        TempTotalSalesLine.Insert;
                    end;
                    TempTotalSalesLine."Qty. to Invoice" := TempTotalSalesLine."Qty. to Invoice" + SalesLine2."Qty. to Invoice";
                    TempTotalSalesLine."Prepmt Amt to Deduct" := TempTotalSalesLine."Prepmt Amt to Deduct" + SalesLine2."Prepmt Amt to Deduct";
                    AdjustInvLineWith100PctPrepmt(SalesLine2, TempTotalSalesLine);
                    TempTotalSalesLine.Modify;
                end;
            until SalesLine2.Next = 0;

        if TempSalesLine3.FindSet then
            repeat
                if TempSalesShptLine.Get(TempSalesLine3."Shipment No.", TempSalesLine3."Shipment Line No.") then
                    if SalesLine2.Get(TempSalesLine3."Document Type"::Order, TempSalesShptLine."Order No.", TempSalesShptLine."Order Line No.") then
                        if TempTotalSalesLine.Get(
                             TempSalesLine3."Document Type"::Order, TempSalesShptLine."Order No.", TempSalesShptLine."Order Line No.")
                        then begin
                            MaxAmtToDeduct := SalesLine2."Prepmt. Amt. Inv." - SalesLine2."Prepmt Amt Deducted";

                            if TempTotalSalesLine."Prepmt Amt to Deduct" > MaxAmtToDeduct then
                                Error(StrSubstNo(Text050, SalesLine2.FieldCaption("Prepmt Amt to Deduct"), MaxAmtToDeduct));

                            if (TempTotalSalesLine."Qty. to Invoice" = SalesLine2.Quantity - SalesLine2."Quantity Invoiced") and
                               (TempTotalSalesLine."Prepmt Amt to Deduct" <> MaxAmtToDeduct)
                            then
                                Error(StrSubstNo(Text051, SalesLine2.FieldCaption("Prepmt Amt to Deduct"), MaxAmtToDeduct));
                        end;
            until TempSalesLine3.Next = 0;
    end;

    local procedure InsertedPrepmtVATBaseToDeduct(SalesLine: Record "Sales Line"; PrepmtLineNo: Integer; TotalPrepmtAmtToDeduct: Decimal): Decimal
    var
        PrepmtVATBaseToDeduct: Decimal;
    begin
        with SalesLine do begin
            if SalesHeader."Prices Including VAT" then
                PrepmtVATBaseToDeduct :=
                  Round(
                    (TotalPrepmtAmtToDeduct + "Prepmt Amt to Deduct") / (1 + "Prepayment VAT %" / 100),
                    Currency."Amount Rounding Precision") -
                  Round(
                    TotalPrepmtAmtToDeduct / (1 + "Prepayment VAT %" / 100),
                    Currency."Amount Rounding Precision")
            else
                PrepmtVATBaseToDeduct := "Prepmt Amt to Deduct";
        end;
        with TempPrepmtDeductLCYSalesLine do begin
            TempPrepmtDeductLCYSalesLine := SalesLine;
            if "Document Type" = "Document Type"::Order then
                "Qty. to Invoice" := GetQtyToInvoice(SalesLine)
            else
                GetLineDataFromOrder(TempPrepmtDeductLCYSalesLine);
            CalcPrepaymentToDeduct;
            if SalesHeader."Prepmt. Include Tax" then
                "Prepmt Amt to Deduct" := CalcAmountIncludingTax(SalesLine."Prepmt Amt to Deduct");
            "Line Amount" := GetLineAmountToHandle("Qty. to Invoice");
            "Attached to Line No." := PrepmtLineNo;
            "VAT Base Amount" := PrepmtVATBaseToDeduct;
            Insert;
        end;
        exit(PrepmtVATBaseToDeduct);
    end;

    local procedure DividePrepmtAmountLCY(var PrepmtSalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    var
        CurrExchRate: Record "Currency Exchange Rate";
        ActualCurrencyFactor: Decimal;
    begin
        with PrepmtSalesLine do begin
            Reset;
            SetFilter(Type, '<>%1', Type::" ");
            if FindSet then
                repeat
                    if SalesHeader."Currency Code" <> '' then
                        ActualCurrencyFactor :=
                          Round(
                            CurrExchRate.ExchangeAmtFCYToLCY(
                              SalesHeader."Posting Date",
                              SalesHeader."Currency Code",
                              "Prepmt Amt to Deduct",
                              SalesHeader."Currency Factor")) /
                          "Prepmt Amt to Deduct"
                    else
                        ActualCurrencyFactor := 1;

                    UpdatePrepmtAmountInvBuf("Line No.", ActualCurrencyFactor);
                until Next = 0;
            Reset;
        end;
    end;

    local procedure Is100PctPrepmtInvoice(var TempSalesLine: Record "Sales Line" temporary) Result: Boolean
    begin
        if TempSalesLine.IsEmpty then
            exit(false);
        TempSalesLine.SetFilter("Prepayment %", '<100');
        Result := TempSalesLine.IsEmpty;
        TempSalesLine.SetRange("Prepayment %");
    end;

    local procedure GetCurrency()
    begin
        with SalesHeader do
            if "Currency Code" = '' then
                Currency.InitRoundingPrecision
            else begin
                Currency.Get("Currency Code");
                Currency.TestField("Amount Rounding Precision");
            end;
    end;

    local procedure DivideAmount(QtyType: Option General,Invoicing,Shipping; SalesLineQty: Decimal; var TempVATAmountLine: Record "VAT Amount Line" temporary; var TempVATAmountLineRemainder: Record "VAT Amount Line" temporary)
    begin
        if RoundingLineInserted and (RoundingLineNo = SalesLine."Line No.") then
            exit;
        with SalesLine do
            if (SalesLineQty = 0) or ("Unit Price" = 0) then begin
                "Line Amount" := 0;
                "Line Discount Amount" := 0;
                "Inv. Discount Amount" := 0;
                "VAT Base Amount" := 0;
                Amount := 0;
                "Amount Including VAT" := 0;
            end else
                if "VAT Calculation Type" = "VAT Calculation Type"::"Sales Tax" then begin
                    if (QtyType = QtyType::Invoicing) and
                       TempSalesLineForSalesTax.Get("Document Type", "Document No.", "Line No.")
                    then begin
                        "Line Amount" := TempSalesLineForSalesTax."Line Amount";
                        "Line Discount Amount" := TempSalesLineForSalesTax."Line Discount Amount";
                        Amount := TempSalesLineForSalesTax.Amount;
                        "Amount Including VAT" := TempSalesLineForSalesTax."Amount Including VAT";
                        "Inv. Discount Amount" := TempSalesLineForSalesTax."Inv. Discount Amount";
                        "VAT Base Amount" := TempSalesLineForSalesTax."VAT Base Amount";
                    end else begin
                        "Line Amount" := Round(SalesLineQty * "Unit Price", Currency."Amount Rounding Precision");
                        if SalesLineQty <> Quantity then
                            "Line Discount Amount" :=
                              Round("Line Amount" * "Line Discount %" / 100, Currency."Amount Rounding Precision");
                        "Line Amount" := "Line Amount" - "Line Discount Amount";
                        if "Allow Invoice Disc." then
                            if QtyType = QtyType::Invoicing then
                                "Inv. Discount Amount" := "Inv. Disc. Amount to Invoice"
                            else begin
                                TempSalesLineForSpread."Inv. Discount Amount" :=
                                  TempSalesLineForSpread."Inv. Discount Amount" +
                                  "Inv. Discount Amount" * SalesLineQty / Quantity;
                                "Inv. Discount Amount" :=
                                  Round(TempSalesLineForSpread."Inv. Discount Amount", Currency."Amount Rounding Precision");
                                TempSalesLineForSpread."Inv. Discount Amount" :=
                                  TempSalesLineForSpread."Inv. Discount Amount" - "Inv. Discount Amount";
                            end;
                        Amount := "Line Amount" - "Inv. Discount Amount";
                        "VAT Base Amount" := Amount;
                        "Amount Including VAT" := Amount;
                    end;
                end else begin
                    TempVATAmountLine.Get("VAT Identifier", "VAT Calculation Type", "Tax Group Code", "Tax Area Code", false, "Line Amount" >= 0);
                    if "VAT Calculation Type" = "VAT Calculation Type"::"Sales Tax" then
                        "VAT %" := TempVATAmountLine."VAT %";
                    TempVATAmountLineRemainder := TempVATAmountLine;
                    if not TempVATAmountLineRemainder.Find then begin
                        TempVATAmountLineRemainder.Init;
                        TempVATAmountLineRemainder.Insert;
                    end;
                    "Line Amount" := GetLineAmountToHandle(SalesLineQty) + GetPrepmtDiffToLineAmount(SalesLine);
                    if SalesLineQty <> Quantity then
                        "Line Discount Amount" :=
                          Round("Line Discount Amount" * SalesLineQty / Quantity, Currency."Amount Rounding Precision");

                    if "Allow Invoice Disc." and (TempVATAmountLine."Inv. Disc. Base Amount" <> 0) then
                        if QtyType = QtyType::Invoicing then
                            "Inv. Discount Amount" := "Inv. Disc. Amount to Invoice"
                        else begin
                            TempVATAmountLineRemainder."Invoice Discount Amount" :=
                              TempVATAmountLineRemainder."Invoice Discount Amount" +
                              TempVATAmountLine."Invoice Discount Amount" * "Line Amount" /
                              TempVATAmountLine."Inv. Disc. Base Amount";
                            "Inv. Discount Amount" :=
                              Round(
                                TempVATAmountLineRemainder."Invoice Discount Amount", Currency."Amount Rounding Precision");
                            TempVATAmountLineRemainder."Invoice Discount Amount" :=
                              TempVATAmountLineRemainder."Invoice Discount Amount" - "Inv. Discount Amount";
                        end;

                    if SalesHeader."Prices Including VAT" then begin
                        if (TempVATAmountLine."Line Amount" - TempVATAmountLine."Invoice Discount Amount" = 0) or
                           ("Line Amount" = 0)
                        then begin
                            TempVATAmountLineRemainder."VAT Amount" := 0;
                            TempVATAmountLineRemainder."Amount Including VAT" := 0;
                        end else begin
                            TempVATAmountLineRemainder."VAT Amount" :=
                              TempVATAmountLineRemainder."VAT Amount" +
                              TempVATAmountLine."VAT Amount" *
                              ("Line Amount" - "Inv. Discount Amount") /
                              (TempVATAmountLine."Line Amount" - TempVATAmountLine."Invoice Discount Amount");
                            TempVATAmountLineRemainder."Amount Including VAT" :=
                              TempVATAmountLineRemainder."Amount Including VAT" +
                              TempVATAmountLine."Amount Including VAT" *
                              ("Line Amount" - "Inv. Discount Amount") /
                              (TempVATAmountLine."Line Amount" - TempVATAmountLine."Invoice Discount Amount");
                        end;
                        if "Line Discount %" <> 100 then
                            "Amount Including VAT" :=
                              Round(TempVATAmountLineRemainder."Amount Including VAT", Currency."Amount Rounding Precision")
                        else
                            "Amount Including VAT" := 0;
                        Amount :=
                          Round("Amount Including VAT", Currency."Amount Rounding Precision") -
                          Round(TempVATAmountLineRemainder."VAT Amount", Currency."Amount Rounding Precision");
                        "VAT Base Amount" :=
                          Round(
                            Amount * (1 - SalesHeader."VAT Base Discount %" / 100), Currency."Amount Rounding Precision");
                        TempVATAmountLineRemainder."Amount Including VAT" :=
                          TempVATAmountLineRemainder."Amount Including VAT" - "Amount Including VAT";
                        TempVATAmountLineRemainder."VAT Amount" :=
                          TempVATAmountLineRemainder."VAT Amount" - "Amount Including VAT" + Amount;
                    end else begin
                        if "VAT Calculation Type" = "VAT Calculation Type"::"Full VAT" then begin
                            if "Line Discount %" <> 100 then
                                "Amount Including VAT" := "Line Amount" - "Inv. Discount Amount"
                            else
                                "Amount Including VAT" := 0;
                            Amount := 0;
                            "VAT Base Amount" := 0;
                        end else begin
                            Amount := "Line Amount" - "Inv. Discount Amount";
                            "VAT Base Amount" :=
                              Round(
                                Amount * (1 - SalesHeader."VAT Base Discount %" / 100), Currency."Amount Rounding Precision");
                            if TempVATAmountLine."VAT Base" = 0 then
                                TempVATAmountLineRemainder."VAT Amount" := 0
                            else
                                TempVATAmountLineRemainder."VAT Amount" :=
                                  TempVATAmountLineRemainder."VAT Amount" +
                                  TempVATAmountLine."VAT Amount" *
                                  ("Line Amount" - "Inv. Discount Amount") /
                                  (TempVATAmountLine."Line Amount" - TempVATAmountLine."Invoice Discount Amount");
                            if "Line Discount %" <> 100 then
                                "Amount Including VAT" :=
                                  Amount + Round(TempVATAmountLineRemainder."VAT Amount", Currency."Amount Rounding Precision")
                            else
                                "Amount Including VAT" := 0;
                            TempVATAmountLineRemainder."VAT Amount" :=
                              TempVATAmountLineRemainder."VAT Amount" - "Amount Including VAT" + Amount;
                        end;
                    end;

                    TempVATAmountLineRemainder.Modify;
                end;
    end;

    local procedure RoundAmount(SalesLineQty: Decimal)
    var
        CurrExchRate: Record "Currency Exchange Rate";
        NoVAT: Boolean;
    begin
        with SalesLine do begin
            IncrAmount(TotalSalesLine);
            Increment(TotalSalesLine."Net Weight", Round(SalesLineQty * "Net Weight", 0.00001));
            Increment(TotalSalesLine."Gross Weight", Round(SalesLineQty * "Gross Weight", 0.00001));
            Increment(TotalSalesLine."Unit Volume", Round(SalesLineQty * "Unit Volume", 0.00001));
            Increment(TotalSalesLine.Quantity, SalesLineQty);
            if "Units per Parcel" > 0 then
                Increment(
                  TotalSalesLine."Units per Parcel",
                  Round(SalesLineQty / "Units per Parcel", 1, '>'));

            TempSalesLine := SalesLine;
            SalesLineACY := SalesLine;

            if SalesHeader."Currency Code" <> '' then begin
                if SalesHeader."Posting Date" = 0D then
                    UseDate := WorkDate
                else
                    UseDate := SalesHeader."Posting Date";

                NoVAT := Amount = "Amount Including VAT";
                "Amount Including VAT" :=
                  Round(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                      UseDate, SalesHeader."Currency Code",
                      TotalSalesLine."Amount Including VAT", SalesHeader."Currency Factor")) -
                  TotalSalesLineLCY."Amount Including VAT";
                if NoVAT then
                    Amount := "Amount Including VAT"
                else
                    Amount :=
                      Round(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                          UseDate, SalesHeader."Currency Code",
                          TotalSalesLine.Amount, SalesHeader."Currency Factor")) -
                      TotalSalesLineLCY.Amount;
                "Line Amount" :=
                  Round(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                      UseDate, SalesHeader."Currency Code",
                      TotalSalesLine."Line Amount", SalesHeader."Currency Factor")) -
                  TotalSalesLineLCY."Line Amount";
                "Line Discount Amount" :=
                  Round(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                      UseDate, SalesHeader."Currency Code",
                      TotalSalesLine."Line Discount Amount", SalesHeader."Currency Factor")) -
                  TotalSalesLineLCY."Line Discount Amount";
                "Inv. Discount Amount" :=
                  Round(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                      UseDate, SalesHeader."Currency Code",
                      TotalSalesLine."Inv. Discount Amount", SalesHeader."Currency Factor")) -
                  TotalSalesLineLCY."Inv. Discount Amount";
                "VAT Difference" :=
                  Round(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                      UseDate, SalesHeader."Currency Code",
                      TotalSalesLine."VAT Difference", SalesHeader."Currency Factor")) -
                  TotalSalesLineLCY."VAT Difference";
            end;
            IncrAmount(TotalSalesLineLCY);
            if "VAT %" <> 0 then
                TotalSalesLineLCY."VAT %" := "VAT %";
            Increment(TotalSalesLineLCY."Unit Cost (LCY)", Round(SalesLineQty * "Unit Cost (LCY)"));
        end;
    end;

    local procedure GetSalesLineAdjCostLCY(SalesLine2: Record "Sales Line"; QtyType: Option General,Invoicing,Shipping; AdjCostLCY: Decimal): Decimal
    begin
        with SalesLine2 do begin
            if "Document Type" in ["Document Type"::Order, "Document Type"::Invoice] then
                AdjCostLCY := -AdjCostLCY;

            case true of
                "Shipment No." <> '', "Return Receipt No." <> '':
                    exit(AdjCostLCY);
                QtyType = QtyType::General:
                    exit(Round("Outstanding Quantity" * "Unit Cost (LCY)") + AdjCostLCY);
                "Document Type" in ["Document Type"::Order, "Document Type"::Invoice]:
                    begin
                        if "Qty. to Invoice" > "Qty. to Ship" then
                            exit(Round("Qty. to Ship" * "Unit Cost (LCY)") + AdjCostLCY);
                        exit(Round("Qty. to Invoice" * "Unit Cost (LCY)"));
                    end;
                "Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]:
                    begin
                        if "Qty. to Invoice" > "Return Qty. to Receive" then
                            exit(Round("Return Qty. to Receive" * "Unit Cost (LCY)") + AdjCostLCY);
                        exit(Round("Qty. to Invoice" * "Unit Cost (LCY)"));
                    end;
            end;
        end;
    end;

    local procedure "MAX"(number1: Integer; number2: Integer): Integer
    begin
        if number1 > number2 then
            exit(number1);
        exit(number2);
    end;

    local procedure InvoiceRounding(UseTempData: Boolean; BiggestLineNo: Integer)
    var
        CustPostingGr: Record "Customer Posting Group";
        InvoiceRoundingAmount: Decimal;
    begin
        Currency.TestField("Invoice Rounding Precision");
        InvoiceRoundingAmount :=
          -Round(
            TotalSalesLine."Amount Including VAT" -
            Round(
              TotalSalesLine."Amount Including VAT",
              Currency."Invoice Rounding Precision",
              Currency.InvoiceRoundingDirection),
            Currency."Amount Rounding Precision");
        if InvoiceRoundingAmount <> 0 then begin
            CustPostingGr.Get(SalesHeader."Customer Posting Group");
            CustPostingGr.TestField("Invoice Rounding Account");
            with SalesLine do begin
                Init;
                BiggestLineNo := BiggestLineNo + 10000;
                "System-Created Entry" := true;
                if UseTempData then begin
                    "Line No." := 0;
                    Type := Type::"G/L Account";
                end else begin
                    "Line No." := BiggestLineNo;
                    Validate(Type, Type::"G/L Account");
                end;
                Validate("No.", CustPostingGr."Invoice Rounding Account");
                "Tax Area Code" := '';
                "Tax Liable" := false;
                Validate(Quantity, 1);
                if "Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"] then
                    Validate("Return Qty. to Receive", Quantity)
                else
                    Validate("Qty. to Ship", Quantity);
                if SalesHeader."Prices Including VAT" then
                    Validate("Unit Price", InvoiceRoundingAmount)
                else
                    Validate(
                      "Unit Price",
                      Round(
                        InvoiceRoundingAmount /
                        (1 + (1 - SalesHeader."VAT Base Discount %" / 100) * "VAT %" / 100),
                        Currency."Amount Rounding Precision"));
                Validate("Amount Including VAT", InvoiceRoundingAmount);
                "Line No." := BiggestLineNo;
                if not UseTempData then
                    ;
                LastLineRetrieved := false;
                RoundingLineInserted := true;
                RoundingLineNo := "Line No.";
            end;
        end;
    end;

    local procedure AdjustInvLineWith100PctPrepmt(var SalesInvoiceLine: Record "Sales Line"; var TempTotalSalesLine: Record "Sales Line" temporary)
    var
        SalesOrderLine: Record "Sales Line";
        DiffAmtToDeduct: Decimal;
    begin
        if SalesInvoiceLine."Prepayment %" = 100 then begin
            SalesOrderLine := TempTotalSalesLine;
            SalesOrderLine.Find;
            if TempTotalSalesLine."Qty. to Invoice" = SalesOrderLine.Quantity - SalesOrderLine."Quantity Invoiced" then begin
                DiffAmtToDeduct :=
                  SalesOrderLine."Prepmt. Amt. Inv." - SalesOrderLine."Prepmt Amt Deducted" - TempTotalSalesLine."Prepmt Amt to Deduct";
                if DiffAmtToDeduct <> 0 then begin
                    SalesInvoiceLine."Prepmt Amt to Deduct" := SalesInvoiceLine."Prepmt Amt to Deduct" + DiffAmtToDeduct;
                    SalesInvoiceLine."Line Amount" := SalesInvoiceLine."Prepmt Amt to Deduct";
                    SalesInvoiceLine."Line Discount Amount" := SalesInvoiceLine."Line Discount Amount" - DiffAmtToDeduct;
                    SalesInvoiceLine.Modify;
                    TempTotalSalesLine."Prepmt Amt to Deduct" := TempTotalSalesLine."Prepmt Amt to Deduct" + DiffAmtToDeduct;
                end;
            end;
        end;
    end;

    local procedure GetQtyToInvoice(SalesLine: Record "Sales Line"): Decimal
    var
        AllowedQtyToInvoice: Decimal;
    begin
        with SalesLine do begin
            AllowedQtyToInvoice := "Qty. Shipped Not Invoiced";
            if SalesHeader.Ship then
                AllowedQtyToInvoice := AllowedQtyToInvoice + "Qty. to Ship";
            if "Qty. to Invoice" > AllowedQtyToInvoice then
                exit(AllowedQtyToInvoice);
            exit("Qty. to Invoice");
        end;
    end;

    local procedure GetLineDataFromOrder(var SalesLine: Record "Sales Line")
    var
        SalesShptLine: Record "Sales Shipment Line";
        SalesOrderLine: Record "Sales Line";
    begin
        with SalesLine do begin
            SalesShptLine.Get("Shipment No.", "Shipment Line No.");
            SalesOrderLine.Get("Document Type"::Order, SalesShptLine."Order No.", SalesShptLine."Order Line No.");

            Quantity := SalesOrderLine.Quantity;
            "Qty. Shipped Not Invoiced" := SalesOrderLine."Qty. Shipped Not Invoiced";
            "Quantity Invoiced" := SalesOrderLine."Quantity Invoiced";
            "Prepmt Amt Deducted" := SalesOrderLine."Prepmt Amt Deducted";
            "Prepmt. Amt. Inv." := SalesOrderLine."Prepmt. Amt. Inv.";
            "Line Discount Amount" := SalesOrderLine."Line Discount Amount";
        end;
    end;

    local procedure UpdatePrepmtAmountInvBuf(PrepmtSalesLineNo: Integer; CurrencyFactor: Decimal)
    var
        PrepmtAmtRemainder: Decimal;
    begin
        with TempPrepmtDeductLCYSalesLine do begin
            Reset;
            SetRange("Attached to Line No.", PrepmtSalesLineNo);
            if FindSet(true) then
                repeat
                    if not SalesHeader."Prepmt. Include Tax" then
                        "Prepmt. Amount Inv. (LCY)" :=
                          CalcRoundedAmount(CurrencyFactor * "VAT Base Amount", PrepmtAmtRemainder);
                    Modify;
                until Next = 0;
        end;
    end;

    local procedure GetPrepmtDiffToLineAmount(SalesLine: Record "Sales Line"): Decimal
    begin
        with TempPrepmtDeductLCYSalesLine do
            if SalesLine."Prepayment %" = 100 then
                if Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.") then
                    exit("Prepmt Amt to Deduct" - "Line Amount");
        exit(0);
    end;

    local procedure IncrAmount(var TotalSalesLine: Record "Sales Line")
    begin
        with SalesLine do begin
            if SalesHeader."Prices Including VAT" or
               ("VAT Calculation Type" <> "VAT Calculation Type"::"Full VAT")
            then
                Increment(TotalSalesLine."Line Amount", "Line Amount");
            Increment(TotalSalesLine.Amount, Amount);
            Increment(TotalSalesLine."VAT Base Amount", "VAT Base Amount");
            Increment(TotalSalesLine."VAT Difference", "VAT Difference");
            Increment(TotalSalesLine."Amount Including VAT", "Amount Including VAT");
            Increment(TotalSalesLine."Line Discount Amount", "Line Discount Amount");
            Increment(TotalSalesLine."Inv. Discount Amount", "Inv. Discount Amount");
            Increment(TotalSalesLine."Inv. Disc. Amount to Invoice", "Inv. Disc. Amount to Invoice");
            Increment(TotalSalesLine."Prepmt. Line Amount", "Prepmt. Line Amount");
            Increment(TotalSalesLine."Prepmt. Amt. Inv.", "Prepmt. Amt. Inv.");
            Increment(TotalSalesLine."Prepmt Amt to Deduct", "Prepmt Amt to Deduct");
            Increment(TotalSalesLine."Prepmt Amt Deducted", "Prepmt Amt Deducted");
            Increment(TotalSalesLine."Prepayment VAT Difference", "Prepayment VAT Difference");
            Increment(TotalSalesLine."Prepmt VAT Diff. to Deduct", "Prepmt VAT Diff. to Deduct");
            Increment(TotalSalesLine."Prepmt VAT Diff. Deducted", "Prepmt VAT Diff. Deducted");
        end;
    end;

    local procedure Increment(var Number: Decimal; Number2: Decimal)
    begin
        Number := Number + Number2;
    end;

    local procedure CalcRoundedAmount(Amount: Decimal; var Remainder: Decimal): Decimal
    var
        AmountRnded: Decimal;
    begin
        Amount := Amount + Remainder;
        AmountRnded := Round(Amount, GLSetup."Amount Rounding Precision");
        Remainder := Amount - AmountRnded;
        exit(AmountRnded);
    end;

    [Scope('Internal')]
    procedure SumSalesLinesTemp(var NewSalesHeader: Record "Sales Header"; var OldSalesLine: Record "Sales Line"; QtyType: Option General,Invoicing,Shipping; var NewTotalSalesLine: Record "Sales Line"; var NewTotalSalesLineLCY: Record "Sales Line"; var VATAmount: Decimal; var VATAmountText: Text[30]; var ProfitLCY: Decimal; var ProfitPct: Decimal; var TotalAdjCostLCY: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        with SalesHeader do begin
            SalesHeader := NewSalesHeader;
            SumSalesLines2(SalesLine, OldSalesLine, QtyType, false, true, TotalAdjCostLCY);
            ProfitLCY := TotalSalesLineLCY.Amount - TotalSalesLineLCY."Unit Cost (LCY)";
            if TotalSalesLineLCY.Amount = 0 then
                ProfitPct := 0
            else
                ProfitPct := Round(ProfitLCY / TotalSalesLineLCY.Amount * 100, 0.1);
            VATAmount := TotalSalesLine."Amount Including VAT" - TotalSalesLine.Amount;
            if TotalSalesLine."VAT %" = 0 then
                VATAmountText := Text016
            else
                VATAmountText := StrSubstNo(Text017, TotalSalesLine."VAT %");
            NewTotalSalesLine := TotalSalesLine;
            NewTotalSalesLineLCY := TotalSalesLineLCY;
        end;
    end;
}


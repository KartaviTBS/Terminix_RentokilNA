codeunit 50017 "ARC Promotion Management"
{
    Permissions = tabledata "ARC Event Log Entry" = i;

    procedure ApplyPromotion(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer)   
    var
        eCommerceEntry: Record "ARC eCommerce Entry";
        lSalesLine:Record "Sales Line";
        promoapplied: Boolean;
        _successInsert: Boolean;
        qtymultiplier: Decimal;
        _attemptsInsert: Integer;
        lineNo: Integer;
        _Text000Msg: Label 'Source sales line: %1 %2 %3 type %4 no. %5 qty. %6.  Promo entry %7.';
        _Text001Err: Label 'Method ApplyPromotion(): failed to insert promo Sales Line %1 Type %2 No. %3 qty. %4.';
    begin
        if SalesLine.Quantity = 0 then
            exit;
        if SalesLine."Attached to Line No." <> 0 then
            exit;
        RNASetup.Get;
        If RNASetup."Disable Custom Price Logic" then
            exit;
        if SalesLine."ARC eCommerce Entry No." <> 0 then
            if eCommerceEntry.Get(SalesLine."ARC eCommerce Entry No.") then
                if eCommerceEntry."eCom Bypass Price/Promo" then
                    exit;

        SetUoM(ABS(SalesLine.Quantity), SalesLine."Qty. per Unit of Measure");
        SalesLine.TestField("Qty. per Unit of Measure");
        case SalesLine.Type of
            SalesLine.Type::Item:
                begin
                    Item.Get(SalesLine."No.");
                    If not SalesLinePromoExists(SalesHeader, SalesLine) then
                        exit;
                    
                    TempPromoEntry.Reset;
                    TempPromoEntry.SetRange("Promotion 1 Item No.",'');
                    TempPromoEntry.SetRange("Unit of Measure Code",SalesLine."Unit of Measure Code");
                    If TempPromoEntry.IsEmpty then
                        TempPromoEntry.SetRange("Unit of Measure Code");
                    If TempPromoEntry.FindSet then 
                        repeat
                            if IsInMinQty(TempPromoEntry."Unit of Measure Code", TempPromoEntry."Minimum Quantity") then begin
                                qtymultiplier := (SalesLine.Quantity/TempPromoEntry."Minimum Quantity") Div 1;
                                ConvertPriceToUoM(TempPromoEntry."Unit of Measure Code", TempPromoEntry."Discount %");
                                ConvertPriceToUoM(TempPromoEntry."Unit of Measure Code", TempPromoEntry."Discount Amount");
                                
                                If (TempPromoEntry."Discount %" <> 0) then
                                        SalesLine.Validate("Line Discount %",TempPromoEntry."Discount %");
                                if (TempPromoEntry."Discount Amount" <> 0) then begin;
                                    SalesLine.Validate("Line Discount Amount",qtyMultiplier  * TempPromoEntry."Discount Amount");   
                                    if Round(SalesLine.Quantity * SalesLine."Unit Price", Currency."Amount Rounding Precision") <> 0 then
                                        SalesLine."Line Discount %" := Round(
                                            SalesLine."Line Discount Amount" / Round(SalesLine.Quantity * SalesLine."Unit Price", Currency."Amount Rounding Precision") * 100,
                                            0.00001);
                                end;
                                SalesLine."ARC Promotion Entry No." := TempPromoEntry."Entry No.";
                                SalesLine."ARC Promotion Code" := TempPromoEntry."Promotion Code";     
                                promoapplied := true;
                            end;               
                        until (TempPromoEntry.Next = 0) or (promoapplied);
                    
                    promoapplied := false;
                    TempPromoEntry.Reset;
                    TempPromoEntry.SetFilter("Promotion 1 Item No.",'<>%1','');
                    TempPromoEntry.SetRange("Unit of Measure Code",SalesLine."Unit of Measure Code");
                    If TempPromoEntry.IsEmpty then
                        TempPromoEntry.SetRange("Unit of Measure Code");
                    if TempPromoEntry.Findset then
                        repeat
                            if IsInMinQty(TempPromoEntry."Unit of Measure Code", TempPromoEntry."Minimum Quantity") then begin
                                if TempPromoEntry."Promotion 1 Qty. Multiplier" then
                                    qtymultiplier := (SalesLine.Quantity/TempPromoEntry."Minimum Quantity") Div 1
                                else
                                    qtymultiplier := 1;   
                                lSalesLine.Reset;
                                lSalesLine.SetRange("Document Type",SalesLine."Document Type");
                                lSalesLine.SetRange("Document No.",SalesLine."Document No.");
                                lSalesLine.SetRange("Attached to Line No.",SalesLine."Line No.");
                                lSalesLine.SetFilter("ARC Promotion Entry No.",'<>%1',0);
                                lSalesLine.SetRange("Quantity Shipped",0);
                                if lSalesLine.FindFirst then begin
                                    lSalesLine."Attached to Line No." := SalesLine."Line No.";
                                    lSalesLine.Validate(Quantity,qtymultiplier * TempPromoEntry."Promotion 1 Quantity");
                                    if TempPromoEntry."Promotion 1 UOM Code" <> '' then
                                        lSalesLine.Validate("Unit of Measure Code",TempPromoEntry."Promotion 1 UOM Code");
                                    if TempPromoEntry."Promotion 2 Tax Group Code" <> '' then
                                        lSalesLine.Validate("Tax Group Code",TempPromoEntry."Promotion 1 Tax Group Code");
                                    If (TempPromoEntry."Promotion 1 Discount %" <> 0) then
                                        lSalesLine.Validate("Line Discount %",TempPromoEntry."Promotion 1 Discount %");
                                    if (TempPromoEntry."Promotion 1 Discount Amount" <> 0) then begin
                                        lSalesLine.Validate("Line Discount Amount",qtyMultiplier  * TempPromoEntry."Promotion 1 Discount Amount");
                                        if Round(SalesLine.Quantity * SalesLine."Unit Price", Currency."Amount Rounding Precision") <> 0 then
                                            lSalesLine."Line Discount %" := Round(
                                                SalesLine."Line Discount Amount" / Round(SalesLine.Quantity * SalesLine."Unit Price", Currency."Amount Rounding Precision") * 100,
                                                0.00001);
                                    end;
                                    lSalesLine."ARC Promotion Entry No." := TempPromoEntry."Entry No.";
                                    lSalesLine."ARC Promotion Code" := TempPromoEntry."Promotion Code";   
                                    lSalesLine.Modify;
                                    SalesLine."ARC Promotion Entry No." := TempPromoEntry."Entry No.";
                                    SalesLine."ARC Promotion Code" := TempPromoEntry."Promotion Code";
                                    exit;
                                end;
                                lineNo := SalesLine."Line No." + 1;
                                lSalesLine.Init;
                                lSalesLine."Document Type" := SalesLine."Document Type";
                                lSalesLine."Document No." := SalesLine."Document No.";
                                repeat
                                    lSalesLine."Line No." := lineNo;
                                    _successInsert := lSalesLine.Insert(true);
                                    lineNo += 1;
                                    _attemptsInsert += 1;
                                until (_successInsert) or (_attemptsInsert >= 999);
                                if not _successInsert then begin
                                    WriteToLog(StrSubstNo(_Text000Msg,SalesLine."Document Type",SalesLine."Document No.",SalesLine."Line No.",
                                        SalesLine.Type,SalesLine."No.",SalesLine.Quantity,TempPromoEntry."Entry No."),StrSubstNo(_Text001Err,
                                        lSalesLine."Line No.",lSalesLine.Type,lSalesLine."No.",lSalesLine.Quantity));
                                    exit;
                                end;
                                lSalesLine.Validate(Type,lSalesLine.Type::Item);
                                lSalesLine.Validate("No.",TempPromoEntry."Promotion 1 Item No.");
                                lSalesLine."ARC Promotion Entry No." := TempPromoEntry."Entry No.";
                                lSalesLine."Attached to Line No." := SalesLine."Line No.";
                                lSalesLine.Validate(Quantity,qtymultiplier * TempPromoEntry."Promotion 1 Quantity");
                                if TempPromoEntry."Promotion 1 UOM Code" <> '' then
                                    lSalesLine.Validate("Unit of Measure Code",TempPromoEntry."Promotion 1 UOM Code");
                                if TempPromoEntry."Promotion 2 Tax Group Code" <> '' then
                                    lSalesLine.Validate("Tax Group Code",TempPromoEntry."Promotion 1 Tax Group Code");
                                If (TempPromoEntry."Promotion 1 Discount %" <> 0) then
                                    lSalesLine.Validate("Line Discount %",TempPromoEntry."Promotion 1 Discount %");
                                if (TempPromoEntry."Promotion 1 Discount Amount" <> 0) then begin;
                                    lSalesLine.Validate("Line Discount Amount",qtyMultiplier  * TempPromoEntry."Promotion 1 Discount Amount");   
                                    if Round(SalesLine.Quantity * SalesLine."Unit Price", Currency."Amount Rounding Precision") <> 0 then
                                        lSalesLine."Line Discount %" := Round(
                                            SalesLine."Line Discount Amount" / Round(SalesLine.Quantity * SalesLine."Unit Price", Currency."Amount Rounding Precision") * 100,
                                            0.00001);
                                end;
                                lSalesLine."ARC Promotion Code" := TempPromoEntry."Promotion Code";
                                lSalesLine.Modify();
                                SalesLine."ARC Promotion Entry No." := TempPromoEntry."Entry No.";
                                SalesLine."ARC Promotion Code" := TempPromoEntry."Promotion Code";   
                                promoapplied := true;
                            end;
                        until (TempPromoEntry.Next = 0) or (promoapplied);
                end;
        end;
    end;

    procedure SalesLinePromoExists(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    begin
        if(SalesLine.Type = SalesLine.Type::Item) and Item.Get(SalesLine."No.") then begin
            FindSalesPromotion(
                TempPromoEntry, GetCustNoForSalesHeader(SalesHeader), SalesLine."Customer Price Group", SalesLine."No.", 
                SalesLine."Variant Code", SalesLine."Unit of Measure Code", SalesLine."Customer Price Group", 
                SalesHeader."Currency Code", SalesHeaderStartDate(SalesHeader, DateCaption), SalesLine."Location Code",
                SalesHeader."Sell-to County");
            exit(TempPromoEntry.FindFirst);
        end;
        exit(false);
    end;

    procedure FindSalesPromotion(var ToPromoEntry: Record "ARC Promotion Entry"; CustNo: Code[20];
    CustPriceGrCode: Code[10]; ItemNo: Code[20];
    VariantCode: Code[10]; UOM: Code[10]; CustPostGrCode: Code[10]; CurrencyCode: Code[20]; StartingDate: Date; LocationCode: Code[20]; CountyCode: Code[20])
    var
        FromPromoEntry: Record "ARC Promotion Entry";     
    begin
        if not ToPromoEntry.IsTemporary then
            Error(TempTableErr);

        ToPromoEntry.Reset;
        ToPromoEntry.DeleteAll;
        FromPromoEntry.SetRange(Type,FromPromoEntry.Type::Item);
        FromPromoEntry.SetRange("No.", ItemNo);
        FromPromoEntry.SetFilter("Location Code",'%1|%2',LocationCode,'');
        FromPromoEntry.SetFilter("Variant Code", '%1|%2', VariantCode, '');
        FromPromoEntry.SetFilter("Expiration Date", '%1|>=%2', 0D, StartingDate);
        FromPromoEntry.SetFilter(County,'%1|%2', CountyCode, '');
        FromPromoEntry.SetFilter("Minimum Quantity",'>%1',0);
        if not ShowAll then begin
            FromPromoEntry.SetFilter("Currency Code", '%1|%2', CurrencyCode, '');
            if UOM <> '' then
                FromPromoEntry.SetFilter("Unit of Measure Code", '%1|%2', UOM, '');
            FromPromoEntry.SetRange("Effective Date", 0D, StartingDate);
        end;

        FromPromoEntry.SetRange("Entity No.", '');
        CopyPromoEntryToPromoEntry(FromPromoEntry, ToPromoEntry);

        if CustNo <> '' then begin
            FromPromoEntry.SetRange("Entity Type", FromPromoEntry."Entity Type"::Customer);
            FromPromoEntry.SetRange("Entity No.", CustNo);
            CopyPromoEntryToPromoEntry(FromPromoEntry, ToPromoEntry);
        end;

        if CustPriceGrCode <> '' then begin
            FromPromoEntry.SetRange("Entity Type", FromPromoEntry."Entity Type"::"Customer Price Group");
            FromPromoEntry.SetRange("Entity No.", CustPriceGrCode);
            CopyPromoEntryToPromoEntry(FromPromoEntry, ToPromoEntry);
        end;

        if CustPostGrCode <> '' then begin
            FromPromoEntry.SetRange("Entity Type", FromPromoEntry."Entity Type"::"Customer Posting Group");
            FromPromoEntry.SetRange("Entity No.", CustPostGrCode);
            CopyPromoEntryToPromoEntry(FromPromoEntry, ToPromoEntry);
        end;
    end;

    
    local procedure CopyPromoEntryToPromoEntry(var FromPromoEntry: Record "ARC Promotion Entry"; var ToPromoEntry: Record "ARC Promotion Entry")
    begin
        if FromPromoEntry.FindSet then begin               
            repeat
                ToPromoEntry := FromPromoEntry;
                ToPromoEntry.Insert;
            until FromPromoEntry.Next = 0;
        end;    
    end;

    procedure NoOfSalesLinePromotions(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Integer
    begin
        if SalesLinePromoExists(SalesHeader, SalesLine) then
            exit(TempPromoEntry.Count);
    end;

    procedure ShowSalesLinePromos(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Integer
    begin
        if SalesLinePromoExists(SalesHeader, SalesLine) then begin
            if not TempPromoEntry.IsEmpty then
                Page.RunModal(Page::"ARC Promotion Entry List", TempPromoEntry);
        end;
    end;

    local procedure SetUoM(Qty2: Decimal; QtyPerUoM2: Decimal)
    begin
        Qty := Qty2;
        QtyPerUOM := QtyPerUoM2;
    end;

    local procedure IsInMinQty(UnitofMeasureCode: Code[10]; MinQty: Decimal): Boolean
    begin
        if UnitofMeasureCode = '' then
            exit(MinQty <= QtyPerUOM * Qty);
        exit(MinQty <= Qty);
    end;

    local procedure GetCustNoForSalesHeader(SalesHeader: Record "Sales Header"): Code[20]
    var
        CustNo: Code[20];
    begin
        CustNo := SalesHeader."Bill-to Customer No.";
        exit(CustNo);
    end;

    local procedure SalesHeaderStartDate(var SalesHeader: Record "Sales Header"; var DateCaption: Text[30]): Date
    begin
        with SalesHeader do
            if "Document Type" in ["Document Type"::Invoice, "Document Type"::"Credit Memo"] then begin
            DateCaption := FieldCaption("Posting Date");
            exit("Posting Date")
        end else begin
            DateCaption := FieldCaption("Order Date");
            exit("Order Date");
        end;
    end;

    local procedure ConvertPriceToUoM(UnitOfMeasureCode: Code[10]; var UnitPrice: Decimal)
    begin
        if UnitOfMeasureCode = '' then
            UnitPrice := UnitPrice * QtyPerUOM;
    end;

    local procedure ConvertPriceLCYToFCY(CurrencyCode: Code[10]; var UnitPrice: Decimal)
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if PricesInCurrency then begin
            if CurrencyCode = '' then
                UnitPrice :=
                  CurrExchRate.ExchangeAmtLCYToFCY(ExchRateDate, Currency.Code, UnitPrice, CurrencyFactor);
            UnitPrice := Round(UnitPrice, Currency."Unit-Amount Rounding Precision");
        end else
            UnitPrice := Round(UnitPrice, GLSetup."Unit-Amount Rounding Precision");
    end;

    local procedure ConvertPriceToVAT(FromPricesInclVAT: Boolean; FromVATProdPostingGr: Code[20]; FromVATBusPostingGr: Code[20]; var UnitPrice: Decimal)
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if FromPricesInclVAT then begin
            VATPostingSetup.Get(FromVATBusPostingGr, FromVATProdPostingGr);

            case VATPostingSetup."VAT Calculation Type" of
                VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT" :
                    VATPostingSetup."VAT %" := 0;
            VATPostingSetup."VAT Calculation Type"::"Sales Tax" :
                    Error(
                      Text010,
                      VATPostingSetup.FieldCaption("VAT Calculation Type"),
                      VATPostingSetup."VAT Calculation Type");
            end;

            case VATCalcType of
                VATCalcType::"Normal VAT",
                VATCalcType::"Full VAT",
                VATCalcType::"Sales Tax" :
            begin
                if PricesInclVAT then begin
                    if VATBusPostingGr <> FromVATBusPostingGr then
                        UnitPrice := UnitPrice * (100 + VATPerCent) / (100 + VATPostingSetup."VAT %");
                end else
                    UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
            end;
            VATCalcType::"Reverse Charge VAT" :
                    UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
            end;
        end else if PricesInclVAT then
                UnitPrice := UnitPrice * (1 + VATPerCent / 100);
    end;

    local procedure WriteToLog(_msgText: Text; _errText: Text)
    var
        _EventLogEntry: Record "ARC Event Log Entry";
        _status: Integer;
    begin
        if _errText <> '' then
            _status := _EventLogEntry.Status::Error
        else
            _status := _EventLogEntry.Status::Message;
        _EventLogEntry.NewEventLogEntry('PROMO',_EventLogEntry."Object Type"::Codeunit,Codeunit::"ARC Promotion Management",
            0,_status,_msgText,_errText,false,'')
    end;

    var
        Item: Record Item;
        TempPromoEntry: Record "ARC Promotion Entry" temporary;
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        RNASetup: Record "ARC RNA Setup";
        QtyPerUOM: Decimal;
        Qty: Decimal;
        FoundSalesPrice: Boolean;
        DateCaption: Text[30];
        ShowAll: Boolean;
        PricesInCurrency: Boolean;
        CurrencyFactor: Decimal;
        VATPerCent: Decimal;
        ExchRateDate: Date;
        PricesInclVAT: Boolean;
        VATBusPostingGr: Code[20];
        VATCalcType: Option "Normal VAT", "Reverse Charge VAT", "Full VAT", "Sales Tax";
        Text001: Label 'The %1 in the %2 must be same as in the %3.';
        Text010: Label 'Prices including VAT cannot be calculated when %1 is %2.';
        TempTableErr: Label 'The table passed as a parameter must be temporary.';
}
codeunit 50012 "ARC Price Management"
{
    Permissions = tabledata "ARC Price Review Entry" = rimd;

    var
        TempPriceEntry: Record "ARC Price Entry" temporary;
        Item: Record Item;
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        RNASetup: Record "ARC RNA Setup";
        GlobalSalesLine: Record "Sales Line";
        SalesLine: Record "Sales Line";
        GlobalItemNo: Code[20];
     
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
        TempTableErr: Label 'The table passed as a parameter must be temporary.';
        Text001: Label 'The %1 in the %2 must be same as in the %3.';
        Text010: Label 'Prices including VAT cannot be calculated when %1 is %2.';
        AgencyItemPriceError: Label 'Price is missing for Agency Item %1';
        ApprRejectError: Label 'You don''t have permission to perform this action';
        MailSubject: Label '%1 your price entry for sales order %2, line %3';
        MailBody: Label 'Price entry for sales order %1, item %2, price %3 is %4';
        SmtpError: Label 'The SMTP mail system returned the following error: %1.';
        ReviewEntryError: Label 'You cannot release the order, there are price review entries for review';
        NotAllowedTxt: Label 'You are not allowed to approve it.\Please contact administrator';
        NotPermissionsTxt: Label 'You don''t have permission to mark the entry';
        ApprovedTxt: Label 'Price is approved';
        RejectedTxt: Label 'Price is rejected';


    procedure FindPriceEntry(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer; ShowAll: Boolean);
    var
        eCommerceEntry: Record "ARC eCommerce Entry";
        bypassPricePromo: Boolean;
        UOMCost: Decimal;
    begin
        RNASetup.Get;
        If RNASetup."Disable Custom Price Logic" then
            exit;
        if SalesLine."ARC eCommerce Entry No." <> 0 then
            if eCommerceEntry.Get(SalesLine."ARC eCommerce Entry No.") then
                bypassPricePromo := eCommerceEntry."eCom Bypass Price/Promo";
        with SalesLine do begin
            SetUoM(ABS(Quantity), "Qty. per Unit of Measure");
            TestField("Qty. per Unit of Measure");
            case Type of
                Type::Item:
                    begin
                        Item.Get("No.");
                        if IsInternalCustomer(SalesHeader."Sell-to Customer No.") then begin 
                            If Item."ARC Agency Item" OR item."ARC MCP" then begin 
                                if not bypassPricePromo then begin
                                    Item.TestField("ARC Minimum Price");
                                    "Unit Price" := Item."ARC Minimum Price" * "Qty. per Unit of Measure";
                                end;
                                UOMCost := Item."ARC Sales Cost" * "Qty. per Unit of Measure";
                                "ARC Sales Cost" := Item."ARC Sales Cost" * "Qty. per Unit of Measure";
                                "ARC Markup Value" := 0;
                                if "Unit Price" <> 0 then
                                    "ARC Margin %" := Round((("Unit Price"- UOMCost)/ "Unit Price") * 100,0.01,'=');
                                exit;     
                            end;
                        end;
                        if not bypassPricePromo then
                            If not SalesLinePriceExists(SalesHeader, SalesLine, ShowAll) then
                                if Item."ARC Agency Item" then
                                    Error(AgencyItemPriceError, Item."No.");

                        CalcBestPrice(TempPriceEntry,SalesHeader."Sell-to Customer No.");
                        if FoundSalesPrice or
                            not((CalledByFieldNo = FieldNo(Quantity)) or
                                (CalledByFieldNo = FieldNo("Variant Code"))) then begin
                            if not bypassPricePromo then begin
                                "Unit Price" := TempPriceEntry."Net Unit Price";
                                "ARC Price Entry No." := TempPriceEntry."Entry No."; 
                            end;
                            UOMCost := Item."ARC Sales Cost" * "Qty. per Unit of Measure";
                            "ARC Sales Cost" := Item."ARC Sales Cost" * "Qty. per Unit of Measure";
                            "ARC Markup Value" := TempPriceEntry."Markup Value";
                            if "Unit Price" <> 0 then
                                "ARC Margin %" := Round((("Unit Price"- UOMCost)/ "Unit Price") * 100,0.01,'=');                         
                        end;
                        if not bypassPricePromo then
                            if not "Allow Line Disc." then
                                "Line Discount %" := 0;
                    end;
            end;
        end;
        OnAfterCalcSalesPrice(SalesLine,SalesHeader,CalledByFieldNo);      
    end;

    procedure SalesLinePriceExists(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ShowAll: Boolean): Boolean
    begin
        with SalesLine do begin 
            GlobalSalesLine := SalesLine;
            if(Type = Type::Item) and Item.Get("No.") then begin
                //if (not item."ARC Agency Item") and (IsInternalCustomer(SalesHeader."Sell-to Customer No.")) then
                //    exit(false);
                FindSalesPrice(
                    TempPriceEntry, GetCustNoForSalesHeader(SalesHeader), "Customer Price Group", "No.", "Variant Code", "Unit of Measure Code",
                    "Customer Price Group", SalesHeader."Currency Code", SalesHeaderStartDate(SalesHeader, DateCaption));
                exit(TempPriceEntry.FindFirst);
            end;
            exit(false);
        end;
    end;



    procedure FindSalesPrice(
        var ToPriceEntry: Record "ARC Price Entry"; 
        CustNo: Code[20];
        CustPriceGrCode: Code[10]; 
        ItemNo: Code[20];
        VariantCode: Code[10]; 
        UOM: Code[10]; 
        CustPostGrCode: Code[10]; 
        CurrencyCode: Code[20]; 
        StartingDate: Date)
    var
        FromPriceEntry: Record "ARC Price Entry";
        _Item: Record Item;
        TempTargetCampaignGr: Record "Campaign Target Group" temporary;
        _entryNo: Integer;
    begin
        if not ToPriceEntry.IsTemporary then
            Error(TempTableErr);

        ToPriceEntry.Reset;
        ToPriceEntry.DeleteAll;

        with FromPriceEntry do begin
            SetFilter(Status,'%1|%2',Status::" ",Status::Approved);
            SetFilter(Type,'%1|%2',Type::"All Items",Type::Item);
            SetFilter("No.",'%1|%2', ItemNo,'');
            SetFilter("Variant Code", '%1|%2', VariantCode, '');
            SetFilter("Expiration Date", '%1|>=%2', 0D, StartingDate);
            if not ShowAll then begin
                SetFilter("Currency Code", '%1|%2', CurrencyCode, '');
                if UOM <> '' then
                    SetFilter("Unit of Measure Code", '%1|%2', UOM, '');
                SetRange("Effective Date", 0D, StartingDate);
            end;

            //SetRange("Entity No.", '');
            //CopyPriceEntryToPriceEntry(FromPriceEntry, ToPriceEntry);

            if CustNo <> '' then begin
                SetRange("Entity Type", "Entity Type"::Customer);
                SetRange("Entity No.", CustNo);
                CopyPriceEntryToPriceEntry(FromPriceEntry, ToPriceEntry);
            end;

            if CustPriceGrCode <> '' then begin
                SetRange("Entity Type", "Entity Type"::"Customer Price Group");
                SetRange("Entity No.", CustPriceGrCode);
                CopyPriceEntryToPriceEntry(FromPriceEntry, ToPriceEntry);
            end;

            if CustPostGrCode <> '' then begin
                SetRange("Entity Type", "Entity Type"::"Customer Posting Group");
                SetRange("Entity No.", CustPostGrCode);
                CopyPriceEntryToPriceEntry(FromPriceEntry, ToPriceEntry);
            end;

            SetRange("Entity Type", "Entity Type"::"All Customers");
            SetRange("Entity No.");
            CopyPriceEntryToPriceEntry(FromPriceEntry, ToPriceEntry);
        end;

        if not ToPriceEntry.FindLast() then
            if _Item.Get(SalesLine."No.") then
                if _Item."ARC MCP" then
                    if SalesLine."Unit Price" >= _Item."ARC Minimum Price" then begin
                        ToPriceEntry.Reset();
                        ToPriceEntry.Init();
                        ToPriceEntry."Entry No." := 1;
                        ToPriceEntry."MCP Include" := true;
                        ToPriceEntry."No." := CopyStr(SalesLine."No.",1,MaxStrLen(ToPriceEntry."No."));
                        ToPriceEntry."Net Unit Price" := SalesLine."Unit Price";
                        ToPriceEntry."Method Value" := SalesLine."Unit Price";
                        ToPriceEntry.Method := ToPriceEntry.Method::"Fixed";
                        ToPriceEntry."Unit of Measure Code" := CopyStr(SalesLine."Unit of Measure Code",1,MaxStrLen(ToPriceEntry."Unit of Measure Code"));
                        ToPriceEntry."Currency Code" := CopyStr(SalesLine."Currency Code",1,MaxStrLen(ToPriceEntry."Currency Code"));
                        ToPriceEntry.Insert();
                    end;
    end;

    procedure CalcBestPrice(var PriceEntry: Record "ARC Price Entry"; CustNo: Code[20]);
    var
        BestPriceEntry: Record "ARC Price Entry";
        BestPriceFound: Boolean;
    begin
        with PriceEntry do
        begin
            FoundSalesPrice := FindSet;
            if FoundSalesPrice then
                repeat
                    if IsInMinQty("Unit of Measure Code", "Minimum Quantity") then begin
                        CalcNetUnitPrice(PriceEntry);
                        ConvertPriceToUoM("Unit of Measure Code", "Net Unit Price");
                        ConvertPriceLCYToFCY("Currency Code", "Net Unit Price");

                        case true of
                                ((BestPriceEntry."Currency Code" = '') and("Currency Code" <> '')) or
                                ((BestPriceEntry."Variant Code" = '') and("Variant Code" <> '')) :
                        begin
                            BestPriceEntry := PriceEntry;
                            BestPriceFound := true;
                        end;
                        ((BestPriceEntry."Currency Code" = '') or("Currency Code" <> '')) and
                                ((BestPriceEntry."Variant Code" = '') or("Variant Code" <> '')) :
                                        if(BestPriceEntry."Net Unit Price" = 0) or
                                            (BestPriceEntry."Net Unit Price" > PriceEntry."Net Unit Price") then begin
                            BestPriceEntry := PriceEntry;
                            BestPriceFound := true;
                        end;
                        end;
                    end;
                until Next = 0;
        end;

        // No price found in agreement
        if not BestPriceFound then begin
            If IsInternalCustomer(CustNo) then begin  
                ConvertPriceToVAT(
                Item."Price Includes VAT", Item."VAT Prod. Posting Group",
                Item."VAT Bus. Posting Gr. (Price)", Item."Unit Cost");
                ConvertPriceToUoM('', Item."Unit Cost");
                ConvertPriceLCYToFCY('', Item."Unit Cost");

                Clear(BestPriceEntry);
                BestPriceEntry."Net Unit Price" := Item."Unit Cost";  

            end else begin 

                ConvertPriceToVAT(
                Item."Price Includes VAT", Item."VAT Prod. Posting Group",
                Item."VAT Bus. Posting Gr. (Price)", Item."Unit Price");
                ConvertPriceToUoM('', Item."Unit Price");
                ConvertPriceLCYToFCY('', Item."Unit Price");

                Clear(BestPriceEntry);
                BestPriceEntry."Net Unit Price" := Item."Unit Price";
            end;
        end;

        PriceEntry := BestPriceEntry;
    end;

    procedure SetUoM(Qty2: Decimal; QtyPerUoM2: Decimal)
    begin
        Qty := Qty2;
        QtyPerUOM := QtyPerUoM2;
    end;

    procedure IsInMinQty(UnitofMeasureCode: Code[10]; MinQty: Decimal): Boolean
    begin
        if UnitofMeasureCode = '' then
            exit(MinQty <= QtyPerUOM * Qty);
        exit(MinQty <= Qty);
    end;

    procedure GetCustNoForSalesHeader(SalesHeader: Record "Sales Header"): Code[20]
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

    procedure CopyPriceEntryToPriceEntry(var FromPriceEntry: Record "ARC Price Entry"; var ToPriceEntry: Record "ARC Price Entry")
    begin
        with ToPriceEntry do
        begin
            if FromPriceEntry.FindSet then begin               
                repeat
                  ToPriceEntry := FromPriceEntry;
                  ToPriceEntry.Insert;
                until FromPriceEntry.Next = 0;
            end;    
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

    local procedure CalcNetUnitPrice(var PriceEntry: Record "ARC Price Entry");
    var 
        CustPostingGroup: Record "Customer Posting Group";
        Customer: Record Customer;
        
    begin
        Case PriceEntry.Method of
            PriceEntry.Method::Discount :
            begin
                PriceEntry."Net Unit Price" := Item."Unit Price" - ((PriceEntry."Method Value" / 100) * Item."Unit Price");
            end;
            PriceEntry.Method::Fixed :
            begin
                PriceEntry."Net Unit Price" := PriceEntry."Method Value";
            end;
            PriceEntry.Method::MarkUp :
            begin
                If PriceEntry."Method Value" = 0 then
                    PriceEntry."Net Unit Price" := 0
                else begin 
                    If GlobalItemNo <> '' then
                        Item.Get(GlobalItemNo)
                    else
                        Item.Get(GlobalSalesLine."No.");
                    PriceEntry."Net Unit Price" := ROUND(Item."ARC Sales Cost" / (1 - (PriceEntry."Method Value" / 100)));
                    ///
                    if PriceEntry."Entity Type" = PriceEntry."Entity Type"::"Customer Posting Group" then begin 
                        if CustPostingGroup.Get(PriceEntry."Entity No.") and (CustPostingGroup."ARC Internal Customer") then begin 
                            PriceEntry."Net Unit Price" := Item."Unit Cost" + ((Item."Unit Cost" * 1) * (PriceEntry."Method Value" / 100));
                            PriceEntry."Markup Value" := ((Item."Unit Cost" * 1) * (PriceEntry."Method Value" / 100));
                        end;    
                    end;   
                    if PriceEntry."Entity Type" = PriceEntry."Entity Type"::"Customer" then begin 
                        if IsInternalCustomer(PriceEntry."Entity No.") then begin 
                            PriceEntry."Net Unit Price" := Item."Unit Cost" + ((Item."Unit Cost") * (PriceEntry."Method Value" / 100));
                            PriceEntry."Markup Value" := ((Item."Unit Cost") * (PriceEntry."Method Value" / 100));
                        end;    
                    end; 
                    ///
                end;    
            end;
        end;
        PriceEntry.Modify(true);
    end;

    procedure CreatePriceReviewEntry(var SalesLine: Record "Sales Line");
    var
        ARCSalesMgt: Codeunit ARCSalesMgt;
        PriceReviewEntry: Record "ARC Price Review Entry";
        SalesHeader: Record "Sales Header";
        Salesperson: Record "Salesperson/Purchaser";
        Item: Record Item;
        MinPrice: Decimal;       
        
    begin
        If SalesLine.Type <> SalesLine.Type::Item then 
            exit;
        if ARCSalesMgt.IsCOILocation(SalesLine."Location Code") then
            exit;
        SalesHeader.Get(SalesLine."Document Type",SalesLine."Document No.");
        Item.Get(SalesLine."No.");
        MinPrice := Item."ARC Minimum Price";
        MinPrice := SalesLine."Qty. per Unit of Measure" * MinPrice;
        If SalesLine."Unit Price" >= MinPrice then begin
            DeletePriceReviewEntry(SalesLine);
            exit;   
        end;    
        PriceReviewEntry.Reset;                    
        PriceReviewEntry.SetRange("Document Area",PriceReviewEntry."Document Area"::Sales);
        PriceReviewEntry.SetRange("Document Type",SalesLine."Document Type");
        PriceReviewEntry.SetRange("Document No.", SalesLine."Document No.");
        PriceReviewEntry.SetRange("Document Line No." , SalesLine."Line No.");  
        PriceReviewEntry.SetRange(Status,PriceReviewEntry.Status::Approved);
        PriceReviewEntry.SetFilter("Unit Price",'>=%1',SalesLine."Unit Price");
        If PriceReviewEntry.FindFirst then 
            exit;

        SalesHeader.TestField("Salesperson Code");
        Salesperson.Get(SalesHeader."Salesperson Code");
        Salesperson.TestField("ARC Manager");     
        PriceReviewEntry.Reset;                    
        PriceReviewEntry.SetRange("Document Area",PriceReviewEntry."Document Area"::Sales);
        PriceReviewEntry.SetRange("Document Type",SalesLine."Document Type");
        PriceReviewEntry.SetRange("Document No.", SalesLine."Document No.");
        PriceReviewEntry.SetRange("Document Line No." , SalesLine."Line No.");  
        If PriceReviewEntry.FindFirst then begin
            PriceReviewEntry.Validate("No.", SalesLine."No.");
            PriceReviewEntry."Unit Price" := SalesLine."Unit Price";
            PriceReviewEntry."Unit Cost" := SalesLine."Unit Cost";
            PriceReviewEntry.Status := PriceReviewEntry.Status::Review;
            PriceReviewEntry.Modify(true);
            exit;
        end;
        If SalesLine."Line No." = 0 then
            Commit;               
        PriceReviewEntry.Init;
        PriceReviewEntry."Document Area" := PriceReviewEntry."Document Area"::Sales;
        PriceReviewEntry."Document Type" := SalesLine."Document Type";
        PriceReviewEntry."Document No." := SalesLine."Document No.";
        PriceReviewEntry."Document Line No." := SalesLine."Line No.";
        PriceReviewEntry.Validate("Entity Type", PriceReviewEntry."Entity Type"::Customer);
        PriceReviewEntry.Validate("Entity No.", SalesLine."Sell-to Customer No.");
        PriceReviewEntry.Validate(Type, PriceReviewEntry.Type::Item);
        PriceReviewEntry.Validate("No.", SalesLine."No.");
        PriceReviewEntry."Unit Price" := SalesLine."Unit Price";
        PriceReviewEntry."Unit Cost" := SalesLine."Unit Cost";
        PriceReviewEntry."Line Amount Excl. Tax" := SalesLine."Line Amount";
        PriceReviewEntry."Price Entry No." := SalesLine."ARC Price Entry No.";
        PriceReviewEntry."Promotional Entry No." := SalesLine."ARC Price Entry No.";
        PriceReviewEntry.Status := PriceReviewEntry.Status::Review;
        PriceReviewEntry.Approver := Salesperson."ARC Manager";
        PriceReviewEntry.Insert(true);
    end;


    procedure DeletePriceReviewEntry(var SalesLine: Record "Sales Line");
    var
        PriceReviewEntry: Record "ARC Price Review Entry";
    begin
       
        PriceReviewEntry.Reset;
        PriceReviewEntry.SetRange("Document Area",PriceReviewEntry."Document Area"::Sales);
        PriceReviewEntry.SetRange("Document Type" ,SalesLine."Document Type");
        PriceReviewEntry.SetRange("Document No.", SalesLine."Document No.");
        PriceReviewEntry.SetRange("Document Line No.",SalesLine."Line No.");
        PriceReviewEntry.SetRange(Status,PriceReviewEntry.Status::Review);
        If PriceReviewEntry.FindSet then
            repeat
                PriceReviewEntry.Delete(true);       
            until PriceReviewEntry.Next  = 0
    end;


    procedure ShowDocument(PriceReviewEntry: Record "ARC Price Review Entry");
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        ServHeader: Record "Service Header";
    begin
        with PriceReviewEntry do
        case "Document Area" of
            "Document Area"::Sales :
        begin
            SalesHeader.Get("Document Type", "Document No.");
            PAGE.Run(PAGE::"Sales Order", SalesHeader);
        end;
        "Document Area"::Purchases :
        begin
            PurchHeader.Get("Document Type", "Document No.");
            PAGE.Run(PAGE::"Purchase Order", PurchHeader);
        end;
        "Document Area"::Service :
        begin
            ServHeader.Get("Document Type", "Document No.");
            PAGE.Run(PAGE::"Service Order", ServHeader);
        end;
        end;
    end;

    procedure ApprovePriceReviewEntry(var PriceReviewEntry: Record "ARC Price Review Entry");
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PriceReviewEntry2: Record "ARC Price Review Entry";
        RNASetup: Record "ARC RNA Setup";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        UserSetup: Record "User Setup";
    begin
        If UserId <> PriceReviewEntry.Approver then
            if (Usersetup.Get(UserId)) and (not UserSetup."ARC Sales Price Approval Mgr.") then
                Error(ApprRejectError);
            
        SalesHeader.Get(PriceReviewEntry."Document Type", PriceReviewEntry."Document No.");
        SalesLine.Get(SalesHeader."Document Type", SalesHeader."No.", PriceReviewEntry."Document Line No.");
        PriceReviewEntry.Status := PriceReviewEntry.Status::Approved;
        PriceReviewEntry."Approved By" := UserId;
        PriceReviewEntry."Approved On" := CurrentDateTime;
        PriceReviewEntry.Modify;
        if GuiAllowed then
            Message(ApprovedTxt);
        SendApprRejectEmail(SalesHeader, SalesLine, 'Approved');
        if RNASetup."Release On Price Approval" then begin 
            PriceReviewEntry2.Reset;
            PriceReviewEntry2.SetFilter("Entry No.",'<>%1',PriceReviewEntry."Entry No.");
            PriceReviewEntry2.SetRange("Document No.",SalesHeader."No.");
            PriceReviewEntry2.SetRange(Status,PriceReviewEntry2.Status::Review);
            If PriceReviewEntry2.FindFirst then
              exit;
            ReleaseSalesDoc.PerformManualRelease(SalesHeader);
        end;
        
    end;

    procedure RejectPriceReviewEntry(var PriceReviewEntry: Record "ARC Price Review Entry");
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        OrderDeleted: Boolean;
        Usersetup: Record "User Setup";
    begin
        If UserId <> PriceReviewEntry.Approver then
            if (Usersetup.Get(UserId)) and (not UserSetup."ARC Sales Price Approval Mgr.") then
                Error(ApprRejectError);

        PriceReviewEntry.Status := PriceReviewEntry.Status::Rejected;
        PriceReviewEntry.Modify(true);
        if GuiAllowed then
            Message(RejectedTxt);
        SalesHeader.Get(PriceReviewEntry."Document Type", PriceReviewEntry."Document No.");
        SalesLine.Get(SalesHeader."Document Type", SalesHeader."No.", PriceReviewEntry."Document Line No.");

        SalesLine.Delete(true);
        SalesLine.Reset;
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("Line No.",'<>%1', PriceReviewEntry."Document Line No.");
        If SalesLine.IsEmpty then begin
            SalesHeader.Delete(true);
            OrderDeleted := true;
        end;
        SendApprRejectEmail(SalesHeader, SalesLine, 'Rejected');
    end;

    procedure ApprovePriceEntry(var PriceEntry: Record "ARC Price Entry");
    var
        User: Record User;
        UserGroupMember: Record "User Group Member";
    begin
        if not User.Get(UserSecurityId) then
            exit;
        if not UserGroupMember.Get(PriceEntry."Approver User Group", User."User Security ID", CompanyName) then
            if not UserGroupMember.Get(PriceEntry."Approver User Group", User."User Security ID", '') then
                error(NotAllowedTxt);

        PriceEntry.Status := PriceEntry.Status::Approved;
        PriceEntry."Approved By" := UserId;
        PriceEntry."Approved On" := CurrentDateTime;
        PriceEntry.Modify(true);
        if GuiAllowed then
            Message(ApprovedTxt);
    end;

    procedure RejectPriceEntry(var PriceEntry: Record "ARC Price Entry");
    var
        User: Record User;
        UserGroupMember: Record "User Group Member";
    begin
        if not User.Get(UserSecurityId) then
            exit;
        if not UserGroupMember.Get(PriceEntry."Approver User Group", User."User Security ID", CompanyName) then
            if not UserGroupMember.Get(PriceEntry."Approver User Group", User."User Security ID", '') then
                error(NotAllowedTxt);
        PriceEntry.Delete(true);
        if GuiAllowed then
            Message(RejectedTxt);
        
    end;

    local procedure SendEmail(SendToAddress: Text; Subject: Text; MessageBody: Text)
    var
        SMTPMail: Codeunit "SMTP Mail";
        SendOK: Boolean;
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
    begin
        If SendToAddress = '' then
            exit;
        CompanyInfo.Get;
        SMTPMail.CreateMessage(CompanyInfo.Name, CompanyInfo."E-Mail", SendToAddress, Subject, MessageBody, true);

        SendOK := SMTPMail.TrySend;

        if not SendOK then
            Error(SmtpError, SMTPMail.GetLastSendMailErrorText);
    end;

    local procedure SendApprRejectEmail(var SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; status: Text);
    var
        SalesPerson: Record "Salesperson/Purchaser";
    begin
        RNASetup.Get;
        If not RNASetup."Send Approval/Reject Email" then
            exit;
        if SalesPerson.Get(SalesHeader."Salesperson Code") and (SalesPerson."E-Mail" <> '') then
            SendEmail(SalesPerson."E-Mail", StrSubstno(MailSubject, status, SalesHeader."No.", SalesLine."Line No."),
                      StrSubstNo(MailBody, SalesHeader."No.", SalesLine."No.", SalesLine."Unit Price", status));

    end;

    procedure CheckPendingPriceReviewEntries(SalesHeader: Record "Sales Header");
    var
        PriceReviewEntry: Record "ARC Price Review Entry";
    begin
        PriceReviewEntry.Reset;
        PriceReviewEntry.SetRange("Document No.", SalesHeader."No.");
        PriceReviewEntry.SetRange(Status, PriceReviewEntry.Status::Review);
        If Not PriceReviewEntry.IsEmpty then
            Error(ReviewEntryError)
    end;

    procedure LookUpPriceEntry(SalesLine: Record "Sales Line");
    var
        PriceEntry: Record "ARC Price Entry";
    begin
        If SalesLine."ARC Price Entry No." = 0 then
            exit;
        PriceEntry.SetRange("Entry No.",SalesLine."ARC Price Entry No.");
        PAGE.RunModal(Page::"ARC Price Entry List", PriceEntry);
    end;

    procedure LookUpPromoEntry(SalesLine: Record "Sales Line");
    var
        PromoEntry: Record "ARC Promotion Entry";
    begin
        If SalesLine."ARC Promotion Entry No." = 0 then
            exit;
        PromoEntry.SetRange("Entry No.",SalesLine."ARC Promotion Entry No.");
        PAGE.RunModal(Page::"ARC Promotion Entry List", PromoEntry);
    end;

    procedure NoOfSalesLinePrice(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ShowAll: Boolean): Integer
    begin
        if SalesLinePriceExists(SalesHeader, SalesLine, ShowAll) then
            exit(TempPriceEntry.Count);
    end;

    procedure ShowSalesLinePrices(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ShowAll: Boolean): Integer
    begin
        if SalesLinePriceExists(SalesHeader, SalesLine, ShowAll) then begin
            if not TempPriceEntry.IsEmpty then
                Page.RunModal(Page::"ARC Price Entry List", TempPriceEntry);
        end;
    end;

    procedure IsInternalCustomer(CustNo: Code[20]): Boolean
    var
        Customer: Record Customer;
        CustPostingGroup: Record "Customer Posting Group";
    begin
        if (Customer.Get(CustNo)) and (Customer."ARC Internal Customer") then
            exit(true);
        if (CustPostingGroup.Get(Customer."Customer Posting Group")) and (CustPostingGroup."ARC Internal Customer") then
            exit(true);        
    end;

    procedure GetLastUnitPrice(var SalesLine: Record "Sales Line"): Decimal
    var
        SalesInvLine : Record "Sales Invoice Line";
    begin
        SalesInvLine.Reset;
        SalesInvLine.SetRange("Bill-to Customer No.",SalesLine."Bill-to Customer No.");
        SalesInvLine.SetRange("No.",SalesLine."No.");
        SalesInvLine.SetFilter(Quantity,'>%1',0);
        if SalesInvLine.FindLast then
            exit(SalesInvLine."Unit Price");
    end;

    procedure GetLastMargin(var SalesLine: Record "Sales Line"): Decimal
    var
        SalesInvLine : Record "Sales Invoice Line";
    begin
        SalesInvLine.Reset;
        SalesInvLine.SetRange("Bill-to Customer No.",SalesLine."Bill-to Customer No.");
        SalesInvLine.SetRange("No.",SalesLine."No.");
        SalesInvLine.SetFilter(Quantity,'>%1',0);
        if SalesInvLine.FindLast then
            exit(SalesInvLine."ARC Margin %");
    end;

    procedure GetLastPurchDate(var SalesLine: Record "Sales Line"): Text
    var
        SalesInvLine : Record "Sales Invoice Line";
    begin
        SalesInvLine.Reset;
        SalesInvLine.SetRange("Bill-to Customer No.",SalesLine."Bill-to Customer No.");
        SalesInvLine.SetRange("No.",SalesLine."No.");
        SalesInvLine.SetFilter(Quantity,'>%1',0);
        if SalesInvLine.FindLast then
            exit(format(SalesInvLine."Posting Date"));
    end;

    procedure setGlobalItemNo(newItemNo: Code[20]);
    begin
        GlobalItemNo := newItemNo;
    end;

    procedure SetSalesLine(_SalesLine: Record "Sales Line")
    begin
        // SOW11 Körber Edge WMS - CO3 MCP Pricing - for details refer to email sent Wed 9 Mar 2022 at 806am to Erik Holmberg
        SalesLine := _SalesLine;
    end;

    procedure VerifyPermissions(var PriceEntry: Record "ARC Price Entry");
    var
        User: Record User;
        UserGroupMember: Record "User Group Member";
        RNASetup: Record "ARC RNA Setup";
    begin
        if not User.Get(UserSecurityId) then
            Error('');
        RNASetup.Get;
        RNASetup.TestField("Price Admin User Group");    
        if not UserGroupMember.Get(RNASetup."Price Admin User Group", User."User Security ID", CompanyName) then
            if not UserGroupMember.Get(RNASetup."Price Admin User Group", User."User Security ID", '') then
                error(NotPermissionsTxt);
    end;

    procedure FixPriceEntryDocLineNo(_PriceReviewEntry: Record "ARC Price Review Entry")
    var
        _SalesLine: Record "Sales Line";
        _EventLogEntry: Record "ARC Event Log Entry";
        _text: Text;
        _Text000Lbl: Label 'Price Review Entry for document %1 %2 %3 line %4 item %5 unit price %6 was deleted because the Sales Line was not found.';
    begin
        _PriceReviewEntry.TestField("Document Area",_PriceReviewEntry."Document Area"::Sales);
        if _SalesLine.Get(_PriceReviewEntry."Document Type",_PriceReviewEntry."Document No.",_PriceReviewEntry."Document Line No.") then begin
            Message('Document line was successfully retrieved, no action was necessary.');
            exit;
        end;
        _text := CopyStr(StrSubstNo(_Text000Lbl,_PriceReviewEntry."Document Area",_PriceReviewEntry."Document Type",_PriceReviewEntry."Document No.",
            _PriceReviewEntry."Document Line No.",_PriceReviewEntry."No.",_PriceReviewEntry."Unit Price"),1,MaxStrLen(_text));
        _EventLogEntry.NewEventLogEntry('REVIEW',_EventLogEntry."Object Type"::Codeunit,Codeunit::"ARC Price Management",_EventLogEntry.Status::Error,_PriceReviewEntry."Entry No.",'',_text,false,'');
        _PriceReviewEntry.Delete();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcSalesPrice(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; CalledByFieldNo: Integer)
    begin
    end;
}
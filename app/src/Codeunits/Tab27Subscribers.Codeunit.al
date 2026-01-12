codeunit 50002 "ARC Table 27 Subscribers"
{
    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Blocked', false, false)]
    local procedure OnAfterValidateBlocked(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer);
    var
        UserSetup: Record "User Setup";
    begin
        if(not Rec.Blocked) and (Rec."ARC Block Regulatory") then
            Error(NotAllowedTxt, Rec.FieldCaption(Blocked), Rec.FieldCaption("ARC Block Regulatory"));

        if not (Rec.Blocked)  then begin
            UserSetup.Get(UserId);
            if not UserSetup."ARC Administrator" then
                Error(BlockPermTxt);
       end;      
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Manufacturer Code', false, false)]
    local procedure OnAfterValidateMFGCode(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer);
    begin
        if(Rec."ARC Agency Item") and (Rec."Manufacturer code" = '') then
            Error(NoBlankMfgCodeTxt, Rec.FieldCaption("Manufacturer Code"), Rec.FieldCaption("ARC Agency Item"))
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Unit Price', false, false)]
    local procedure OnAfterValidateUnitPrice(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer);
    begin
       if (Rec."Unit Price" <> xRec."Unit Price") then begin 
         if (Rec."ARC Minimum Price" = 0) then
            Rec.Validate("ARC Minimum Price",Rec."Unit Price")
         else begin 
            if (Rec."ARC Minimum Price" > Rec."Unit Price") then
                Error(MinPriceErrorTxt,Rec."Unit Price");
         end;   
       end;  
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Price/Profit Calculation', false, false)]
    local procedure OnAfterValidatePriceProfitCalc(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer);
    var
        GLSetup: Record "General Ledger Setup";
    begin
        case Rec."Price/Profit Calculation" of
            Rec."Price/Profit Calculation"::"Profit=Price-Cost":
                if Rec."Unit Price" <> 0 then
                    if Rec."ARC Sales Cost" = 0 then
                        Rec."Profit %" := 0
                    else
                        Rec."Profit %" :=
                            Round(
                            100 * (1 - Rec."ARC Sales Cost"/
                                    (Rec."Unit Price" / (1 + CalcTax(Rec)))), 0.00001)
                else
                    Rec."Profit %" := 0;
            Rec."Price/Profit Calculation"::"Price=Cost+Profit":
                if Rec."Profit %" < 100 then begin
                    GLSetup.Get;
                    Rec."Unit Price" :=
                        Round(
                        (Rec."ARC Sales Cost" / (1 - Rec."Profit %" / 100)) *
                        (1 + CalcTax(Rec)),
                        GLSetup."Unit-Amount Rounding Precision");
                end    

        end;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'ARC Minimum Price', false, false)]
    local procedure OnAfterValidateARCMinPrice(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer);
    begin
       if (Rec."ARC Minimum Price" <> xRec."ARC Minimum Price") then begin
            if (Rec."ARC Minimum Price" > Rec."Unit Price") then
                Error(MinPriceErrorTxt,Rec."Unit Price");
       end;  
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertItem(var Rec: Record "Item"; RunTrigger: Boolean);
    var
    begin
        if not RunTrigger then
            exit;
        if (Rec."Unit Price" <> 0) and (Rec."ARC Minimum Price" = 0) then
            Rec.Validate("ARC Minimum Price",Rec."Unit Price");       
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'ARC Purchase Block', false, false)]
    local procedure OnAfterValidateARCPurchaseBlock(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer);
    var
        UserSetup: Record "User Setup";
    begin
       if not (Rec."ARC Purchase Block") then begin
            UserSetup.Get(UserId);
            if not UserSetup."ARC Purchasing Manager" then
                Error(PurchBlockPermTxt);
       end;  
    end;

    

    local procedure CalcTax(item: Record Item): Decimal
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if item."Price Includes VAT" then begin
            VATPostingSetup.Get(item."VAT Bus. Posting Gr. (Price)", item."VAT Prod. Posting Group");
            case VATPostingSetup."VAT Calculation Type" of
                VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
                    VATPostingSetup."VAT %" := 0;
                VATPostingSetup."VAT Calculation Type"::"Sales Tax":
                    Error(
                      Text50000,
                      VATPostingSetup.FieldCaption("VAT Calculation Type"),
                      VATPostingSetup."VAT Calculation Type");
            end;
        end else
            Clear(VATPostingSetup);

        exit(VATPostingSetup."VAT %" / 100);
    end; 

    var
        NotAllowedTxt: Label 'You are not allowed to change %1, when %2 is enabled.';
        NoBlankMfgCodeTxt: Label 'You cannot remove %1, while %2 is checked';
        MinPriceErrorTxt: Label 'Minimum price must be less than unit price %1';
        Text50000: Label 'Prices including VAT cannot be calculated when %1 is %2.';
        PurchBlockPermTxt: Label 'You are not allowed to remove block.\Please contact purchasing manager.';
        BlockPermTxt: Label 'You are not allowed to remove block.\Please contact administrator.';


}
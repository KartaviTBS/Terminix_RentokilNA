page 50037 "ARC Item Price Entry FactBox"
{
    Caption = 'Item Price EntryDetails';
    PageType = CardPart;
    SourceTable = "Sales Line";


    layout
    {
        area(content)
        {
            field(ItemNo; ShowNo())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Item No.';
                Lookup = false;
                ToolTip = 'Specifies the item that is handled on the sales line.';

                trigger OnDrillDown()
                begin
                    SalesInfoPaneMgt.LookupItem(Rec);
                end;
            }

            field("ARC Price Entry No."; "ARC Price Entry No.")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Price Entry No.';
                Lookup = false;
                DrillDown = true;

                trigger OnDrillDown()
                begin
                    PriceMgt.LookUpPriceEntry(Rec);
                end;
            }

             field("ARC Promotion Entry No.";"ARC Promotion Entry No.")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Promotion Entry No.';
                Lookup = false;
                DrillDown = true;

                trigger OnDrillDown()
                begin
                   PriceMgt.LookUpPromoEntry(Rec);
                end;
            }
            field(ItemType; GetItemType())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Item Type';
            }

            field(ItemLowestPrice; GetItemLowestPrice())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Item Lowest Price';
            }

            field(ItemLastPrice; PriceMgt.GetLastUnitPrice(Rec))
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Item Last Price';
            }
            field(ItemLastMargin; PriceMgt.GetLastMargin(Rec))
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Item Last Margin %';
            }
            field(LastPurchDate; PriceMgt.GetLastPurchDate(Rec))
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Item Last Purchase Date';
            }
            field(Substitutions; SalesInfoPaneMgt.CalcNoOfSubstitutions(Rec))
            {
                ApplicationArea = Suite;
                Caption = 'Substitutions';
                DrillDown = true;
                ToolTip = 'Specifies other items that are set up to be traded instead of the item in case it is not available.';

                trigger OnDrillDown()
                begin
                    CurrPage.SaveRecord;
                    ShowItemSub;
                    CurrPage.Update(true);
                    if(Reserve = Reserve::Always) and ("No." <> xRec."No.") then begin
                        AutoReserve;
                        CurrPage.Update(false);
                    end;
                end;
            }
            field(SalesPrices; CalcNoOfSalesPrices(Rec))
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Price Entries';
                DrillDown = true;
                ToolTip = 'Specifies special sales prices that you grant when certain conditions are met, such as customer, quantity, or ending date. The price agreements can be for individual customers, for a group of customers, for all customers or for a campaign.';

                trigger OnDrillDown()
                begin
                    GetSalesPrices(Rec);
                    CurrPage.Update;
                end;
            }
            field(SalesPromotions; CalcNoOfSalesPromotions(Rec))
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Promotions';
                DrillDown = true;
                ToolTip = 'Promotions available for this item  with certain conditions are met, such as customer, quantity. The promotions can be for individual customers, for a group of customers, for all customers or for a campaign.';

                trigger OnDrillDown()
                begin
                    GetSalesPromotions(Rec);
                    CurrPage.Update;
                end;
            }

        }
    }

    actions
    {
    }

    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        SalesPriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
        SalesInfoPaneMgt: Codeunit "Sales Info-Pane Management";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        PriceMgt: Codeunit "ARC Price Management";
        PromoMgt: Codeunit "ARC Promotion Management";
        


    trigger OnAfterGetCurrRecord()
    begin
        ClearSalesHeader;
    end;

    local procedure ShowLineDisc()
    begin
        SalesHeader.Get("Document Type", "Document No.");
        Clear(SalesPriceCalcMgt);
        SalesPriceCalcMgt.GetSalesLineLineDisc(SalesHeader, Rec);
    end;

    local procedure ShowNo(): Code[20]
    begin
        if Type <> Type::Item then
            exit('');
        exit("No.");
    end;

    local procedure GetItemType(): Text[30]
    begin
        if Type <> Type::Item then
            exit('');
        Item.Get("No.");
        If Item."ARC Agency Item" then
            exit(Item.FieldCaption("ARC Agency Item"));
        If Item."ARC MCP" then
            exit(Item.FieldCaption("ARC MCP"));
        exit('');
    end;

    local procedure GetItemLowestPrice(): Text[30]
    var
        Item: Record Item;
    begin
        if Type <> Type::Item then
            exit('');
        Item.Get("No.");
        exit(format(Item."ARC Minimum Price"));

    end;

    procedure CalcNoOfSalesPrices(var SalesLine: Record "Sales Line"): Integer
    begin
        if GetItem(SalesLine) then begin
            GetSalesHeader(SalesLine);
            exit(PriceMgt.NoOfSalesLinePrice(SalesHeader, SalesLine, true));
        end;
    end;

     procedure CalcNoOfSalesPromotions(var SalesLine: Record "Sales Line"): Integer
    begin
        if GetItem(SalesLine) then begin
            GetSalesHeader(SalesLine);
            exit(PromoMgt.NoOfSalesLinePromotions(SalesHeader, SalesLine));
        end;
    end;

    local procedure GetItem(var SalesLine: Record "Sales Line"): Boolean
    begin
        with Item do begin
            if (SalesLine.Type <> SalesLine.Type::Item) or (SalesLine."No." = '') then
                exit(false);

            if SalesLine."No." <> "No." then
                Get(SalesLine."No.");
            exit(true);
        end;
    end;

    local procedure GetSalesHeader(var SalesLine: Record "Sales Line")
    begin
        if (SalesLine."Document Type" <> SalesHeader."Document Type") or
           (SalesLine."Document No." <> SalesHeader."No.")
        then
            SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
    end;

    procedure GetSalesPrices(var SalesLine: Record "Sales Line"): Integer
    begin
        if GetItem(SalesLine) then begin
            GetSalesHeader(SalesLine);
            exit(PriceMgt.ShowSalesLinePrices(SalesHeader, SalesLine, true));
        end;
    end;

    procedure GetSalesPromotions(var SalesLine: Record "Sales Line"): Integer
    begin
        if GetItem(SalesLine) then begin
            GetSalesHeader(SalesLine);
            exit(PromoMgt.ShowSalesLinePromos(SalesHeader, SalesLine));
        end;
    end;

    procedure GetLastUnitPrice(var SalesLine: Record "Sales Line"): Decimal
    var
        PriceMgt : Codeunit "ARC Price Management";
    begin
        PriceMgt.GetLastUnitPrice(SalesLine);
    end;



}
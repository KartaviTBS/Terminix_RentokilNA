pageextension 50075 "ARC Sales Return Order" extends "Sales Return Order"
{
    layout
    {
       addafter("Sell-to Customer Name")
        {
            field("Customer Name 2";"Sell-to Customer Name 2")
            {
                ApplicationArea = All;
            }
        }
       addafter("Bill-to Name")
        {
            field("Bill-to Name 2";"Bill-to Name 2")
            {
                ApplicationArea = All;
            }
        }
       addafter("Ship-to Name")
        {
            field("Ship-to Name 2";"Ship-to Name 2")
            {
                ApplicationArea = All;
            }
        }
                
        addafter("Ship-to County")
        {
            field("ARC Locality Code"; "ARC Locality Code")
            {
                Importance = Promoted;
                ApplicationArea = Basic, Suite;
            }
            field("ARC Business Type Code";"ARC Business Type Code")
            {
                Importance = Promoted;
                ApplicationArea = Basic, Suite;
            }
        }
        addafter("Assigned User ID")
        {
           field("ARC Created By";"ARC Created By")
           {
               ApplicationArea = All;
           }
       
        }
        modify("Tax Liable")
        {
            Enabled = false;
        }
    }
    actions
    {
        addafter(EDI)
        {
            group("2Ship")
            {
                Caption = '2 Ship';               
                action("2Ship Get Edit URL")
                {
                    ApplicationArea = All;
                    Caption = '2Ship Return Get Edit URL';
                    Image = Link;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    
                    trigger OnAction();
                    var
                        ShipIntMgt:Codeunit "2Ship Integration Mgmt.";
                    begin
                        ShipIntMgt.Submit2ShipRateShopRequest(Rec,true);
                        //Rec.Testfield("2Ship Get Edit URL");
                        CurrPage.Update;
                        Hyperlink(Rec."2Ship Get Edit URL");
                    end;
                }
            }
        }        
    }
}
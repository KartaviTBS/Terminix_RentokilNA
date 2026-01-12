pageextension 50026 "ARC Sales Order List" extends "Sales Order List"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("Sell-to Customer Name 2"; "Sell-to Customer Name 2")
            {
                ApplicationArea = All;
            }
            field("Sell-to Address"; "Sell-to Address")
            {
                ApplicationArea = All;
            }
        }

        addafter("Bill-to Name")
        {
            field("Bill-to Name 2"; "Bill-to Name 2")
            {
                ApplicationArea = All;
            }
        }

        addafter("Ship-to Name")
        {
            field("Ship-to Name 2"; "Ship-to Name 2")
            {
                ApplicationArea = All;
            }
        }

    }
    actions
    {
        addlast(Navigation)
        {

            
            action("WorkWaveEntries")
            {
                Caption = 'WorkWave Entries';
                Image = CreditCardLog;
                Promoted = true;
                PromotedCategory = Category4;
                RunObject = page "ARC Workwave Entries";
                RunPageLink = "Sales Order No." = field("No.");
            }
        }
    }

}
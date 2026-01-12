pageextension 50012 "ARC Sales Quote" extends "Sales Quote"
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

        addafter("Assigned User ID")
        {
            field("ARC Created By"; "ARC Created By")
            {
                ApplicationArea = All;
            }

            field("ARC Expiration Date";"ARC Expiration Date")
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
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}
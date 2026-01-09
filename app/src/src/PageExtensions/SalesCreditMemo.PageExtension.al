pageextension 50073 "ARC Sales Credit Memo" extends "Sales Credit Memo"
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
                
        addafter("Location Code")
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
}
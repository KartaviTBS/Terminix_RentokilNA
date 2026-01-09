pageextension 50072 "ARC Sales Invoice" extends "Sales Invoice"
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
}
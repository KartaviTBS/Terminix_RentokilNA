pageextension 50074 "ARC Sales Cr. Memo Subform" extends "Sales Cr. Memo Subform"
{
    layout
    {
        addafter("Unit Price")
        {
            field("ARC Supplemental Charge Code";"ARC Supplemental Charge Code")
            {
                ApplicationArea = All;
                Visible = false;                
            } 
            field("ARC Supplemental Charge Rate";"ARC Supplemental Charge Rate")
            {
                ApplicationArea = All;
                Visible = false;                
            }  
            field("ARC Supplemental Fixed Amount";"ARC Supplemental Fixed Amount")
            {
                ApplicationArea = All;
                Visible = false;                
            }                    
        }
    }

    actions
    {
        // Add changes to page actions here
    }
}
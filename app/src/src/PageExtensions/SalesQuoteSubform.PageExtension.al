pageextension 50010 "ARC Sales Quote Subform" extends "Sales Quote Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Description 2";"Description 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Appl.-to Item Entry")
        {
            field("ARC Price Entry No.";"ARC Price Entry No.")
            {
                ApplicationArea = All;
            }
        }
        addafter("Unit Price")
        {
            field("ARC Sales Cost";"ARC Sales Cost")
            {
                ApplicationArea = All;
            }
            field("ARC Margin %";"ARC Margin %")
            {
                ApplicationArea = All;
                
                trigger OnValidate()
                begin
                    if Rec."Line No." = 0 then begin 
                        CurrPage.SaveRecord();                   
                        CurrPage.Update(true);
                        PriceMgt.CreatePriceReviewEntry(Rec);
                    end;    
                end;
            } 
            field("ARC Price Review Exist";"ARC Price Review Exist")
            {
                ApplicationArea = All;
                Style = Attention;
            } 
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
    
    var
        PriceMgt: Codeunit "ARC Price Management";
}
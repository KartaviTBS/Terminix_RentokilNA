pageextension 50032 "ARC Sales Order Archive Subf." extends "Sales Order Archive Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Description 2"; Rec."Description 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Appl.-to Item Entry")
        {
            field("ARC Price Entry No."; Rec."ARC Price Entry No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("ARC Business Type Code"; Rec."ARC Business Type Code")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("ARC Promotion Entry No."; Rec."ARC Promotion Entry No.")
            {
                ApplicationArea = All;
            }
            field("ARC Promotion Code"; Rec."ARC Promotion Code")
            {
                ApplicationArea = All;
            }  
            field(Pack;Pack)
            {
                ApplicationArea = All;
                Visible = false;
                Editable = true;
            }                           
        }   

        addafter("Unit Price")
        {
            field("ARC Sales Cost"; Rec."ARC Sales Cost")
            {
                ApplicationArea = All;
            }
            field("ARC Margin %"; Rec."ARC Margin %")
            {
                ApplicationArea = All;
            }            
            field("ARC Price Review Exist"; Rec."ARC Price Review Exist")
            {
                ApplicationArea = All;
                Style = Attention;
            }
            field("ARC Supplemental Charge Code"; Rec."ARC Supplemental Charge Code")
            {
                ApplicationArea = All;
                Visible = false;
             } 
            field("ARC Supplemental Charge Rate"; Rec."ARC Supplemental Charge Rate")
            {
                ApplicationArea = All;
                 Visible = false;               
            }  
            field("ARC Supplemental Fixed Amount"; Rec."ARC Supplemental Fixed Amount")
            {
                ApplicationArea = All;
                Visible = false;                
            }
        }
    }

    actions
    {
    }
}
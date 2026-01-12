pageextension 50042 "ARC Customer Card" extends "Customer Card"
{
    layout
    {
        addafter(Name)
        {
            field("Name 2"; Rec."Name 2")
            {
                 ApplicationArea = All;
            }            
        }
            
        addlast(General)
        {
            field("ARC Internal Customer"; Rec."ARC Internal Customer")
            {
            }
            field("ARC LOB Lift %"; Rec."ARC LOB Lift %")
            {
            }
            field("ARC COI Permit"; Rec."ARC COI Permit")
            {
                ApplicationArea = All;
            }            
            field("Chain Name"; Rec."Chain Name")
            {
                ApplicationArea = All;
            }
            field("ARC ReOrder Referecne"; Rec."ARC ReOrder Referecne")
            {
                ApplicationArea = All;
            }
            field("ARC PestPac Customer ID"; Rec."ARC PestPac Customer ID")
            {
                ApplicationArea = All;
            }
            field("ARC eCommerce Enabled"; Rec."ARC eCommerce Enabled")
            {
                ApplicationArea = All;
                Importance = Additional;
            }
            field("Last Modified Date Time"; Rec."Last Modified Date Time")
            {
                ApplicationArea = All;
                Editable = false;
                Importance = Additional;
            }
            field("NAV Modified Date"; Rec."NAV Modified Date")
            {
                ApplicationArea = All;
                Editable = false;
                Importance = Additional;
            }
        }
    }

    actions
    {
        addafter("Ship-to Address List")
        {
            action("Lift")
            {
                Caption = 'Item Lift %';
                Image = Percentage;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                RunObject = Page "ARC Customer Item Lift List";
                RunPageLink = "Customer No." = field("No.");
            }
        }
    }
}
pageextension 50016 "ARC Item List" extends "Item List"
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
        addafter(Blocked)
        {
            field("ARC APL"; Rec."ARC APL")
            {
                ApplicationArea = All;
            }
        }

        addlast(Item)
        {
            field("Sales Cost"; Rec."ARC Sales Cost")
            {
                ApplicationArea = All;
            }
            field("ARC Ranking Code";Rec."ARC Ranking Code")
            {
                ApplicationArea = All;
            }
        }


    }

    actions
    {
        addlast(Action126)
        {
            action(SupplementalCharges)
            {
                Caption = 'Supplemental Charges';
                Image = Price;
                RunObject = Page "ARC Item Supplemental Charges";
                RunPageLink = "Item No." = FIELD ("No.");
            }


            action(ImportItemAttributes)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Import Item Attributes';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = false;
                PromotedOnly = true;


                trigger OnAction()
                begin
                    XMLPORT.Run(XMLPORT::"ARC Item Attributes Import", false, true);
                end;
            }

        }
    }

    var
        myInt: Integer;
}
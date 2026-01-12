pageextension 50011 "ARC Salesperson/Purchaser Card" extends "Salesperson/Purchaser Card"
{
    layout
    {
        addafter("Commission %")
        {
            field("ARC Manager"; "ARC Manager")
            {
                ApplicationArea = All;
            }
            field("Agency User Group";"ARC Agency User Group")
            {
                 ApplicationArea = All;
            }
            field("MCP User Group";"ARC MCP User Group")
            {
                 ApplicationArea = All;
            }

        }

        addafter(Invoicing)
        {
            group(Dimensions)
            {
                Caption = 'Salesperson Dimensions';

                field("ARC Salesperson Dimension 1"; "ARC Salesperson Dimension 1")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ARC Salesperson Dimension 2"; "ARC Salesperson Dimension 2")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ARC Salesperson Dimension 3"; "ARC Salesperson Dimension 3")
                {
                    ApplicationArea = Basic, Suite;
                }

                field("ARC Salesperson Dimension 4"; "ARC Salesperson Dimension 4")
                {
                    ApplicationArea = Basic, Suite;
                }

                field("ARC Salesperson Dimension 5"; "ARC Salesperson Dimension 5")
                {
                    ApplicationArea = Basic, Suite;
                }

                field("ARC Salesperson Dimension 6"; "ARC Salesperson Dimension 6")
                {
                    ApplicationArea = Basic, Suite;
                }

                field("ARC Salesperson Dimension 7"; "ARC Salesperson Dimension 7")
                {
                    ApplicationArea = Basic, Suite;
                }


            }
        }

    }

}
page 50049 "ARC NAPC BOL Subform"
{
    
    PageType = ListPart;
    SourceTable = "ARC NAPC BOL Line";
    Caption = 'Bill of Lading Lines';
    AutoSplitKey = true;
    DelayedInsert = true;
    
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                
                
                field("Source Doc. Type"; "Source Doc. Type")
                {
                    ApplicationArea = All;
                }
                field("Source Doc. No."; "Source Doc. No.")
                {
                    ApplicationArea = All;
                }
                field("Source Doc. Line No."; "Source Doc. Line No.")
                {
                    ApplicationArea = All;
                }
                field("Manifest Code"; "Manifest Code")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("NAPC BOL Code"; "NAPC BOL Code")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Line Weight"; "Line Weight")
                {
                    ApplicationArea = All;
                }
                field("Line Volume"; "Line Volume")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
}

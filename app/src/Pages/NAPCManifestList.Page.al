page 50050 "ARC NAPC Manifest List"
{
    
    PageType = List;
    SourceTable = "ARC NAPC Manifest";
    Caption = 'ARC NAPC Manifest List';
    ApplicationArea = All;
    UsageCategory = Lists;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = All;
                }
                field("E-Ship Agent Service"; "E-Ship Agent Service")
                {
                    ApplicationArea = All;
                }
                field("No. of BOL"; "No. of BOL")
                {
                    ApplicationArea = All;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
}

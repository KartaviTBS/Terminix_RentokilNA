page 50068 "ARC Supplemental Charges"
{
    
    PageType = List;
    SourceTable = "ARC Supplemental Charge";
    Caption = 'Supplemental Charges';
    ApplicationArea = All;
    UsageCategory = Lists;
    RefreshOnActivate = true;   
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Resource No."; "Resource No.")
                {
                    ApplicationArea = All;
                }
                field("Rate %"; "Rate %")
                {
                    ApplicationArea = All;
                }
                field("Fixed amount"; "Fixed amount")
                {
                    ApplicationArea = All;
                }
                field("Ship-to County"; "Ship-to County")
                {
                    ApplicationArea = All;
                }
                field("Last Update"; "Last Update")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Changed By"; "Changed By")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
    
}

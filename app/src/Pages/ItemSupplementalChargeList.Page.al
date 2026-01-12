page 50070 "ARC Item Supplemental Charges"
{
    
    PageType = List;
    SourceTable = "ARC Item Supplemental Charge";
    Caption = 'Item Supplemental Charges';
    ApplicationArea = All;
    UsageCategory = Lists;
    RefreshOnActivate = true;     
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    editable = false;
                }               
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    editable = false;
                }
                field("Resource No."; "Resource No.")
                {
                    ApplicationArea = All;
                    editable = false;
                }
                field("Rate %"; "Rate %")
                {
                    ApplicationArea = All;
                    editable = false;
                }
                field("Fixed amount"; "Fixed amount")
                {
                    ApplicationArea = All;
                    editable = false;
                }
                field("Ship-to County"; "Ship-to County")
                {
                    ApplicationArea = All;
                    editable = false;
                }
                field("Last Update"; "Last Update")
                {
                    ApplicationArea = All;
                    editable = false;
                }
                field("Changed By"; "Changed By")
                {
                    ApplicationArea = All;
                    editable = false;
                }

            }
        }
    }
    
}

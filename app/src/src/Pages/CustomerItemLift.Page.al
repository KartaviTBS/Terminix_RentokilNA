page 50046 "ARC Customer Item Lift List"
{
    
    PageType = List;
    SourceTable = "ARC Customer Item Lift";
    Caption = 'Customer Item Lift List';
    ApplicationArea = All;
    UsageCategory = Lists;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Lift %"; "Lift %")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
}

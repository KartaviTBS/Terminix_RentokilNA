page 50031 "ARC Product Type Restrictions"
{
    PageType = List;
    SourceTable = "ARC Product Type Restriction";
    UsageCategory = Lists;
    Caption = 'Product Type Restrictions';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
               field(Code;Code)
               {
                   ApplicationArea = All;
               }
               field(Description;Description)
               {
                   ApplicationArea = All;
               }
               field("CAS Level Restriction";"CAS Level Restriction")
               {
                   ApplicationArea = All;
               }
               field("Sales Order Approval Code";"Sales Order Approval Code")
               {
                   ApplicationArea = All;
               }
               
            }
        }
        area(factboxes)
        {
        }
    }

    actions
    {
        area(processing)
        {
            action(ActionName)
            {
                trigger OnAction();
                begin
                end;
            }
        }
    }
}
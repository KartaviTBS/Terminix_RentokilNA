pageextension 50070 "ARC Get Receipt Lines" extends "Get Receipt Lines"
{
    layout
    {
        addlast(Control1)
        {
            field("Direct Unit Cost";"Direct Unit Cost")
            {
                ApplicationArea = All;
            }
             field("Order No.";"Order No.")
            {
                ApplicationArea = All;
            }                      
        }
    }
}
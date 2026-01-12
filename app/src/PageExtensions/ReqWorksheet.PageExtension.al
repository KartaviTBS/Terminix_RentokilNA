pageextension 50052 "ARC Req. Worksheet" extends "Req. Worksheet"
{
    layout
    {
        addbefore(Type)
        {
            field("ARC Selected";"ARC Selected")
            {
                ApplicationArea = All;
            }
            
        }
        addafter("Due Date")
        {
            field("Sales Order No.";"Sales Order No.")
            {
                ApplicationArea = All;
            }
            field("Sales Order Line No.";"Sales Order Line No.")
            {
                ApplicationArea = All;
            }           
            
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    
    var
        myInt : Integer;
}
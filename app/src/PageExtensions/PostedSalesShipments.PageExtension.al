pageextension 50029 "ARC Posted Sales Shipments" extends "Posted Sales Shipments"
{
    layout
    {
        addafter("Ship-to Post Code")
        {
            field("Order No.";"Order No.")
            {
                ApplicationArea = All;
            }
            
            field("ARC Workwave Order";"ARC Workwave Order")
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
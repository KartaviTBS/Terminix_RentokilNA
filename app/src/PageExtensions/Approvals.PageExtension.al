pageextension 50021 "ARC Approval Entries" extends "Approval Entries"
{
    layout
    {
        addafter("Approval Type")
        {
            field("Approval Code";"Approval Code")
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
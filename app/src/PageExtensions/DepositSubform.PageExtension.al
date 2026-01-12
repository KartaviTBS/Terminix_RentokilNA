pageextension 50023 "ARC Deposit Subform" extends "Deposit Subform"
{
    layout
    {
        addafter("Document No.")
        {
            field("Line No.";"Line No.")
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
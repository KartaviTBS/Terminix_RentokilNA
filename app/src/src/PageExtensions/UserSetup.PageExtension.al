pageextension 50022 "ARC User Setup" extends "User Setup"
{
    layout
    {
        addafter("Time Sheet Admin.")
        {
            field("ARC Sales Price Approval Mgr.";"ARC Sales Price Approval Mgr.")
            {
                ApplicationArea = All;
            }
            field("ARC Purchasing Manager";"ARC Purchasing Manager")
            {
                ApplicationArea = All;
            }
            field("ARC Administrator";"ARC Administrator")
            {
                ApplicationArea = All;
            }
            field("ARC Workwave Administrator";"ARC Workwave Administrator")
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
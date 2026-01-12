pageextension 50082 "ARC Outbound Warehouse Rquest" extends "Outbound Warehouse Requests"
{
    layout
    {
        addlast("Repeater")
        {
            field("Bill-to Customer Name";"Bill-to Customer Name")
            {
                ApplicationArea = All;
            }
            field("Ship-to Address";"Ship-to Address")
            {
                ApplicationArea = All;
            }
            field("Ship-to Address 2";"Ship-to Address 2")
            {
                ApplicationArea = All;
            }  
            field("Ship-to City";"Ship-to City")
            {
                ApplicationArea = All;
            }  
            field("Ship-to County";"Ship-to County")
            {
                ApplicationArea = All;
            }  
            field("Ship-to Post Code";"Ship-to Post Code")
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
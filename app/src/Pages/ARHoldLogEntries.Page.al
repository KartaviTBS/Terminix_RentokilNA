page 50040  "ARC AR Hold Log Entries"
{
    PageType = List;
    SourceTable = "ARC AR Hold Log Entry";
    Caption = 'AR Hold Log Entries';
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Genearal)
            {
                field("Entry No.";"Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Customer No.";"Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name";"Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Sales Order No.";"Sales Order No.")
                {
                    ApplicationArea = All;
                }
                field("Credit Limit Amount";"Credit Limit Amount")
                {
                    ApplicationArea = All;
                }
                field("Balance Due";"Balance Due")
                {
                    ApplicationArea = All;
                }
                field("Balance Due Amount";"Balance Due Amount")
                {
                    ApplicationArea = All;
                }
                field("Order Amount";"Order Amount")
                {
                    ApplicationArea = All;
                }
                field(Status;Status)
                {
                    ApplicationArea = All;
                }
                field("Created By";"Created By")
                {
                    ApplicationArea = All;
                }
                field("Created On";"Created On")
                {
                    ApplicationArea = All;
                }
                field("Approved By";"Approved By")
                {
                    ApplicationArea = All;
                }
                field("Approved On";"Approved On")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
           
        }
    }
    
    var
        myInt : Integer;
}
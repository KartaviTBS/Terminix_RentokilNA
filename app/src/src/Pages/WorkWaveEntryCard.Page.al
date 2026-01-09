page 50074 "ARC WorkWave Entry Card"
{
    PageType = Card;
    SourceTable = "ARC Workwave Entry";
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Entry No.";"Entry No.")
                {
                    ApplicationArea = All;
                }
                 field("Transaction ID"; "Transaction ID")
                {
                    ApplicationArea = All;
                }
                field("Transaction Status"; "Transaction Status")
                {
                    ApplicationArea = All;
                }
                field("Transaction Type"; "Transaction Type")
                {
                    ApplicationArea = All;
                }
                field("Payment Acct Type"; "Payment Acct Type")
                {
                    ApplicationArea = All;
                }
                field("Card Type"; "Card Type")
                {
                    ApplicationArea = All;
                }
                field("Masked Card No."; "Masked Card No.")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Captured"; "Amount Captured")
                {
                    ApplicationArea = All;
                }
                field("Approval No."; "Approval No.")
                {
                    ApplicationArea = All;
                }
                field("Payment Acct Token"; "Payment Acct Token")
                {
                    ApplicationArea = All;
                }
                field("Employee ID"; "Employee ID")
                {
                    ApplicationArea = All;
                }
                field("Billing Address"; "Billing Address")
                {
                    ApplicationArea = All;
                }
                field("Billing City";"Billing City")
                {
                    ApplicationArea = All;
                }
                field("Billing State"; "Billing State")
                {
                    ApplicationArea = All;
                }
                field(Reference; Reference)
                {
                    ApplicationArea = All;
                }
                field("Payment Acct Reference"; "Payment Acct Reference")
                {
                    ApplicationArea = All;
                }
                field("Web Order No."; "Web Order No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Order No."; "Sales Order No.")
                {
                    ApplicationArea = All;
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field(Status;Status)
                {
                    ApplicationArea = All;
                }
                field("Related Entry No.";"Related Entry No.")
                {
                    ApplicationArea = All;
                }
                
                field("Created On"; "Created On")
                {
                    ApplicationArea = All;
                }
                field("Updated On"; "Updated On")
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
            action(ActionName)
            {
                trigger OnAction();
                begin
                end;
            }
        }
    }
    
    var
        myInt : Integer;
}
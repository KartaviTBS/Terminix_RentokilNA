pageextension 50020 "ARC Customer List" extends "Customer List"
{
    layout
    {
        addafter("Customer Posting Group")
        {
            field("ARC Internal Customer"; "ARC Internal Customer")
            {
            }
        }
        addafter("Sales (LCY)")
        {
            field("ARC Created By";"ARC Created By")
            {
                ApplicationArea = All;
            }
            field("ARC Created On";"ARC Created On")
            {
                ApplicationArea = All;
            }
            field("ARC Modified By";"ARC Modified By")
            {
                ApplicationArea = All;
            }
            field("ARC Modified On";"ARC Modified On")
            {
                ApplicationArea = All;
            }
        }

    }

    actions
    {
        addlast("&Customer")
        {
            action(ShowMyReport)
            {
                trigger OnAction()
                begin
                    BOLCustomerReport.Run;                    
                end;
            }
        }

    }

    var
    BOLCustomerReport: Report "ARC NAPC BOL Customer Report";

   
}
page 50063 "ARC AP Sweep Registers"
{
    PageType = List;
    Caption = 'AP Sweep Registers';
    SourceTable = "ARC AP Sweep Register";
    Editable = FALSE;
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                }
                field("Export Date"; "Export Date")
                {
                }
                field("Export Time"; "Export Time")
                {
                }
                field("No. of Transactions"; "No. of Transactions")
                {
                }
                field("Transaction Amount"; "Transaction Amount (LCY)")
                {
                }
                field("From Entry No."; "From Entry No.")
                {
                }
                field("To Entry No."; "To Entry No.")
                {
                }

            }
        }
        area(factboxes)
        {
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
}
page 50071 "Invoice Print Log Entries"
{
    PageType = List;
    SourceTable = "ARC Invoice Print Log Entry";
    Caption = 'Invoice Print Log Entries';
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
                field("Starting Invoice No.";"Starting Invoice No.")
                {
                   ApplicationArea = All;
                }
                field("Last Invoice No.";"Last Invoice No.")
                {
                   ApplicationArea = All;
                }
                field("No. of Invoices";"No. of Invoices")
                {
                   ApplicationArea = All;
                }
                field("Created User";"Created User")
                {
                    ApplicationArea = All;
                }
                field("Created On";"Created On")
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
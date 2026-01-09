page 50032 "ARC Alloc8 Export Entries"
{
    PageType = List;
    SourceTable = "ARC Alloc8 Export Entry";
    UsageCategory = Lists;
    Caption = 'Alloc8 Export Entries';
    ApplicationArea = All;
    InsertAllowed = false;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Entry Type";"Entry Type")
                {
                    ApplicationArea = All;
                }
                field("Export Date/Time";"Export Date/Time")
                {
                    ApplicationArea = All;
                }
                field("No. of Transactions";"No. of Transactions")
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
            action("Export Invoices")
            {
                Caption = 'Export Invoices';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                var 
                    Alloc8ExportInv: Codeunit "ARC Alloc8 Invoice Export";
                begin
                    Alloc8ExportInv.Run;                    
                end;
            }
            action("Export Customers")
            {
                Caption = 'Export Customers';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                var 
                    Alloc8ExportCust: Codeunit "ARC Alloc8 Customer Export";
                begin
                    Alloc8ExportCust.Run;                   
                end;
            }
        }
    }
}
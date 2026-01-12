report 50006 "Print Invoice Test"
{
    Caption = 'Print Invoice Test';
    ProcessingOnly = true;
    UsageCategory = Administration;
    
    dataset
    {
        dataitem(InvoiceTest; Integer)
        {
            DataItemTableView = SORTING (Number) WHERE (Number = CONST (1));

            trigger OnAfterGetRecord()
            var
              printInvoice: Codeunit "ARC Print Invoces";
            begin
                printInvoice.Run;
            end;

            trigger OnPostDataItem()
            var
            begin
               
                Message('Complete');
            end;
        }
    }
    
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                    
                }
            }
        }
    
        actions
        {
            area(processing)
            {
                
            }
        }
    }
    
    var
        myInt : Integer;
}
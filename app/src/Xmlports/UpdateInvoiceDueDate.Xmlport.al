xmlport 50006 "Update Invoice Due Dates"
{
    Caption = 'Update Invoice Due Dates';
    Direction = Import;
    FieldDelimiter = '<None>';
    FieldSeparator = '<TAB>';
    Format = VariableText;
    Permissions = TableData "Cust. Ledger Entry" = rimd,
                  TableData "Sales Invoice Header" = rimd,
                  TableData "Detailed Cust. Ledg. Entry" = rimd;
    UseRequestPage = false;
    

    schema
    {
        textelement(Root)
        {
           tableelement(Table2000000026;Integer)
            {
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                XmlName = 'Integer';            
               
                textelement(SalesInvNo)
                {
                    
                }
                textelement(DueDate)
                {
                    
                }
                              

                trigger OnBeforeInsertRecord()
                begin
                    UpdateEntries();
                    ClearAll;
                    i+=1;
                    currXMLport.Skip;                   
                end;            

                              
            }
        }
    }

    trigger OnPostXmlPort();
    begin 
        Message('Update Complete');
    end;
    
    local procedure UpdateEntries();
    var
       SalesInvHeader: Record "Sales Invoice Header";
       CustLedgEntry: Record "Cust. Ledger Entry";
       DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
       newDate: Date;
    begin
        if i =0 then begin;
           i+=1;
           currXMLport.Skip;
        end;    
        if (SalesInvNo = '') OR (DueDate = '') then
            currXMLport.Skip;
        Evaluate(newDate,DueDate);    
        If SalesInvHeader.Get(SalesInvNo) then begin 
            SalesInvHeader."Due Date" := newDate;
            SalesInvHeader.Modify;
        end;   
        CustLedgEntry.SetCurrentKey("Document Type", "Customer No.", "Posting Date");
        CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
        CustLedgEntry.SetRange("Document No.",SalesInvNo);
        CustLedgEntry.SetRange(Open, true);
        if CustLedgEntry.FindFirst then begin 
            CustLedgEntry."Due Date" := newDate;
            CustLedgEntry.Modify;
         end;

    end;
    
    var
       i: Integer;

    }



   
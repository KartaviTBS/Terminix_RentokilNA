page 50030 "ARC Alloc8 Setup"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Alloc8 Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "ARC Alloc8 Setup";
    UsageCategory = Administration;


    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Customer File Export Path"; "Customer File Export Path")
                {
                    ApplicationArea = All;
                    AssistEdit = true;

                    trigger OnValidate()
                    begin
                        CheckAndAppendPath("Customer File Export Path");
                    end;

                    trigger OnAssistEdit()
                    var
                        FileManagement: Codeunit "File Management";
                    begin
                        "Customer File Export Path" := FileManagement.BrowseForFolderDialog(CustomerExportFileTxt, '', false);
                        CheckAndAppendPath("Customer File Export Path");
                    end;
                }
                field("Invoice File Export Path"; "Invoice File Export Path")
                {
                    ApplicationArea = All;
                    AssistEdit = true;

                    trigger OnValidate()
                    begin
                        CheckAndAppendPath("Invoice File Export Path");
                    end;

                    trigger OnAssistEdit()
                    var
                        FileManagement: Codeunit "File Management";
                    begin
                        "Invoice File Export Path" := FileManagement.BrowseForFolderDialog(TransactionExportFileTxt, '', false);
                        CheckAndAppendPath("Invoice File Export Path");
                    end;
                }
                field("Cust Gen. Bus Posting Group";"Cust Gen. Bus Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Incremental Export";"Incremental Export")
                {
                    ApplicationArea = All;
                }              
            }
        }
    }



    local procedure CheckAndAppendPath(var value: Text)
    begin
        if value <> '' then
            if CopyStr(value, StrLen(value), 1) <> '\' then
                value += '\'
    end;


    trigger OnOpenPage();
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;

    var
        CustomerExportFileTxt: Label 'Select Customer File Export Path';
        TransactionExportFileTxt: Label 'Select Invoice File Export Path';
        ImportFileTxt: Label 'Select Import File Export Path';
}
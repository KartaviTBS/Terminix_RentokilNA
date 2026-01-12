page 50028 "ARC OnGuard Setup"
{
    ApplicationArea = Basic, Suite;
    Caption = 'OnGuard Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "ARC OnGuard Setup";
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
                field("Transaction File Export Path"; "Transaction File Export Path")
                {
                    ApplicationArea = All;
                    AssistEdit = true;

                    trigger OnValidate()
                    begin
                        CheckAndAppendPath("Transaction File Export Path");
                    end;

                    trigger OnAssistEdit()
                    var
                        FileManagement: Codeunit "File Management";
                    begin
                        "Transaction File Export Path" := FileManagement.BrowseForFolderDialog(TransactionExportFileTxt, '', false);
                        CheckAndAppendPath("Transaction File Export Path");
                    end;
                }
                field("Last Sequence No."; "Last Sequence No.")
                {
                    ApplicationArea = All;
                }
                field("Import File Export Path"; "Import File Export Path")
                {
                    ApplicationArea = All;
                    AssistEdit = true;

                    trigger OnValidate()
                    begin
                        CheckAndAppendPath("Import File Export Path");
                    end;

                    trigger OnAssistEdit()
                    var
                        FileManagement: Codeunit "File Management";
                    begin
                        "Import File Export Path" := FileManagement.BrowseForFolderDialog(ImportFileTxt, '', false);
                        CheckAndAppendPath("Import File Export Path");
                    end;
                }
                field("Use Company Prefix"; "Use Company Prefix")
                {
                    ApplicationArea = All;
                }
                field("Incremental Export"; "Incremental Export")
                {
                    ApplicationArea = All;
                }

                field("File CharSet"; "File CharSet")
                {
                    ApplicationArea = All;
                }
                field("Increase Sequence Number"; "Increase Sequence Number")
                {
                    ApplicationArea = All;
                }
                field("Migration Date";"Migration Date")
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
           
            action(ResetRegister)
            {
                ApplicationArea = All;
                Caption = 'Reset Register';
                Image = Restore;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = codeunit "ARC Set up OnGuard Register";

               
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
        TransactionExportFileTxt: Label 'Select Transaction File Export Path';
        ImportFileTxt: Label 'Select Import File Export Path';
}
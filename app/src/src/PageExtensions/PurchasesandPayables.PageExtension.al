pageextension 50063 "ARC Purchases & Payables Setup" extends "Purchases & Payables Setup"
{
    layout
    {
        addafter(General)
        {
            group("AP Sweep")
            {
                Caption = 'AP Sweep';

                field("ARC AP Sweep Folder"; "ARC AP Sweep Folder")
                {
                    ApplicationArea = All;
                    AssistEdit = true;

                    trigger OnValidate()
                    begin
                        CheckAndAppendPath("ARC AP Sweep Folder");
                    end;

                    trigger OnAssistEdit()
                    var
                        FileManagement: Codeunit "File Management";
                    begin
                        "ARC AP Sweep Folder" := FileManagement.BrowseForFolderDialog(APSweepExportFileTxt, '', false);
                        CheckAndAppendPath("ARC AP Sweep Folder");
                    end;
                }
                field("ARC AP Sweep File Name"; "ARC AP Sweep File Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ARC AP Sweep Account Type"; "ARC AP Sweep Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ARC AP Sweep Bal. Account Type"; "ARC AP Sweep Bal. Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ARC AP Sweep Bal. Account No."; "ARC AP Sweep Bal. Account No.")
                {
                    ApplicationArea = Basic, Suite;
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

    var
        APSweepExportFileTxt: Label 'Select AP Sweep Export Path';

}
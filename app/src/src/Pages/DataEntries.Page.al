page 50076 "ARC Data Entries"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ARC Data Entry";
    Editable = false;
    Caption = 'Data Entries';

    layout
    {
        area(Content)
        {
            repeater(Entries)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Size;Rec.Size)
                {
                    ApplicationArea = All;
                }
                field("Created by"; Rec."Created by")
                {
                    ApplicationArea = All;
                }
                field("Created at DateTime"; Rec."Created at DateTime")
                {
                    ApplicationArea = All;
                }
                field("Created at Date"; Rec."Created at Date")
                {
                    ApplicationArea = All;
                }
                field("Created at Time"; Rec."Created at Time")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {
        }
    }

    actions
    {
        area(Processing)
        {
            action(Create)
            {
                ApplicationArea = All;
                Image = Create;
                ToolTip = 'Choose to create a sample record';
                Caption = 'Create sample record';

                trigger OnAction()
                var
                    _DataMgt: Codeunit "ARC DataMgt";
                begin
                    _DataMgt.CreateSampleRecord();
                    CurrPage.Update(false);
                end;
            }
            action(ImportFile)
            {
                ApplicationArea = All;
                Image = Import;
                ToolTip = 'Choose to import a file';
                Caption = 'Import File';

                trigger OnAction()
                var
                    _DataMgt: Codeunit "ARC DataMgt";
                begin
                    _DataMgt.ImportFile('IMPORT_FILE','User selected action Import File from Data Entries','Choose file to import');
                    CurrPage.Update(false);
                end;
            }
            action(Show)
            {
                ApplicationArea = All;
                Image = EndingText;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Reveal the contents of the Data field (Ctrl+A to select all text, Ctrl+C to copy to clipboard, Ctrl+V to paste into Notepad)';
                Caption = 'Show data contents';

                trigger OnAction()
                var
                    _DataMgt: Codeunit "ARC DataMgt";
                begin
                    _DataMgt.ShowValue(Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec.FindLast() then;
        Rec.Ascending(false);
    end;
}
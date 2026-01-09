page 50081 "2Ship Integration Log"
{
    Caption = '2Ship Integration Log';
    Editable = false;
    PageType = List;
    SourceTable = "2Ship Integration Log";
    UsageCategory = History;
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.', Comment = '%';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }
                field("Date & Time"; Rec."Date & Time")
                {
                    ToolTip = 'Specifies the value of the Date & Time field.', Comment = '%';
                }
                field("User Id"; Rec."User Id")
                {
                    ToolTip = 'Specifies the value of the User Id field.', Comment = '%';
                }
                field(ErrorVar; ErrorVar)
                {
                    Caption = 'Error';
                    ApplicationArea = All;
                }
                
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Get Request JSON")
            {
                ApplicationArea = All;
                Image = Export;

                trigger OnAction()
                var
                    Instrm: InStream;
                    outstrm: OutStream;
                    Filename: Text;
                    Request: Text;
                    TempFile:File;
                begin
                    Filename := Format(Rec."Entry No.") + '_'+ delchr(Rec."Document No.",'=','/\') + 'Request' + '.Json';
                    Rec.CalcFields("JSON Request Blob");
                    if Rec."JSON Request Blob".HasValue then begin
                        Rec."JSON Request Blob".CreateInStream(Instrm);
                        DownloadFromStream(Instrm, '', '', '', Filename);
                    end;
                end;
            }
            action("Get Response JSON")
            {
                ApplicationArea = All;
                Image = Export;

                trigger OnAction()
                var
                    Instrm: InStream;
                    outs: OutStream;
                    Filename: Text;
                    Title: Text;
                    Test2: Text;
                begin
                   Filename := Format(Rec."Entry No.") + '_'+ delchr(Rec."Document No.",'=','/\') + 'Response' + '.Json';
                    Rec.CalcFields("JSON Response Blob");
                    if Rec."JSON Response Blob".HasValue then begin
                        Rec."JSON Response Blob".CreateInStream(Instrm);
                        DownloadFromStream(Instrm, '', '', '', Filename);
                    end;
                end;
            }
        }
    }
    Var
        ErrorVar: Text;

    trigger OnAfterGetRecord()
    var
        ErrorInstr: InStream;
    begin
        Rec.CalcFields(Error);
        Rec.Error.CreateInStream(ErrorInstr);
        ErrorInstr.ReadText(ErrorVar);
    end;
}


page 50005 "ARC SDS Region Blocks"
{
    PageType = List;
    SourceTable = "ARC SDS Region Block";
    Caption = 'SDS Region Blocks';
    DelayedInsert = true;
    RefreshOnActivate = true;
   layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("SDS Code";"SDS Code")
                {
                    ApplicationArea = All;
                    Editable = SDSCodeEditable;
                }
                field("Country/Region Code";"Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(County;County)
                {
                    ApplicationArea = All;
                }
                field("Post Code";"Post Code")
                {
                    ApplicationArea = All;
                }
                field("Locality Code";"Locality Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    [Scope('Personalization')]
    procedure SetFields(CalledFrom: Integer);
    begin
        Case CalledFrom of
        Database::"ARC SDS Product":
            SDSCodeEditable := true;
        end;
    end;

    var
        SDSCodeEditable: Boolean;
}
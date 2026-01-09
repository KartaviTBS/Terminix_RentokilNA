page 50004 "ARC SDS Ship-From Block List"
{
    PageType = List;
    SourceTable = "ARC SDS Ship-from Block";
    ApplicationArea = Basic, Suite, Service;
    Caption = 'SDS Ship-From Blocks';
    DelayedInsert = true;
    RefreshOnActivate = true;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("SDS Code"; "SDS Code")
                {
                    ApplicationArea = All;
                    Editable = SDSCodeEditable;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Country/Region Code"; "Ship-to Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to County"; "Ship-to County")
                {
                    ApplicationArea = All;
                }
                field("Product Use"; "Product Use")
                {
                    ApplicationArea = All;
                }
                field("Product Type Restriction Code"; "Product Type Restriction Code")
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
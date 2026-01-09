page 50027 "ARC County List"
{
    PageType = List;
    SourceTable ="ARC County";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'County List';
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Country/Region Code";"Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(Code;Code)
                {
                    ApplicationArea = All;
                }
                field(Description;Description)
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
            action(ActionName)
            {
                trigger OnAction();
                begin
                end;
            }
        }
    }

    var
        myInt: Integer;
}
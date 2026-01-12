page 50010 "ARC License Types"
{
    PageType = List;
    SourceTable = "ARC License Type";
    Caption = 'License Types';
    RefreshOnActivate = true;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(County; County)
                {
                    ApplicationArea = All;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                }
                field("Locality Code"; "Locality Code")
                {
                    ApplicationArea = All;
                }
                field(Restricted; Restricted)
                {
                    ApplicationArea = All;
                }
            }
        }

    }
}
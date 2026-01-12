page 50023 "ARC Placard List"
{
    PageType = List;
    SourceTable = "ARC Placard";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Placard List';
    RefreshOnActivate = true;


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
                field("Class No."; "Class No.")
                {
                    ApplicationArea = All;
                }
                field("Class Description"; "Class Description")
                {
                    ApplicationArea = All;
                }
            }
        }

    }

}
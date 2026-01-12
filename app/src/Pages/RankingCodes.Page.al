page 50052 "ARC Ranking Codes"
{
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "ARC Ranking Code";
    RefreshOnActivate = true;
    Caption = 'Ranking Codes';
    
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Ranking Code';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Description';
                }
                field("Use Location Priority";"Use Location Priority")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether items classified with this ranking will leverage Location Priorities (logic found in COD50078 "ARC OrderManagement")';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
    }
}
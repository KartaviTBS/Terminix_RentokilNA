page 50053 "ARC Order Sources"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ARC Order Source";
    Caption = 'Order Sources';

    layout
    {
        area(content)
        {
            repeater(Codes)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Code';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Description';
                }
                field(Memo; Rec.Memo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a free text field for additional information';
                }
                field(Default; Rec.Default)
                {
                    ApplicationArea = All;
                    ToolTip = 'When a new Sales Header record is initialized, the first Order Source marked Default will be selected';
                }
                field("Created by"; Rec."Created by")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the user credential that created the record';
                }
                field("Created at Date"; Rec."Created at Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the date when the record was created';
                }
                field("Created at DateTime"; Rec."Created at DateTime")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the DateTime when the record was created';
                }
                field("Created at Time"; Rec."Created at Time")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the time when the record was created';
                }
            }
        }
        area(factboxes)
        {
        }
    }

    actions
    {
        area(processing)
        {
        }
    }
}
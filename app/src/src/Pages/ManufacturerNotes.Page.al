page 50062 "ARC Manufacturer Notes"
{
    PageType = List;
    SourceTable = "ARC Manufacturer Notes";
    Caption = 'Manufacturer Notes';
    RefreshOnActivate = true;
    ApplicationArea = All;
    UsageCategory = Administration;
    AutoSplitKey = true;
    DataCaptionFields = Code;
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Code; Code)
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;

                }
                field("Line No."; "Line No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field(Notes; Notes)
                {
                    Importance = Promoted;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Manufacturer Code Note itself.';
                }
            }

        }

    }

}
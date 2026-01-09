page 50011 "ARC Hazard Class Comment Sheet"
{
    AutoSplitKey = true;
    Caption = 'Hazard Class Comment Sheet';
    DataCaptionFields = "Hazard Class Code";
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "ARC Hazard Class Comment Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Comment;Comment)
                {
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies the comment itself.';
                }                
            }
        }
    }

}
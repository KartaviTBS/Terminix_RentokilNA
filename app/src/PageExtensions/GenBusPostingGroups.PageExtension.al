pageextension 50044 "ARC Gen. Bus. Posting Groups" extends "Gen. Business Posting Groups"
{
    layout
    {
        addlast(Control1)
        {
            field("ARC Korber Freight"; Rec."ARC Korber Freight")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether Korber freight charges are added to order';
            }
            field("ARC Korber Frgt Max Threshold"; Rec."ARC Korber Frgt Max Threshold")
            {
                ApplicationArea = All;
                ToolTip = 'If Korber Freight is "Add Freight," then any freight charge will be added unless order total exceeds this amount';
            }
            field("ARC Korber Frgt Resource No."; Rec."ARC Korber Frgt Resource No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Resource No. to use for freight charges';
            }
        }
    }

    actions
    {
    }
}
pageextension 50030 "ARC No. Series" extends "No. Series"
{
    layout
    {
        addlast(Control1)
        {
            field("Release Permitted"; Rec."Release Permitted")
            {
                ApplicationArea = All;
                ToolTip = 'If Order Management is active in Sales Setup, this field determines whether Sales Order Release is permitted for the No. Series; if Yes, new sales orders may not be created with this No. Series';
            }
        }
    }

    actions
    {
    }
}
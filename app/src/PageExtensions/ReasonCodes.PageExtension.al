pageextension 50119 "ARC Reason Codes" extends "Reason Codes"
{
    layout
    {
        addafter(Description)
        {
            field("ARC Korber Reason Code"; Rec."ARC Korber Reason Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Korber Edge WMS Reason Code';
            }
        }
    }

    actions
    {
    }
}
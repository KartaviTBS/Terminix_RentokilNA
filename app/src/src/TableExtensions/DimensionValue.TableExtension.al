tableextension 50021 "ARC Dimension Value" extends "Dimension Value"
{
    fields
    {
        field(50001;"ARC Target Branch";Boolean)
        {
            Caption = 'Target Branch';
        }
    }
    
    var
        myInt : Integer;
}
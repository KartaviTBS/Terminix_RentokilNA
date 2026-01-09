tableextension 50027 "ARC Requisition Line" extends "Requisition Line"
{
    fields
    {
        field(50001; "ARC Selected"; Boolean)
        {
            Caption = 'Selected';
        }
    }
    
    var
        myInt : Integer;
}
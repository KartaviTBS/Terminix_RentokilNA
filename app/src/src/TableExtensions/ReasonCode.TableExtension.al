tableextension 50119 "ARC Reason Code" extends "Reason Code"
{
    fields
    {
        field(50000; "ARC Korber Reason Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Korber Reason Code';
        }
    }
}
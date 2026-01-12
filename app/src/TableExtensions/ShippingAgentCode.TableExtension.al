tableextension 50063 "ARC Shipping Agent" extends "Shipping Agent"
{
    fields
    {
        field(50001; "ARC Use Location Ship-to"; Boolean)
        {
            Caption = 'Use Location Ship-to';
        }
        field(50002; "ARC Bypass E-Ship"; Boolean)
        {
            Caption = 'Bypass E-Ship';
        }
        field(50003; "Freight Class ID"; Integer)
        {
            Caption = 'Freight Class ID';
            DataClassification = ToBeClassified;
        }
    }
}
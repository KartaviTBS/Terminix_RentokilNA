tableextension 50043 "ARC Customer Posting Group" extends "Customer Posting Group"
{
    fields
    {
        field(50042; "ARC Internal Customer"; Boolean)
        {
            Caption = 'Internal Customer';
        }
        field(50043;"ARC LOB Lift %";Decimal)
        {
            Caption = 'LOB Lift %';
        }
        field(50044;"ARC Material Expense Account";Code[20])
        {
            Caption = 'Material Expense Account';
            TableRelation = "G/L Account";
        }
    }
    
    var
        myInt : Integer;
}
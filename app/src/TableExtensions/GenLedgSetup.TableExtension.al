tableextension 50041 "ARC General Ledger Setup" extends "General Ledger Setup"
{
    fields
    {
        field(50041;"ARC LOB Lift G/L Account";Code[20])
        {
            Caption = 'LOB Lift G/L Account';
            TableRelation = "G/L Account";
        }
        field(50042;"ARC Default Target LOB Code";Code[20])
        {
            Caption = 'Default Target LOB Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(3));
        }
        field(50043;"ARC Default Pest LOB Code";Code[20])
        {
            Caption = 'Default Pest LOB Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(3));
        }
        field(50044;"ARC Default Tax LOB Code";Code[20])
        {
            Caption = 'Default Tax LOB Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(3));
        }
        field(50102; "ARC Job Queue Credential"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Job Queue Credential';
        }
    }
}
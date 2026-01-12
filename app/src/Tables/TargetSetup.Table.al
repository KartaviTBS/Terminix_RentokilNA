table 50026 "ARC Target Setup"
{
    Caption = 'Target Setup';
    DataClassification = CustomerContent;


    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "CA Prop 65 Statement"; Text[200])
        {
            DataClassification = CustomerContent;
        }
        field(3; "NAPC BOL Nos."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(4; "NAPC Manifest Nos."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(5; "Unregulated Product BOL Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "ARC NAPC BOL".Code;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }



}
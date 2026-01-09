table 50047 "2Ship Integration Setup"
{
    Caption = '2Ship Integration Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary key"; Code[10])
        {
            Caption = 'Primary key';
        }
        field(2; "Ship URL"; Text[250])
        {
            Caption = 'Ship URL';
            ExtendedDatatype = URL;
        }
        field(3; "WS_Key"; Text[250])
        {
            Caption = 'WS_Key';
        }
        field(4; "Delete Shipment URL"; Text[250])
        {
            Caption = 'Delete Shipment URL';
            ExtendedDatatype = URL;
        }
        field(5; "Freight Resource No."; Text[250])
        {
            Caption = 'Freight Resource No.';
            TableRelation = Resource;
        }
        field(6; "Get Edit URL"; Text[250])
        {
            Caption = 'Get Edit URL';
            //TableRelation = Resource;
        }
    }
    keys
    {
        key(PrimaryKey; "Primary key")
        {
            Clustered = true;
        }
    }
}
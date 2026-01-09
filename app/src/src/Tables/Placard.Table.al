table 50020 "ARC Placard"
{
    Caption = 'Placard';
    LookupPageID = 50023;

    fields
    {
        field(1;"Code";Code[10])
        {
        }
        field(10;"Class No.";Code[1])
        {
            Numeric = true;
            SQLDataType = Integer;
        }
        field(11;"Class Description";Text[50])
        {
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}


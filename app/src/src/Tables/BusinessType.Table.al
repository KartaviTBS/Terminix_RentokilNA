table 50014 "ARC Business Type"
{
    Caption = 'Business Type';
    LookupPageID = 50015;

    fields
    {
        field(1;"Code";Code[10])
        {
            NotBlank = true;
        }
        field(2;Description;Text[50])
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


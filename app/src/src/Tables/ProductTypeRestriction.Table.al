table 50021 "ARC Product Type Restriction"
{
    
    LookupPageID = 50031;

    fields
    {
        field(1;"Code";Code[20])
        {
            NotBlank = true;
        }
        field(2;Description;Text[100])
        {
        }
        field(9;"CAS Level Restriction";Boolean)
        {
        }
        field(10;"Sales Order Approval Code";Code[20])
        {
            //TableRelation = Table453.Field1 WHERE (Field4=CONST(36));
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


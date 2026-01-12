table 50027 "ARC NAPC BOL Comment Line"
{
   
    Caption = 'NAPC BOL Comment Line';

    fields
    {
        field(1;"Code";Code[10])
        {

        }
        field(2;"Line No.";Integer)
        {
        }
        field(10;Comment;Text[80])
        {
        }
    }

    keys
    {
        key(Key1;"Code","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}


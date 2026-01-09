table 50010 "ARC Hazard Class Comment Line"
{
   
    Caption = 'Hazard Class Comment Line';

    fields
    {
        field(1;"Hazard Class Code";Code[10])
        {
            NotBlank = true;
            TableRelation = "ARC Hazard Class".Code;
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
        key(Key1;"Hazard Class Code","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}


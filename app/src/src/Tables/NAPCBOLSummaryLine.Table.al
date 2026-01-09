table 50028 "ARC NAPC BOL Summary Line"
{
    // version DRS
   
    Caption = 'NAPC BOL Summary Line';

    fields
    {
        field(1;"NAPC BOL Document No.";Code[20])
        {
        }
        field(2;"NAPC BOL Code";Code[10])
        {
        }
        field(10;Description;Text[50])
        {
        }
        field(11;"Unit of Measure Code";Code[10])
        {
        }
        field(12;"Line Quantity";Decimal)
        {
            DecimalPlaces = 0:5;
        }
        field(13;"Line Weight";Decimal)
        {
            DecimalPlaces = 0:5;
        }
        field(14;"Line Volume";Decimal)
        {
            DecimalPlaces = 0:5;
        }
        field(15;"Placard Code";Code[10])
        {
        }
        field(16;HazMat;Code[2])
        {
        }
    }

    keys
    {
        key(Key1;"NAPC BOL Document No.","NAPC BOL Code")
        {
        }
    }

    fieldgroups
    {
    }
}


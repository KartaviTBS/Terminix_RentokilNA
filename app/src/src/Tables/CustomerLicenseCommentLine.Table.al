table 50018 "ARC Customer Lic. Comment Line"
{
    
    Caption = 'Customer License Comment Line';

    fields
    {
        field(1;"Customer No.";Code[20])
        {
            NotBlank = true;
            TableRelation = Customer;
        }
        field(2;"Ship-to Code";Code[10])
        {
            TableRelation = "Ship-to Address".Code WHERE ("Customer No."=FIELD("Customer No."));
        }
        field(3;"Country/Region Code";Code[10])
        {
            TableRelation = "Country/Region";
        }
        field(4;County;Text[30])
        {
            Caption = 'State';
            TableRelation = "ARC County".Code WHERE ("Country/Region Code"=FIELD("Country/Region Code"));
        }
        field(6;"Locality Code";Code[20])
        {
            TableRelation = "ARC Locality".Code WHERE ("Country/Region Code"=FIELD("Country/Region Code"),
                                                 County=FIELD(County));
        }
        field(7;"Business Type Code";Code[10])
        {
            TableRelation = "ARC Business Type";
        }
        field(8;"License Type Code";Code[20])
        {
            TableRelation = "ARC License Type";
        }
        field(9;"License No.";Text[30])
        {
        }
        field(10;"Line No.";Integer)
        {
        }
        field(20;Comment;Text[80])
        {
        }
    }

    keys
    {
        key(Key1;"Customer No.","Ship-to Code","Country/Region Code",County,"Locality Code","Business Type Code","License Type Code","License No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}


table 50017 "ARC Customer License CAS Code"
{
    Caption = 'Customer License CAS Code';
    DrillDownPageID = 50022;
    LookupPageID = 50022;

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
        field(8;"Product Type Restriction Code";Code[20])
        {
            TableRelation = "ARC Product Type Restriction".Code;
        }
        field(9;"License Type Code";Code[20])
        {
            TableRelation = "ARC License Type".Code;
        }
        field(10;"License No.";Text[30])
        {
        }
        field(11;"CAS Code";Code[30])
        {
            NotBlank = true;
            TableRelation = "ARC CAS";
        }
        field(100;"Locality Description";Text[50])
        {
            CalcFormula = Lookup("ARC Locality".Description WHERE (Code=FIELD("Locality Code"),
                                                             "Country/Region Code"=FIELD("Country/Region Code"),
                                                             County=FIELD(County)));
            Description = 'Flowfield';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101;"Chemical Name";Text[100])
        {
            CalcFormula = Lookup("ARC CAS"."Chemical Name" WHERE (Code=FIELD("CAS Code")));
            Description = 'Flowfield';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Customer No.","Ship-to Code","Country/Region Code",County,"Locality Code","Business Type Code","Product Type Restriction Code","License Type Code","License No.","CAS Code")
        {
        }
    }

    fieldgroups
    {
    }
}


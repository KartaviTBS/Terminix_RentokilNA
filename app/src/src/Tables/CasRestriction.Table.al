table 50008 "ARC CAS Restriction"
{
    
    Caption = 'CAS Restriction';
    DrillDownPageID = 50008;
    LookupPageID = 50008;

    fields
    {
        field(1;"CAS Code";Code[30])
        {
            NotBlank = true;
            TableRelation = "ARC CAS";
        }
        field(2;"Country/Region Code";Code[10])
        {
            TableRelation = "Country/Region";
        }
        field(3;County;Text[30])
        {
            Caption = 'State';
            TableRelation = "ARC County".Code WHERE ("Country/Region Code"=FIELD("Country/Region Code"));
        }
        field(5;"Locality Code";Code[20])
        {
            TableRelation = "ARC Locality".Code WHERE ("Country/Region Code"=FIELD("Country/Region Code"),
                                                 County=FIELD(County));
        }
        field(6;"Product Type Restriction Code";Code[20])
        {
            TableRelation = "ARC Product Type Restriction".Code;
        }
    }

    keys
    {
        key(Key1;"CAS Code","Country/Region Code",County,"Locality Code","Product Type Restriction Code")
        {
        }
    }

    fieldgroups
    {
    }
}


table 50022 "ARC Restricted Prod. Lic. Type"
{
    

    Caption = 'Restricted Product Lic. Type';

    fields
    {
        field(1;"License Type Code";Code[20])
        {
            NotBlank = true;
            TableRelation = "ARC License Type";
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
        field(4;"Post Code";Code[20])
        {
            Caption = 'Zip Code';
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup();
            begin
                PostCode.LookUpPostCode(cityTxt,"Post Code",County,"Country/Region Code");
            end;

            trigger OnValidate();
            begin
                PostCode.ValidatePostCode(cityTxt,"Post Code",County,"Country/Region Code",false);
            end;
        }
        field(5;"Locality Code";Code[20])
        {
            TableRelation = "ARC Locality".Code WHERE ("Country/Region Code"=FIELD("Country/Region Code"),County=FIELD(County),"Post Code"=FIELD("Post Code"));
        }
        field(10;"Business Type Code";Code[10])
        {
            TableRelation = "ARC Business Type";
        }
        field(11;"Product Type Restriction Code";Code[20])
        {
            NotBlank = true;
            TableRelation = "ARC Product Type Restriction".Code;
        }
    }

    keys
    {
        key(Key1;"License Type Code","Country/Region Code",County,"Post Code","Locality Code","Business Type Code","Product Type Restriction Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        PostCode : Record "Post Code";
        cityTxt : Text[30];
}


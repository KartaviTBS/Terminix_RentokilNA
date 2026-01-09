table 50011 "ARC Locality"
{
    
    Caption = 'Locality';
    DrillDownPageId = "ARC Localities";
    LookupPageId = "ARC Localities";
    

    fields
    {
        field(1;"Code";Code[20])
        {
            NotBlank = true;
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
                PostCode.LookUpPostCode(CityTxt,"Post Code",County,"Country/Region Code");
            end;

            trigger OnValidate();
            begin
                PostCode.ValidatePostCode(CityTxt,"Post Code",County,"Country/Region Code",false);
            end;
        }
        field(10;Description;Text[50])
        {
        }
    }

    keys
    {
        key(Key1;"Country/Region Code",County,"Post Code","Code")
        {
        }
       
    }

    fieldgroups
    {
    }

    var
        PostCode : Record "Post Code";
        CityTxt : Text[30];
}


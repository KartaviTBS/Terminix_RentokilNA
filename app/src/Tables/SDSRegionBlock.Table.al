table 50005 "ARC SDS Region Block"
{
    
    Caption = 'SDS Region Block';
    DrillDownPageId = 50005;
    LookupPageId = 50005;

    fields
    {
        field(1;"SDS Code";Code[20])
        {
            NotBlank = true;
            TableRelation = "ARC SDS Product";
        }
        field(2;"Country/Region Code";Code[10])
        {
            TableRelation = "Country/Region".Code;
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
            ValidateTableRelation = false;

            trigger OnLookup();
            begin
                PostCode.LookupPostCode(cityTxt,"Post Code",County,"Country/Region Code");              
            end;

            trigger OnValidate();
            begin
                PostCode.ValidatePostCode(CityTxt,"Post Code",County,"Country/Region Code",false);                
            end;
        }
        field(5;"Locality Code";Code[20])
        {
            TableRelation = "ARC Locality".Code WHERE ("Country/Region Code"=FIELD("Country/Region Code"),County=FIELD(County),"Post Code"=FIELD("Post Code"));
        }
    }

    keys
    {
        key(Key1;"SDS Code","Country/Region Code",County,"Post Code","Locality Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        PostCode : Record "Post Code";
        CityTxt: Text[30];
}


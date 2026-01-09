table 50012 "ARC License Type"
{
    
    Caption = 'License Type';
    LookupPageID = 50010;

    fields
    {
        field(1;"Code";Code[20])
        {
            NotBlank = true;
        }
        field(6;"Country/Region Code";Code[10])
        {
            TableRelation = "Country/Region";
        }
        field(7;County;Text[30])
        {
            Caption = 'State';
            TableRelation = "ARC County".Code WHERE ("Country/Region Code"=FIELD("Country/Region Code"));
        }
        field(8;"Post Code";Code[20])
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
        field(9;"Locality Code";Code[20])
        {
            TableRelation = "ARC Locality".Code;
        }
        field(15;Description;Text[100])
        {
        }
        field(30;Restricted;Boolean)
        {
            CalcFormula = Exist("ARC Restricted Prod. Lic. Type" WHERE ("License Type Code"=FIELD(Code)));
            Description = 'Flowfield';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Code","Country/Region Code",County,"Post Code","Locality Code")
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


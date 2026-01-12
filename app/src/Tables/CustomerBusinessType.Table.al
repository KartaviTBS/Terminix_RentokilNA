table 50015 "ARC Customer Business Type"
{
    
    Caption = 'Customer Business Type';
    DrillDownPageID = 50016;
    LookupPageID = 50016;

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
        field(5;"Post Code";Code[20])
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
        field(6;"Locality Code";Code[20])
        {
            TableRelation = "ARC Locality".Code WHERE ("Country/Region Code"=FIELD("Country/Region Code"),County=FIELD(County),"Post Code"=FIELD("Post Code"));
        }
        field(7;"Business Type Code";Code[10])
        {
            NotBlank = true;
            TableRelation = "ARC Business Type";
        }
        field(100;"Customer Name";Text[50])
        {
            
            CalcFormula = Lookup(Customer.Name WHERE ("No."=FIELD("Customer No.")));
            Editable = false;
            Caption = 'Customer Name';            
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Customer No.","Ship-to Code","Country/Region Code",County,"Post Code","Locality Code","Business Type Code")
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


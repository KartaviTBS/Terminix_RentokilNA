table 50006 "ARC SDS Product CAS"
{
   
    Caption = 'SDS Product CAS';
    DrillDownPageID = 50006;
    LookupPageID = 50006;

    fields
    {
        field(1;"SDS Product Code";Code[20])
        {
            NotBlank = true;
            TableRelation = "ARC SDS Product";
        }
        field(2;"CAS Code";Code[30])
        {
            NotBlank = true;
            TableRelation = "ARC CAS";
        }
        field(10;"Ingredient %";Decimal)
        {
        }
        field(11;"SDS Product Description";Text[100])
        {
            CalcFormula = Lookup("ARC SDS Product".Description WHERE (Code=FIELD("SDS Product Code")));
            Description = 'Flowfield';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12;"CAS Chemical Name";Text[100])
        {
            CalcFormula = Lookup("ARC CAS"."Chemical Name" WHERE (Code=FIELD("CAS Code")));
            Description = 'Flowfield';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20;Restricted;Boolean)
        {
            CalcFormula = Exist("ARC CAS Restriction" WHERE ("CAS Code"=FIELD("CAS Code")));
            Description = 'Flowfield';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"SDS Product Code","CAS Code")
        {
        }
    }

    fieldgroups
    {
    }
}


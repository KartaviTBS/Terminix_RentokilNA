table 50007 "ARC CAS"
{
   

    Caption = 'CAS';
    DrillDownPageID = 50007;
    LookupPageID = 50007;    
    
    fields
    {
        field(1;"Code";Code[30])
        {
            NotBlank = true;            
        }
        field(2;"Chemical Name";Text[100])
        {
        }
        field(10;"CA Prop 65";Boolean)
        {
        }
        field(11;Clopyralid;Boolean)
        {
        }
        field(12;"Ground Water";Boolean)
        {
        }
        field(13;Restricted;Boolean)
        {
            CalcFormula = Exist("ARC CAS Restriction" WHERE ("CAS Code"=FIELD(Code)));
            Description = 'Flowfield';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        CASRestriction.SETRANGE("CAS Code",Code);
        CASRestriction.DELETEALL;
        CustomerLicenseCASCode.SETRANGE("CAS Code",Code);
        CustomerLicenseCASCode.DELETEALL;
    end;

    trigger OnRename();
    begin
        CASRestriction.SETRANGE("CAS Code",Code);
        if not CASRestriction.ISEMPTY then
          ERROR(Text001);
        CustomerLicenseCASCode.SETRANGE("CAS Code",Code);
        if not CustomerLicenseCASCode.ISEMPTY then
          ERROR(Text001);
    end;

    var
        CustomerLicenseCASCode : Record "ARC Customer License CAS Code";
        CASRestriction : Record "ARC CAS Restriction";
        Text001 : Label 'Rename not allowed CAS Restrictions exist';
        
}


table 50009 "ARC Hazard Class"
{
    

    Caption = 'Hazard Class';
    LookupPageID = 50013;

    fields
    {
        field(1;"Code";Code[10])
        {
            NotBlank = true;
        }
        field(10;Description;Text[50])
        {
        }
        field(20;"Warehouse Storage Code";Option)
        {
            OptionCaption = 'G,A,CA,CB,F,GF,O,OUT,T';
            OptionMembers = G,A,CA,CB,F,GF,O,OUT,T;
        }
        field(30;Comments;Boolean)
        {
            CalcFormula = Exist("ARC Hazard Class Comment Line" WHERE ("Hazard Class Code"=FIELD(Code)));
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
        HazardClassCommentLine.SETRANGE("Hazard Class Code",Code);
        HazardClassCommentLine.DELETEALL;
    end;

    trigger OnRename();
    begin
        HazardClassCommentLine.SETRANGE("Hazard Class Code",Code);
        if not HazardClassCommentLine.ISEMPTY then
          ERROR(Text001);
    end;

    var
        HazardClassCommentLine : Record "ARC Hazard Class Comment Line";
        Text001 : Label 'Rename not allowed';
}


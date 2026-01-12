table 50024 "ARC NAPC BOL"
{
  
    Caption = 'NAPC BOL';
    LookupPageID = 50026;

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(11;"Matter State";Option)
        {
            Caption = 'Matter State';
            OptionCaption = 'Solid,Liquid,Gas,Other';
            OptionMembers = Solid,Liquid,Gas,Other;
        }
        field(13;"BOL Limit Unit";Option)
        {
            Caption = 'BOL Limit Unit';
            OptionCaption = '" ,Quantity,Weight"';
            OptionMembers = " ",Quantity,Weight;
        }
        field(14;"BOL Limit";Decimal)
        {
            Caption = 'BOL Limit';
        }
        field(15;"Placard Limit Unit";Option)
        {
            Caption = 'Placard Limit Unit';
            OptionCaption = '" ,Volume,Weight"';
            OptionMembers = " ",Volume,Weight;
        }
        field(16;"Placard Limit";Decimal)
        {
            Caption = 'Placard Limit';
        }
        field(17;"Placard Code";Code[10])
        {
            Caption = 'Placard Code';
            TableRelation = "ARC Placard".Code;
        }
        field(20;"Alt. BOL Code";Code[10])
        {
            Caption = 'Alt. BOL Code';
            TableRelation = "ARC NAPC BOL".Code;
        }
        field(30;Comments;Boolean)
        {
            CalcFormula = Exist("ARC NAPC BOL Comment Line" WHERE (Code=FIELD(Code)));
            Caption = 'Comments';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
        key(Key2;"Matter State")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
       NAPCBOLCommentLine.SetRange(Code,Code);
       NAPCBOLCommentLine.DeleteAll;
    end;

    trigger OnRename();
    begin
       NAPCBOLCommentLine.SetRange(Code,Code);
       if not NAPCBOLCommentLine.IsEmpty then
         Error(Text001);
    end;

    var
        NAPCBOLCommentLine : Record "ARC NAPC BOL Comment Line";
        Text001 : Label 'Rename not allowed';
}


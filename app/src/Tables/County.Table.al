table 50023 "ARC County"
{
    DataClassification = ToBeClassified;
    Caption = 'County';
    DrillDownPageId = 50027;
    LookupPageId = 50027;
    
    fields
    {
        field(1;"Country/Region Code";Code[10])
        {
           
        }
        field(2;"Code";Text[30])
        {
           
        }
        field(3;"Description";Text[50])
        {
           
        }
    }

    keys
    {
        key(Key1;"Country/Region Code",Code)
        {
            Clustered = true;
        }
    }

   

    trigger OnInsert();
    begin
    end;

    trigger OnModify();
    begin
    end;

    trigger OnDelete();
    begin
    end;

    trigger OnRename();
    begin
    end;

}
table 50040 "ARC Ranking Code"
{
    DataClassification = CustomerContent;
    LookupPageId = "ARC Ranking Codes";
    Caption = 'Ranking Code';
    
    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(11; "Use Location Priority"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK;Code)
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
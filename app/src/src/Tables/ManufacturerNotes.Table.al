table 50062 "ARC Manufacturer Notes"
{
    DataClassification = CustomerContent;
    Caption = 'Manufacturer Notes';
    DrillDownPageID = 50062;
    LookupPageID = 50062;

    fields
    {
        field(1; Code; Code[20])
        {
            TableRelation = Manufacturer;
            NotBlank = true; 
            DataClassification = CustomerContent;
        }

        field(2;"Line No.";Integer)
        {
            DataClassification = CustomerContent;  
        }

        field(3;Notes;Text[250])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code, "Line No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

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
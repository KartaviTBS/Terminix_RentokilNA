table 50019 "ARC Alloc8 Setup"
{
    
    Caption = 'Alloc8 Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Customer File Export Path"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Invoice File Export Path"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        
        field(9; "Incremental Export"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Cust Gen. Bus Posting Group"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
        }
       
    }

    keys
    {
        key(PK; "Primary Key")
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
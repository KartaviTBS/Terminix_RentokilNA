table 50030 "ARC OnGuard Setup"
{
    Caption = 'OnGuard Setup';
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
        field(3; "Transaction File Export Path"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Last Sequence No."; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Import File Export Path"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(6; "Use Company Prefix"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(7;"File CharSet";Option)
        {
            OptionCaption = 'UTF-8,ISO-8859-1';
            OptionMembers = "UTF-8","ISO-8859-1";
        }
        field(8;"Increase Sequence Number";Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(9; "Incremental Export"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(10;"Migration Date";Date)
        {
            DataClassification = CustomerContent;
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
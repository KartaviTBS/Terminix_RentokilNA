table 50065 "ARC AP Journal Errors"
{
    DataClassification = CustomerContent;
    Caption = 'AP Journal Errors';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Document Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(3; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(4; "Terms code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Due Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Document Type"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(7; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(8; "Description"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(9; "Remaining Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(10; "External Document No."; Code[35])
        {
            DataClassification = CustomerContent;
        }
        field(11; "Vendor 1099 Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(12; "GL Bal. Account"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(13; "Account No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(14; "Reason Code"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(15; "Dim Code1"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(16; "Dim Code2"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(17; "Dim Code3"; Text[20])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
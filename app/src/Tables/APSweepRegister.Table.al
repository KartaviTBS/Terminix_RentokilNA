table 50063 "ARC AP Sweep Register"
{
    Caption = '"AP Sweep Register';
    DataClassification = CustomerContent;
    LookupPageId = 50063;
    DrillDownPageId = 50063;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }

        field(2; "Export Date"; Date)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(3; "Export Time"; Time)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(4; "No. of Transactions";Integer)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(5; "Transaction Amount (LCY)";Decimal)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6; "From Entry No.";Integer)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7; "To Entry No.";Integer)
        {
            Editable = false;
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
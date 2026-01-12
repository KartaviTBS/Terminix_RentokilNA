table 50098 "ARC Data Entry"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "ARC Data Entries";
    LookupPageId = "ARC Data Entries";
    Caption = 'Data Entry';

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(11; Code; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(12; Description; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(101; Data; Blob)
        {
            DataClassification = CustomerContent;
        }
        field(201; Size; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(4911; "Created by"; Text[50])
        {
            DataClassification = CustomerContent;
            TableRelation = User;
            ValidateTableRelation = false;
            Editable = false;
        }
        field(4912; "Created at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4913; "Created at Date"; Date)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4914; "Created at Time"; Time)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Code; Code) { }
        key(Size; Size) { }
        key(CreatedAtDateTime; "Created at DateTime") { }
    }

    trigger OnInsert()
    var
        _time: Time;
    begin
        _time := Time();
        "Created by" := CopyStr(UserId(), 1, MaxStrLen("Created by"));
        "Created at DateTime" := CreateDateTime(Today(),_time);
        "Created at Date" := Today();
        "Created at Time" := _time;
    end;

    trigger OnModify()
    begin
    end;

    trigger OnDelete()
    begin
    end;

    trigger OnRename()
    begin
    end;
}
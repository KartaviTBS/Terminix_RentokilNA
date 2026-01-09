table 50053 "ARC Order Source"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "ARC Order Sources";
    LookupPageId = "ARC Order Sources";
    Caption = 'Order Source';
    
    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(11; Description; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(101; Memo; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(201; Default; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(4911; "Created by"; Code[50])
        {
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
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
        field(4921; "Modified by"; Code[50])
        {
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(4922; "Modified at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4923; "Modified at Date"; Date)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4924; "Modified at Time"; Time)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Primary; Code)
        {
            Clustered = true;
        }
    }

    trigger OnInsert();
    var
        _time: Time;
    begin
        _time := Time();
        "Created by" := CopyStr(UserId(),1,MaxStrLen("Created by"));
        "Created at Date" := Today();
        "Created at DateTime" := CreateDateTime(Today(),_time);
        "Created at Time" := _time;
    end;

    trigger OnModify();
    var
        _time: Time;
    begin
        _time := Time();
        "Modified by" := CopyStr(UserId(),1,MaxStrLen("Modified by"));
        "Modified at Date" := Today();
        "Modified at DateTime" := CreateDateTime(Today(),_time);
        "Modified at Time" := _time;
    end;

    trigger OnDelete();
    begin
    end;

    trigger OnRename();
    var
        _time: Time;
    begin
        _time := Time();
        "Modified by" := CopyStr(UserId(),1,MaxStrLen("Modified by"));
        "Modified at Date" := Today();
        "Modified at DateTime" := CreateDateTime(Today(),_time);
        "Modified at Time" := _time;
    end;
}
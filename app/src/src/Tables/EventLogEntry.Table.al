table 50072 "ARC Event Log Entry"
{
    DataClassification = CustomerContent;
    Permissions = tabledata 50072 = i;
    Caption = 'Event Log Entry';

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(11; Code; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(21; "Related Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
        }
        field(31; "Related Data Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
        }
        field(501; "Object Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = TableData,Table,Report,Codeunit,XMLport,MenuSuite,Page,Query,System,FieldNumber;
        }
        field(502; "Object ID"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(601; "Notification to be Sent"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(602; "Notification Sent"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(603; "Notification Sent at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(611; "Notification E-Mail Addresses"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(621; "Notification Error Text"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(1001; Status; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ",Success,Error,Message;
        }
        field(1011; "Message Text"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(1021; "Error Text"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(5001; "Created by"; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(5002; "Created at DateTime"; DateTime)
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
        key(Code; Code, "Object Type", "Object ID") { }
        key(Obj; "Object Type", "Object ID") { }
        key(Notification; "Notification to be Sent", "Notification Sent") { }
        key(NotifCode; Code,"Notification to be Sent","Notification Sent") { }
        key(Created; "Created at DateTime") { }
    }

    procedure DeleteEntriesOlderThan(_DateTime: DateTime)
    var
        _EventLogEntry: Record "ARC Event Log Entry";
        _rc: BigInteger;
        _tc: BigInteger;
        _Text000Qst: Label 'This operation may take a while.  Are you sure you want to delete %1 of %2 record(s)?';
    begin
        if _DateTime = 0DT then
            _DateTime := CreateDateTime(CalcDate('-3M',Today()),0T);
        _tc := _EventLogEntry.Count;
        _EventLogEntry.SetCurrentKey("Created at DateTime");
        _EventLogEntry.SetFilter("Created at DateTime", '<%1', _DateTime);
        _rc := _EventLogEntry.Count;
        if GuiAllowed then
            if not Confirm(_Text000Qst, false, _rc, _tc) then
                exit;
        _EventLogEntry.DeleteAll();
    end;

    procedure NewEventLogEntry(
        _Code: Text; 
        _ObjType: Integer; 
        _ObjID: Integer; 
        _Status: Integer; 
        _RelatedEntryNo: BigInteger; 
        _MsgText: Text; 
        _ErrText: Text; 
        _SendNotif: Boolean; 
        _NotifEmail: Text)
    var
        _EventLogEntry: Record "ARC Event Log Entry";
    begin
        _EventLogEntry.Init();
        _EventLogEntry.Code := CopyStr(UpperCase(_Code),1,MaxStrLen(_EventLogEntry.Code));
        _EventLogEntry."Object Type" := _ObjType;
        _EventLogEntry."Object ID" := _ObjID;
        _EventLogEntry.Status := _Status;
        _EventLogEntry."Related Entry No." := _RelatedEntryNo;
        _EventLogEntry."Message Text" := CopyStr(_MsgText,1,MaxStrLen(_EventLogEntry."Message Text"));
        _EventLogEntry."Error Text" := CopyStr(_ErrText,1,MaxStrLen(_EventLogEntry."Error Text"));
        _EventLogEntry."Notification to be Sent" := _SendNotif;
        _EventLogEntry."Notification E-Mail Addresses" := CopyStr(_NotifEmail,1,MaxStrLen(_EventLogEntry."Notification E-Mail Addresses"));
        _EventLogEntry."Created by" := CopyStr(UserId(), 1, MaxStrLen(_EventLogEntry."Created by"));
        _EventLogEntry."Created at DateTime" := CurrentDateTime();
        _EventLogEntry.Insert();
    end;

    trigger OnInsert()
    begin
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
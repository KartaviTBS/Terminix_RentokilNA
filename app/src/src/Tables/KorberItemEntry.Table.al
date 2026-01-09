table 50105 "ARC Korber Item Entry"
{
    // SOW11 Körber Edge WMS Integration

    DataClassification = CustomerContent;
    DrillDownPageId = "ARC Korber Item Entries";
    LookupPageId = "ARC Korber Item Entries";
    Caption = 'Korber Edge WMS Item Entry';
    
    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(21;"Item No.";Code[20])
        {
            Caption = 'Item No.';
        }
        field(91; "Record Action"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(4911; "Created by"; Code[50])
        {
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
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
        field(5001; "Sent to WMS"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5002; "Sent to WMS at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5003; "Sent to WMS No. of Attempts"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5004; "Sent to WMS Duration"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5005; "Sent to WMS Error Text"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5006; "Sent to WMS Data Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK;"Entry No.")
        {
            Clustered = true;
        }
        key(SendToWMS; "Sent to WMS") { }
        key(ItemNo; "Item No.", "Record Action") { }
        key(CreatedAtDateTime; "Created at DateTime") { }
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
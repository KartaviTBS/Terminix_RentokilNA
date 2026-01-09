table 50118 "ARC Korber Import Entry"
{
    // SOW11 Körber Edge WMS Integration

    DataClassification = CustomerContent;
    DrillDownPageId = "ARC Korber Import Entries";
    LookupPageId = "ARC Korber Import Entries";
    Caption = 'Korber Edge WMS Import Entry';
    
    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(11; "File Name"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(12; "File Path"; Code[100])
        {
            DataClassification = CustomerContent;
        }
        field(13; "File Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(14; "File Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(17; "File Size"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(201; "Document Type"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(211; "Action Text"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(221; "Container Batch Reference"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(231; "Date Text"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(251; "Order Number"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(261; "Order Type"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(271; "Purchase Order Number"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(281; Status; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(291; "Time Text"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(301; "Total Shipment Charge"; Decimal)
        {
            DataClassification = CustomerContent;
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
        field(5000; Import; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5001; Imported; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5002; "Imported at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5003; "Imported No. of Attempts"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5004; "Imported Duration"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5005; "Imported Error Text"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5006; "Imported Data Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5010; Process; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5011; Processed; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5012; "Processed at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5013; "Processed No. of Attempts"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5014; "Processed Duration"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5015; "Processed Error Text"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5016; "Processed Data Entry No."; BigInteger)
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
        key(Filename; Imported,"File Name") { }
        key(Import; Import,Imported) { }
        key(Process; Process,Processed) { }
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
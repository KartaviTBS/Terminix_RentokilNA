table 50117 "ARC Cubiscan Entry"
{
    // SOW11 Körber Edge WMS Integration - CO2 Cubiscan Integration

    DataClassification = CustomerContent;
    Caption = 'Cubiscan Entry';
    
    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(21;"Item No.";Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(31; "Unit of Measure Code"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(32; "Base Unit of Measure"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(33; "Selling Unit of Measure"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(51; Description; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(52; "Description 2"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(101; Length; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(102; Width; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(103; Height; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(104; Weight; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(105; Volume; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(121; "Dim. Weight"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(122; "Dim. Unit"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(123; "Wgt. Unit"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(124; "Vol. Unit"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(125; Cubage; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(201; "Site Id"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(301; "Date/Time"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(405; "Optional Info. 5"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(406; "Optional Info. 6"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(407; "Optional Info. 7"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(408; "Optional Info. 8"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(501; "Image File"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(601; Updated; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(4912; "Created at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(4913; "Created at Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(4914; "Created at Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(5000; Import; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(5001; Imported; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(5002; "Imported at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(5003; "Imported No. of Attempts"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(5004; "Imported Duration"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(5005; "Imported Error Text"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(5006; "Imported Data Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
        }
        field(5011; "Import Filename"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(5100; Process; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(5101; Processed; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(5102; "Processed at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(5103; "Processed No. of Attempts"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(5104; "Processed Duration"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(5105; "Processed Error Text"; Text[250])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK;"Entry No.")
        {
            Clustered = true;
        }
        key(Import; Import, Imported) { }
        key(Process; Process, Processed) { }
        key(Item; "Item No.", "Created at DateTime") { }
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
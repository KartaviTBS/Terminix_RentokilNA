table 50043 "ARC APL Review Entry"
{
    DataClassification = ToBeClassified;
    Caption = 'APL Review Entry';
    
    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
            Editable = false;
        }
        field(11; "Document Area"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Sales, Purchases;
            OptionCaption = 'Sales,Purchases';
        }
        field(12; "Document Type"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Document Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Sell-to Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Sell-to Customer Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Sell-to Customer Name 2"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Sell-to Address"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Sell-to Address 2"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Sell-to City"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Sell-to County"; Text[30])
        {
            Caption = 'Sell-to State';
            DataClassification = ToBeClassified;
        }
        field(28; "Sell-to Post Code"; Code[20])
        {
            Caption = 'Sell-to ZIP Code';
            DataClassification = ToBeClassified;
        }
        field(31; "Bill-to Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Bill-to Customer Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(33; "Bill-to Customer Name 2"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(34; "Bill-to Address"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(35; "Bill-to Address 2"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(36; "Bill-to City"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(37; "Bill-to County"; Text[30])
        {
            Caption = 'Bill-to State';
            DataClassification = ToBeClassified;
        }
        field(38; "Bill-to Post Code"; Code[20])
        {
            Caption = 'Bill-to ZIP Code';
            DataClassification = ToBeClassified;
        }
        field(51; "Ship-to Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(52; "Ship-to Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(54; "Ship-to Address"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(55; "Ship-to Address 2"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(56; "Ship-to City"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(57; "Ship-to County"; Text[30])
        {
            Caption = 'Ship-to State';
            DataClassification = ToBeClassified;
        }
        field(58; "Ship-to Post Code"; Code[20])
        {
            Caption = 'Ship-to ZIP Code';
            DataClassification = ToBeClassified;
        }
        field(71; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(72; Description; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(81; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(91; "Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(96; "Line Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(4001; "Created by"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4002; "Created at DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5001; "Reviewed"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5002; "Reviewed at DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5003; "Reviewed by"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5004; "Reviewed Error Text"; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5011; "Notified"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5012; "Notified at DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5014; "Notified Error Text"; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    keys
    {
        key(PK;"Entry No.")
        {
            Clustered = true;
        }
        key(Doc; "Document Area", "Document Type", "Document No.", "Document Line No.", Reviewed)
        {
        }
        key(Reviewed; Reviewed)
        {
        }
        key(Notified; Reviewed, Notified)
        {
        }
    }

    trigger OnInsert();
    begin
        "Created at DateTime" := CurrentDateTime;
        "Created by" := UserId();
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
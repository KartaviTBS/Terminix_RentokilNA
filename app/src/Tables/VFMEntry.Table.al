table 50044 "ARC VFM Entry"
{
    DataClassification = ToBeClassified;
    Caption = 'VFM Entry';
    
    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
            Editable = false;
        }
        field(11; "Item No."; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(12; Description; Text[50])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(Item.Description where ("No." = field("Item No.")));
            Editable = false;
        }
        field(21; "Substitution No."; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Subst. Description"; Text[50])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(Item.Description where ("No." = field("Substitution No.")));
            Editable = false;
        }
        field(31; Ranking; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(41; "Unit of Measure Code"; Text[10])
        {
            DataClassification = ToBeClassified;
        }
        field(51; "Cost per Application"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(61; "Applications per UOM"; Decimal)
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
        field(5001; "NAV Processed"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5002; "NAV Processed at DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5003; "NAV Processed Duration"; Duration)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5004; "NAV Processed Error Text"; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5005; "NAV No. of Attempts"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5011; "NAV Notified"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5012; "NAV Notified at DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5014; "NAV Notified Error Text"; DateTime)
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
        key(Processed; "NAV Processed")
        {
        }
        key(ItemNo; "Item No.")
        {
        }
        key(SubstNo; "Substitution No.")
        {
        }
    }
    
    var
        myInt : Integer;

    trigger OnInsert();
    begin
        "Created by" := UserId;
        "Created at DateTime" := CurrentDateTime;
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
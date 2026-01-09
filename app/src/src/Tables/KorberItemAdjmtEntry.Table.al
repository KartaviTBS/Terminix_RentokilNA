table 50106 "ARC Korber Item Adjmt. Entry"
{
    // SOW11 Körber Edge WMS Integration

    DataClassification = CustomerContent;
    DrillDownPageId = "ARC Korber Item Adjmt. Entries";
    LookupPageId = "ARC Korber Item Adjmt. Entries";
    Caption = 'Korber Edge WMS Item Adjmt. Entry';
    
    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(4; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Purchase,Sale,Positive Adjmt.,Negative Adjmt.,Transfer,Consumption,Output, ,Assembly Consumption,Assembly Output';
            OptionMembers = Purchase,Sale,"Positive Adjmt.","Negative Adjmt.",Transfer,Consumption,Output," ","Assembly Consumption","Assembly Output";
        }
        field(21;"Item No.";Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Item;
            ValidateTableRelation = false;
        }
        field(61; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = Location;
            ValidateTableRelation = false;
        }
        field(66; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(67; "Quantity (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(71; "Item Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code where ("Item No." = field("Item No."));
            ValidateTableRelation = false;
        }
        field(76; "Qty. per Unit of Measure"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(101; "Reason Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
            ValidateTableRelation = false;
        }
        field(901; "Item Ledger Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2001; "WMS Quantity"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(2011; "WMS RowId"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(2021; "WMS Adjustment Date"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(2031; "WMS Bin Location"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(2041; "WMS Operator Name"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(2046; "WMS OrderNum"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(2051; "WMS Product Code"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(2061; "WMS Reason Code"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(2071; "WMS Transaction Code"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(2081; "WMS Warehouse"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(2091; "WMS Zone Code"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(3991; "Import Data Entry No."; BigInteger)
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
        field(4950; Analyze; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4951; Analyzed; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4952; "Analyzed at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4953; "Analyzed No. of Attempts"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4954; "Analyzed Duration"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4955; "Analyzed Error Text"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5000; "Send to WMS"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5006; "Sent to WMS Data Entry No."; BigInteger)
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
    }

    keys
    {
        key(PK;"Entry No.")
        {
            Clustered = true;
        }
        key(Analyze; Analyze,Analyzed) { }
        key(Item; "Item No.","Location Code") { }
        key(CreatedAtDateTime; "Created at DateTime") { }
        key(Process; Processed) { }
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
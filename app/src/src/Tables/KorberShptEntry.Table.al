table 50103 "ARC Korber Shpt. Entry"
{
    // SOW11 Körber Edge WMS Integration

    DataClassification = CustomerContent;
    DrillDownPageId = "ARC Korber Shpt. Entries";
    LookupPageId = "ARC Korber Shpt. Entries";
    Caption = 'Korber Edge WMS Shipment Entry';
    
    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(11;"Document Area";Option)
        {
            DataClassification = CustomerContent;
            OptionCaption = 'Sales,Purchases,Transfers';
            OptionMembers = Sales,Purchases,Transfers;
        }
        field(12;"Document Type";Option)
        {
            DataClassification = CustomerContent;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(13;"Document No.";Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(14;"Document Line No.";Integer)
        {
            DataClassification = CustomerContent;
        }
        field(20;"Sell-to/Buy-from Entity No.";Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(21;"Item No.";Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(26;"Unit of Measure Code";Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code WHERE ("Item No." = field("Item No."));
            ValidateTableRelation = false;
        }
        field(31;Quantity;Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(32;"Qty. per Unit of Measure";Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(33;"Quantity (Base)";Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(41;"Location Code";Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(3001; "Picker ID"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(3011; "Track Trace Number"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(3101; "Ship Via"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(3102; "Shipment Carrier"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(3103; "Shipment Service"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(3104; "Shipment ID"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(3105; "Total Shipment Charge"; Decimal)
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
        field(4956; "Analyzed Data Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5000; "Send to WMS"; Boolean)
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
        field(5100; Process; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5101; Processed; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5102; "Processed at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5103; "Processed No. of Attempts"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5104; "Processed Duration"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5105; "Processed Error Text"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5106; "Processed Data Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5109; "Import Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Import Data Entry No.';
            Editable = false;
        }
    }

    keys
    {
        key(PK;"Entry No.")
        {
            Clustered = true;
        }
        key(Docs; "Document Area","Document Type","Document No.","Document Line No.") { }
        key(Analyze; Analyze,Analyzed) { }
        key(SendToWMS; "Send to WMS","Sent to WMS","Document Area","Document Type","Document No.") { }
        key(Process; Process,Processed,"Import Entry No.") { }
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
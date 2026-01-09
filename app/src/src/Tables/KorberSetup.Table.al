table 50102 "ARC Korber Setup"
{
    // SOW11 Körber Edge WMS Integration

    DataClassification = CustomerContent;
    Caption = 'Korber Edge WMS Setup';
    
    fields
    {
        field(1;Code;Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(41; "Location Priority Active"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(51; "Log Level"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = None,Error,Warning,Normal,Verbose;
        }
        field(61; "Data Retention DateFormula"; DateFormula)
        {
            DataClassification = CustomerContent;
        }
        field(81; "Remove Special Characters"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(82; "Special Characters"; Text[30])
        {
            DataClassification = CustomerContent;
            InitValue = '`~''!$%^&*()=+[]{}\|;:"<>/?';
        }
        field(101;"Process Queue Enabled";Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(111;"Process Queue No. Entries";Integer)
        {
            DataClassification = CustomerContent;
        }
        field(121;"Maximum No. of Attempts";Integer)
        {
            DataClassification = CustomerContent;
        }
        field(401;"Post Shipment";Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(402;"Post Invoice for Outb. Shpts.";Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(411; "Shipment - Incl. Drop Ship"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(421; "Freight Charges Active"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(501;"Post Receipt";Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(502;"Post Invoice for Inb. Rcpts.";Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(601;"Send Shipments";Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(701;"Send Receipts";Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(801;"Send Items";Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(806; "Activate Item Subscribers"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(811; "Send Inventory Snapshot"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(821; "Send Item Adjmts."; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(841; "Item Journal Template"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Template";

            trigger OnValidate()
            begin
                if (Rec."Item Journal Template" <> xRec."Item Journal Template") and (Rec."Item Journal Template" = '') then
                    Clear(Rec."Item Journal Batch");
            end;
        }
        field(842; "Item Journal Batch"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Batch".Name where ("Journal Template Name" = field("Item Journal Template"));
        }
        field(851; "Hazmat Shpt. Method Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Shipment Method";
        }
        field(901; "Outb. Base File Path"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(911; "Inb. Base File Path"; Text[250])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK;Code)
        {
            Clustered = true;
        }
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
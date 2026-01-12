table 50084 "ARC Inventory Balance Entry"
{
    // SOW13 Adobe eCommerce to CSM to NAV 2018

    DataClassification = CustomerContent;
    Caption = 'Inventory Balance Entry';
    
    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(8; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(4901; "Item Ledger Entry No."; Integer)
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
        field(4912; "Created at Date"; Date)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4913; "Created at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4914; "Created at Time"; Time)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4952; "Item Description"; Text[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("Item No.")));
            Editable = false;
        }
        field(4958; "Location Name"; Text[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Location.Name where(Code = field("Location Code")));
            Editable = false;
        }
    }

    keys
    {
        key(PrimaryKey; "Entry No.")
        {
            Clustered = true;
        }
        key(ItemNo; "Item No.","Location Code") { }
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
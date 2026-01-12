table 50083 "ARC eCommerce Entry"
{
    // SOW13 Adobe eCommerce to CSM to NAV 2018

    DataClassification = CustomerContent;
    Caption = 'eCommerce Entry';
    
    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(1001; "eCom Order ID"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(1011; "eCom Customer No."; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(1051; "eCom Your Reference"; Text[35])
        {
            DataClassification = CustomerContent;
        }
        field(1052; "eCom Customer PO No."; Text[35])
        {
            DataClassification = CustomerContent;
        }
        field(1061; "eCom Payment Method Code"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(1151; "eCom Shipment Method Code"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(1161; "eCom Shipping Agent Code"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(1201; "eCom Ship-to Code"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(1211; "eCom Ship-to Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(1212; "eCom Ship-to Name 2"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(1221; "eCom Ship-to Address"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(1222; "eCom Ship-to Address 2"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(1231; "eCom Ship-to City"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(1232; "eCom Ship-to County"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'eCom Ship-to State';
        }
        field(1233; "eCom Ship-to Post Code"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'eCom Ship-to ZIP Code';
        }
        field(1234; "eCom Ship-to Country"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(3001; "eCom Type"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(3002; "eCom No."; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(3011; "eCom Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(3021; "eCom Unit of Measure Code"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(3051; "eCom Unit Price"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(3071; "eCom Line Discount Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(3091; "eCom Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(3092; "eCom Amount Including VAT"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'eCom Amount Including Tax';
        }
        field(3099; "eCom Amount Mismatch"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(3991; "eCom Bypass Price/Promo"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(3999; "eCom Group Count"; Integer)
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
        field(5101; Processed; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5102; "Processed at Date"; Date)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5103; "Processed at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5104; "Processed at Time"; Time)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5105; "Processed Duration"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5106; "Processed No. of Attempts"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5107; "Processed Data Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5109; "Processed Error Text"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6003; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6004; "Document Line No."; Integer)
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
        key(Processed; Processed) { }
        key(OrderID; "eCom Order ID") { }
        key(Customer; "eCom Customer No.", "eCom Ship-to Code") { }
        key(CreatedAtDate; "Created at Date") { }
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
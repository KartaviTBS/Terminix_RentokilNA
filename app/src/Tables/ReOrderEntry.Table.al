table 50041 "ARC ReOrder Entry"
{
    DataClassification = CustomerContent;
    Caption = 'ReOrder Entry';

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(11; "ReOrder ID"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(12; "ReOrder ID Line Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(21; "SellToCustNo"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(22; "BillToCustNo"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(31; "ShipToCode"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(41; "LocationCode"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(101; "ItemNo"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(111; "ItemVariant"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(112; "ItemUnitOfMeasure"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(131; Comment; Text[80])
        {
            DataClassification = CustomerContent;
        }
        field(151; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(161; "UnitPrice"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(171; "RequestedDeliveryDate"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(172;"Shipment Method Code";Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(173;"Memo";Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(4901; "Created at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(4902; "Created by User ID"; Text[50])
        {
            DataClassification = CustomerContent;
            TableRelation = User;
            ValidateTableRelation = false;
        }
        field(5001; "NAV Processed"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5002; "NAV Processed at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5003; "NAV Processed Duration"; Duration)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5004; "NAV Processed Error Text"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5006; "NAV No. of Attempts"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5011; "NAV Sales Order No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5012; "NAV Sales Order Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(ReOrderID; "ReOrder ID", "NAV Processed")
        {
            MaintainSiftIndex = false;
        }
        key(Processed; "NAV Processed", "ReOrder ID")
        {
            MaintainSiftIndex = false;
        }
        key(NavSalesOrder; "NAV Sales Order No.", "NAV Sales Order Line No.") { }
    }

    trigger OnInsert()
    begin
        if "Created at DateTime" = 0DT then
            "Created at DateTime" := CurrentDateTime;
        if "Created by User ID" = '' then
            "Created by User ID" := CopyStr(UserId(),1,MaxStrLen("Created by User ID"));
    end;

    trigger OnModify()
    begin
    end;

    trigger OnDelete()
    begin
    end;

    trigger OnRename()
    begin
    end;
}
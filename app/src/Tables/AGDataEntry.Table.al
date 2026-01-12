table 50002 "ARC AG Data Entry"
{
    Caption = 'AG Data Entry';
    Permissions = TableData "ARC AG Data Entry" = rimd;
    LookupPageId = 50002;
    DrillDownPageId = 50002;

    fields
    {
        field(1; "ARC Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "ARC Manufacturer IC Code "; Text[100])
        {
            Caption = 'Manaufacturer IC Code';
        }
        field(3; "ARC Distributor IC Code"; Text[100])
        {
            Caption = 'Distirbutor IC Code';

        }
        field(4; "ARC Location IC Code"; Text[100])
        {
            Caption = 'Location IC Code';
        }
        field(5; "ARC Location City"; Text[50])
        {
            Caption = 'Location City';
        }
        field(6; "ARC Location State"; Text[50])
        {
            Caption = 'Location State';
        }
        field(7; "ARC Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        field(8; "ARC Customer Address 1"; Text[50])
        {
            Caption = 'Customer Address 1';
        }
        field(9; "ARC Customer Address 2"; Text[50])
        {
            Caption = 'Customer Address 2';
        }
        field(10; "ARC Customer City"; Text[50])
        {
            Caption = 'Customer City';
        }
        field(11; "ARC Customer State"; Text[50])
        {
            Caption = 'Customer State';
        }
        field(12; "ARC Customer Address"; Text[50])
        {
            Caption = 'Customer ZipCode';
        }
        field(13; "ARC Invoice Date"; Date)
        {
            Caption = 'Invoice Date';
        }
        field(14; "ARC Invoice No."; Code[50])
        {
            Caption = 'Invoice No.';
        }
        field(15; "ARC Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            ValidateTableRelation = false;
        }
        field(16; "ARC Item Description"; Text[50])
        {
            Caption = 'Item Description';
        }
        field(17; "ARC Quantity"; Decimal)
        {
            Caption = 'Quantity';
        }
        field(18; "ARC Unit of Measure Code"; Code[50])
        {
            Caption = 'Unit of Measure Code';
        }
        field(19; "ARC Agency"; Boolean)
        {
            Caption = 'Agency';
        }
        field(20; "ARC Sales Type"; Text[50])
        {
            Caption = 'Sales Type';
        }
        field(21; "ARC Return Reason Code"; Text[50])
        {
            Caption = 'Return Reason Code';
        }
        field(22; "ARC Bill To"; Text[50])
        {
            Caption = 'Bill To';
        }
        field(23; "ARC Bill To Name"; Text[50])
        {
            Caption = 'Bill To Name';
        }
        field(24; "ARC Bill To State"; Text[50])
        {
            Caption = 'Bill To State';
        }
        field(25; "ARC Bill To City"; Text[50])
        {
            Caption = 'Bill To City';
        }
        field(26; "ARC Bill To ZipCode"; Text[50])
        {
            Caption = 'Bill To ZipCode';
        }
        field(27; "ARC Unit UOM"; Text[50])
        {
            Caption = 'Unit UOM';
        }
        field(28; "ARC SalesPerson Code"; Code[50])
        {
            Caption = 'SalesPerson Code';
        }
        field(29; "ARC Processed"; Boolean)
        {
            Caption = 'Processed';
        }
        field(30; "ARC Created Date"; Date)
        {
            Caption = 'Created Date';
        }
        field(31; "ARC Created Time"; Time)
        {
            Caption = 'Created Time';
        }
        field(32; "ARC Created By"; Text[100])
        {
            Caption = 'Created By';
        }
        field(33; "ARC Salesperson Name"; Text[50])
        {
            Caption = 'Salesperson Name';
        }
        field(34; "ARC Bill To Address 1"; Text[50])
        {
            Caption = 'Bill To Address 1';
        }
        field(35; "ARC Bill To Address 2"; Text[50])
        {
            Caption = 'Bill To Address 2';
        }
        field(36; "ARC Bill To Unit of Measure"; Text[50])
        {
            Caption = 'Bill to UOM';
        }
        field(37; "ARC Ship To Code"; Code[10])
        {
            Caption = 'Ship To Code';
        }

        field(38; "ARC Ship To Name"; Text[50])
        {
            Caption = 'Ship To Name';
        }
        field(39; "ARC Ship To Address 1"; Text[50])
        {
            Caption = 'Ship To Address 1';
        }
        field(40; "ARC Ship To Address 2"; Text[50])
        {
            Caption = 'Ship To Address 2';
        }

        field(41; "ARC Ship To State"; Text[50])
        {
            Caption = 'Ship To State';
        }
        field(42; "ARC Ship To City"; Text[50])
        {
            Caption = 'Ship To City';
        }
        field(43; "ARC Ship To ZipCode"; Text[50])
        {
            Caption = 'Ship To ZipCode';
        }
        field(44; "ARC Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
        }
        field(45; "ARC Customer Name"; Text[50])
        {
            Caption = 'Customer Name';
        }
    }

    keys
    {
        key(Key1; "ARC Entry No.")
        {
        }
    }
}
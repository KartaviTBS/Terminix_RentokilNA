table 50068 "ARC Import Order Line Errors"
{
    DataClassification = CustomerContent;
    Caption = 'Import Order Line Errors';

    fields
    {
        field(1; "Document Type"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
        }

        field(4; "Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers =  ,"G/L Account",Item,Resource,"Fixed Asset","Charge (Item)"; 
        }
       
        field(5; "No."; Code[20])
        {
            DataClassification = CustomerContent;
        } 

        field(6; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }

        field(7; "Shipment/Exp.Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
        }

        field(8; "Description"; Text[50])
        {
            DataClassification = CustomerContent;
        }

        field(9; "Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Unit Price"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(11; "Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(12; "Line Discount %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(13; "Line Discount Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }

        field(14; "Dim Code1"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(15; "Dim Code2"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(16; "Dim Code3"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(17; "Drop Shipment"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(18; "Purch/Sales Order No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(19; "Purch/Sales Order Line No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(20; "UOM Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(21; "Qty. per Unit of Measure"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(22; "Purchasing Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(23; "Special Order"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(24; "Special Order Purch/Sales No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(25; "Special Order Purch/Sales Line No."; Integer)
        {
            DataClassification = CustomerContent;
        }

        field(26; "Requested Delivery/Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(27; "Promised Delivery/Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(28; "Shipping Time"; DateFormula)
        {
            DataClassification = CustomerContent;
        }
        field(29; "Planned Delivery/Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(30;"Planned Shipment/Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(31; "Minimum Price"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(32; "Lead Time Calculation"; DateFormula)
        {
            DataClassification = CustomerContent;
        } 
        field(33; "Safety Lead Time"; DateFormula)
        {
            DataClassification = CustomerContent;
        }          
        field(34; "Reason Code"; Text[50])
        {
            DataClassification = CustomerContent;
        }          

    }

    keys
    {
        key(PK; "Document Type","Document No.","Line No.")
        {
            Clustered = true;
        }
    }
}
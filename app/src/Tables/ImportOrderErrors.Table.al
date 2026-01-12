table 50067 "ARC Import Order Errors"
{
    DataClassification = CustomerContent;
    Caption = 'Import Order Errors';

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
        field(3; "Customer/Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
        }

        field(4; "Order Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Shipment/Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Posting Description"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(7; "Payment Terms Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(8; "Shipment Method Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(9; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(10; "Dim Code1"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(11; "Dim Code2"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(12; "Dim Code3"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(13; "Salesperson/Purchaser Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(14; "External Document No."; Code[35])
        {
            DataClassification = CustomerContent;
        }
        field(15; "Ship-to Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(16; "Ship-to Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(17; "Ship-to Address"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(18; "Ship-to Address 2"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(19; "Ship-to City"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(20; "Ship-to Contact"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(21; "Ship-to Post Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(22; "Ship-to County"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(23; "Ship-to Country/Region Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(24; "Reason Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(25; "Shipping Agent Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(26; "Shipping Agent Service Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(27; "Requested Delivery/Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(28; "Promised Delivery/Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(29; "E-Ship Agent Service"; Code[30])
        {
            DataClassification = CustomerContent;
        }
        field(30; "Free Freight"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(31;"Locality Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(32; "Business Type Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(33; "Transport Method"; Code[10])
        {
            DataClassification = CustomerContent;
        } 
        field(34; "Payment Method Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(35; "1099 Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }  
        field(36; "Error Reason Code"; Text[50])
        {
            DataClassification = CustomerContent;
        }                           
    }

    keys
    {
        key(PK; "Document Type","Document No.")
        {
            Clustered = true;
        }
    }
}
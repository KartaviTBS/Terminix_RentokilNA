table 50064 "ARC Inventory Journal Errors"
{
    DataClassification = CustomerContent;
    Caption = 'Inventory Journal Errors';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Rem. Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(6; "Standard Cost"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(7; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(8; "Reason Code"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(9; "Bin Code"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(10; "Dim Code1"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(11; "Dim Code2"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(12; "Dim Code3"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(13; "Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(14; "Inv. Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(15; "Agency Item"; Boolean)
        {
            DataClassification = CustomerContent;
        }  
        field(16; "Document Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers =   ,"Sls Shpt","Sls Invc","Sls RetRct","Sls CM","Pur Rct","Pur Inv","Pur RetShpt","Pur CM","Trn Shpt","Trn Rct","Svc Shpt","Svc Inv","Svc CM","Posted Assembly";
        }
        field(17; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(18; "Document Line No."; Integer)
        {
            DataClassification = CustomerContent;
        }  
        field(19; "Purchase Order No."; Code[20])
        {
            DataClassification = CustomerContent;
        }  
        field(20; "Transfer Order No."; Code[20])
        {
            DataClassification = CustomerContent;
        }  
        field(21; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
        }  
        field(22; "Vendor Name"; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(23; "Old Item No."; Code[20])
        {
            DataClassification = CustomerContent;
        }  
        field(24; "Old Item Description"; Code[50])
        {
            DataClassification = CustomerContent;
        }                                                        
        field(25; "Zero cost"; Boolean)
        {
            DataClassification = CustomerContent;
        }       
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key("Reason Code"; "Reason Code")
        {}
        key("Purchase Order No."; "Purchase Order No.")
        {}
  
    }
}
tableextension 50064 "ARC Warehouse Request" extends "Warehouse Request"
{
    fields
    {
        field(50000; "Bill-to Customer Name"; Text[50])
        {
            Caption = 'Bill-to Name';
            Editable = false;
        }
        field(50001; "Ship-to Address"; Text[50])
        {
            Caption = 'Ship-to Address';
            Editable = false;
        }
        field(50002; "Ship-to Address 2"; Text[50])
        {
            Caption = 'Ship-to Address 2';
            Editable = false;
        }
        field(50003; "Ship-to City"; Text[30])
        {
            Caption = 'Ship-to City';
            Editable = false;
        }   
         field(50004; "Ship-to County"; Text[30])
        {
            Caption = 'Ship-to County';
            Editable = false;
        }  
         field(50005; "Ship-to Post Code"; Text[20])
        {
            Caption = 'Ship-to ZIP Code';
            Editable = false;
        }  
        field(50006;"ARC Requested Delivery Date"; Date)
        {
            Caption = 'Requested Delivery Date';
            Editable = false;
        }               
    }   
} 
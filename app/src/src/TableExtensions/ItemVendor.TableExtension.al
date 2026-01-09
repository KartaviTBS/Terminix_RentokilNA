tableextension 50004 "ARC Item Vendor" extends "Item Vendor"
{
    fields
    {
        field(50000; "ARC Manufacturer IC Code"; Text[100])
        {
            Caption = 'Manufacturer IC Code';
        }
        field(50001; "ARC Distributor IC Code"; Text[100])
        {
            Caption = 'Distributor IC Code';
        }
    }
}
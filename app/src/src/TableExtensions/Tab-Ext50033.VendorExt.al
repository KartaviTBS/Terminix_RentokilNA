tableextension 50033 VendorExt extends Vendor
{
    fields
    {
        field(50000; "W9 Name"; Text[50])
        {
            Caption = 'W9 Name';
        }
        field(50001; "Exclude From Remittance"; Boolean)
        {
            Caption = 'Exclude From Remittance';
        }
    }
}

pageextension 50004 "ARC Item Vendor Catalog" extends "Item Vendor Catalog"
{
    layout
    {
        addafter("Vendor Item No.")
        {
            field("ARC Manufacturer IC Code"; "ARC Manufacturer IC Code")
            {
                ApplicationArea = Planning;
                ToolTip = 'Manaufacturer IC Code for AGData';
            }
            field("ARC Distributor IC Code"; "ARC Distributor IC Code")
            {
                ApplicationArea = Planning;
                ToolTip = 'Distributor IC Code for AGData';
            }
        }
    }
}
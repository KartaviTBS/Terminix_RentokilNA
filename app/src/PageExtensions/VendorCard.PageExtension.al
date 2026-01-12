pageextension 50068 "ARC Vendor Card" extends "Vendor Card"
{
    layout
    {
        addafter(Name)
        {
            field("Name 2";"Name 2")
            {
                ApplicationArea = All;
            }
            field("W9 Name";"W9 Name")
            {
                ApplicationArea = all;                
            }
            field("Exclude From Remittance";"Exclude From Remittance")
            {
                ApplicationArea = all;
            }
        }
    }
}
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
        }
    }
}
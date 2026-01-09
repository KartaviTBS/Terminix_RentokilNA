pageextension 50060 "ARC Inventory Setup" extends "Inventory Setup"
{
    layout
    {
        addlast(General)
        {
            field("ARC APL Notification E-Mail";"ARC APL Notification E-Mail")
            {
                ApplicationArea = All;
                Importance = Additional;
            }
            field("ARC Cubiscan Import Path";"ARC Cubiscan Import Path")
            {
                ApplicationArea = All;
                Importance = Additional;
            }
        }
    }

    actions
    {
    }
}
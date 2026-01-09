tableextension 50060 "ARC Inventory Setup" extends "Inventory Setup"
{
    fields
    {
        field(50060; "ARC APL Notification E-Mail"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'APL Notification E-Mail';
        }
        field(50117; "ARC Cubiscan Import Path"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Cubiscan Import Path';
        }
    }
}
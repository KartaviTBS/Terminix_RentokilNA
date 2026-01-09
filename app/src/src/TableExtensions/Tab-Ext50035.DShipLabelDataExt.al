tableextension 50035 DShipLabelDataExt extends "DSHIP Label Data"
{
    fields
    {
        field(50000; "Bill of Lading URL"; Text[250])
        {
            Caption = 'Bill of Lading URL';
            DataClassification = ToBeClassified;
        }
        field(50002; "2Ship Tracking No."; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;          
            Caption = '2Ship Tracking No.';
        }               
    }
}

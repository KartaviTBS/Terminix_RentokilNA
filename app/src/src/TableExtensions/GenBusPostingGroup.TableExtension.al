tableextension 50044 "ARC Gen. Bus. Posting Group" extends "Gen. Business Posting Group"
{
    fields
    {
        field(50000; "ARC Korber Freight"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "No change","Add Freight","Free Freight";
            OptionCaption = 'No change,Add Freight,Free Freight';
            Caption = 'Korber Freight';
        }
        field(50001; "ARC Korber Frgt Max Threshold"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Korber Freight Max. Threshold';
        }
        field(50002; "ARC Korber Frgt Resource No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Resource;
            ValidateTableRelation = false;
            Caption = 'Korber Freight Resource No.';
        }
    }
}
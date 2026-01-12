tableextension 50061 "ARC Vendor Ledger Entry" extends "Vendor Ledger Entry"
{
    fields
    {
        field(50061;"ARC Exported for Financials";Boolean)
        {
            Caption = 'Exported for Financials';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
    
    var
        myInt : Integer;
}
tableextension 50028 "ARC Cust. Ledg Entry" extends "Cust. Ledger Entry"
{
    fields
    {
        field(50002;"ARC WorkWave Entry No.";Integer)
        {
            Caption = 'Workwave Entry No.';
        }
    }
    
    var
        myInt : Integer;
}
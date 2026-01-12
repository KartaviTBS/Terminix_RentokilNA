tableextension 50020 "ARC Gen. Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        field(50001;"ARC Alloc8 Check No.";Code[20])
        {
            Caption = 'Alloc8 Check No.';
        }
        field(50002;"ARC WorkWave Entry No.";Integer)
        {
            Caption = 'Workwave Entry No.';
        }
    }
    var
        myInt : Integer;
}
tableextension 50013 "ARC Contact" extends Contact
{
    fields
    {
        field(60001;"ARC Credit Control";Boolean)
        {
           Caption = 'Credit Control';
        }
        field(60002;"ARC Person Job";Text[50])
        {
            Caption = 'Person Job';
        }
    }
    
    var
        myInt : Integer;
}
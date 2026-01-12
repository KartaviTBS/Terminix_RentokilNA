pageextension 50003 "ARC Item Template Card" extends "Item Template Card"
{
    layout
    {
        addlast(General)
        {
            field("ARC Block Regulatory";"ARC Block Regulatory")
            {
                Importance = Promoted;
                ApplicationArea = Basic,Suite;
                ToolTip = 'Specifies that the related record is blocked for regulatory, for example a customer that is declared insolvent or an item that is placed in quarantine.';

            }
        
        }
    }
}
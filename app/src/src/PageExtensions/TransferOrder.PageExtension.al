pageextension 50002 "ARC Transfer Order" extends "Transfer Order"
{
    layout
    {
        addlast(General)
        {
            field("ARC Created On";"ARC Created On")
            {
                Importance = Promoted;
                ApplicationArea = Location;
                ToolTip = 'ARC Created On';
            }
            field("ARC Created By";"ARC Created By")
            {
                Importance = Promoted;
                ApplicationArea = Location;
                ToolTip = 'ARC Created By';
            }
            
        }
    }

   
}
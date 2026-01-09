pageextension 50035 PostedTransferShipmentExt extends "Posted Transfer Shipment"
{
    layout
    {
        addlast(General)
        {
            group("2Ship Integration")
            {
                Caption = '2Ship';
                Editable = false;
                field("2Ship Label Link"; Rec."2Ship Label Link")
                {
                    ApplicationArea = All;
                }
                field("2Ship BOL Link"; Rec."2Ship BOL Link")
                {
                    ApplicationArea = All;
                }
                field("2Ship Tracking No."; Rec."2Ship Tracking No.")
                {
                    ApplicationArea = All;
                }                            
            }
        }
    }
}

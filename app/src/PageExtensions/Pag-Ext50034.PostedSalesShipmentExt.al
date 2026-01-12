pageextension 50034 PostedSalesShipmentExt extends "Posted Sales Shipment"
{
    layout
    {
        addlast(General)
        {
            field(Priority_Korber;Priority_Korber)
            {
                ApplicationArea = all;
            }
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
    actions
    {
        addafter(Approvals)
        {
            action(DeleteShipment)
            {
                ApplicationArea = All;
                Caption = 'Delete 2Ship Shipment';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;
                
                trigger OnAction()              
                begin
                    Rec.TestField("2Ship Tracking No.");
                    ShipMgt.Submit2ShipCancelRequest(Rec."No.",Rec."2Ship Tracking No.");
                end;
            }
        }
    }
    var
        ShipMgt: Codeunit "2Ship Integration Mgmt.";

}

pageextension 50036 DSHIPPackageWorksheetExt extends "DSHIP Package Worksheet"
{
   actions
   {
        addbefore(acCommInv)
        {
            action(DeleteShipment)
            {
                ApplicationArea = All;
                Caption = 'Delete 2Ship Shipment';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                
                trigger OnAction()    
                var
                    DShipLabelData:Record "DSHIP Label Data";
                    ShipMgt: Codeunit "2Ship Integration Mgmt.";     
                begin
                    Rec.TestField("License Plate No.");
                    DShipLabelData.Reset();
                    DShipLabelData.SetRange("License Plate No.",Rec."License Plate No.");
                    if DShipLabelData.FindFirst() then                    
                        ShipMgt.Submit2ShipCancelRequest(Rec."Document No.",DShipLabelData."2Ship Tracking No.");
                end;
            }
        }
   }
}

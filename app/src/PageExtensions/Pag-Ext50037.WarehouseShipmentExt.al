pageextension 50037 WarehouseShipmentExt extends "Warehouse Shipment"
{
    actions
    {
        addafter("Get Source Documents")
        {
            action("2Ship Get Edit URL")
            {
                ApplicationArea = All;
                Caption = '2Ship Get Edit URL';
                Image = Link;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                
                trigger OnAction();
                var
                    lrecWhseShipLine:Record "Warehouse Shipment Line";
                    SalesHdr:Record "Sales Header";
                    ShipIntMgt:Codeunit "2Ship Integration Mgmt.";
                begin
                    lrecWhseShipLine.SETRANGE("No.", Rec."No.");
                    IF ( lrecWhseShipLine.FINDFIRST ) THEN BEGIN
                        CASE lrecWhseShipLine."Source Document" OF
                            lrecWhseShipLine."Source Document"::"Sales Order":
                                BEGIN                
                                    IF ( SalesHdr.GET(1, lrecWhseShipLine."Source No.") ) THEN
                                        ShipIntMgt.Submit2ShipRateShopRequest(Rec,false);                       
                                END; 
                        end;
                    end;
                    //Rec.Testfield("2Ship Get Edit URL");
                    CurrPage.Update;
                    Hyperlink(SalesHdr."2Ship Get Edit URL");
                end;
            }            
        }
    }
}

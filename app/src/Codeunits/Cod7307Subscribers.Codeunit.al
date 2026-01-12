codeunit 50041 "ARC Codeunit 7307 Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, 7307, 'OnAfterWhseShptLineModify', '', false, false)]
    local procedure OnAfterWhseShptLineModify(WarehouseShipmentLine: Record "Warehouse Shipment Line")

    var
        SalesLine: Record "Sales Line";
    begin
        IF WarehouseShipmentLine."Source Document" = WarehouseShipmentLine."Source Document"::"Sales Order" then begin
            SalesLine.SETRANGE("Document Type",SalesLine."Document Type"::Order);
            SalesLine.SETRANGE("Document No.",WarehouseShipmentLine."Source No.");
            SalesLine.SETRANGE("Type",SalesLine.Type::Resource);
            SalesLine.SETRANGE("Attached to Line No.",WarehouseShipmentLine."Source Line No.");
            SalesLine.SETFILTER("Quantity Shipped",'%1',0);
            IF SalesLine.FINDFIRST then begin
                SalesLine.Pack := True;
                SalesLine.MODIFY(False);
            end;
        end;
    end;
        
}
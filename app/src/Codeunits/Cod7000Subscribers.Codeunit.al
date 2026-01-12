codeunit 50014 "ARC Codeunit 7000 Subscribers"
{
    
    [EventSubscriber(ObjectType::Codeunit, 7000, 'OnAfterFindSalesLinePrice', '', false, false)]
    local procedure OnAfterFindSalesLinePrice(var SalesLine : Record "Sales Line";SalesHeader : Record "Sales Header";
                    SalesPrice : Record "Sales Price";ResourcePrice : Record "Resource Price";CalledByFieldNo : Integer) ;
    var
        PriceManagement: Codeunit "ARC Price Management";
        PromoMgt: Codeunit "ARC Promotion Management";
    begin
        PriceManagement.FindPriceEntry(SalesHeader,SalesLine,CalledByFieldNo,True);
        PromoMgt.ApplyPromotion(SalesHeader,SalesLine,CalledByFieldNo);
    end;
        
}
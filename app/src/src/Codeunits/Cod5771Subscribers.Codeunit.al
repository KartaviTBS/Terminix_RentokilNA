codeunit 50046 "ARC Codeunit 5771 Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, 5771, 'OnBeforeCreateWhseRequest', '', false, false)]
    local procedure OnBeforeCreateWhseRequest(Var WhseRqst: Record "Warehouse Request"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")

    var

    begin
        if WhseRqst."Source Type" = DATABASE::"Sales Line" then begin
            WhseRqst."Bill-to Customer Name" := SalesHeader."Bill-to Name";
            WhseRqst."Ship-to Address" := SalesHeader."Ship-to Address";
            WhseRqst."Ship-to Address 2" := SalesHeader."Ship-to Address 2";
            WhseRqst."Ship-to City" := SalesHeader."Ship-to City";
            WhseRqst."Ship-to County" := SalesHeader."Ship-to County";
            WhseRqst."Ship-to Post Code" := SalesHeader."Ship-to Post Code";
            WhseRqst."ARC Requested Delivery Date" := SalesHeader."Requested Delivery Date";
            WhseRqst."Req. Del. Date" := SalesHeader."Requested Delivery Date";
        end;
    end;
        
}
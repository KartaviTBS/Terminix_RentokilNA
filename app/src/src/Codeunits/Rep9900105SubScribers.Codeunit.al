codeunit 50032 "ARC Rep. 99001015 Subscribers"
{
    trigger OnRun();
    begin
    end;

    [EventSubscriber(ObjectType::Report, 99001015, 'OnBeforeReqWkshLineInsert', '', false, false)]
    local procedure OnBeforeReqWkshLineInsert(RequisitionLine: Record "Requisition Line"; ProdOrderLine: Record "Prod. Order Line")
    begin
        RequisitionLine."ARC Selected" := true;        
    end;
    
    var
        myInt : Integer;
}
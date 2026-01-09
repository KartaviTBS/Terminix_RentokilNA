codeunit 50025 "ARC Codeunit 333 Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, 333, 'OnBeforeCarryOutBatchActionCode', '', false, false)]
    local procedure OOnBeforeCarryOutBatchActionCode(var RequisitionLine : Record "Requisition Line") ;
    begin
        RequisitionLine.SetRange("ARC Selected",true);
    end;
}
codeunit 50039 "ARC Table 18 Subscribers"
{
    [EventSubscriber(ObjectType::Table, 18, 'OnAfterValidateEvent', 'Customer Posting Group', false, false)]
    local procedure OnAfterValidateCustPostingGroup(var Rec: Record Customer; var xRec: Record Customer; CurrFieldNo: Integer);
    var
        APLMgt: Codeunit "ARC APL Management";
        LOBLiftMgt: Codeunit "ARC LOBLiftMgt";
    begin
        APLMgt.OnAfterValidateCustPostGrpOnCustomerAPL(Rec);
        LOBLiftMgt.OnAfterValidateLOBLiftCustPostGrp(Rec,xRec,CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, 18, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsert(var Rec: Record Customer; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        Rec."ARC Created By" := UserId;
        Rec."ARC Created On" := CurrentDateTime;    

    end;

    [EventSubscriber(ObjectType::Table, 18, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModify(var Rec: Record Customer; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        Rec."ARC Modified By" := UserId;
        Rec."ARC Modified On" := CurrentDateTime;    

    end;
}
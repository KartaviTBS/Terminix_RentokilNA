codeunit 50043 "ARC Table 222 Subscribers"
{
    [EventSubscriber(ObjectType::Table, 222, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertEvent(Var Rec: Record "Ship-To Address"; RunTrigger: Boolean)
    var
    Customer: Record Customer;
    begin
        if not RunTrigger then
            exit;   
        if Customer.Get(Rec."Customer No.") then begin
            Rec.Validate("ARC Salesperson Code",Customer."Salesperson Code");
            Rec.Validate("Tax Area Code",Customer."Tax Area Code");
            Rec.Validate("Tax Liable", Customer."Tax Liable");
            Rec.Validate("CCH Exemption Code",Customer."CCH Exemption Code");
        end;
    end;
}

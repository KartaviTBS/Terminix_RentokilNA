codeunit 50037 "ARC Codeunit 414 Subscribers"
{
    trigger OnRun();
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterReleaseSalesDoc', '', false, false)]
    local procedure OnAfterReleaseSalesDoc(SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    var
        _OrderMgt: Codeunit "ARC OrderManagement";
    begin
        _OrderMgt.OnAfterReleaseSalesDoc(SalesHeader,PreviewMode);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterReopenSalesDoc', '', false, false)]
    local procedure OnAfterReopenSalesDoc(SalesHeader: Record "Sales Header")
    var
        LOBLiftMgt: Codeunit "ARC LOBLiftMgt";
    begin
        LOBLiftMgt.OnAfterReopenSalesDoc(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReleaseSalesDocCustom', '', false, false)]
    local procedure OnBeforeReleaseSalesDocCustom(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean)
    var
        _OrderMgt: Codeunit "ARC OrderManagement";
    begin
        SalesHeader.CalcFields("Pending Deletion");
        SalesHeader.TestField("Pending Deletion",false);
        // SOW11 Körber Edge WMS Integration - _OrderMgt.OnBeforeReleaseSalesDocCustom contains PreflightRoutinesBeforeRelease
        _OrderMgt.OnBeforeReleaseSalesDocCustom(SalesHeader,PreviewMode,IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReopenSalesDocCustom', '', false, false)]
    local procedure OnBeforeReopenSalesDocCustom(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    var
        _OrderMgt: Codeunit "ARC OrderManagement";
    begin
        _OrderMgt.OnBeforeReopenSalesDocCustom(SalesHeader,IsHandled);
    end;
}
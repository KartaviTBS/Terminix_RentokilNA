codeunit 50118 "ARC KorberSubscriberMgt"
{
    // SOW11 Körber Edge WMS Integration

    trigger OnRun();
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnAfterReleasePurchaseDoc', '', false, false)]
    local procedure OnAfterReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; LinesWereModified: Boolean)
    var
        _KorberRcptMgt: Codeunit "ARC KorberRcptMgt";
        _KorberShptMgt: Codeunit "ARC KorberShptMgt";
    begin
        _KorberRcptMgt.OnAfterReleasePurchaseDoc(PurchaseHeader,PreviewMode,LinesWereModified);
        _KorberShptMgt.OnAfterReleasePurchDoc(PurchaseHeader,PreviewMode,LinesWereModified);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnBeforeReleasePurchaseDoc', '', false, false)]
    local procedure OnBeforeReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    var
        _KorberRcptMgt: Codeunit "ARC KorberRcptMgt";
    begin
        _KorberRcptMgt.OnBeforeReleasePurchaseDoc(PurchaseHeader,PreviewMode);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterReleaseSalesDoc', '', false, false)]
    local procedure OnAfterReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; LinesWereModified: Boolean)
    var
        _KorberRcptMgt: Codeunit "ARC KorberRcptMgt";
        _KorberShptMgt: Codeunit "ARC KorberShptMgt";
    begin
        _KorberRcptMgt.OnAfterReleaseSalesDoc(SalesHeader,PreviewMode,LinesWereModified);
        _KorberShptMgt.OnAfterReleaseSalesDoc(SalesHeader,PreviewMode,LinesWereModified);
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Release Transfer Document", 'OnAfterReleaseTransferDoc', '', false, false)]
    local procedure OnAfterReleaseTransferDoc(var TransferHeader: Record "Transfer Header")
    var
        _KorberMgt: Codeunit "ARC KorberMgt";
    begin
        _KorberMgt.OnAfterReleaseTransferDoc(TransferHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"ARC Korber Item Entry", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertItemEntry(var Rec: Record "ARC Korber Item Entry"; RunTrigger: Boolean)
    var
        _KorberItemMgt: Codeunit "ARC KorberItemMgt";
    begin
        _KorberItemMgt.OnBeforeInsertItemEntry(Rec,RunTrigger);
    end;

    [EventSubscriber(ObjectType::Table, Database::"ARC Korber Item Adjmt. Entry", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertItemAdjmtEntry(var Rec: Record "ARC Korber Item Adjmt. Entry"; RunTrigger: Boolean)
    var
        _KorberItemMgt: Codeunit "ARC KorberItemAdjmtMgt";
    begin
        _KorberItemMgt.OnBeforeInsertItemAdjmtEntry(Rec,RunTrigger);
    end;

    [EventSubscriber(ObjectType::Table, Database::"ARC Korber Rcpt. Entry", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertRcptEntry(var Rec: Record "ARC Korber Rcpt. Entry"; RunTrigger: Boolean)
    var
        _KorberRcptMgt: Codeunit "ARC KorberRcptMgt";
    begin
        _KorberRcptMgt.OnBeforeInsertRcptEntry(Rec,RunTrigger);
    end;

    [EventSubscriber(ObjectType::Table, Database::"ARC Korber Shpt. Entry", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertShptEntry(var Rec: Record "ARC Korber Shpt. Entry"; RunTrigger: Boolean)
    var
        _KorberShptMgt: Codeunit "ARC KorberShptMgt";
    begin
        _KorberShptMgt.OnBeforeInsertShptEntry(Rec,RunTrigger);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteItemRecord(var Rec: Record Item; RunTrigger: Boolean)
    var
        _KorberItemMgt: Codeunit "ARC KorberItemMgt";
    begin
        _KorberItemMgt.EnqueueItem(Rec,'DELETE');
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertItemRecord(var Rec: Record Item; RunTrigger: Boolean)
    var
        _KorberItemMgt: Codeunit "ARC KorberItemMgt";
    begin
        _KorberItemMgt.EnqueueItem(Rec,'INSERT');
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeModifyEvent', '', true, true)]
    local procedure OnBeforeModifyItemRecord(var Rec: Record Item; RunTrigger: Boolean)
    var
        _KorberItemMgt: Codeunit "ARC KorberItemMgt";
    begin
        _KorberItemMgt.EnqueueItem(Rec,'MODIFY');
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyEvent(var Rec: Record Location; var xRec: Record Location; RunTrigger: Boolean)
    var
        _KorberMgt: Codeunit "ARC KorberMgt";
    begin
        _KorberMgt.OnAfterModifyLocation(Rec,xRec,RunTrigger);
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterValidateEvent', 'ARC Enable Korber WMS', false, false)]
    local procedure OnAfterValidateLocationEnableKorberWMS(var Rec: Record Location; var xRec: Record Location; CurrFieldNo: Integer)
    var
        _KorberMgt: Codeunit "ARC KorberMgt";
    begin
        _KorberMgt.OnAfterValidateLocationEnableKorberWMS(Rec,xRec,CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInitRecord', '', true, true)]
    local procedure OnAfterInitRecord(var SalesHeader: Record "Sales Header")
    var
        _OrderMgt: Codeunit "ARC OrderManagement";
    begin
        _OrderMgt.InitializeOrderSourceForSalesHeader(SalesHeader);
    end;
}
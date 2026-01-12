codeunit 50034 "ARC Table 454 Subscribers"
{
    trigger OnRun();
    begin
    end;

    [EventSubscriber(ObjectType::Table, 454, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertDefaultDim(var Rec: Record "Approval Entry"; RunTrigger: Boolean);
    var
        SalesHeader: Record "Sales Header";
        RecID: RecordId;
        RecRef: RecordRef;
        SalesMgt: Codeunit ARCSalesMgt;

    begin
       If rec.Status = rec.Status::Approved then begin 
            If Rec."Table ID" = Database::"Sales Header" then begin 
                RecID := Rec."Record ID to Approve";
                RecRef := RecID.GetRecord;
                RecRef.SetTable(SalesHeader);
                SalesHeader.Get(SalesHeader."Document Type",SalesHeader."No.");
                If SalesHeader."ARC AR Hold" then begin 
                    SalesMgt.UpdateARHoldStatus(SalesHeader,1);
                    SalesHeader."ARC AR Hold" := false;
                    SalesHeader.Modify;
                end;    
            end;    
       end;
    end;
    
    var
        myInt : Integer;
}
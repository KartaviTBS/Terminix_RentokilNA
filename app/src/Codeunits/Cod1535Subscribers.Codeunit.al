codeunit 50022 "ARC Codeunit 1535 Subscribers"
{
   Permissions = TableData "Approval Entry" = imd,
                  TableData "Approval Comment Line" = imd,
                  TableData "Posted Approval Entry" = imd,
                  TableData "Posted Approval Comment Line" = imd,
                  TableData "Overdue Approval Entry" = imd,
                  TableData "Notification Entry" = imd;

    [EventSubscriber(ObjectType::Codeunit, 1535, 'OnBeforeCreateApprTypeWorkflowUserGroup', '', false, false)]
    procedure OnBeforeCreateApprTypeWorkflowUserGroup(RecRef: RecordRef;var WorkflowStepArgument: Record "Workflow Step Argument");
    var
        SalesHeader: Record "Sales Header";
        Location: Record Location;
    begin
        If RecRef.Number <> Database::"Sales Header" then
            exit;
        RecRef.SetTable(SalesHeader);
        If not SalesHeader."ARC Regulatory Hold" then
            exit;
         
        Location.Get(SalesHeader."Location Code");
        If Location."ARC Regulaotry Workflow Group Code" <> '' then
            WorkflowStepArgument."Workflow User Group Code" := Location."ARC Regulaotry Workflow Group Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, 1535, 'OnApproveApprovalRequestBefore', '', false, false)]
    procedure OnApproveApprovalRequest(var ApprovalEntry: Record "Approval Entry");
    var
        ApprovalEntry2: Record "Approval Entry";
        RNASetup: Record "ARC RNA Setup";
        RecRef: RecordRef;
        RecID: RecordID;
        SalesHeader: Record "Sales Header";
        SalesMgt: Codeunit ARCSalesMgt;
    begin
        RNASetup.Get;
        If RNASetup."Regulatory Workflow Code" = '' then
            exit;
        ApprovalEntry2.Reset;
        ApprovalEntry2.SetRange("Approval Code",ApprovalEntry."Approval Code");
        ApprovalEntry2.SetFilter("Entry No.",'<>%1',ApprovalEntry."Entry No.");
        ApprovalEntry2.SetRange("Document No.",ApprovalEntry."Document No.");
        ApprovalEntry2.SetRange("Table ID",ApprovalEntry."Table ID");
        ApprovalEntry2.SetFilter(Status,'%1|%2',ApprovalEntry2.Status::Created,ApprovalEntry2.Status::Open);
        If ApprovalEntry2.FindSet then 
        repeat
            ApprovalEntry2.VALIDATE(Status,ApprovalEntry2.Status::Approved);
            ApprovalEntry2.Modify(true);
        until ApprovalEntry2.Next = 0;
        If (ApprovalEntry."Table ID" = Database::"Sales Header") AND (ApprovalEntry."Approval Code" <> RNASetup."Regulatory Workflow Code") then begin 
            RecID := ApprovalEntry."Record ID to Approve";
            RecRef := RecID.GetRecord;
            RecRef.SetTable(SalesHeader);
            SalesHeader.Get(SalesHeader."Document Type",SalesHeader."No.");
            If SalesHeader."ARC AR Hold" then begin 
                SalesHeader."ARC AR Hold" := false;
                SalesHeader.Modify;
                SalesMgt.UpdateARHoldStatus(SalesHeader,1);
            end;
        end;
    end;    

    [EventSubscriber(ObjectType::Codeunit, 1535, 'OnAfterRejectApprovalRequest', '', false, false)]
    procedure OnAfterRejectApprovalRequest(var ApprovalEntry: Record "Approval Entry");
    var
        ApprovalEntry2: Record "Approval Entry";
        RNASetup: Record "ARC RNA Setup";
        RecRef: RecordRef;
        RecID: RecordID;
        SalesHeader: Record "Sales Header";
        SalesMgt: Codeunit ARCSalesMgt;
    begin
        RNASetup.Get;
        If RNASetup."Regulatory Workflow Code" = '' then
            exit;
        ApprovalEntry2.Reset;
        ApprovalEntry2.SetRange("Approval Code",ApprovalEntry."Approval Code");
        ApprovalEntry2.SetFilter("Entry No.",'<>%1',ApprovalEntry."Entry No.");
        ApprovalEntry2.SetRange("Document No.",ApprovalEntry."Document No.");
        ApprovalEntry2.SetRange("Table ID",ApprovalEntry."Table ID");
        ApprovalEntry2.SetFilter(Status,'%1|%2',ApprovalEntry2.Status::Created,ApprovalEntry2.Status::Open);
        If ApprovalEntry2.FindSet then 
        repeat
            ApprovalEntry2.VALIDATE(Status,ApprovalEntry2.Status::Rejected);
            ApprovalEntry2.Modify(true);
        until ApprovalEntry2.Next = 0;
        If ApprovalEntry."Table ID" = Database::"Sales Header" then begin 
            RecID := ApprovalEntry."Record ID to Approve";
            RecRef := RecID.GetRecord;
            RecRef.SetTable(SalesHeader);
            SalesHeader.Get(SalesHeader."Document Type",SalesHeader."No.");
            If SalesHeader."ARC AR Hold" then begin 
                SalesMgt.UpdateARHoldStatus(SalesHeader,2);
                SalesMgt.CheckCustCrLimitBalanceDue(SalesHeader);
            end;
        end;
       

    end;

}
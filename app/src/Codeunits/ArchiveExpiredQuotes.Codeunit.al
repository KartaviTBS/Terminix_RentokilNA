codeunit 50013 "ARC Archive Expired Quotes"
{
    var
       JobQueueEntryDescTxt: Label 'Auto-created to archive expired sales quotes';

    trigger OnRun();
    begin
        ArchiveQuotes();
    end;

    local procedure ArchiveQuotes();
    var
        SalesHeader: Record "Sales Header";
        ArchiveManagement: Codeunit ArchiveManagement;
    begin
        SalesHeader.Reset;
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        if SalesHeader.FindSet() then
            repeat
                if SalesHeader."ARC Expiration Date" < WorkDate then begin
                   ArchiveManagement.ArchSalesDocumentNoConfirm(SalesHeader);
                   SalesHeader.SetHideValidationDialog(true);
                   SalesHeader.Delete(true);
                end;   
            until SalesHeader.Next = 0;
    end;

    procedure SetupArchiveQuotes();
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "Job Queue Management";
    begin
        
        JobQueueEntry.Reset;
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"ARC Archive Expired Quotes");
        if not JobQueueEntry.IsEmpty then
            exit;
        JobQueueEntry."No. of Minutes between Runs" := 1440;
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := CODEUNIT::"ARC Export OnGuard Data";
        JobQueueEntry."Earliest Start Date/Time" := CreateDateTime(Today, 200000T);
        JobQueueEntry.Description := CopyStr(JobQueueEntryDescTxt, 1, MaxStrLen(JobQueueEntry.Description));
        JobQueueManagement.CreateJobQueueEntry(JobQueueEntry);

    end;

}
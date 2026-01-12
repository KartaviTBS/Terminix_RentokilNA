codeunit 50009 "ARC Set up OnGuard Register"
{


    trigger OnRun();
    begin
        if CONFIRM('This action will delete all transaction registers and set up a beginning register!' +
                   ' Please make sure you are in the correct company! \' + 'Continue (Y/N)?', FALSE) then begin

            ResetRegister;

            MESSAGE('Register(s) have been created.');
        end;
    end;

    procedure SetupOnGuard();
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "Job Queue Management";
    begin
        if not OnGuardSetup.Get then begin
            OnGuardSetup.Init;
            OnGuardSetup.Insert;
        end;
        JobQueueEntry.Reset;
        JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"ARC Export OnGuard Data");
        if not JobQueueEntry.IsEmpty then
            exit;
        JobQueueEntry."No. of Minutes between Runs" := 1440;
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := CODEUNIT::"ARC Export OnGuard Data";
        JobQueueEntry."Earliest Start Date/Time" := CreateDateTime(Today, 200000T);
        JobQueueEntry.Description := CopyStr(JobQueueEntryDescTxt, 1, MaxStrLen(JobQueueEntry.Description));
        JobQueueManagement.CreateJobQueueEntry(JobQueueEntry);
        ResetRegister;

    end;

    local procedure ResetRegister();
    begin
        If not DetCustLedgEntry.FINDLAST then
            exit;

        OnGuardTrans.DELETEALL;

        OnGuardTrans.INIT;
        OnGuardTrans."Entry No." := 1;
        OnGuardTrans."Export Date" := TODAY;
        OnGuardTrans."Export Time" := TIME;
        OnGuardTrans."No. of Transactions" := 0;
        OnGuardTrans."From Entry No." := 0;
        OnGuardTrans."To Entry No." := 0;
        OnGuardTrans.INSERT;

        OnGuardSetup.GET;
        OnGuardSetup."Last Sequence No." := 1;
        OnGuardSetup.MODIFY;
    end;

    var
        OnGuardTrans: Record "ARC OnGuard Trans. Register";
        DetCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        OnGuardSetup: Record "ARC OnGuard Setup";
        JobQueueEntryDescTxt: Label 'Auto-created for exporting OnGuard Data';
}


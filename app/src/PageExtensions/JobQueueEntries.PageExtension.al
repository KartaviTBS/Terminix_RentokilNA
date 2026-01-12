pageextension 50084 "ARC Job Queue Entries" extends "Job Queue Entries"
{
    layout
    {
    }

    actions
    {
        addlast("Job &Queue")
        {
            action(ResetUser)
            {
                ApplicationArea = All;
                Image = User;
                Caption = 'Reset User';
                ToolTip = 'Restore credential specified in General Ledger Setup';

                trigger OnAction()
                var
                    _GeneralLedgerSetup: Record "General Ledger Setup";
                begin
                    _GeneralLedgerSetup.Get();
                    _GeneralLedgerSetup.TestField("ARC Job Queue Credential");
                    Rec."User ID" := CopyStr(_GeneralLedgerSetup."ARC Job Queue Credential",1,MaxStrLen(Rec."User ID"));
                    Rec.Modify();
                end;
            }
        }
    }
}
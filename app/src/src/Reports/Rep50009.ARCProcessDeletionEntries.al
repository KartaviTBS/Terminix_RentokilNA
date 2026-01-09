report 50009 "ARC Process Deletion Entries"
{
    ProcessingOnly = true;
    Caption = 'Process Deletion Entries';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem("ARC Deletion Entry"; "ARC Deletion Entry")
        {
            RequestFilterFields = "Document No.";
            trigger OnPreDataItem()
            begin
                SetRange(Deleted, false);
            end;

            trigger OnAfterGetRecord()
            var
                SalesHeader: Record "Sales Header";
            begin
                SalesHeader.LockTable(true);
                SalesHeader.SetHideValidationDialog(true);
                if SalesHeader.Get(SalesHeader."Document Type"::Order, "Document No.") then begin
                    SalesHeader.Delete(true);
                    Deleted := true;
                    Modify();
                end;
            end;
        }
    }
}

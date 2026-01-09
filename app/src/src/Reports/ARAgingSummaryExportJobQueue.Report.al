report 50032 "ARC AR Aging Summary Job Queue"
{
    Caption = 'AR Aging Summary Job Queue';
    ProcessingOnly = true;
    UsageCategory = Lists;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = SORTING (Number) WHERE (Number = CONST (1));
        }
    }
    
        trigger OnPreReport()
        var
            InputDate: Date;
            Day: Integer;
            DimValue: Record "Dimension Value";
            CustLedgEntry: Record "Cust. Ledger Entry";
            RNASetup: Record "ARC RNA Setup";               
            ARAgingSumExport: Report "ARC AR Aging Summary Export";           
        begin
            RNASetup.GET;
            InputDate := WORKDATE;
            Day := DATE2DMY(InputDate,1);
            IF RNASetup."AR Summary Export Day of Month" <> Day THEN 
                EXIT; 
            ARAgingSumExport.RunFromJobQ(true);
            ARAgingSumExport.SetAsofDate(CALCDATE('CM-1M+CM',WORKDATE)); //Last day of prior month based on Workdate
            ARAgingSumExport.SetExportFilePath(RNASetup."AR Summary Export File");
            DimValue.Reset;
            CustLedgEntry.Reset;
            ARAgingSumExport.SetTableView(DimValue);
            ARAgingSumExport.SetTableView(CustLedgEntry);
            ARAgingSumExport.UseRequestPage(false);
            ARAgingSumExport.RUN;
        end;
    
}
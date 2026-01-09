report 50061 "ARC AP Sweep Export"
{
    Caption = 'AP Sweep Export';
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
            APSweepExport: Codeunit "ARC Export AP Sweep Data";
        begin
            APSweepExport.RUN;
        end;
    
}
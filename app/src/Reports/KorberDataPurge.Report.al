report 50518 "ARC Korber Data Purge"
{
    // SOW11 Körber Edge WMS Integration

    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    UseRequestPage = false;
    ProcessingOnly = true;
    Permissions = tabledata "ARC Data Entry" = rd,
                  tabledata "ARC eCommerce Entry" = rd,
                  tabledata "ARC Event Log Entry" = rd,
                  tabledata "ARC Korber Import Entry" = rd,
                  tabledata "ARC Korber Item Entry" = rd,
                  tabledata "ARC Korber Item Adjmt. Entry" = rd,
                  tabledata "ARC Korber Rcpt. Entry" = rd,
                  tabledata "ARC Korber Shpt. Entry" = rd,
                  tabledata "ARC Order Translation Entry" = rd;
    Caption = 'Korber WMS Data Purge';

    dataset
    {
        dataitem(Integer;Integer)
        {
            DataItemTableView = sorting(Number) where (Number = const(1));

            trigger OnAfterGetRecord()
            var
                _DataEntry: Record "ARC Data Entry";
                eCommerceEntry: Record "ARC eCommerce Entry";
                _EventLogEntry: Record "ARC Event Log Entry";
                _KorberImportEntry: Record "ARC Korber Import Entry";
                _KorberItemEntry: Record "ARC Korber Item Entry";
                _KorberItemAdjmtEntry: Record "ARC Korber Item Adjmt. Entry";
                _KorberRcptEntry: Record "ARC Korber Rcpt. Entry";
                _KorberSetup: Record "ARC Korber Setup";
                _KorberShptEntry: Record "ARC Korber Shpt. Entry";
                _OrderTranslationEntry: Record "ARC Order Translation Entry";
                _KorberMgt: Codeunit "ARC KorberMgt";
                _dateRetain: Date;
                _dateTimeRetain: DateTime;
                _Text000Msg: Label 'Data retention calcformula %1 starts %2';
            begin
                _KorberSetup.Get();
                _KorberSetup.TestField("Data Retention DateFormula");
                _dateRetain := CalcDate('-' + Format(_KorberSetup."Data Retention DateFormula") + '-1D',Today());
                _dateTimeRetain := CreateDateTime(_dateRetain,235959T);
                _KorberMgt.WriteLog(_KorberSetup."Log Level"::Verbose,Report::"ARC Korber Data Purge",'PURGE',0,0,
                    StrSubstNo(_Text000Msg,_KorberSetup."Data Retention DateFormula",_dateRetain),'');
                _DataEntry.SetCurrentKey("Created at DateTime");
                _DataEntry.SetRange("Created at DateTime",0DT,_dateTimeRetain);
                _DataEntry.DeleteAll();
                Commit();
                _EventLogEntry.SetCurrentKey("Created at DateTime");
                _EventLogEntry.SetRange("Created at DateTime",0DT,_dateTimeRetain);
                _EventLogEntry.DeleteAll();
                Commit();
                _KorberImportEntry.SetCurrentKey("Created at DateTime");
                _KorberImportEntry.SetRange("Created at DateTime",0DT,_dateTimeRetain);
                _KorberImportEntry.DeleteAll();
                Commit();
                _KorberItemEntry.SetCurrentKey("Created at DateTime");
                _KorberItemEntry.SetRange("Created at DateTime",0DT,_dateTimeRetain);
                _KorberItemEntry.DeleteAll();
                Commit();
                _KorberItemAdjmtEntry.SetCurrentKey("Created at DateTime");
                _KorberItemAdjmtEntry.SetRange("Created at DateTime",0DT,_dateTimeRetain);
                _KorberItemAdjmtEntry.DeleteAll();
                Commit();
                _KorberRcptEntry.SetCurrentKey("Created at DateTime");
                _KorberRcptEntry.SetRange("Created at DateTime",0DT,_dateTimeRetain);
                _KorberRcptEntry.DeleteAll();
                Commit();
                _KorberShptEntry.SetCurrentKey("Created at DateTime");
                _KorberShptEntry.SetRange("Created at DateTime",0DT,_dateTimeRetain);
                _KorberShptEntry.DeleteAll();
                Commit();
                _OrderTranslationEntry.SetCurrentKey("Created at DateTime");
                _OrderTranslationEntry.SetRange("Created at DateTime",0DT,_dateTimeRetain);
                _OrderTranslationEntry.DeleteAll();
                Commit();
                eCommerceEntry.SetCurrentKey("Created at DateTime");
                eCommerceEntry.SetRange("Created at DateTime",0DT,_dateTimeRetain);
                eCommerceEntry.DeleteAll();
            end;
        }
    }
}
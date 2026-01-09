codeunit 50031 "ARC ReOrder WebServices"
{
    
    procedure ProcessReOrder(ReOrderNo: Text[50]): Integer;
    var
        ReOrderEntry: Record "ARC ReOrder Entry";
        ReOrderEntry2: Record "ARC ReOrder Entry";
        SalesCommentLine: Record "Sales Comment Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ReOrderMgt: Codeunit "ARC ReOrderMgt";
        errorText: Text;
        NavSalesOrderNo: Code[20];
        LineNo: Integer;
        NavSalesOrderLineNo: Integer;
        TimeEnd: Time;
        TimeBegin: Time;
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        if ReOrderNo = '' then
            exit(-1);
        Commit();    
        TimeBegin := Time();
        Clear(ReOrderMgt); 
        ReOrderEntry.SetCurrentKey("ReOrder ID");
        ReOrderEntry.SetRange("ReOrder ID", ReOrderNo);
        ReOrderEntry.SetRange("NAV Processed", 0);
        if ReOrderEntry.FindFirst then begin 
            ReOrderMgt.SetEntryNoToProcess(ReOrderEntry."Entry No.");
            if not ReOrderMgt.Run then begin 
                TimeEnd := Time();
                errorText := CopyStr(GetLastErrorText, 1, MaxStrLen(errorText));
                Clear(ReOrderEntry2);
                ReOrderEntry2.SetCurrentKey("ReOrder ID");
                ReOrderEntry2.SetRange("ReOrder ID", ReOrderEntry."ReOrder ID");
                ReOrderEntry2.SetRange("NAV Processed", 0);
                ReOrderEntry2.ModifyAll("NAV Processed at DateTime", CurrentDateTime);
                ReOrderEntry2.ModifyAll("NAV Processed Duration", TimeEnd - TimeBegin);
                ReOrderEntry2.ModifyAll("NAV Processed Error Text", CopyStr(errorText, 1, MaxStrLen(ReOrderEntry2."NAV Processed Error Text")));
                ReOrderEntry2.ModifyAll("NAV Processed", -1);
                Commit();
                exit(-1);
            end else 
                exit(0);
        end else
            exit(-1)  
    end;

    local procedure TrimReOrderRec(var ReOrderEntry: Record "ARC ReOrder Entry")
    begin
        ReOrderEntry."ReOrder ID" := ReOrderEntry."ReOrder ID".Trim();
        ReOrderEntry.SellToCustNo := ReOrderEntry.SellToCustNo.Trim();
        ReOrderEntry.BillToCustNo := ReOrderEntry.BillToCustNo.Trim();
        ReOrderEntry.ShipToCode := ReOrderEntry.ShipToCode.Trim();
        ReOrderEntry.LocationCode := ReOrderEntry.LocationCode.Trim();
        ReOrderEntry.ItemNo := ReOrderEntry.ItemNo.Trim();
        ReOrderEntry.ItemVariant := ReOrderEntry.ItemVariant.Trim();
        ReOrderEntry.ItemUnitOfMeasure := ReOrderEntry.ItemUnitOfMeasure.Trim();
        ReOrderEntry.Comment := ReOrderEntry.Comment.Trim();
    end;
}
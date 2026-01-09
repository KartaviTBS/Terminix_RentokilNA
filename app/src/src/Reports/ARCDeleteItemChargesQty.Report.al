Report 50071 "ARC Delete Item Charges Qty."
{
    Caption = 'Delete Orphaned Item Charge PO Lines';
    ProcessingOnly = true;
    UsageCategory =  Administration;

    trigger OnPostReport()
    var
        PurchLine: Record "Purchase Line";
    begin
        if not Confirm('Are you sure you want to remove orphaned Item Charge lines from Purchase Order?') then
            CurrReport.Quit;

        PurchLine.RESET();
        PurchLine.SetRange("Document Type",PurchLine."Document Type"::Order);
        PurchLine.SetRange(Type,PurchLine.Type::"Charge (Item)");
        PurchLine.SetFilter(Quantity,'>%1',0);
        PurchLine.SetFilter("Qty. Assigned",'=%1',0);
        PurchLine.SetFilter("Quantity Received",'>%1',0);
        PurchLine.SetFilter("Quantity Invoiced",'>%1',0);
        IF PurchLine.FindSet then
            repeat
                if PurchLine."Quantity Received" = PurchLine."Quantity Invoiced" then
                    PurchLine.Delete;
            until PurchLine.Next = 0;

        Message('Report processed successfully.');
    end;
}
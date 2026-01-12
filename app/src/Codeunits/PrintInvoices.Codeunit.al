codeunit 50047 "ARC Print Invoces"
{

    trigger onrun();
    begin
        printinvoices();
    end;


    local procedure printinvoices();
    var
        salesinvheader: record "sales invoice header";
        rnasetup: record "arc rna setup";
    begin
        rnasetup.get;
        invcount := 0;
        TotalInvoices := 0;
        BatchNo := 0;
        salesinvheader.Reset;
        salesinvheader.ClearMarks;
        if rnasetup."Test Posting Date" = 0D then
            salesinvheader.setrange("posting date", CalcDate('<-1D>', Today))
        else
            salesinvheader.setrange("posting date", rnasetup."Test Posting Date");
        salesinvheader.setrange("customer posting group", 'EXTERNAL');
        if salesinvheader.findset then
            repeat
                if invcount >= rnasetup."no. of invoice per batch" then begin
                    printreport(salesinvheader);
                    TotalInvoices += invcount;
                    invcount := 0;

                end;
                if validatefilters(salesinvheader) then begin
                    if StartInvoiceNo = '' then
                        StartInvoiceNo := salesinvheader."No.";
                    salesinvheader.mark(true);
                    invcount += 1;
                end;
            until salesinvheader.next = 0;
        LastInvoiceNo := salesinvheader."No.";
        TotalInvoices += invcount;
        if invcount > 0 then
            printreport(salesinvheader);
        CreateInvoiceEntry();

    end;

    local procedure printreport(var salesinvheader: record "sales invoice header");
    var
        rnasetup: record "arc rna setup";
        destinationfilepath: text;
    begin
        rnasetup.get;
        BatchNo += 1;
        destinationfilepath := delchr(rnasetup."ddc invoice file path", '>', '\');
        destinationfilepath += '\';
        salesinvheader.markedonly(true);
        if rnasetup."Invoice Report File Name" <> '' then
            destinationfilepath += rnasetup."Invoice Report File Name" + format(currentdatetime, 0, '<Month,2> <Day,2> <Year>') + 'v' + format(BatchNo) + '#' + format(invcount) + '.pdf'
        else
            destinationfilepath += 'TargetUSA' + format(currentdatetime, 0, '<Month,2> <Day,2> <Year>') + 'v' + format(BatchNo) + '#' + format(invcount) + '.pdf';
        if rnasetup."Invoice Report ID" <> 0 then
            report.saveaspdf(rnasetup."Invoice Report ID", destinationfilepath, salesinvheader)
        else
            report.saveaspdf(50060, destinationfilepath, salesinvheader);
        salesinvheader.MarkedOnly(false);
        salesinvheader.clearmarks;
        //TargetUSAMM.DD.YYv(batch number)#(number of invoices)

    end;

    local procedure validatefilters(salesinvheader: record "sales invoice header"): boolean
    var
        customer: record customer;
    begin
        customer.get(salesinvheader."sell-to customer no.");
        if StrPos(customer."Document Sending Profile", 'PRINT') = 0 then
            exit(false);

        if customer."Customer Posting Group" <> 'EXTERNAL' then
            exit(false);
        if calcbalancedue(salesinvheader) = 0 then
            exit(false);

        exit(true);
    end;

    local procedure calcbalancedue(salesinvheader: record "sales invoice header"): decimal
    var
        custledgentry: record "cust. ledger entry";
        detailedcustledgentry: record "detailed cust. ledg. entry";
        amt: decimal;
        balancedue: decimal;
    begin
        custledgentry.setcurrentkey("document type", "customer no.", "posting date", "currency code");
        custledgentry.setrange("document type", custledgentry."document type"::invoice);
        custledgentry.setrange("customer no.", salesinvheader."bill-to customer no.");
        custledgentry.setrange("document no.", salesinvheader."no.");
        if custledgentry.findset then
            repeat
                detailedcustledgentry.setrange(detailedcustledgentry."cust. ledger entry no.", custledgentry."entry no.");
                detailedcustledgentry.setrange("entry type", detailedcustledgentry."entry type"::application);
                if detailedcustledgentry.findset then
                    repeat
                        amt += -detailedcustledgentry."amount (lcy)";
                    until detailedcustledgentry.next = 0;
            until custledgentry.next = 0;

        salesinvheader.calcfields("amount including vat");

        balancedue := salesinvheader."amount including vat" - amt;
        exit(balancedue);
    end;

    local procedure CreateInvoiceEntry();
    var
        InvoicePrintLogEntry: Record "ARC Invoice Print Log Entry";
    begin
        With InvoicePrintLogEntry do begin
            Init;
            "Entry No." := 0;
            "No. of Invoices" := TotalInvoices;
            "Starting Invoice No." := StartInvoiceNo;
            "Last Invoice No." := LastInvoiceNo;
            "Created User" := UserId;
            "Created On" := CurrentDateTime;
            Insert(true);
        end;

    end;

    var
        TotalInvoices: integer;
        StartInvoiceNo: Code[20];
        LastInvoiceNo: Code[20];
        BatchNo: Integer;
        invcount: integer;
}
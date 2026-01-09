codeunit 50033 "ARC Print Credit Memos"
{

    trigger onrun();
    begin
        PrintCrMemos();
    end;


    local procedure PrintCrMemos();
    var
        SalesCrMemoHeader: record "Sales Cr.Memo Header";
        rnasetup: record "arc rna setup";        
    begin
        rnasetup.get;
        invcount := 0;
        TotalInvoices := 0;
        BatchNo := 0;
        SalesCrMemoHeader.Reset;
        SalesCrMemoHeader.ClearMarks;
        if rnasetup."Test Posting Date" = 0D then 
            SalesCrMemoHeader.setrange("posting date", CalcDate('<-1D>', Today))
        else 
            SalesCrMemoHeader.setrange("posting date", rnasetup."Test Posting Date");
        SalesCrMemoHeader.setrange("customer posting group", 'EXTERNAL');
        if SalesCrMemoHeader.findset then
            repeat
                if invcount >= rnasetup."no. of invoice per batch" then begin 
                    printreport(SalesCrMemoHeader);
                    TotalInvoices += invcount;
                    invcount := 0;

                end;    
                if validatefilters(SalesCrMemoHeader) then begin
                    if StartInvoiceNo = '' then 
                        StartInvoiceNo := SalesCrMemoHeader."No.";
                    SalesCrMemoHeader.mark(true);
                    invcount += 1;
                end;
            until SalesCrMemoHeader.next = 0;
        LastInvoiceNo := SalesCrMemoHeader."No.";
        TotalInvoices += invcount;
        if invcount > 0 then 
            printreport(SalesCrMemoHeader);
        CreateInvoiceEntry();
        
    end;

    local procedure printreport(var SalesCrMemoHeader: record "Sales Cr.Memo Header");
    var
        rnasetup: record "arc rna setup";
        destinationfilepath: text;
    begin
        rnasetup.get;
        BatchNo += 1;
        destinationfilepath := delchr(rnasetup."DDC CrMemo File Path", '>', '\');
        destinationfilepath += '\';
        SalesCrMemoHeader.markedonly(true);
        destinationfilepath += 'TargetUSA' + format(currentdatetime, 0, '<Month,2> <Day,2> <Year>')  + 'v' + format(BatchNo) + '#' + format(invcount) + '.pdf';
        report.saveaspdf(50022, destinationfilepath, SalesCrMemoHeader);
        SalesCrMemoHeader.MarkedOnly(false);
        SalesCrMemoHeader.clearmarks;
        //TargetUSAMM.DD.YYv(batch number)#(number of invoices)

    end;

    local procedure validatefilters(SalesCrMemoHeader: record "Sales Cr.Memo Header"): boolean
    var
        customer: record customer;
    begin
        customer.get(SalesCrMemoHeader."sell-to customer no.");
        if StrPos(customer."Document Sending Profile",'PRINT') = 0 then
            exit(false);
        if customer."Customer Posting Group"  <> 'EXTERNAL' then
            exit(false);
        if calcbalancedue(SalesCrMemoHeader) = 0 then
            exit(false);

        exit(true);
    end;

    local procedure calcbalancedue(SalesCrMemoHeader: record "Sales Cr.Memo Header"): decimal
    var
        custledgentry: record "cust. ledger entry";
        detailedcustledgentry: record "detailed cust. ledg. entry";
        amt: decimal;
        balancedue: decimal;
    begin
        custledgentry.setcurrentkey("document type", "customer no.", "posting date", "currency code");
        custledgentry.setrange("document type", custledgentry."document type"::"Credit Memo");
        custledgentry.setrange("customer no.", SalesCrMemoHeader."bill-to customer no.");
        custledgentry.setrange("document no.", SalesCrMemoHeader."no.");
        if custledgentry.findset then
            repeat
            detailedcustledgentry.setrange(detailedcustledgentry."cust. ledger entry no.", custledgentry."entry no.");
            detailedcustledgentry.setrange("entry type", detailedcustledgentry."entry type"::application);
            if detailedcustledgentry.findset then
                repeat
                amt += -detailedcustledgentry."amount (lcy)";
                until detailedcustledgentry.next = 0;
            until custledgentry.next = 0;

        SalesCrMemoHeader.calcfields("amount including vat");

        balancedue := SalesCrMemoHeader."amount including vat" - amt;
        exit(balancedue);
    end;

    local procedure CreateInvoiceEntry();
    var
        InvoicePrintLogEntry : Record "ARC Invoice Print Log Entry";
    begin
        With InvoicePrintLogEntry do begin 
            Init;
            "Entry No." := 0;
            Type := Type::"Cr. Memo";
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
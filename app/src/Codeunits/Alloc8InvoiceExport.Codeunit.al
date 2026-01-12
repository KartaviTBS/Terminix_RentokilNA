codeunit 50011 "ARC Alloc8 Invoice Export"
{
    trigger OnRun();
    begin
        Intialize;
        ExportInvoices;
    end;

    procedure ExportInvoices();
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
        OutputFile: File;
        FileName: Text;
        OStream: OutStream;
        Addr3: Text;
        TransDate: Text;
        StmtTransType: Text;
        InvDueDate: Text;
        NoOfTrans: Integer;
    begin
        CompanyInformation.Get;
        CustLedgEntry.Reset;
        CustLedgEntry.SetFilter("Document Type", '%1|%2|%3|%4',
                      CustLedgEntry."Document Type"::Invoice,
                      CustLedgEntry."Document Type"::"Credit Memo",
                      CustLedgEntry."Document Type"::Payment,
                      CustLedgEntry."Document Type"::"Finance Charge Memo");
        CustLedgEntry.SetRange(Open, true);
        OutputFile.WriteMode(true);
        FileName := Alloc8Setup."Invoice File Export Path" + 'Invoices-' + Format(Today, 0, '<Day,2><Month,2><Year4>') + '.txt';
        OutputFile.Create(FileName);
        OutputFile.CreateOutStream(OStream);
        if CustLedgEntry.findset then begin
            repeat
                CustLedgEntry.CalcFields("Remaining Amount");
                
                if CustLedgEntry."Document Date" <> 0D then
                    TransDate := ConvertStr(Format(Date2DMY(CustLedgEntry."Document Date", 2), 2), ' ', '0') + '/' +
                                ConvertStr(Format(Date2DMY(CustLedgEntry."Document Date", 1), 2), ' ', '0') + '/' +
                                COPYSTR(Format(Date2DMY(CustLedgEntry."Document Date", 3)), 3, 2);

                if CustLedgEntry."Due Date" <> 0D then
                    InvDueDate := ConvertStr(Format(Date2DMY(CustLedgEntry."Due Date", 2), 2), ' ', '0') + '/' +
                                ConvertStr(Format(Date2DMY(CustLedgEntry."Due Date", 1), 2), ' ', '0') + '/' +
                                COPYSTR(Format(Date2DMY(CustLedgEntry."Due Date", 3)), 3, 2);
                Case CustLedgEntry."Document Type" of
                    CustLedgEntry."Document Type"::Invoice: StmtTransType := 'INV';
                    CustLedgEntry."Document Type"::"Credit Memo": StmtTransType := 'CRN';
                    CustLedgEntry."Document Type"::Payment: StmtTransType := 'PMT';
                    CustLedgEntry."Document Type"::"Finance Charge Memo": StmtTransType := 'IFC';
                end;              
                if Customer.Get(CustLedgEntry."Customer No.") then;
                Addr3 := Customer.City;
                if Addr3 = '' then
                    Addr3 := Customer.County
                else
                    Addr3 := Addr3 + ', ' + Customer.County;
                OStream.WriteText
                    (Format(CompanyInformation."ARC Company Code", 10) +
                        Format(CustLedgEntry."Customer No.", 20) +
                        Format('', 20) +
                        Format(CustLedgEntry."Document No.", 20) +
                        Format(TransDate, 8) +
                        Format(Customer.Contact, 30) +
                        Format(Customer."Phone No.", 30) +
                        Format(Format(CustLedgEntry."Global Dimension 1 Code"), 10) +
                        Format('0', 2) +
                        Format(Format(CustLedgEntry."Remaining Amount", 15, '<sign><integer><decimal,3>'), 15) +
                        Format(StmtTransType, 5) +
                        Format(Customer.Name, 32) +
                        Format(Customer.Address, 32) +
                        Format(Customer."Address 2", 32) +
                        Format(Addr3, 32) +
                        Format('', 32) +
                        Format(Customer."Post Code", 32) +
                        Format('', 10) +
                        Format(InvDueDate, 8) +
                        Format(Format(CustLedgEntry."Remaining Amount",15,'<sign><integer><decimal,3>'), 15) +
                        Format('', 10) +
                        Format(CustLedgEntry."Entry No.", 16) +
                        Format('', 8) +
                        Format('', 8) +
                        Format('', 4) +
                        Format('', 4) +
                        Format('', 8) +
                        Format('', 8)
                        );
                        OStream.WriteText;
                        NoOfTrans += 1;
            until CustLedgEntry.Next = 0;

            Alloc8ExportEntry."No. of Transactions" := NoOfTrans;
            Alloc8ExportEntry.Insert(true);
            OutputFile.Close;
        end;

    end;

    local procedure Intialize();
    begin
        Alloc8Setup.Get;
        Alloc8Setup.TestField("Invoice File Export Path");
        CR := 13;
        LF := 10;
        Alloc8ExportEntry.Init;
        Alloc8ExportEntry."Entry Type" := Alloc8ExportEntry."Entry Type"::Invoice;
        Alloc8ExportEntry."Export Date/Time" := CurrentDateTime;
    end;

    var
        Alloc8Setup: Record "ARC Alloc8 Setup";
        Alloc8ExportEntry: Record "ARC Alloc8 Export Entry";
        CR : Char;
        LF : Char;
}
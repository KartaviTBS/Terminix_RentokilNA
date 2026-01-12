codeunit 50067 "Export AP Details to JDE TEST"
{
    // RNK01-129 BMICO 08.31.2023 Export AP Details to JDE

    Permissions = TableData 25 = rim;

    trigger OnRun()
    var
        TotalAmount:Decimal;
    begin
        PPSetup.GET('');
        GLSetup.Get();
        LCYCurr := COPYSTR(GLSetup."LCY Code", 1, 3);
        PPSetup.TESTFIELD("JDE AP Export File Path");
        PPSetup.TESTFIELD("JDE AP Last Export File Name");

        FileName := RBMgt.ServerTempFileName('');

        BatchNo := INCSTR(PPSetup."JDE AP Last Export File Name");
        ClientFileName := BatchNo + '.txt';
        PPSetup."JDE AP Last Export File Name" := BatchNo;//INCSTR(PPSetup."JDE Last Export File Name");
        PPSetup.MODIFY;


        // CurrentDate_Time := CURRENTDATETIME;
        // FormatString := '<Month,2><Day,2><Year4> <Hours24,2><Minutes,2><Seconds,2>';

        // IF (COMPANYNAME = 'TSP_US') THEN
        //     ClientFileName := 'JDE_APSweep_TSP_' + FORMAT(CURRENTDATETIME, 0, FormatString) + '.txt'
        // ELSE
        //     IF (COMPANYNAME = 'TSP_CA Test') OR (COMPANYNAME = 'TSP_CA') THEN
        //         ClientFileName := 'JDE_APSweep_TSP_CAD_' + FORMAT(CURRENTDATETIME, 0, FormatString) + '.txt';           


        IF EXISTS(FileName) THEN
            ERROR(Text003,
                  FileName,
                  PPSetup.FIELDCAPTION("JDE AP Last Export File Name"),
                  PPSetup.TABLECAPTION);
        ExportFile.TEXTMODE(TRUE);
        ExportFile.WRITEMODE(TRUE);
        ExportFile.CREATE(FileName);

        CR := 13;
        LF := 10;

        IF (COMPANYNAME = 'TSP_US') THEN BEGIN
            InterfaceName := 'APN18RNA';
            BranchName := '101';
            CurrencyCode := 'USD';
        END ELSE
            IF (COMPANYNAME = 'TSP_CA Test') OR (COMPANYNAME = 'TSP_CA') THEN BEGIN
                InterfaceName := 'APN18CAD';
                BranchName := '201';
                CurrencyCode := 'CAD';
            END;

        VLE.Reset();
        VLE.SETCURRENTKEY("Transaction No.", "Posting Date");
        VLE.SETFILTER("Posting Date",'>=%1', DMY2Date(14,11,24));
        VLE.SETRANGE(Open, TRUE);
        VLE.SETRANGE("Exported To JDE", FALSE);
        IF VLE.FIND('-') THEN
            REPEAT
                VLE.CALCFIELDS("Remaining Amount", "Remaining Amt. (LCY)");
                IF VLE."Currency Code" <> '' THEN
                    TransAmount :=
                      ROUND(
                        CurrExchRate.ExchangeAmtFCYToFCY(
                          TODAY,
                          VLE."Currency Code",
                          Vendor."Currency Code",
                          VLE."Remaining Amount"),
                        Currency."Amount Rounding Precision")
                ELSE
                    TransAmount := VLE."Remaining Amt. (LCY)";
            TotalAmount := TotalAmount + TransAmount;
            until VLE.Next()=0;
        ExportFile.WRITE(
                         'P' + '|' + 
                         format('0'+copystr(BatchNo,strlen(BatchNo)-4,5)) + '|' +
                         format(VLE.Count) + '|' +
                         format(-TotalAmount));         
        VLE.LOCKTABLE;
        VLE.Reset();
        VLE.SETCURRENTKEY("Transaction No.", "Posting Date");
        VLE.SETFILTER("Posting Date",'>=%1', DMY2Date(14,11,24));
        VLE.SETRANGE(Open, TRUE);
        VLE.SETRANGE("Exported To JDE", FALSE);
        IF VLE.FIND('-') THEN
            REPEAT

                IF (COMPANYNAME = 'TSP_US') THEN
                    JDLAcctCode := '101.931062';
                IF (COMPANYNAME = 'TSP_CA Test') OR (COMPANYNAME = 'TSP_CA') THEN
                    JDLAcctCode := '201.931064';


                Vendor.GET(VLE."Vendor No.");
                OrigPhoneNo := Vendor."Phone No.";
                OrigPhoneNo := DELCHR(OrigPhoneNo, '=', DELCHR(OrigPhoneNo, '=', '1234567890'));

                IF (Vendor."Country/Region Code" <> 'US') AND (Vendor."Country/Region Code" <> 'CA') THEN BEGIN
                    IF Vendor."Post Code" <> '' THEN
                        VendPostCode := Vendor."Post Code"
                    ELSE
                        VendPostCode := '99999';
                END ELSE  //for us and canada
                    VendPostCode := Vendor."Post Code";

                IF Vendor."Federal ID No." <> '' THEN
                    CorpCode := 'C'
                ELSE
                    CorpCode := 'P';

                PurchInvoice.RESET;
                PurchInvoice.SETRANGE("No.", VLE."Document No.");
                IF PurchInvoice.FIND('-') THEN
                    PaymentTermsCode := MapPaymentTerms(PurchInvoice."Payment Terms Code");

                CASE VLE."IRS 1099 Code" OF
                    'MISC-01':
                        TenNNCode := 'A1';
                    'MISC-06':
                        TenNNCode := 'A6';
                    'NEC-01':
                        TenNNCode := 'A7';
                END;

                PaymentMethodCode := '';
                CASE VLE."Payment Method Code" OF
                    'ACH':
                        PaymentMethodCode := 'T';
                    'EFT':
                        PaymentMethodCode := 'T';
                    'CHECK':
                        PaymentMethodCode := '';
                    'SUA':
                        PaymentMethodCode := '4';
                    'INHOUSE':
                        PaymentMethodCode := '';
                    'RTS':
                        PaymentMethodCode := '';
                    'WIRE':
                        PaymentMethodCode := 'W';
                END;


                BankRoutingNumber := '';
                BankAccountNumber := '';
                BankAccountName := '';
                IF PaymentMethodCode = 'T' THEN BEGIN
                    CLEAR(VendBankAccount);
                    VendBankAccount.RESET;
                    VendBankAccount.SETRANGE("Vendor No.", VLE."Vendor No.");
                    VendBankAccount.SETRANGE("Use for Electronic Payments", TRUE);
                    IF VendBankAccount.FIND('-') THEN BEGIN
                        
                        IF VendBankAccount."Country/Region Code" <> 'CA' THEN
                            BankRoutingNumber := VendBankAccount."Transit No."
                        ELSE
                            IF VendBankAccount."Country/Region Code" = 'CA' THEN
                                BankRoutingNumber := STRSUBSTNO('0' + VendBankAccount."Institution Code" + VendBankAccount."Transit No.");
                        BankAccountNumber := VendBankAccount."Bank Account No.";
                        BankAccountName := VendBankAccount.Name;
                    END;
                END;

                IF (PaymentMethodCode = 'T') OR (PaymentMethodCode = '4') THEN BEGIN
                    IF NOT Vendor."Exclude From Remittance" THEN
                        Email := Vendor."E-Mail"
                    ELSE
                        Email := 'NA@NA.NA';
                END ELSE
                    Email := '';

                IF Vendor."W9 Name" <> '' THEN BEGIN
                    LegalName := COPYSTR(Vendor."W9 Name", 1, 40);
                    TaxID := Vendor."Federal ID No.";
                END ELSE BEGIN
                    LegalName := COPYSTR(Vendor.Name, 1, 40);
                    TaxID := '999999999';
                END;

                VLE.CALCFIELDS("Remaining Amount", "Remaining Amt. (LCY)");
                IF VLE."Currency Code" <> '' THEN begin
                    TransAmount :=
                      ROUND(
                        CurrExchRate.ExchangeAmtFCYToFCY(
                          TODAY,
                          VLE."Currency Code",
                          Vendor."Currency Code",
                          VLE."Remaining Amount"),
                        Currency."Amount Rounding Precision");                    
                    FCYCurr :=  COPYSTR(VLE."Currency Code", 1, 3);
                end ELSE begin
                    TransAmount := VLE."Remaining Amt. (LCY)";
                    FCYCurr := LCYCurr;
                end;
                TransAmountFCY := TransAmount;


                ExportFile.WRITE(
                         'H' + '|' + '0' +
                         COPYSTR(PPSetup."JDE AP Last Export File Name", strlen(PPSetup."JDE AP Last Export File Name")-4, 5) + '|' +
                         COPYSTR(FORMAT(VLE."Entry No."), 1, 22) + '|' +
                         InterfaceName + '|' +
                         BranchName + '|' +
                         COPYSTR(VLE."Vendor No.", 1, 15) + '|' +
                         COPYSTR(Vendor.Name, 1, 38) + '|' +           //First Name
                         '' + '|' +                                   //LastName
                         COPYSTR(LegalName, 1, 40) + '|' +              //Legal Name
                         COPYSTR(Vendor.Address, 1, 40) + '|' +        //Address Line 1
                         COPYSTR(Vendor."Address 2", 1, 40) + '|' +     //Address Line 2
                         '' + '|' +                                   //Address Line 3
                         COPYSTR(Vendor.City, 1, 25) + '|' +
                         COPYSTR(Vendor.County, 1, 3) + '|' +
                         COPYSTR(VendPostCode, 1, 12) + '|' +
                         COPYSTR(Vendor."Country/Region Code", 1, 2) + '|' +
                         COPYSTR(TaxID, 1, 20) + '|' +                  //Tax ID
                         CorpCode + '|' +                             //Person/Corp Code
                         TenNNCode + '|' +                            // Form 1099 reporting
                         COPYSTR(OrigPhoneNo, 1, 3) + '|' +             //Telephone Number Area Code
                         INSSTR(COPYSTR(OrigPhoneNo, 4), '-', 4) + '|' + //Telephone Number
                         '' + '|' +                                   //Fax Number Area Code
                         '' + '|' +                                   //Fax Number
                         FORMAT(VLE."Document Date", 0, '<Month,2>/<Day,2>/<Year4>') + '|' +    //Transaction Date
                         FORMAT(-TransAmount) + '|' +                   //Transaction Amount
                         COPYSTR(VLE."External Document No.", 1, 30) + '|' +          //Payment Remark
                         '' + '|' +                      //Payment Handling Code
                         COPYSTR(PaymentTermsCode, 1, 3) + '|' +        //Payment terms
                         PaymentMethodCode + '|' +                    //Payment Method
                         BankAccountNumber + '|' +                    //Bank Account Number
                         BankRoutingNumber + '|' +                    //Bank Routing Number
                         '' + '|' +                                   //Checking or Saving Account          always blank
                         COPYSTR(BankAccountName, 1, 30) + '|' +   //Bank Name
                         COPYSTR(Email, 1, 3) + '|' +            //Email Address
                         COPYSTR(LCYCurr, 1, 3) + '|' +          //Base Currency
                         COPYSTR(FCYCurr, 1, 3) + '|' +          //Payment Currency
                         FORMAT(-TransAmountFCY));                //Transaction Amount Foreign

                ExportFile.WRITE(
                        'D' + '|' + '0' +                                   //Format Designator
                        COPYSTR(PPSetup."JDE AP Last Export File Name", strlen(PPSetup."JDE AP Last Export File Name")-4, 5) + '|' +   //Batch ID
                        FORMAT(VLE."Entry No.") + '|' +              //Transaction ID
                        '1' + '|' +                                   //Line Number  - always 1
                        JDLAcctCode + '|' +                           //General Ledger Account
                        FORMAT(-TransAmount) + '|' +                    //VLE Amount
                        VLE."Document No." + '|' +                    //Remark  opt
                        '' + '|' +                                    //Subledger opt
                        '' + '|' +                                    //Subledger Type  opt
                        '' + '|');                                   //Reference 2     opt


                VLE."Exported To JDE" := TRUE;
                VLE.MODIFY;
            UNTIL VLE.NEXT = 0;

        ExportFile.CLOSE;


        /*ClientFile :=   PPSetup."JDE AP Export File Path" + ClientFileName;      //  'C:\BMI\JDEExport-APSweep\testfile.txt';
        RBMgt.DownloadToFile(FileName,ClientFile);
        ERASE(FileName);*/


        IF FILE.EXISTS(FileName) THEN BEGIN
            FILE.COPY(FileName, PPSetup."JDE AP Export File Path" + ClientFileName);
            FILE.ERASE(FileName);
        END;

    end;

    var
        Text000: Label 'Cannot start new Export File while %1 is in process.';
        Text001: Label 'is not valid.';
        Text002: Label '%1 in %2 %3 is invalid.';
        Text003: Label 'File %1 already exists. Check the %2 in %3.';
        Text004: Label 'Cannot start export batch until an export file is started.';
        Text005: Label 'Cannot start new export batch until previous batch is completed.';
        Text006: Label 'Cannot export details until an export file is started.';
        Text007: Label 'Cannot export details until an export batch is started.';
        Text008: Label 'Vendor No. %1 has no bank account setup for electronic payments.';
        Text009: Label 'Vendor No. %1 has more than one bank account setup for electronic payments.';
        Text010: Label 'Customer No. %1 has no bank account setup for electronic payments.';
        Text011: Label 'Customer No. %1 has more than one bank account setup for electronic payments.';
        Text012: Label 'Cannot end export batch until an export file is started.';
        Text013: Label 'Cannot end export batch until an export batch is started.';
        Text014: Label 'Cannot end export file until an export file is started.';
        Text015: Label 'Cannot end export file until export batch is ended.';
        Text016: Label 'File %1 does not exist.';
        Text017: Label 'Did the transmission work properly?';
        Text018: Label 'Either %1 or %2 must refer to either a %3 or a %4 for an electronic payment.';
        Text1020100: Label '%1 is blocked for %2 processing';
        Text019: Label 'You must now run the program that transmits the payments file to the bank. Transmit the file named %1 located at %2 to %3 (%4 %5 %6).  After the transmission is completed, you will be asked if it worked correctly.  Are you ready to transmit (answer No to cancel the transmission process)?';
        Text1480002: Label 'No file name.';
        Text020: Label 'The length of %1 must not be %2';
        Text021: Label '%1 must be numeric only. Current value %2';
        Text022: Label 'Check No. must be greater than 99.';
        Text023: Label 'Check No. must be numeric.';
        JPMText: Label '%1.%2.%3.%4.%5.%6';
        WCText001: Label 'ON ACCOUNT';
        WCText002: Label 'Customers have not been setup for Exporting';
        PPSetup: Record "ARC RNA Setup";
        GLSetup: Record "General Ledger Setup";
        FileName: Text[250];
        VLE: Record 25;
        PurchInvoice: Record 122;
        PurchInvLine: Record 123;
        VendBankAccount: Record 288;
        Vendor: Record 23;
        CurrExchRate: Record 330;
        Currency: Record 4;
        InterfaceName: Text[30];
        RBMgt: Codeunit 419;
        BatchNo: Code[30];
        ExportFile: File;
        TransactionNo: Integer;
        LineNo: Integer;
        CurrencyCode: Code[20];
        DocType: Code[10];
        ClientFile: Text;
        _Day: Text[10];
        _Month: Text[10];
        _Year: Integer;
        PostingDateText: Text[10];
        _DayLength: Integer;
        _MonthLength: Integer;
        AmountText: Text[20];
        CommaPos: Integer;
        PeriodPos: Integer;
        BaseAmountText: Text[15];
        DecimalText: Text[3];
        BranchName: Text[5];
        CR: Char;
        LF: Char;
        CorpCode: Code[10];
        PaymentTermsCode: Code[10];
        PaymentMethodCode: Code[10];
        TenNNCode: Code[10];
        JDLAcctCode: Code[10];
        OrigPhoneNo: Text[30];
        CurrentDate_Time: DateTime;
        FormatString: Text[100];
        ClientFileName: Text[250];
        BankRoutingNumber: Text[20];
        BankAccountNumber: Code[20];
        LegalName: Text[40];
        TaxID: Code[20];
        Email: Text[250];
        BankAccountName: Text[50];
        VendPostCode: Code[10];
        TransAmount: Decimal;
        LCYCurr:Code[5];
        FCYCurr:Code[5];
        TransAmountFCY: Decimal;

    [Scope('Internal')]
    procedure MapPaymentTerms(PymntTerms: Code[10]): Code[10]
    var
        GDEPaymentTermsCode: Code[10];
    begin
        CASE PymntTerms OF
            '10-30NET31':
                GDEPaymentTermsCode := '103';
            '10TH1M':
                GDEPaymentTermsCode := 'M10';
            '1-10,NET30':
                GDEPaymentTermsCode := '110';
            '1-15,NET25':
                GDEPaymentTermsCode := '125';
            '1-30,NET31':
                GDEPaymentTermsCode := '131';
            '1ST':
                GDEPaymentTermsCode := 'P1';
            '20TH2M':
                GDEPaymentTermsCode := '202';
            '2-15,NET30':
                GDEPaymentTermsCode := '216';
            '2-20,NET30':
                GDEPaymentTermsCode := '220';
            '2-20,NET60':
                GDEPaymentTermsCode := '236';
            '2-30,NET31':
                GDEPaymentTermsCode := '230';
            '3-15,NET30':
                GDEPaymentTermsCode := '315';
            '3-30,NET60':
                GDEPaymentTermsCode := '336';
            'D05':
                GDEPaymentTermsCode := 'P5';
            'D18':
                GDEPaymentTermsCode := 'P18';
            'NET005':
                GDEPaymentTermsCode := 'N5';
            'NET007':
                GDEPaymentTermsCode := 'N7';
            'NET010':
                GDEPaymentTermsCode := 'N10';
            'NET012':
                GDEPaymentTermsCode := '12';
            'NET014':
                GDEPaymentTermsCode := 'N14';
            'NET015':
                GDEPaymentTermsCode := 'N15';
            'NET018':
                GDEPaymentTermsCode := 'N18';
            'NET020':
                GDEPaymentTermsCode := 'N20';
            'NET021':
                GDEPaymentTermsCode := 'N21';
            'NET022':
                GDEPaymentTermsCode := 'N22';
            'NET023':
                GDEPaymentTermsCode := '23';
            'NET024':
                GDEPaymentTermsCode := '24';
            'NET025':
                GDEPaymentTermsCode := 'N25';
            'NET026':
                GDEPaymentTermsCode := 'N26';
            'NET028':
                GDEPaymentTermsCode := 'N28';
            'NET029':
                GDEPaymentTermsCode := 'N29';
            'NET030':
                GDEPaymentTermsCode := 'N30';
            'NET033':
                GDEPaymentTermsCode := 'N33';
            'NET045':
                GDEPaymentTermsCode := 'N45';
            'NET060':
                GDEPaymentTermsCode := 'N60';
            'NET075':
                GDEPaymentTermsCode := 'N75';
            'NET090':
                GDEPaymentTermsCode := 'N90';
            'NET120':
                GDEPaymentTermsCode := 'N4M';
            'RECEIPT':
                GDEPaymentTermsCode := 'ON';
        END;
        EXIT(GDEPaymentTermsCode);
    end;

    [Scope('Internal')]
    procedure TransmitExportedFile(FName: Text[30])
    var
        ExportFullPathName: Text[250];
        TransmitFullPathName: Text[250];
    begin
        ExportFullPathName := PPSetup."JDE AP Export File Path" + FName;
        TransmitFullPathName := PPSetup."JDE AP Export File Path" + FName;

        IF NOT RBMgt.ClientFileExists(ExportFullPathName) THEN
            ERROR(Text016, FName);
        RBMgt.CopyClientFile(ExportFullPathName, TransmitFullPathName, TRUE);

        IF CONFIRM(Text017) THEN
            RBMgt.DeleteClientFile(ExportFullPathName);
    end;
}


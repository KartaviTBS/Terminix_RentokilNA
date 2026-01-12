codeunit 50066 "Export GL Details to JDE TEST"
{
    // 
    // RNK01-129 BMILGL 08.28.2023 Export General Ledger Details to JDE

    Permissions = TableData 17 = rimd;

    trigger OnRun()
    begin
        GLSetup.GET('');
        GLSetup.TESTFIELD("JDE GL Export File Path");
        GLSetup.TESTFIELD("JDE Last Export File Name");

        FileName := RBMgt.ServerTempFileName('');

        BatchNo := INCSTR(GLSetup."JDE Last Export File Name");
        ClientFileName := BatchNo + '.txt';
        GLSetup."JDE Last Export File Name" := BatchNo;//INCSTR(PPSetup."JDE Last Export File Name");
        GLSetup.MODIFY;
        // CurrentDate := FORMAT(TODAY, 0, 5);
        // CurrentTime := FORMAT(TIME);

        // CurrentDate_Time := CURRENTDATETIME;
        // FormatString := '<Month,2><Day,2><Year4> <Hours24,2>:<Minutes,2>:<Seconds,2>';

        // IF (COMPANYNAME = 'TSP_US') THEN
        //     FileName := 'JDE_GLSweep_TSP_' + FORMAT(CURRENTDATETIME, 0, FormatString) + '.txt'
        // ELSE
        //     IF (COMPANYNAME = 'TSP_CA Test') OR (COMPANYNAME = 'TSP_CA') THEN
        //         FileName := 'JDE_GLSweep_TSP_CAD_' + FORMAT(CURRENTDATETIME, 0, FormatString) + '.txt'; 


        // ColonPos := STRPOS(FileName, ':');
        // FileName := DELSTR(FileName, ColonPos, 1);
        // ColonPos := STRPOS(FileName, ':');
        // FileName := DELSTR(FileName, ColonPos, 1);


        IF EXISTS(FileName) THEN
            ERROR(Text003,
                  FileName,
                  GLSetup.FIELDCAPTION("JDE Last Export File Name"),
                  GLSetup.TABLECAPTION);
        ExportFile.TEXTMODE(TRUE);
        ExportFile.WRITEMODE(TRUE);
        ExportFile.CREATE(FileName);
        // GLSetup."JDE Last Export File Name" := INCSTR(GLSetup."JDE Last Export File Name");
        // GLSetup.MODIFY;

        IF (COMPANYNAME = 'TSP_US') THEN BEGIN
            InterfaceName := PADSTR('GLN18RNA', 10);
            CurrencyCode := 'USD';
        END ELSE
            IF (COMPANYNAME = 'TSP_CA Test') OR (COMPANYNAME = 'TSP_CA') THEN BEGIN
                InterfaceName := PADSTR('GLN18CAD', 10);
                CurrencyCode := 'CAD';

                    END;

        LineNo := 0;
        TransactionNo := 0;
        GenLedSetup.Get();
        GLEntry.Reset;
        GLEntry.SETCURRENTKEY("Transaction No.", "Posting Date");
        if (GenLedSetup."Allow Posting From" > DMY2Date(01,07,24)) and (GenLedSetup."Allow Posting To" <> 0D) then
            GLEntry.SetRange("Posting Date",GenLedSetup."Allow Posting From",GenLedSetup."Allow Posting To")
        else
            GLEntry.SETFILTER("Posting Date", '>=%1', DMY2Date(01,07,24));
        GLEntry.SETRANGE(GLEntry."Exported To JDE", FALSE);
        CountVar := GLEntry.Count;
        GLEntry.SetFilter(Amount,'<0');
        IF GLEntry.FindSet THEN
            GLEntry.CalcSums(Amount);

        AmountDec := GLEntry.Amount;
        AmountText := FORMAT(AmountDec);
        CommaPos := STRPOS(AmountText, ',');
        IF CommaPos <> 0 THEN  //Remove first comma
            AmountText := DELSTR(AmountText, CommaPos, 1);
        CommaPos := STRPOS(AmountText, ',');
        IF CommaPos <> 0 THEN  //Remove second comma
            AmountText := DELSTR(AmountText, CommaPos, 1);
        CommaPos := STRPOS(AmountText, ',');
        IF CommaPos <> 0 THEN  //Remove first comma
            AmountText := DELSTR(AmountText, CommaPos, 1);

        PeriodPos := STRPOS(AmountText, '.');
        IF PeriodPos = 0 THEN
            AmountText := AmountText + '.00'
        ELSE BEGIN
            BaseAmountText := COPYSTR(AmountText, 1, (PeriodPos - 1));
            DecimalText := COPYSTR(AmountText, PeriodPos, 3);
            DecimalText := PADSTR(DecimalText, 3, '0');
            AmountText := BaseAmountText + DecimalText;
        END;    

        ExportFile.WRITE(
                        'P' + '|' + 
                        format('0000000000'+copystr(BatchNo,StrLen(BatchNo)-4,StrLen(BatchNo))) + '|' +
                        format(CountVar) + '|' +
                        format(AmountText));  

        GLEntry.LOCKTABLE;
        GLEntry.Reset();
        GLEntry.SETCURRENTKEY("Transaction No.", "Posting Date");
        if (GenLedSetup."Allow Posting From" > DMY2Date(01,07,24)) and (GenLedSetup."Allow Posting To" <> 0D) then
            GLEntry.SetRange("Posting Date",GenLedSetup."Allow Posting From",GenLedSetup."Allow Posting To")
        else
            GLEntry.SETFILTER("Posting Date", '>=%1', DMY2Date(01,07,24));
        GLEntry.SETRANGE(GLEntry."Exported To JDE", FALSE);
        IF GLEntry.FIND('-') THEN
            REPEAT
                LineNo += 1;
                CASE GLEntry."Document Type" OF
                    GLEntry."Document Type"::Payment:
                        BEGIN
                            IF (GLEntry."Source Type" = GLEntry."Source Type"::Customer) OR (GLEntry."Bal. Account Type" = GLEntry."Bal. Account Type"::Customer) THEN
                                DocType := 'RC'
                            ELSE
                                IF (GLEntry."Source Type" = GLEntry."Source Type"::Vendor) OR (GLEntry."Bal. Account Type" = GLEntry."Bal. Account Type"::Vendor) THEN
                                    DocType := 'PK';
                        END;
                    GLEntry."Document Type"::Invoice:
                        BEGIN
                            IF (GLEntry."Source Type" = GLEntry."Source Type"::Customer) OR (GLEntry."Bal. Account Type" = GLEntry."Bal. Account Type"::Customer) THEN
                                DocType := 'RI'
                            ELSE
                                IF (GLEntry."Source Type" = GLEntry."Source Type"::Vendor) OR (GLEntry."Bal. Account Type" = GLEntry."Bal. Account Type"::Vendor) THEN
                                    DocType := 'PV';
                        END;
                    GLEntry."Document Type"::"Credit Memo":
                        BEGIN
                            IF (GLEntry."Source Type" = GLEntry."Source Type"::Customer) OR (GLEntry."Bal. Account Type" = GLEntry."Bal. Account Type"::Customer) THEN
                                DocType := 'RM'
                            ELSE
                                IF (GLEntry."Source Type" = GLEntry."Source Type"::Vendor) OR (GLEntry."Bal. Account Type" = GLEntry."Bal. Account Type"::Vendor) THEN
                                    DocType := 'PD';
                        END;
                    GLEntry."Document Type"::"Finance Charge Memo":
                        DocType := 'RF';
                    GLEntry."Document Type"::Refund:
                        BEGIN
                            IF (GLEntry."Source Type" = GLEntry."Source Type"::Customer) OR (GLEntry."Bal. Account Type" = GLEntry."Bal. Account Type"::Customer) THEN
                                DocType := 'RM'
                            ELSE
                                IF (GLEntry."Source Type" = GLEntry."Source Type"::Vendor) OR (GLEntry."Bal. Account Type" = GLEntry."Bal. Account Type"::Vendor) THEN
                                    DocType := 'PD';
                        END;
                END;

                //GLEntry.CALCFIELDS("ARC Global Dimension 3 Code");
                _Day := FORMAT(DATE2DMY(GLEntry."Posting Date", 1));

                _DayLength := STRLEN(_Day);
                IF _DayLength = 1 THEN
                    _Day := '0' + _Day;
                _Month := FORMAT(DATE2DMY(GLEntry."Posting Date", 2));
                _MonthLength := STRLEN(_Month);
                IF _MonthLength = 1 THEN
                    _Month := '0' + _Month;
                _Year := DATE2DMY(GLEntry."Posting Date", 3);
                PostingDateText := _Day + _Month + FORMAT(_Year);

                AmountDec := GLEntry.Amount;
                AmountText := FORMAT(AmountDec);
                CommaPos := STRPOS(AmountText, ',');
                IF CommaPos <> 0 THEN  //Remove first comma
                    AmountText := DELSTR(AmountText, CommaPos, 1);
                CommaPos := STRPOS(AmountText, ',');
                IF CommaPos <> 0 THEN  //Remove second comma
                    AmountText := DELSTR(AmountText, CommaPos, 1);
                CommaPos := STRPOS(AmountText, ',');
                IF CommaPos <> 0 THEN  //Remove first comma
                    AmountText := DELSTR(AmountText, CommaPos, 1);

                PeriodPos := STRPOS(AmountText, '.');
                IF PeriodPos = 0 THEN
                    AmountText := AmountText + '.00'
                ELSE BEGIN
                    BaseAmountText := COPYSTR(AmountText, 1, (PeriodPos - 1));
                    DecimalText := COPYSTR(AmountText, PeriodPos, 3);
                    DecimalText := PADSTR(DecimalText, 3, '0');
                    AmountText := BaseAmountText + DecimalText;
                END;

                IF (GLEntry."ARC Global Dimension 3 Code" = '') THEN BEGIN
                    IF COPYSTR(GLEntry."G/L Account No.", 1, 1) = '1' THEN
                        GLEntry."ARC Global Dimension 3 Code" := '000';
                    IF GLEntry."G/L Account No." = '340200' THEN
                        GLEntry."ARC Global Dimension 3 Code" := '290';
                END;

                IF (GLEntry."Global Dimension 2 Code" = '') THEN
                    IF COPYSTR(GLEntry."G/L Account No.", 1, 1) = '1' THEN
                        // GLEntry."ARC Global Dimension 3 Code" := '901';
                        GLEntry."Global Dimension 2 Code" := '901';

                GLAccountSuffix := '';
                GLAccountText := GLEntry."G/L Account No.";
                HyphenPos := STRPOS(GLEntry."G/L Account No.", '-');
                IF HyphenPos <> 0 THEN
                    GLAccountSuffix := COPYSTR(GLEntry."G/L Account No.", HyphenPos + 1)
                ELSE
                    GLAccountSuffix := ' ';

                ExportFile.WRITE(
                  InterfaceName +                                  // indicates company   10
                  PADSTR(FORMAT(GLEntry."Transaction No."), 22) +   // GL transaction no.  22
                  PADSTR(FORMAT(LineNo), 7) +                       // line number of entries in this transaction  7
                  PADSTR('0000000000'+copystr(BatchNo,StrLen(BatchNo)-4,5), 15) +                             // File name / Batch No. 15
                  PADSTR(FORMAT(AmountText), 15) +                  // Amount                15
                  CurrencyCode +                                   // Currency               3
                  PADSTR(FORMAT(GLEntry."Entry No."), 8) +          // Entry No.              8
                  PADSTR(DocType, 2) +                              // Document Type mapped to JDE 2
                  PADSTR(GLEntry."Global Dimension 1 Code", 4) +    // Branch                      4
                  PADSTR(GLEntry."ARC Global Dimension 3 Code", 3) +  // LOB                    3
                  PADSTR(GLEntry."Global Dimension 2 Code", 3) +    // Function                 3
                  PADSTR(GLAccountText, 6) +                        // GL Account No.              6
                  PADSTR(PostingDateText, 8) +                      // Posting Date                8
                  '        ' +                                     // Reference Leave blank       8
                  PADSTR(GLEntry."Document No.", 30) +              // Document No.               30
                  GLAccountSuffix);                                // Suffix                      1

                GLEntry."Exported To JDE" := TRUE;
                GLEntry.MODIFY;
                TransactionNo := GLEntry."Transaction No.";
            UNTIL GLEntry.NEXT = 0;

        ExportFile.CLOSE;

        /*ClientFile :=  GLSetup."JDE GL Export File Path" + FileName;
        RBMgt.DownloadToFile(FileName,ClientFile);
        ERASE(FileName);*/

        IF FILE.EXISTS(FileName) THEN BEGIN
            FILE.COPY(FileName, GLSetup."JDE GL Export File Path" + ClientFileName);
            FILE.ERASE(FileName);
        END;
        //TransmitExportedFile(FileName);

    end;

    var
        GenLedSetup:Record "General Ledger Setup";
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
        GLSetup: Record "ARC RNA Setup";
        FileName: Text[250];
        ClientFileName: Text[250];
        GLEntry: Record 17;
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
        CurrentDate: Text[30];
        CurrentTime: Text[30];
        CurrentDate_Time: DateTime;
        Precision: Text;
        FormatString: Text[100];
        ColonPos: Integer;
        AmountDec: Decimal;
        GLAccountSuffix: Text[5];
        GLAccountText: Text[30];
        HyphenPos: Integer;
        CountVar:Decimal;
    procedure TransmitExportedFile(FName: Text[30])
    var
        ExportFullPathName: Text[250];
        TransmitFullPathName: Text[250];
    begin
        ExportFullPathName := GLSetup."JDE GL Export File Path" + FName;
        TransmitFullPathName := GLSetup."JDE GL Export File Path" + FName;

        IF NOT RBMgt.ClientFileExists(ExportFullPathName) THEN
            ERROR(Text016, FName);
        RBMgt.CopyClientFile(ExportFullPathName, TransmitFullPathName, TRUE);

        IF CONFIRM(Text017) THEN
            RBMgt.DeleteClientFile(ExportFullPathName);
    end;
}


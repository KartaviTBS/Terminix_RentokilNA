report 50001 "ARC Alloc8 Import"
{
    Caption = 'Alloc8 Import';
    ProcessingOnly = true;
    UsageCategory = Lists;
    Permissions = TableData "Cust. Ledger Entry" = rimd; 

    dataset
    {
        dataitem(Alloc8Import; Integer)
        {
            DataItemTableView = sorting (Number) where (Number = const (1));

            trigger OnPreDataItem();
            begin
                ImportRec;
            end;

        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(FileNameControl; FileName)
                    {
                        ApplicationArea = Suite;
                        Caption = 'File Name';
                        ToolTip = 'Specifies the name of the file that you want to use for Alloc8.';
                        AssistEdit = true;

                        trigger OnAssistEdit()
                        var
                            FileManagement: Codeunit "File Management";
                            ClientTypeMgt: Codeunit ClientTypeManagement;
                        begin
                    
                            FilePath := FileManagement.OpenFileDialog(Text031, FileName, FileManagement.GetToFilterText('', '.txt'));
                            if ClientTypeMgt.GetCurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop] then
                                ServerFileName := FilePath;
                            FileName := FilePath;
                           
                        end;
                    }
                    field(JournalTemplate; JournalTemplate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Journal Template';
                        TableRelation = "Gen. Journal Template".Name;
                        ToolTip = 'Specifies the journal template that the customer journal is based on.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GenJnlTemplate: Record "Gen. Journal Template";
                            GenJnlTemplates: Page "General Journal Templates";
                        begin
                            //GenJnlTemplate.SetRange(Type, GenJnlTemplate.Type::General);
                            GenJnlTemplate.SetRange(Recurring, false);
                            GenJnlTemplates.SetTableView(GenJnlTemplate);

                            GenJnlTemplates.LookupMode := true;
                            GenJnlTemplates.Editable := false;
                            if GenJnlTemplates.RunModal = ACTION::LookupOK then begin
                                GenJnlTemplates.GetRecord(GenJnlTemplate);
                                JournalTemplate := GenJnlTemplate.Name;
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            CheckJournalTemplate;
                        end;
                    }
                    field(BatchName; BatchName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Batch Name';
                        TableRelation = "Gen. Journal Batch".Name;
                        ToolTip = 'Specifies the name of the journal batch, a personalized journal layout, that the journal is based on.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GenJnlBatches: Page "General Journal Batches";
                        begin
                            if JournalTemplate <> '' then begin
                                GenJnlBatch.SetRange("Journal Template Name", JournalTemplate);
                                GenJnlBatches.SetTableView(GenJnlBatch);
                            end;

                            GenJnlBatches.LookupMode := true;
                            GenJnlBatches.Editable := false;
                            if GenJnlBatches.RunModal = ACTION::LookupOK then begin
                                GenJnlBatches.GetRecord(GenJnlBatch);
                                BatchName := GenJnlBatch.Name;
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            CheckBatchName;
                        end;
                    }

                }
            }
        }

        trigger OnInit()
        var
            ClientTypeMgt: Codeunit ClientTypeManagement;
        begin
            OnWebClient := ClientTypeMgt.GetCurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop];
        end;





    }

    local procedure CheckBatchName()
    begin
        if BatchName = '' then
            Error(Text002);
    end;

    local procedure CheckJournalTemplate()
    begin
        if JournalTemplate = '' then
            Error(Text001);
    end;

    local procedure ImportRec();
    var
        FileMgt: Codeunit "File Management";
    begin
        GetNextLineNo;
        RecInfo.TextMode(true);
        FileName := FileMgt.UploadFileSilent(FileName);
        RecInfo.Open(FileName);
        RecInfo.CreateInStream(InFileStream);

        while not(InFileStream.EOS()) do
        begin
            repeat
            InFileStream.ReadText(InText);
            InText := DelChr(InText, '=', ',');
            RecordCode := '';
            RecordType := '';
            FillVariables();
            if RecordCode = 'T' then
                UpdateCLERecord;
            if RecordType = 'Customer' then
                AddCRLine;
            if RecordType = 'Bank' then
                UpdateCRLine;
            until RecordCode = ''

        end;

        RecInfo.Close();

    end;

    local procedure FillVariables();
    begin
        if CopyStr(InText, 1, 1) <> '|' then begin
            RecordCode := CopyStr(InText, 1, 1);
            InText := CopyStr(InText, 3);
        end;

        if RecordCode = 'H' then
            FillHeaderVars
        else if RecordCode = 'L' then begin
                if CopyStr(InText, 1, 1) <> '|' then begin
                    if STRPOS(InText, '|') > 0 then begin
                        RecordType := CopyStr(InText, 1, STRPOS(InText, '|') - 1);
                        InText := CopyStr(InText, STRPOS(InText, '|') + 1);
                    end;
                end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);
                if RecordType = 'Customer' then
                    FillCustVars;
                if RecordType = 'Bank' then
                    FillBankVars;
            end else if RecordCode = 'T' then FillInvVars;


    end;

    local procedure FillHeaderVars();
    begin

        // FILE REFERENCE
        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                FileRef := CopyStr(InText, 1, STRPOS(InText, '|') - 1);
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

        //TOTAL CUSTOMER AND BANK LINES
        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                Evaluate(TotalLines, CopyStr(InText, 1, STRPOS(InText, '|') - 1));
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

        //TOTAL AMOUNT OF PAYMENTS
        if CopyStr(InText, 1, 1) <> '|' then begin
           
            Evaluate(TotalAmt, InText);
        end;
    end;

    local procedure FillCustVars();
    var
        myInt: Integer;
    begin

        //CUSTOMER NO
        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                CustNo := CopyStr(InText, 1, STRPOS(InText, '|') - 1);
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

        Window.Update(1, CustNo);

        //CUSTOMER DESCRIPTION
        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                CustDesc := CopyStr(InText, 1, STRPOS(InText, '|') - 1);
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

        GetScrapField;

        //CUSTOMER AMOUNT
        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                Evaluate(CustAmt, CopyStr(InText, 1, STRPOS(InText, '|') - 1));
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

        GetScrapField;

        //CUSTOMER DATE
        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                DateToText := CopyStr(InText, 1, STRPOS(InText, '|') - 1);
                DateToText := CopyStr(DateToText, 4, 2) + CopyStr(DateToText, 3, 1) +
                          CopyStr(DateToText, 1, 2) + CopyStr(DateToText, 6, 1) +
                          CopyStr(DateToText, 7, 4);
                Evaluate(CustDate, DateToText);
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

        GetScrapField;

        GetScrapField;

        GetScrapField;

        //CHECK NUMBER FIELD
        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                ChkNo := CopyStr(InText, 1, STRPOS(InText, '|') - 1);
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

        //CUSTOMER REFERENCE FIELD
        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                CustRef := CopyStr(InText, 1, STRPOS(InText, '|') - 1);
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

        //CUSTOMER CURRENCY
        if CopyStr(InText, 1, 1) <> '|' then begin
            if InText <> '' then
                CurrCode := InText;
        end;

    end;

    local procedure FillBankVars();
    var
        myInt: Integer;
    begin

        //BANK NO
        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                BankNo := CopyStr(InText, 1, STRPOS(InText, '|') - 1);
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

        GetScrapField;

        //BANK AMOUNT
        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                Evaluate(BankAmt, CopyStr(InText, 1, STRPOS(InText, '|') - 1));
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

        GetScrapField;

        GetScrapField;

        //BANK DATE
        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                DateToText := CopyStr(InText, 1, STRPOS(InText, '|') - 1);
                DateToText := CopyStr(DateToText, 4, 2) + CopyStr(DateToText, 3, 1) +
                          CopyStr(DateToText, 1, 2) + CopyStr(DateToText, 6, 1) +
                          CopyStr(DateToText, 7, 4);
                Evaluate(BankDate, DateToText);
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

        GetScrapField;

        GetScrapField;

        //CUSTOMER NAME FIELD
        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                CustName := CopyStr(InText, 1, STRPOS(InText, '|') - 1);
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

        //CHECK NUMBER FIELD
        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                BChkNo := CopyStr(InText, 1, STRPOS(InText, '|') - 1);
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

        //BANK REFERENCE FIELD
        if CopyStr(InText, 1, 1) <> '|' then begin
            BankRef := InText;
        end;

    end;

    local procedure FillInvVars();
    var
        myInt: Integer;
    begin

        ClearInvVars;

        //INVOICE NO
        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                Evaluate(InvNo, CopyStr(InText, 1, STRPOS(InText, '|') - 1));
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

        Window.Update(2, Format(InvNo));

        //INVOICE DATE
        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                DateToText := CopyStr(InText, 1, STRPOS(InText, '|') - 1);
                DateToText := CopyStr(DateToText, 4, 2) + CopyStr(DateToText, 3, 1) +
                          CopyStr(DateToText, 1, 2) + CopyStr(DateToText, 6, 1) +
                          CopyStr(DateToText, 7, 4);
                Evaluate(InvDate, DateToText);
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

        //INVOICE AMOUNT
        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                Evaluate(InvAmt, CopyStr(InText, 1, STRPOS(InText, '|') - 1));
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

        //ADDT AMOUNT
        if CopyStr(InText, 1, 1) <> '|' then begin
            Evaluate(AddtAmt, InText);
        end;


    end;

    local procedure ClearInvVars();
    begin

        InvDate := 0D;
        InvDateText := '';
        InvAmt := 0;
        InvNo := 0;
        AddtAmt := 0;

    end;

    local procedure UpdateCLERecord();
    begin
        if InvAmt = CustAmt then begin
            GenJnlLine.Reset();
            GenJnlLine.SetFilter("Document No.", ChkNo);
            if GenJnlLine.FindLast() then begin
                if CustLedgRec.Get(InvNo) then begin
                    GenJnlLine."Applies-to Doc. Type" := CustLedgRec."Document Type";
                    GenJnlLine."Applies-to Doc. No." := CustLedgRec."Document No.";
                end;
                GenJnlLine."Applies-to ID" := '';
                GenJnlLine.Modify();
            end;
        end else begin
            if CustLedgRec.Get(InvNo) then begin
                CustLedgRec."Applies-to ID" := ChkNo;
                CustLedgRec.Validate("Amount to Apply", InvAmt);
                CustLedgRec.Modify();
            end;
        end;

    end;

    local procedure UpdateCRLine();
    begin
        GenJnlLine.Reset();
        GenJnlLine.SetFilter("Document No.", ChkNo);
        if GenJnlLine.FindFirst() then
            repeat
            GenJnlLine.Validate("Posting Date", BankDate);
            if GenJnlLine.Description = '' then
                GenJnlLine.Description := CustName;
            GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Bank Account";
            GenJnlLine.Validate("Bal. Account No.", BankNo);
            GenJnlLine.Modify();
            until GenJnlLine.Next = 0;

    end;

    local procedure AddCRLine();
    begin

        Clear(GenJnlLine);
        GenJnlLine."Journal Template Name" := JournalTemplate;
        GenJnlLine."Journal Batch Name" := BatchName;
        GenJnlLine."Line No." := NextLineNo;
        GenJnlLine.Insert();

        GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Payment);
        GenJnlLine."Document No." := ChkNo;
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::Customer);
        GenJnlLine.Validate("Account No.", CustNo);

        GenJnlLine.Description := CustDesc;

        GenJnlLine.Validate(Amount, -CustAmt);

        GenJnlLine."External Document No." := FileRef;
        GenJnlLine."ARC Alloc8 Check No." := CustRef;
        GenJnlLine."Source Code" := GetSourceCode(JournalTemplate);
        GenJnlLine."Applies-to ID" := ChkNo;

        GenJnlLine.Modify();

        NextLineNo := NextLineNo + 10000

    end;

    local procedure GetSourceCode(TemplateName: Code[10]): Code[10];
    var
        GenJnlTemplate: Record "Gen. Journal Template";
    begin
        GenJnlTemplate.Get(TemplateName);
        exit(GenJnlTemplate."Source Code");
    end;

    local procedure GetScrapField();
    begin

        if CopyStr(InText, 1, 1) <> '|' then begin
            if STRPOS(InText, '|') > 0 then begin
                ScrapField := CopyStr(InText, 1, STRPOS(InText, '|') - 1);
                InText := CopyStr(InText, STRPOS(InText, '|') + 1);
            end;
        end else InText := CopyStr(InText, STRPOS(InText, '|') + 1);

    end;

    local procedure GetNextLineNo();
    begin
        GenJnlLine.Reset();
        GenJnlLine.SetRange("Journal Template Name", JournalTemplate);
        GenJnlLine.SetRange("Journal Batch Name", BatchName);
        if GenJnlLine.FindLast() then
            NextLineNo := GenJnlLine."Line No." + 10000
        else
            NextLineNo := 10000;
    end;

    local procedure GetFileName(FilePath: Text): Text
    var
        FileManagement: Codeunit "File Management";
    begin
        exit(FileManagement.GetFileName(FilePath));
    end;

    trigger OnPreReport()
    var
        FileManagement: Codeunit "File Management";
    begin
        if not OnWebClient then begin
            if FileName = '' then
                Error(Text000);
            ServerFileName := FileManagement.UploadFileSilent(FilePath);
        end;
        if BatchName = '' then
            Error(BatchNameBlank);
        if JournalTemplate = '' then
            Error(TempNameBlank);
        GetNextLineNo;

        Window.OPEN(
                'Processing...\\' +
                'Customer  #1####################\' +
                'Invoice   #2####################');

    end;

  
    trigger OnInitReport();
    begin

    end;

    trigger OnPostReport();
    begin
        Window.Close;
    end;

    var

        BatchNameBlank: Label 'Please select the batch name';
        TempNameBlank: Label 'Please select the batch name';
        Text001: Label 'Gen. Journal Template name is blank.';
        Text002: Label 'Gen. Journal Batch name is blank.';
        GenJnlBatch: Record "Gen. Journal Batch";
        Text031: Label 'Import from Text File';
        Text000: Label 'Enter the file name.';
        GenJnlLine: Record "Gen. Journal Line";
        CustLedgRec: Record "Cust. Ledger Entry";
        NextLineNo: Integer;
        InvNo: Integer;
        TotalLines: Integer;
        ChkNo: Code[20];
        RecInfo: File;
        FileName: Text;
        FilePath: Text;
        ServerFileName: Text;
        InFileStream: InStream;
        InText: Text;
        RecordCode: Text[1];
        RecordType: Text[10];
        CustName: Text[40];
        BankNo: Text[20];
        CustDesc: Text[50];
        FileRef: Text[50];
        ScrapField: Text[100];
        DateToText: Text[30];
        InvDateText: Text[6];
        CustRef: Code[20];
        CustNo: Code[20];
        CurrCode: Code[10];
        InvAmt: Decimal;
        CustAmt: Decimal;
        TotalAmt: Decimal;
        AddtAmt: Decimal;
        BankAmt: Decimal;
        BChkNo: Code[20];
        BankRef: Code[20];
        BankDate: Date;
        CustDate: Date;
        InvDate: Date;
        Window: Dialog;
        BatchName: Code[10];
        JournalTemplate: Text[10];
        TemplateCode: Code[20];
        FileManagement: Codeunit "File Management";
        
        [InDataSet]
        OnWebClient: Boolean;
}
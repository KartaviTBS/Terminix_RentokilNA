report 50064 "ARC AR Import"
{
    Caption = 'AR Import';
    ProcessingOnly = true;
    UsageCategory = Administration;

    dataset
    {
        dataitem(ARImport; Integer)
        {
            DataItemTableView = SORTING (Number) WHERE (Number = CONST (1));

            trigger OnAfterGetRecord()
            var
            begin
                GLSetup.Get;
                ReadData;
            end;

            trigger OnPostDataItem()
            var
            begin
                Window.Close;
                Message(ProcessComplete);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

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
                        ToolTip = 'Specifies the name of the file that you want Import';
                        AssistEdit = true;

                        trigger OnAssistEdit()
                        var
                        begin
                            FilePath := FileManagement.OpenFileDialog(Text031, FileName, FileManagement.GetToFilterText('', '.txt'));
                            if ClientTypeMgt.GetCurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop] then
                                ServerFileName := FilePath;
                            FileName := FilePath;
                        end;
                    }

                    field(TemplateName; ARJnlTemplateName)
                    {
                        Caption = 'ARJnlTemplateName';
                    }
                    field(BatchName; ARJnlBatchName)
                    {
                        Caption = 'ARJnlBatchName';

                        Trigger OnLookup(VAR Text: Text): Boolean
                        var
                            ARJnlBatch: Record "Gen. Journal Batch";
                            ARJnlBatches: Page "General Journal Batches";
                        begin
                            if ARJnlTemplateName <> '' then begin
                                ARJnlBatch.SETRANGE("Journal Template Name", ARJnlTemplateName);
                                ARJnlBatches.SETTABLEVIEW(ARJnlBatch);
                            end;

                            ARJnlBatches.LOOKUPMODE := TRUE;
                            ARJnlBatches.EDITABLE := FALSE;
                            if ARJnlBatches.RUNMODAL = ACTION::LookupOK then begin
                                ARJnlBatches.GETRECORD(ARJnlBatch);
                                ARJnlBatchName := ARJnlBatch.Name;
                            end;
                        end;

                    }
                    field(PostingDate; PostingDate)
                    {
                        Caption = 'Posting Date';
                    }
                    
                    field(SourceSystem;SourceSystem)
                    {
                        Caption = 'Import from';
                    }

                }
            }


        }

        trigger OnInit()
        var
        begin
            OnWebClient := ClientTypeMgt.GetCurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop];
        end;

        Trigger OnOpenPage()
        var
        begin
            ARJnlTemplateName := 'SALES';
        end;

    }

    local procedure ReadData();
    var
        ImpFile: File;
        StreamInFile: InStream;
        Buffer: Text;
    begin
        ImpFile.Open(FileName);
        ImpFile.CreateInStream(StreamInFile);
        while not StreamInFile.EOS do begin
            ClearVariables;
            StreamInFile.ReadText(Buffer);
            Evaluate(EntryNo, GetSubString(Buffer, 1));
            Evaluate(DocumentDate, GetSubString(Buffer, 2));
            Evaluate(DocumentType, GetSubString(Buffer, 3));
            Evaluate(DocumentNo, GetSubString(Buffer, 4));
            Evaluate(AccountNo, GetSubString(Buffer, 5));
            //overflow issues with GP Evaluate(Description, GetSubString(Buffer, 6));
            Evaluate(RemainingAmount, GetSubString(Buffer, 7));
            Evaluate(ExternalDocumentNo, GetSubString(Buffer, 8));
            Evaluate(OldPostingDate, GetSubString(Buffer, 9));
            Evaluate(DueDate, GetSubString(Buffer, 10));
            Evaluate(DimCode1, GetSubString(Buffer, 11));
            Evaluate(DimCode2, GetSubString(Buffer, 12));
            Evaluate(DimCode3, GetSubString(Buffer, 13));
            Window.Update(1, EntryNo);
            ImportData;
        end;
        ImpFile.Close;
    end;

    local procedure ImportData();
    var
        Customer: Record Customer;
        CustomerPostGroup: Record "Customer Posting Group";
        ARJnlLine: Record "Gen. Journal Line";
        DimMgt: Codeunit DimensionManagement;
    begin
        ARJournalError := false;
        AccountNo := GetMapping('Customer', AccountNo);
        if Customer.GET(AccountNo) then begin
            if Customer.Blocked = Customer.Blocked::All then
              SaveJrnlErrors('Blocked');
            
            if CustomerPostGroup.Get(Customer."Customer Posting Group") then
                GLBalAccount := CustomerPostGroup."Receivables Account"
            else 
                SaveJrnlErrors('Posting Group');

            GLSetup.Get;
            if DimCode1 <> '' then 
                IF not DimMgt.CheckDimValue(GLSetup."Global Dimension 1 Code", DimCode1) then 
                    SaveJrnlErrors('Dim1 Value');

            if DimCode2 <> '' then 
                IF not DimMgt.CheckDimValue(GLSetup."Global Dimension 2 Code", DimCode2) then 
                    SaveJrnlErrors('Dim2 Value');

            if DimCode3 <> '' then 
                IF not DimMgt.CheckDimValue(GLSetup."Shortcut Dimension 3 Code", DimCode3) then 
                    SaveJrnlErrors('Dim3 Value');

            if not ARJournalError then begin
                Clear(ARJnlLine);
                ARJnlLine.Validate("Journal Template Name", ARJnlTemplateName);
                ARJnlLine.Validate("Journal Batch Name", ARJnlBatchName);
                if NextLineNo = 0 then
                    GetNextLineNo()
                else
                    NextLineNo := NextLineNo + 10000;
                ARJnlLine.VALIDATE("Line No.", NextLineNo);
                ARJnlLine.Validate("Posting Date", PostingDate);
                case DocumentType of
                    'Invoice' :
                        ARJnlLine.Validate("Document Type", ARJnlLine."Document Type"::Invoice);
                    'Credit Memo' :
                        ARJnlLine.Validate("Document Type", ARJnlLine."Document Type"::"Credit Memo");
                    'Payment' :
                        ARJnlLine.Validate("Document Type", ARJnlLine."Document Type"::Payment);
                    'Finance Charge Memo' :
                        ARJnlLine.Validate("Document Type", ARJnlLine."Document Type"::"Finance Charge Memo");                       
                end;
                if (RemainingAmount < 0) and (DocumentType = 'Invoice') then
                    Clear(ARJnlLine."Document Type")
                else
                if (RemainingAmount > 0) and (DocumentType <> 'Invoice') then
                    Clear(ARJnlLine."Document Type");
                DocumentNo := CheckforDuplicates(DocumentNo); //Duplicate Document No check
                ARJnlLine.Validate("Document No.", DocumentNo);
                ARJnlLine.Validate("Account Type", ARJnlLine."Account Type"::Customer);
                ARJnlLine.Validate("Account No.", AccountNo);
                ARJnlLine.Validate(Amount, RemainingAmount);
                ARJnlLine.Validate("Bal. Account Type", ARJnlLine."Bal. Account Type"::"G/L Account");
                ARJnlLine.Validate("Bal. Account No.", GLBalAccount);
                if ExternalDocumentNo = '' then
                  ExternalDocumentNo := DocumentNo;
                ARJnlLine.ValiDATE("External Document No.", ExternalDocumentNo);
                ARJnlLine.ValiDATE("Document Date", DocumentDate);
                ARJnlLine.ValiDATE("Due Date", DueDate);
                ARJnlLine.VALIDATE("Source Code", 'SALESJNL');
                ARJnlLine.Validate("Shortcut Dimension 1 Code", DimCode1);
                ARJnlLine.Validate("Shortcut Dimension 2 Code", DimCode2);
                ARJnlLine.ValidateShortcutDimCode(3, DimCode3);
                ARJnlLine.Insert(true);
                Clear(ARJnlLine."Bal. Gen. Posting Type");
                ARJnlLine.Modify; 
                TotalAR += ARJnlLine.Amount;               
            end;
        end else
            SaveJrnlErrors('Customer');
    end;



    trigger OnPreReport()
    var
    begin
        Window.OPEN('#1##########');
        if not OnWebClient then begin
            if FileName = '' then
                Error(Text000);
            ServerFileName := FileManagement.UploadFileSilent(FilePath);
        end;
        if ARJnlBatchName = '' then
            Error(BatchNameBlank);
        if ARJnlTemplateName = '' then
            Error(TempNameBlank);
        if PostingDate = 0D then
            Error(PostingDateBlank);
        ARJnlErrors.RESET;
        ARJnlErrors.DELETEALL;
    end;

    trigger OnPostReport()
    var
    begin
        Message('Total AR Journal = %1, Total AR Errors = %2',TotalAR,TotalError);
    end;
    local procedure CheckforDuplicates(ARDocumentNo: Code[20]): Code[20]
    var
        ARJnlLine2: Record "Gen. Journal Line";
    begin
        ARJnlLine2.SETRANGE("Journal Template Name", ARJnlTemplateName);
        ARJnlLine2.SETRANGE("Journal Batch Name", ARJnlBatchName); 
        ARJnlLine2.SETRANGE("Document No.",ARDocumentNo); 
        if ARJnlLine2.FindLast then begin   
            if StrLen(ARDocumentNo) > MaxStrLen(ARDocumentNo) - 2 then
              ARDocumentNo := COPYSTR(ARDocumentNo,1,18);
            ARDocumentNo := ARDocumentNo + '-1';  
        end;
        exit(ARDocumentNo);        
    end;
    local procedure ClearVariables();
    var
    begin
        Clear(EntryNo);
        Clear(AccountNo);
        Clear(DocumentDate);
        Clear(OldPostingDate);
        Clear(TermsCode);
        Clear(DueDate);
        Clear(DocumentType);
        Clear(DocumentNo);
        Clear(Description);
        Clear(RemainingAmount);
        Clear(ExternalDocumentNo);
        Clear(GLBalAccount);
        Clear(DimCode1);
        Clear(DimCode2);
        Clear(DimCode3);
    end;

    local procedure GetFileName(FilePath: Text): Text
    var
    begin
        exit(FileManagement.GetFileName(FilePath));
    end;

    local procedure GetNextLineNo();
    var
        ARJnlLine: Record "Item Journal Line";
    begin
        ARJnlLine.Reset;
        ARJnlLine.SetRange("Journal Template Name", ARJnlTemplateName);
        ARJnlLine.SetRange("Journal Batch Name", ARJnlBatchName);
        if ARJnlLine.FindLast then
            NextLineNo := ARJnlLine."Line No." + 10000
        else
            NextLineNo := 10000;
    end;

    local procedure GetSubString(TextString: Text[1024]; ItemNumber: Integer): Text[100];
    VAR
        ReturnValue: Text[100];
        Counter: Integer;
        Char: Text[1];
        TempString: Text[100];
        TabCounter: Integer;
        CharIn: Char;
    begin
        CharIn := 9;
        Counter := 0;
        if TextString <> '' then
            WHILE STRLEN(TextString) > 0 do begin
                Counter += 1;
                if STRPOS(TextString, FORMAT(CharIn)) <> 0 then begin
                    TabCounter += 1;
                    if TabCounter = ItemNumber then
                        exit(DELCHR((COPYSTR(TextString, 1, STRPOS(TextString, FORMAT(CharIn)) - 1)), '<>', '"'));
                    TextString := COPYSTR(TextString, STRPOS(TextString, FORMAT(CharIn)) + 1);
                end else begin
                    TabCounter += 1;
                    if TabCounter = ItemNumber then
                        exit(DELCHR(TextString, '<>', '"'))
                    else
                        exit('');
                end;
            end;
        exit('');
    end;

    local procedure SaveJrnlErrors(ReasonCode: Text[50]);
    var
    begin
        CLEAR(ARJnlErrors);
        ARJnlErrors."Entry No." := EntryNo;
        ARJnlErrors."Account No." := AccountNo;
        ARJnlErrors."Document Date" := DocumentDate;
        ARJnlErrors."Posting Date" := OldPostingDate;
        ARJnlErrors."Terms Code" := TermsCode;
        ARJnlErrors."Due Date" := DueDate;
        ARJnlErrors."Document Type" := DocumentType;
        ARJnlErrors."Document No." := DocumentNo;
        ARJnlErrors.Description := Description;
        ARJnlErrors."Remaining Amount" := RemainingAmount;
        ARJnlErrors."External Document No." := ExternalDocumentNo;
        ARJnlErrors."GL Bal. Account" := GLBalAccount;
        ARJnlErrors."Reason Code" := ReasonCode;
        ARJnlErrors."Dim Code1" := DimCode1;
        ARJnlErrors."Dim Code2" := DimCode2;
        ARJnlErrors."Dim Code3" := DimCode3;
        if NOT ARJnlErrors.Insert then;
        ARJournalError := true;
        TotalError += ARJnlErrors."Remaining Amount";
    end;

    procedure GetMapping(MapType: Text[20]; MapNo: Code[20]): Code[20];
    var
        SystemMapping: Record "ARC System Mapping";
        NewNo: Code[20];
    begin
        SystemMapping.SetRange("Source System", SourceSystem);
        Case MapType of
        'Customer' :
          SystemMapping.SetRange("Source Type", SystemMapping."Source Type"::Customer);
        end;
        SystemMapping.SetRange("Source No.", MapNo);
        if SystemMapping.FindFirst then
            NewNo := SystemMapping."Destination No."
        else
            NewNo := MapNo;
        exit(NewNo);
    end;

    var


        GLSetup: Record "General Ledger Setup";
        ARJnlErrors: Record "ARC AR Journal Errors";
        ARJournalError: Boolean;
        ARJnlBatchName: Code[20];
        ARJnlTemplateName: Code[20];
        DocumentNo: Code[20];
        AccountNo: Code[20];
        TermsCode: Code[10];
        ExternalDocumentNo: Code[35];
        GLBalAccount: Code[20];
        DimCode1: Code[20];
        DimCode2: Code[20];
        DimCode3: Code[20];
        ClientTypeMgt: Codeunit ClientTypeManagement;
        FileManagement: Codeunit "File Management";
        DocumentDate: Date;
        DueDate: Date;
        PostingDate: Date;
        OldPostingDate: Date;
        RemainingAmount: Decimal;
        TotalAR: Decimal;
        TotalError: Decimal;
        Window: Dialog;
        RecInfo: File;
        NextLineNo: Integer;
        EntryNo: Integer;
        TempNameBlank: Label 'Please select the template name';
        BatchNameBlank: Label 'Please select the batch name';
        PostingDateBlank: Label 'Please enter a Posting Date for the Journal';
        ProcessComplete: Label 'Import Complete';
        Text031: Label 'Import from Text File';
        Text000: Label 'Enter the file name.';
        SourceSystem: Option NAV2009, GreatPlains, Sage;
        DocumentType: Text[30];
        Description: Text[50];
        FileName: Text;
        FilePath: Text;
        ServerFileName: Text;

        [InDataSet]
        OnWebClient: Boolean;

}
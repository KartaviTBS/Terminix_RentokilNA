report 50063 "ARC AP Import"
{
    Caption = 'AP Import';
    ProcessingOnly = true;
    UsageCategory = Administration;

    dataset
    {
        dataitem(APImport; Integer)
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

                    field(TemplateName; APJnlTemplateName)
                    {
                        Caption = 'APJnlTemplateName';
                    }
                    field(BatchName; APJnlBatchName)
                    {
                        Caption = 'APJnlBatchName';

                        Trigger OnLookup(VAR Text: Text): Boolean
                        var
                            APJnlBatch: Record "Gen. Journal Batch";
                            APJnlBatches: Page "General Journal Batches";
                        begin
                            if APJnlTemplateName <> '' then begin
                                APJnlBatch.SETRANGE("Journal Template Name", APJnlTemplateName);
                                APJnlBatches.SETTABLEVIEW(APJnlBatch);
                            end;

                            APJnlBatches.LOOKUPMODE := TRUE;
                            APJnlBatches.EDITABLE := FALSE;
                            if APJnlBatches.RUNMODAL = ACTION::LookupOK then begin
                                APJnlBatches.GETRECORD(APJnlBatch);
                                APJnlBatchName := APJnlBatch.Name;
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
            APJnlTemplateName := 'PURCHASES';
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
            //Overflow errors on GP Evaluate(Description, GetSubString(Buffer, 6));
            Evaluate(RemainingAmount, GetSubString(Buffer, 7));
            Evaluate(ExternalDocumentNo, GetSubString(Buffer, 8));
            Evaluate(OldPostingDate, GetSubString(Buffer, 9));
            Evaluate(DueDate, GetSubString(Buffer, 10));
            Evaluate(Vendor1099Code, GetSubString(Buffer, 11));
            Evaluate(DimCode1, GetSubString(Buffer, 12));           
            Evaluate(DimCode2, GetSubString(Buffer, 13));
            Evaluate(DimCode3, GetSubString(Buffer, 14));           
            Window.Update(1, EntryNo);
            ImportData;
        end;
        ImpFile.Close;
    end;

    local procedure ImportData();
    var
        Vendor: Record Vendor;
        VendorPostGroup: Record "Vendor Posting Group";
        IRS1099: Record "IRS 1099 Form-Box";
        APJnlLine: Record "Gen. Journal Line";
        DimMgt: Codeunit DimensionManagement;
    begin
        APJournalError := false;
        AccountNo := GetMapping('Vendor', AccountNo);
        if Vendor.GET(AccountNo) then begin
            if Vendor.Blocked = Vendor.Blocked::All then
                SaveJrnlErrors('Blocked');

            if VendorPostGroup.Get(Vendor."Vendor Posting Group") then
                GLBalAccount := VendorPostGroup."Payables Account"
            else
                SaveJrnlErrors('Posting Group');

            if Vendor1099Code <> '' then
                if not IRS1099.Get(Vendor1099Code) then
                    SaveJrnlErrors('1099 code');

            if DimCode1 <> '' then
                IF not DimMgt.CheckDimValue(GLSetup."Global Dimension 1 Code", DimCode1) then
                    SaveJrnlErrors('Dim1 Value');

            if DimCode2 <> '' then
                IF not DimMgt.CheckDimValue(GLSetup."Global Dimension 2 Code", DimCode2) then
                    SaveJrnlErrors('Dim2 Value');

            if DimCode3 <> '' then
                IF not DimMgt.CheckDimValue(GLSetup."Shortcut Dimension 3 Code", DimCode3) then
                    SaveJrnlErrors('Dim3 Value');

            if not APJournalError then begin
                Clear(APJnlLine);
                APJnlLine.Validate("Journal Template Name", APJnlTemplateName);
                APJnlLine.Validate("Journal Batch Name", APJnlBatchName);
                if NextLineNo = 0 then
                    GetNextLineNo()
                else
                    NextLineNo := NextLineNo + 10000;
                APJnlLine.VALIDATE("Line No.", NextLineNo);
                APJnlLine.Validate("Posting Date", PostingDate);
                case DocumentType of
                    'Invoice' :
                        APJnlLine.Validate("Document Type", APJnlLine."Document Type"::Invoice);
                    'Credit Memo' :
                        APJnlLine.Validate("Document Type", APJnlLine."Document Type"::"Credit Memo");
                    'Payment' :
                        APJnlLine.Validate("Document Type", APJnlLine."Document Type"::Payment);
                    'Finance Charge Memo' :
                        APJnlLine.Validate("Document Type", APJnlLine."Document Type"::"Finance Charge Memo");                       
                end;

                APJnlLine.Validate("Document No.", DocumentNo);
                APJnlLine.Validate("Account Type", APJnlLine."Account Type"::Vendor);
                APJnlLine.Validate("Account No.", AccountNo);
                APJnlLine.Validate(Amount, RemainingAmount);
                APJnlLine.Validate("Bal. Account Type", APJnlLine."Bal. Account Type"::"G/L Account");
                APJnlLine.Validate("Bal. Account No.", GLBalAccount);
                if ExternalDocumentNo = '' then
                  ExternalDocumentNo := DocumentNo;
                APJnlLine.ValiDATE("External Document No.", ExternalDocumentNo);
                APJnlLine.Validate("Document Date", DocumentDate);
                APJnlLine.Validate("Due Date", DueDate);
                APJnlLine.Validate("IRS 1099 Code", Vendor1099Code);
                APJnlLine.VALIDATE("Source Code", 'PURCHJNL');
                APJnlLine.Validate("Shortcut Dimension 1 Code", DimCode1);
                APJnlLine.Validate("Shortcut Dimension 2 Code", DimCode2);
                APJnlLine.ValidateShortcutDimCode(3, DimCode3);
                APJnlLine.Insert(true);
                TotalAP += APJnlLine.Amount;
            end;
        end else
            SaveJrnlErrors('Vendor');
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
        if APJnlBatchName = '' then
            Error(BatchNameBlank);
        if APJnlTemplateName = '' then
            Error(TempNameBlank);
        if PostingDate = 0D then
            Error(PostingDateBlank);
        APJnlErrors.RESET;
        APJnlErrors.DELETEALL;
    end;

    trigger OnPostReport()
    var
    begin
        Message('Total AP Journal = %1, Total AP Errors = %2',TotalAP,TotalError);
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
        Clear(Vendor1099Code);
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
        APJnlLine: Record "Item Journal Line";
    begin
        APJnlLine.Reset;
        APJnlLine.SetRange("Journal Template Name", APJnlTemplateName);
        APJnlLine.SetRange("Journal Batch Name", APJnlBatchName);
        if APJnlLine.FindLast then
            NextLineNo := APJnlLine."Line No." + 10000
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
        CLEAR(APJnlErrors);
        APJnlErrors."Entry No." := EntryNo;
        APJnlErrors."Account No." := AccountNo;
        APJnlErrors."Document Date" := DocumentDate;
        APJnlErrors."Posting Date" := OldPostingDate;
        APJnlErrors."Terms Code" := TermsCode;
        APJnlErrors."Due Date" := DueDate;
        APJnlErrors."Document Type" := DocumentType;
        APJnlErrors."Document No." := DocumentNo;
        APJnlErrors.Description := Description;
        APJnlErrors."Remaining Amount" := RemainingAmount;
        APJnlErrors."External Document No." := ExternalDocumentNo;
        APJnlErrors."GL Bal. Account" := GLBalAccount;
        APJnlErrors."Vendor 1099 Code" := Vendor1099Code;
        APJnlErrors."Reason Code" := ReasonCode;
        APJnlErrors."Dim Code1" := DimCode1;
        APJnlErrors."Dim Code2" := DimCode2;
        APJnlErrors."Dim Code3" := DimCode3;
        if NOT APJnlErrors.Insert then;
        APJournalError := true;
        TotalError += APJnlErrors."Remaining Amount";        
    end;

    procedure GetMapping(MapType: Text[20]; MapNo: Code[20]): Code[20];
    var
        SystemMapping: Record "ARC System Mapping";
        NewNo: Code[20];
    begin
        SystemMapping.SetRange("Source System", SourceSystem);
        Case MapType of
        'Vendor' :
          SystemMapping.SetRange("Source Type", SystemMapping."Source Type"::Vendor);
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
        APJnlErrors: Record "ARC AP Journal Errors";
        APJournalError : Boolean;
        APJnlBatchName: Code[20];
        APJnlTemplateName: Code[20];
        DocumentNo: Code[20];
        AccountNo: Code[20];
        TermsCode: Code[10];
        ExternalDocumentNo: Code[35];
        GLBalAccount: Code[20];
        Vendor1099Code: Code[10];
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
        TotalAP: Decimal;
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
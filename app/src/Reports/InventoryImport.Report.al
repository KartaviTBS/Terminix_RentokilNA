report 50062 "ARC Inventory Import"
{
    Caption = 'Inventory Import';
    ProcessingOnly = true;
    UsageCategory = Administration;

    dataset
    {
        dataitem(InventoryImport; Integer)
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

                    field(TemplateName; ItemJnlTemplateName)
                    {
                        Caption = 'ItemJnlTemplateName';
                    }
                    field(BatchNameBegBal; ItemJnlBatchBegBal)
                    {
                        Caption = 'ItemJnlBatch-BegBal';

                        Trigger OnLookup(VAR Text: Text): Boolean
                        var
                            ItemJnlBatch: Record "Item Journal Batch";
                            ItemJnlBatches: Page "Item Journal Batches";
                        begin
                            if ItemJnlTemplateName <> '' then begin
                                ItemJnlBatch.SETRANGE("Journal Template Name", ItemJnlTemplateName);
                                ItemJnlBatches.SETTABLEVIEW(ItemJnlBatch);
                            end;

                            ItemJnlBatches.LOOKUPMODE := TRUE;
                            ItemJnlBatches.EDITABLE := FALSE;
                            if ItemJnlBatches.RUNMODAL = ACTION::LookupOK then begin
                                ItemJnlBatches.GETRECORD(ItemJnlBatch);
                                ItemJnlBatchBegBal := ItemJnlBatch.Name;
                            end;
                        end;
                    }    

                    field(JnlDocumentNo; JnlDocumentNo)
                    {
                        Caption = 'Jnl Document No.';
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
            ItemJnlBatch: Record "Item Journal Batch";

        begin
            OnWebClient := ClientTypeMgt.GetCurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop];
        end;

        Trigger OnOpenPage()
        var
        begin
            ItemJnlTemplateName := 'ITEM';
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
            Evaluate(ItemNo, GetSubString(Buffer, 2));
            Evaluate(LocationCode, GetSubString(Buffer, 3));
            Evaluate(Quantity, GetSubString(Buffer, 4));
            Evaluate(UOMCode, GetSubString(Buffer, 5));
            Evaluate(StandardCost, GetSubString(Buffer, 6));
            Evaluate(OldPostingDate, GetSubString(Buffer, 7));
            Evaluate(BinCode, GetSubString(Buffer, 8));
            Evaluate(DimCode1, GetSubString(Buffer, 9));
            Evaluate(DimCode2, GetSubString(Buffer, 10));
            Evaluate(DimCode3, GetSubString(Buffer, 11));
            Evaluate(RemQuantity, GetSubString(Buffer, 12));
            Evaluate(InvQuantity, GetSubString(Buffer, 13));
            Evaluate(DocumentType, GetSubString(Buffer, 14));
            Evaluate(DocumentNo, GetSubString(Buffer, 15));
            Evaluate(DocumentLineNo, GetSubString(Buffer, 16));
            Evaluate(PurchaseOrderNo, GetSubString(Buffer, 17));
            Evaluate(TransferOrderNo, GetSubString(Buffer, 18)); 
            Evaluate(VendorNo, GetSubString(Buffer, 19));   
            Evaluate(VendorName, GetSubString(Buffer, 20));   
            Evaluate(OldItemNo, GetSubString(Buffer, 21));   
            Evaluate(OldItemDescription, GetSubString(Buffer, 22));   
            Evaluate(ZeroCost, GetSubString(Buffer, 23));                                                                                                                          
            Window.Update(1, EntryNo);
            ImportData;
        end;
        ImpFile.Close;
    end;

    local procedure ImportData();
    var
        ItemRec: Record Item;
        Location: Record Location;
        UnitofMeasure: Record "Unit of Measure";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        Bin: Record Bin;
        ItemJnlLine: Record "Item Journal Line";
        DefaultDim: Record "Default Dimension";
        DimMgt: Codeunit DimensionManagement;


    begin
        ItemJournalError := false;
        ItemNo := GetMapping('Item', ItemNo);
        if ItemRec.GET(ItemNo) then begin
            
            AgencyItem := ItemRec."ARC Agency Item";

            if Quantity < 0 then
              SaveJrnlErrors('Negative');
            if ItemRec.Blocked then
              SaveJrnlErrors('Blocked');
            AgencyItem := ItemRec."ARC Agency Item";
            UOMCode := Itemrec."Base Unit of Measure";
            if UOMCode <> '' then begin
                if not UnitofMeasure.Get(UOMCode) then 
                    UOMCode := ItemRec."Base Unit of Measure";
 
                if not ItemUnitofMeasure.Get(ItemNo, UOMCode) then begin
                    CLEAR(ItemUnitofMeasure);
                    ItemUnitofMeasure."Item No." := ItemNo;
                    ItemUnitofMeasure.Code := UOMCode;
                    ItemUnitofMeasure."Qty. per Unit of Measure" := 1;
                    ItemUnitofMeasure."NAV Modified by" := 'Inventory Import';
                    ItemUnitofMeasure."NAV Created Date" := CurrentDateTime;
                    ItemUnitofMeasure.Insert(false);
                end;
            end;

            LocationCode := GetMapping('Location', LocationCode);
            if not Location.Get(LocationCode) then 
                SaveJrnlErrors('Location');

            if BinCode <> '' then begin 
                if not Bin.Get(LocationCode, BinCode) then begin
                    Bin."Location Code" := LocationCode;
                    Bin.Code := BinCode;
                    Bin.Insert;
                end;
            end else begin
                if Location."Bin Mandatory" then begin
                    BinCode := 'NoBin';
                    if not Bin.Get(LocationCode,BinCode) then begin 
                        Bin."Location Code" := LocationCode;
                        Bin.Code := BinCode;
                        Bin.Insert;
                    end;
                end;
            end;
            //use nav dimensions from item(dim2&3) and location(dim1) validations 121419
            //if DimCode1 <> '' then 
            //    IF not DimMgt.CheckDimValue(GLSetup."Global Dimension 1 Code", DimCode1) then 
            //        SaveJrnlErrors('Dim1 Value');

            //if DimCode2 <> '' then 
            //    IF not DimMgt.CheckDimValue(GLSetup."Global Dimension 2 Code", DimCode2) then 
            //        SaveJrnlErrors('Dim2 Value');

            //DefaultDim.SetRange("Table ID",27);
            //DefaultDim.SetRange("No.",ItemNo);
            //DefaultDim.SetRange("Dimension Code",GLSetup."Shortcut Dimension 3 Code");
            //if DefaultDim.FindFirst then
            //  DimCode3 := DefaultDim."Dimension Value Code"
            //else
            //if DimCode3 <> '' then 
            //    IF not DimMgt.CheckDimValue(GLSetup."Shortcut Dimension 3 Code", DimCode3) then 
            //        SaveJrnlErrors('Dim3 Value');

            //new code for Rcvd not Invoiced
            if AgencyItem then begin
                if (InvQuantity = 0) and (Quantity = RemQuantity) then 
                    SaveJrnlErrors('GRNI');//receive PO
            end else //not agency
            if (InvQuantity = 0) and (Quantity = RemQuantity) then 
                    SaveJrnlErrors('GRNI');//receive PO

            if (Quantity <> InvQuantity) then begin
                if (InvQuantity<>0) then
                    SaveJrnlErrors('PartPaid');
                if (InvQuantity = 0) and (Quantity<>RemQuantity) then
                    SaveJrnlErrors('SoldNotInv');
            end;

            if not ItemJournalError then begin
                Clear(ItemJnlLine);
                ItemJnlLine.Validate("Journal Template Name", ItemJnlTemplateName);
                //new code Rcvd not Invoiced
                CurItemJnlBatch := ItemJnlBatchBegBal;
                ItemJnlLine.Validate("Journal Batch Name", CurItemJnlBatch);
                if NextLineNo = 0 then
                    GetNextLineNo(ItemJnlLine."Journal Batch Name")
                else
                    NextLineNo := NextLineNo + 10000;
                ItemJnlLine.VALIDATE("Line No.", NextLineNo);
                ItemJnlLine.Validate("Posting Date", PostingDate);
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.");
                ItemJnlLine.Validate("Document No.", JnlDocumentNo);
                ItemJnlLine.Validate("Item No.", ItemNo);
                ItemJnlLine.Validate("Location Code", LocationCode);
                ItemJnlLine.Validate(Quantity, RemQuantity);
                ItemJnlLine.Validate("Bin Code", BinCode);
                ItemJnlLine.ValiDATE("Unit Cost", StandardCost);
                ItemJnlLine.Validate("Unit Amount",StandardCost);
                ItemJnlLine.Validate("Source Code", 'ITEMJNL');
                //use nav dimensions from item and location validations 121419
                //ItemJnlLine.Validate("Shortcut Dimension 1 Code", DimCode1);
                //ItemJnlLine.Validate("Shortcut Dimension 2 Code", DimCode2);
                //ItemJnlLine.ValidateShortcutDimCode(3, DimCode3);
                ItemJnlLine."External Document No." := DocumentNo;
                if Zerocost then                     
                    if AgencyItem then
                        ItemJnlLine."Reason Code" := 'Zero/Ret'
                    else
                        ItemJnlLine."Reason Code" := 'ZeroCost';
                ItemJnlLine.Insert(true);
                TotalINV += ItemJnlLine.Amount;
                if ItemRec."Item Tracking Code" <> '' then
                    CreateLotTracking(ItemJnlLine);                
            end;
        end else
            SaveJrnlErrors('Item');
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
        if ItemJnlBatchBegBal = '' then
            Error(BatchNameBlank);
        if ItemJnlTemplateName = '' then
            Error(TempNameBlank);
        if JnlDocumentNo = '' then
            Error(DocNoBlank);
        if PostingDate = 0D then
            Error(PostingDateBlank);
        InvJrnlErrors.RESET;
        InvJrnlErrors.DELETEALL;
    end;

    trigger OnPostReport()
    var
    begin
        Message('Total INV Journal = %1, Total INV Errors = %2',TotalINV,TotalError);
    end;
    local procedure ClearVariables();
    var
    begin
        Clear(EntryNo);
        Clear(ItemNo);
        Clear(LocationCode);
        Clear(RemQuantity);
        Clear(UOMCode);
        Clear(StandardCost);
        Clear(OldPostingDate);
        Clear(BinCode);
        Clear(DimCode1);
        Clear(DimCode2);
        Clear(DimCode3);
        Clear(Quantity);
        Clear(InvQuantity);
        Clear(DocumentType);
        Clear(DocumentNo);
        Clear(DocumentLineNo);
        Clear(PurchaseOrderNo);
        Clear(TransferOrderNo);
        Clear(VendorNo);
        Clear(VendorName);
        Clear(OldItemNo);
        Clear(OldItemDescription);
        Clear(Zerocost);        
    end;

    local procedure GetFileName(FilePath: Text): Text
    var
    begin
        exit(FileManagement.GetFileName(FilePath));
    end;

    local procedure GetNextLineNo(ItemJnlBatch: Code[10]);
    var
        ItemJnlLine: Record "Item Journal Line";
    begin
        ItemJnlLine.Reset;
        ItemJnlLine.SetRange("Journal Template Name", ItemJnlTemplateName);
        ItemJnlLine.SetRange("Journal Batch Name", CurItemJnlBatch);
        if ItemJnlLine.FindLast then
            NextLineNo := ItemJnlLine."Line No." + 10000
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
        CLEAR(InvJrnlErrors);
        InvJrnlErrors."Entry No." := EntryNo;
        InvJrnlErrors."Item No." := ItemNo;
        InvJrnlErrors."Location Code" := LocationCode;
        InvJrnlErrors."Rem. Quantity" := RemQuantity;
        InvJrnlErrors."Unit of Measure Code" := UOMCode;
        InvJrnlErrors."Posting Date" := OldPostingDate;
        InvJrnlErrors."Standard Cost" := StandardCost;
        InvJrnlErrors."Bin Code" := BinCode;
        InvJrnlErrors."Reason Code" := ReasonCode;
        InvJrnlErrors."Dim Code1" := DimCode1;
        InvJrnlErrors."Dim Code2" := DimCode2;
        InvJrnlErrors."Dim Code3" := DimCode3;
        InvJrnlErrors.Quantity := Quantity;
        InvJrnlErrors."Inv. Quantity" := InvQuantity;
        InvJrnlErrors."Agency Item" := AgencyItem;
        InvJrnlErrors."Document Type" := DocumentType;
        InvJrnlErrors."Document No." := DocumentNo;
        InvJrnlErrors."Document Line No." := DocumentLineNo;
        InvJrnlErrors."Purchase Order No." := PurchaseOrderNo;
        InvJrnlErrors."Transfer Order No." := TransferOrderNo;
        InvJrnlErrors."Vendor No." := VendorNo;
        InvJrnlErrors."Vendor Name" := VendorName;
        InvJrnlErrors."Old Item No." := OldItemNo;
        InvJrnlErrors."Old Item Description" := OldItemDescription;
        InvJrnlErrors."Zero cost" := Zerocost;
        ItemJournalError := true;
        TotalError += (InvJrnlErrors."Rem. Quantity" * InvJrnlErrors."Standard Cost");
        if not InvJrnlErrors.Insert then;
    end;

    procedure GetMapping(MapType: Text[20]; MapNo: Code[20]): Code[20];
    var
        SystemMapping: Record "ARC System Mapping";
        NewNo: Code[20];
    begin
        SystemMapping.SetRange("Source System", SourceSystem);
        Case MapType of
        'Item' :
          SystemMapping.SetRange("Source Type", SystemMapping."Source Type"::Item);
        'Location' :
          SystemMapping.SetRange("Source Type", SystemMapping."Source Type"::Location);
        end;
        SystemMapping.SetRange("Source No.", MapNo);
        if SystemMapping.FindFirst then
            NewNo := SystemMapping."Destination No."
        else
            NewNo := MapNo;
        exit(NewNo);
    end;
    local procedure CreateLotTracking(ItemJnl: Record "Item Journal Line")
    var
        ResEntry: Record "Reservation Entry";
    begin
        With ItemJnl do begin
            if ResEntry.FindLast then
              ResEntry."Entry No." := ResEntry."Entry No." + 1 
            else
              ResEntry."Entry No." := 1;
            ResEntry."Item No." := ItemJnl."Item No.";
            ResEntry."Location Code" := ItemJnl."Location Code";
            ResEntry."Reservation Status" := ResEntry."Reservation Status"::Prospect;
            ResEntry."Source Type" := 83;
            ResEntry."Source Subtype" := 2;
            ResEntry."Source ID" := 'ITEM';
            ResEntry."Source Batch Name" := ItemJnl."Journal Batch Name";
            ResEntry."Source Ref. No." := ItemJnl."Line No.";
            ResEntry."Lot No." := 'TARGET';
            ResEntry."Qty. per Unit of Measure" := 1;
            ResEntry.Validate("Quantity (Base)",ItemJnl."Quantity (Base)");
            ResEntry."Creation Date" := ItemJnl."Posting Date";
            ResEntry."Expected Receipt Date" := ItemJnl."Posting Date";
            ResEntry."Warranty Date" := CalcDate('1Y',ItemJnl."Posting Date");
            ResEntry."Expiration Date" := CalcDate('1Y',ItemJnl."Posting Date");
            ResEntry.INSERT;
        end;
    end;
    
    var

        GLSetup: Record "General Ledger Setup";
        InvJrnlErrors: Record "ARC Inventory Journal Errors";
        AgencyItem: Boolean;
        ItemJournalError: Boolean; 
        Zerocost: Boolean;
        CurItemJnlBatch: Code[20];     
        ItemJnlBatchAgency: Code[20];
        ItemJnlBatchGRNI: Code[20];
        ItemJnlBatchBegBal: Code[20];                
        ItemJnlTemplateName: Code[20];
        DocumentNo: Code[20];
        JnlDocumentNo: Code[20];        
        PurchaseOrderNo: Code[20];
        TransferOrderNo: Code[20];                
        ItemNo: Code[20];
        LocationCode: Code[10];
        UOMCode: Code[10];
        BinCode: Code[20];
        DimCode1: Code[20];
        DimCode2: Code[20];
        DimCode3: Code[20];
        VendorNo: Code[20];
        VendorName: Code[50];
        OldItemNo: Code[20];
        OldItemDescription: Code[50];

        ClientTypeMgt: Codeunit ClientTypeManagement;
        FileManagement: Codeunit "File Management";
        PostingDate: Date;
        OldPostingDate: Date;
        Quantity: Decimal;
        InvQuantity: Decimal;
        RemQuantity: Decimal;               
        StandardCost: Decimal;
        TotalINV: Decimal;
        TotalError: Decimal;        
        Window: Dialog;
        RecInfo: File;
        NextLineNo: Integer;
        EntryNo: Integer;
        DocumentLineNo: Integer;
        TempNameBlank: Label 'Please select the template name';
        BatchNameBlank: Label 'Please select the batch name';
        DocNoBlank: Label 'Please enter a Document No, for the Journal';
        PostingDateBlank: Label 'Please enter a Posting Date for the Journal';
        ProcessComplete: Label 'Import Complete';
        Text031: Label 'Import from Text File';
        Text000: Label 'Enter the file name.';
        SourceSystem: Option NAV2009, GreatPlains, Sage;
        DocumentType: Option  ,"Sls Shpt","Sls Invc","Sls RetRct","Sls CM","Pur Rct","Pur Inv","Pur RetShpt","Pur CM","Trn Shpt","Trn Rct","Svc Shpt","Svc Inv","Svc CM","Posted Assembly";
        FileName: Text;
        FilePath: Text;
        ServerFileName: Text;

        [InDataSet]
        OnWebClient: Boolean;

}
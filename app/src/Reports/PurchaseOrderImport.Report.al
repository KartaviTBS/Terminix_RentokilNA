report 50067 "ARC Purchase Order Import"
{
    Caption = 'Purchase Order Import';
    ProcessingOnly = true;
    UsageCategory = Administration;

    dataset
    {
        dataitem(OrderImport; Integer)
        {
            DataItemTableView = SORTING (Number) WHERE (Number = CONST (1));

            trigger OnAfterGetRecord()
            var
            begin
                GLSetup.get;
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


    }

    local procedure ReadData();
    var
        ImpFile: File;
        StreamInFile: InStream;
        Buffer: Text;
    begin
        ImpFile.Open(FileName);
        ImpFile.CreateInStream(StreamInFile);
        while not StreamInFile.EOS do
        begin
            ClearVariables;
            StreamInFile.ReadText(Buffer);
            Evaluate(CustomerVendorNo, GetSubString(Buffer, 1));
            Evaluate(DocumentNo, GetSubString(Buffer, 2));
            Evaluate(OrderDate, GetSubString(Buffer, 3));
            Evaluate(ShipmentReceiptDate, GetSubString(Buffer, 4));
            Evaluate(PostingDescription, GetSubString(Buffer, 5));
            Evaluate(PaymentTermsCode, GetSubString(Buffer, 6));
            Evaluate(ShipmentMethodCode, GetSubString(Buffer, 7));
            Evaluate(LocationCode, GetSubString(Buffer, 8));
            Evaluate(DimCode1, GetSubString(Buffer, 9));
            Evaluate(DimCode2, GetSubString(Buffer, 10));
            Evaluate(SalespersonPurchaserCode, GetSubString(Buffer, 11));
            Evaluate(ExternalDocumentNo, GetSubString(Buffer, 12));
            Evaluate(ReasonCode, GetSubString(Buffer, 13));
            Evaluate(TransportMethod, GetSubString(Buffer, 14));
            Evaluate(PaymentMethodCode, GetSubString(Buffer, 15));
            Evaluate(RequestedDeliveryReceiptDate, GetSubString(Buffer, 16));
            Evaluate(PromisedDeliveryReceiptDate, GetSubString(Buffer, 17));
            Evaluate(DimCode3, GetSubString(Buffer, 18));
            Evaluate(Vendor1099Code, GetSubString(Buffer, 19));
            Window.Update(1, DocumentNo);
            ImportData;
        end;
        ImpFile.Close;
    end;

    local procedure ImportData();
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        Location: Record Location;
        PaymentTermsRec: Record "Payment Terms";
        ShipmentMethodRec: Record "Shipment Method";
        SalespersonRec: Record "Salesperson/Purchaser";
        ReasonCodeRec: Record "Reason Code";
        DimMgt: Codeunit DimensionManagement;
    begin
        OrdError := false;
        CustomerVendorNo := GetMapping('Vendor', CustomerVendorNo);
        if Vendor.Get(CustomerVendorNo) then begin
            if Vendor.Blocked = Vendor.Blocked::All then
                SaveOrderErrors('Purchase02','Vend Blocked');
            if LocationCode = 'IMPORT' then
              Clear(LocationCode);
            if LocationCode <> ''then begin
                LocationCode := GetMapping('Location', LocationCode);
                if not Location.Get(LocationCode) then
                    SaveOrderErrors('Purchase03','Location');
            end;

            if PaymentTermsCode <> '' then
                if PaymentTermsCode = 'RECEIPT' then
                  PaymentTermsCode := 'COD';
                if not PaymentTermsRec.Get(PaymentTermsCode) then
                    SaveOrderErrors('Purchase05','Payment Terms');


            if ShipmentMethodCode <> '' then
                if not ShipmentMethodRec.Get(ShipmentMethodCode) then
                    SaveOrderErrors('Purchase06','Shipment Method');

            if ReasonCode <> '' then
                if not ReasonCodeRec.Get(ReasonCode) then
                    SaveOrderErrors('Purchase08','Reason Code');

            //if DimCode1 <> '' then
            //    IF not DimMgt.CheckDimValue(GLSetup."Global Dimension 1 Code", DimCode1) then
            //        SaveOrderErrors('Purchase12','Dim1 Value');

            //if DimCode2 <> '' then
            //    IF not DimMgt.CheckDimValue(GLSetup."Global Dimension 2 Code", DimCode2) then
            //        SaveOrderErrors('Purchase13','Dim2 Value');

            //if DimCode3 <> '' then
            //    IF not DimMgt.CheckDimValue(GLSetup."Shortcut Dimension 3 Code", DimCode3) then
            //        SaveOrderErrors('Purchase14','Dim3 Value');
            
            if SalespersonPurchaserCode <> '' then begin
                SalespersonPurchaserCode := GetMapping('SalesPerson', SalespersonPurchaserCode);
                if not SalespersonRec.Get(SalespersonPurchaserCode) then
                    SaveOrderErrors('Purchase15','Salesperson');
            end;        
            if not OrdError then begin
                Clear(PurchaseHeader);
                PurchaseHeader.Validate("Document Type", PurchaseHeader."Document Type"::Order);
                PurchaseHeader.Validate("No.", DocumentNo);
                PurchaseHeader.Validate("Buy-from Vendor No.", CustomerVendorNo);
                PurchaseHeader.Insert(true);
                PurchaseHeader.Validate("Order Date", OrderDate);
                PurchaseHeader.Validate("Expected Receipt Date", ShipmentReceiptDate);
                PurchaseHeader.Validate("Posting Description", PostingDescription);
                PurchaseHeader.Validate("Payment Terms Code", PaymentTermsCode);
                PurchaseHeader.Validate("Shipment Method Code", ShipmentMethodCode);
                PurchaseHeader.Validate("Location Code", LocationCode);
                PurchaseHeader.ValiDATE("Your Reference", ExternalDocumentNo);
                PurchaseHeader.Validate("Purchaser Code", SalespersonPurchaserCode);
                PurchaseHeader."Reason Code" := 'IMPORT';
                PurchaseHeader.Validate("Transport Method", TransportMethod);
                PurchaseHeader.Validate("Payment Method Code", PaymentMethodCode);
                PurchaseHeader.Validate("Requested Receipt Date", RequestedDeliveryReceiptDate);
                PurchaseHeader.Validate("Promised Receipt Date", PromisedDeliveryReceiptDate);
                //PurchaseHeader.Validate("Shortcut Dimension 1 Code", DimCode1);
                //PurchaseHeader.Validate("Shortcut Dimension 2 Code", DimCode2);
                //PurchaseHeader.ValidateShortcutDimCode(3, DimCode3);
                PurchaseHeader.MODIFY;  
                TotalCount += 1;             
            end;
        end else
            SaveOrderErrors('Purchase01','Vendor');
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

        OrderErrors.RESET;
        OrderErrors.SETRANGE("Document Type",'Purchase01','Purchase99');
        OrderErrors.DELETEALL;
    end;

    trigger OnPostReport()
    var
    begin
        Message('Total POs Created = %1, Total PO Errors = %2',TotalCount,TotalError);
    end;
    local procedure ClearVariables();
    var
    begin
        Clear(LocationCode);
        Clear(Vendor1099Code);
        Clear(PaymentMethodCode);
        Clear(PaymentTermsCode);
        Clear(ReasonCode);
        Clear(ShipmentMethodCode);
        Clear(TransportMethod);
        Clear(CustomerVendorNo);
        Clear(DimCode1);
        Clear(DimCode2);
        Clear(DimCode3);
        Clear(DocumentNo);
        Clear(SalespersonPurchaserCode);
        Clear(ExternalDocumentNo);
        Clear(OrderDate);
        Clear(PromisedDeliveryReceiptDate);
        Clear(RequestedDeliveryReceiptDate);
        Clear(ShipmentReceiptDate);
        Clear(DocumentType);
        Clear(PostingDescription);
    end;

    local procedure GetFileName(FilePath: Text): Text
    var
    begin
        exit(FileManagement.GetFileName(FilePath));
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
            WHILE STRLEN(TextString) > 0 do
            begin
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

    local procedure SaveOrderErrors(ErrType: Text[50]; ErrReasonCode: Text[50]);
    var
    begin
        CLEAR(OrderErrors);
        OrderErrors."Document Type" := ErrType;
        OrderErrors."Customer/Vendor No." := CustomerVendorNo;
        OrderErrors."Document No." := DocumentNo;
        OrderErrors."Order Date" := OrderDate;
        OrderErrors."Shipment/Receipt Date" := ShipmentReceiptDate;
        OrderErrors."Posting Description" := PostingDescription;
        OrderErrors."Payment Terms Code" := PaymentTermsCode;
        OrderErrors."Shipment Method Code" := ShipmentMethodCode;
        OrderErrors."Location Code" := LocationCode;
        OrderErrors."Dim Code1" := DimCode1;
        OrderErrors."Dim Code2" := DimCode2;
        OrderErrors."Salesperson/Purchaser Code" := SalespersonPurchaserCode;
        OrderErrors."External Document No." := ExternalDocumentNo;
        OrderErrors."Reason Code" := ReasonCode;
        OrderErrors."Requested Delivery/Receipt Date" := RequestedDeliveryReceiptDate;
        OrderErrors."Promised Delivery/Receipt Date" := PromisedDeliveryReceiptDate;
        OrderErrors."1099 Code" := Vendor1099Code;
        OrderErrors."Payment Method Code" := PaymentMethodCode;
        OrderErrors."Transport Method" := TransportMethod;
        OrderErrors."Dim Code3" := DimCode3;
        OrderErrors."Error Reason Code" := ErrReasonCode;
        if NOT OrderErrors.Insert then;
        OrdError := true;
        TotalError += 1;
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

    var


        GLSetup: Record "General Ledger Setup";
        OrderErrors: Record "ARC Import Order Errors";
        OrdError: Boolean;
        FreeFreight: Boolean;
        BusinessTypeCode: Code[10];
        LocationCode: Code[10];
        Vendor1099Code: Code[10];
        PaymentMethodCode: Code[10];
        PaymentTermsCode: Code[10];
        ReasonCode: Code[10];
        ShipmentMethodCode: Code[10];
        ShippingAgentCode: Code[10];
        ShippingAgentServiceCode: Code[10];
        ShipToCode: Code[10];
        ShipToCountry: Code[10];
        TransportMethod: Code[10];
        CustomerVendorNo: Code[20];
        DimCode1: Code[20];
        DimCode2: Code[20];
        DimCode3: Code[20];
        DocumentNo: Code[20];
        LocalityCode: Code[20];
        SalespersonPurchaserCode: Code[20];

        ShipToPostCode: Code[20];
        EshipAgentService: Code[30];
        ExternalDocumentNo: Code[35];
        ClientTypeMgt: Codeunit ClientTypeManagement;
        FileManagement: Codeunit "File Management";
        DocumentDate: Date;
        OrderDate: Date;
        PromisedDeliveryReceiptDate: Date;
        RequestedDeliveryReceiptDate: Date;
        ShipmentReceiptDate: Date;
        Window: Dialog;
        RecInfo: File;
        TotalCount: Integer;
        TotalError: integer;
        ProcessComplete: Label 'Import Complete';
        Text031: Label 'Import from Text File';
        Text000: Label 'Enter the file name.';
        SourceSystem: Option NAV2009, GreatPlains, Sage;         
        DocumentType: Text[10];
        ShipToCounty: Text[30];
        ShipToCity: Text[30];
        ShipToAddress: Text[50];
        ShipToAddress2: Text[50];
        ShipToContact: Text[50];
        ShipToName: Text[50];
        PostingDescription: Text[50];
        FileName: Text;
        FilePath: Text;
        ServerFileName: Text;

        [InDataSet]
        OnWebClient: Boolean;

}
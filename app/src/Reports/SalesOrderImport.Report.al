report 50065 "ARC Sales Order Import"
{
    Caption = 'Sales Order Import';
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
            Evaluate(ShipToCode, GetSubString(Buffer, 13));
            Evaluate(ShipToName, GetSubString(Buffer, 14));
            Evaluate(ShipToAddress, GetSubString(Buffer, 15));
            Evaluate(ShipToAddress2, GetSubString(Buffer, 16));
            Evaluate(ShipToCity, GetSubString(Buffer, 17));
            Evaluate(ShipToContact, GetSubString(Buffer, 18));
            Evaluate(ShipToPostCode, GetSubString(Buffer, 19));
            Evaluate(ShipToCounty, GetSubString(Buffer, 20));
            Evaluate(ShipToCountry, GetSubString(Buffer, 21));
            Evaluate(ReasonCode, GetSubString(Buffer, 22));
            Evaluate(ShippingAgentCode, GetSubString(Buffer, 23));
            Evaluate(ShippingAgentServiceCode, GetSubString(Buffer, 24));
            Evaluate(RequestedDeliveryReceiptDate, GetSubString(Buffer, 25));
            Evaluate(PromisedDeliveryReceiptDate, GetSubString(Buffer, 26));
            Evaluate(EshipAgentService, GetSubString(Buffer, 27));
            Evaluate(FreeFreight, GetSubString(Buffer, 28));
            Evaluate(LocalityCode, GetSubString(Buffer, 29));
            Evaluate(BusinessTypeCode, GetSubString(Buffer, 30));
            Evaluate(DimCode3, GetSubString(Buffer, 31));
            Window.Update(1, DocumentNo);
            ImportData;
        end;
        ImpFile.Close;
    end;

    local procedure ImportData();
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        Location: Record Location;
        ShipToAddressRec: Record "Ship-to Address";
        PaymentTermsRec: Record "Payment Terms";
        ShipmentMethodRec: Record "Shipment Method";
        SalespersonRec: Record "Salesperson/Purchaser";
        ReasonCodeRec: Record "Reason Code";
        ShippingAgentRec: Record "Shipping Agent";
        ShippingAgentServRec: Record "Shipping Agent Services";
        EshipAgentServRec: Record "E-Ship Agent Service";
        LocalityRec: Record "ARC Locality";
        BusTypeRec: Record "ARC Business Type";
        CustBusTypeRec: Record "ARC Customer Business Type";
        DimMgt: Codeunit DimensionManagement;
    begin
        OrdError := false;
        CustomerVendorNo := GetMapping('Customer', CustomerVendorNo);
        if Customer.Get(CustomerVendorNo) then begin
            if Customer.Blocked = Customer.Blocked::All then
                SaveOrderErrors('Sales02','Cust Blocked');
            if LocationCode <> '' then begin
                LocationCode := GetMapping('Location', LocationCode);
                if not Location.Get(LocationCode) then
                    SaveOrderErrors('Sales03','Location');
            end;
            if ShipToCode <> '' then
              if not ShipToAddressRec.Get(CustomerVendorNo,ShipToCode) then 
                  SaveOrderErrors('Sales04','Ship-to Code');
            if PaymentTermsCode <> '' then
                if PaymentTermsCode = 'RECEIPT' then
                  PaymentTermsCode := 'COD';
                if not PaymentTermsRec.Get(PaymentTermsCode) then
                    SaveOrderErrors('Sales05','Payment Terms');
            if ShipmentMethodCode <> '' then
                if not ShipmentMethodRec.Get(ShipmentMethodCode) then
                    SaveOrderErrors('Sales06','Shipment Method');
            if SalespersonPurchaserCode <> '' then begin
                SalespersonPurchaserCode := GetMapping('SalesPerson', SalespersonPurchaserCode);
                if not SalespersonRec.Get(SalespersonPurchaserCode) then
                    SaveOrderErrors('Sales07','Salesperson');
            end;        
            if ReasonCode <> '' then
                if not ReasonCodeRec.Get(ReasonCode) then
                    SaveOrderErrors('Sales08','Reason Code');
            if ShippingAgentCode <> '' then
                if not ShippingAgentRec.Get(ShippingAgentCode) then
                    SaveOrderErrors('Sales09','Shipping Agent');
            if ShippingAgentServiceCode <> '' then        
                if not ShippingAgentServRec.Get(ShippingAgentCode,ShippingAgentServiceCode) then
                    SaveOrderErrors('Sales10','Shipping Agent Service');
            if EshipAgentService <> '' then
                if not EshipAgentServRec.Get(ShippingAgentCode,EshipAgentService) then
                    SaveOrderErrors('Sales11','E-Ship Agent Service');

            //if DimCode1 <> '' then
            //    IF not DimMgt.CheckDimValue(GLSetup."Global Dimension 1 Code", DimCode1) then
            //        SaveOrderErrors('Sales12','Dim1 Value');

            //if DimCode2 <> '' then
            //    IF not DimMgt.CheckDimValue(GLSetup."Global Dimension 2 Code", DimCode2) then
            //        SaveOrderErrors('Sales13','Dim2 Value');

            //if DimCode3 <> '' then
            //    IF not DimMgt.CheckDimValue(GLSetup."Shortcut Dimension 3 Code", DimCode3) then
            //        SaveOrderErrors('Sales14','Dim3 Value');

            if LocalityCode <> '' then
              if not LocalityRec.Get(ShipToCountry,ShipToPostCode,LocalityCode) then
                Clear(LocalityCode);

            if BusinessTypeCode <> '' then
              if not BusTypeRec.Get(BusinessTypeCode) then
                Clear(BusinessTypeCode);

            if BusinessTypeCode <> '' then
              if not CustBusTypeRec.Get(CustomerVendorNo,ShipToCode,ShipToCountry,ShipToCounty,ShipToPostCode,LocalityCode,BusinessTypeCode) then
                Clear(BusinessTypeCode);
                
            if not OrdError then begin
                Clear(SalesHeader);
                SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order);
                SalesHeader.Validate("No.", DocumentNo);
                SalesHeader.Validate("Sell-to Customer No.", CustomerVendorNo);
                SalesHeader.Insert(true);                
                SalesHeader.Validate("Order Date", OrderDate);
                SalesHeader.Validate("Shipment Date", ShipmentReceiptDate);
                SalesHeader.Validate("Posting Description", PostingDescription);
                SalesHeader.Validate("Payment Terms Code", PaymentTermsCode);
                SalesHeader.Validate("Shipment Method Code", ShipmentMethodCode);
                SalesHeader.Validate("Location Code", LocationCode);
                SalesHeader.ValiDATE("External Document No.", ExternalDocumentNo);
                SalesHeader.Validate("Salesperson Code", SalespersonPurchaserCode);
                SalesHeader.Validate("Ship-To Code", ShipToCode);
                SalesHeader.Validate("Ship-To Name", ShipToName);
                SalesHeader.Validate("Ship-To Address", ShipToAddress);
                SalesHeader.Validate("Ship-To Address 2", ShipToAddress2);
                SalesHeader.Validate("Ship-To City", ShipToCity);
                SalesHeader.Validate("Ship-To County", ShipToCounty);
                SalesHeader.Validate("Ship-to Country/Region Code", ShipToCountry);
                SalesHeader.Validate("Ship-To Contact", ShipToContact);
                SalesHeader."Reason Code":='IMPORT';
                SalesHeader.Validate("Shipping Agent Code", ShippingAgentCode);
                SalesHeader.Validate("Shipping Agent Service Code", ShippingAgentServiceCode);
                SalesHeader.Validate("Requested Delivery Date", RequestedDeliveryReceiptDate);
                SalesHeader.Validate("Promised Delivery Date", PromisedDeliveryReceiptDate);
                SalesHeader.Validate("E-Ship Agent Service", EshipAgentService);
                SalesHeader.Validate("Free Freight", FreeFreight);
                SalesHeader.Validate("ARC Locality Code", LocalityCode);
                SalesHeader.Validate("ARC Business Type Code", BusinessTypeCode);              
                //SalesHeader.Validate("Shortcut Dimension 1 Code", DimCode1);
                //SalesHeader.Validate("Shortcut Dimension 2 Code", DimCode2);
                //SalesHeader.ValidateShortcutDimCode(3, DimCode3);
                SalesHeader.Modify; 
                TotalCount += 1;               
            end;
        end else
            SaveOrderErrors('Sales01','Customer');
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
        OrderErrors.SETRANGE("Document Type",'Sales01','Sales99');
        OrderErrors.DELETEALL;
    end;

    trigger OnPostReport()
    var
    begin
        Message('Total SOs Created = %1, Total SO Errors = %2',TotalCount,TotalError);
    end;
    local procedure ClearVariables();
    var
    begin
        Clear(FreeFreight);
        Clear(LocationCode);
        Clear(Vendor1099Code);
        Clear(PaymentMethodCode);
        Clear(PaymentTermsCode);
        Clear(ReasonCode);
        Clear(ShipmentMethodCode);
        Clear(ShippingAgentCode);
        Clear(ShippingAgentServiceCode);
        Clear(ShipToCode);
        Clear(ShipToCountry);
        Clear(TransportMethod);
        Clear(CustomerVendorNo);
        Clear(DimCode1);
        Clear(DimCode2);
        Clear(DimCode3);
        Clear(DocumentNo);
        Clear(LocalityCode);
        Clear(BusinessTypeCode);
        Clear(SalespersonPurchaserCode);
        Clear(EshipAgentService);
        Clear(ExternalDocumentNo);
        Clear(DocumentDate);
        Clear(OrderDate);
        Clear(PromisedDeliveryReceiptDate);
        Clear(RequestedDeliveryReceiptDate);
        Clear(ShipmentReceiptDate);
        Clear(DocumentType);
        Clear(ShipToCounty);
        Clear(ShipToCity);
        Clear(ShipToAddress);
        Clear(ShipToAddress2);
        Clear(ShipToContact);
        Clear(ShipToName);
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
        OrderErrors."Ship-to Code" := ShipToCode;
        OrderErrors."Ship-to Name" := ShipToName;
        OrderErrors."Ship-to Address" := ShipToAddress;
        OrderErrors."Ship-to Address 2" := ShipToAddress2;
        OrderErrors."Ship-to City" := ShipToCity;
        OrderErrors."Ship-to Contact" := ShipToContact;
        OrderErrors."Ship-to Post Code" := ShipToPostCode;
        OrderErrors."Ship-to County" := ShipToCounty;
        OrderErrors."Ship-to Country/Region Code" := ShipToCountry;
        OrderErrors."Reason Code" := ReasonCode;
        OrderErrors."Shipping Agent Code" := ShippingAgentCode;
        OrderErrors."Shipping Agent Service Code" := ShippingAgentServiceCode;
        OrderErrors."Requested Delivery/Receipt Date" := RequestedDeliveryReceiptDate;
        OrderErrors."Promised Delivery/Receipt Date" := PromisedDeliveryReceiptDate;
        OrderErrors."E-Ship Agent Service" := EshipAgentService;
        OrderErrors."Free Freight" := FreeFreight;
        OrderErrors."Locality Code" := LocalityCode;
        OrderErrors."Business Type Code" := BusinessTypeCode;
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
        'Customer' :
            SystemMapping.SetRange("Source Type", SystemMapping."Source Type"::Customer);
        'Location' :
            SystemMapping.SetRange("Source Type", SystemMapping."Source Type"::Location);
        'SalesPerson' :
            SystemMapping.SetRange("Source Type", SystemMapping."Source Type"::SalesPerson);           
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
        TotalError: Integer;
     
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
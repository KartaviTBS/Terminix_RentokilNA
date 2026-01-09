xmlport 50104 "ARC KorberRcpt"
{
    // SOW11 Körber Edge WMS Integration

    Encoding = UTF8;
    Direction = Export;
    UseRequestPage = false;
    Caption = 'Korber Edge WMS Receipt Export';

    schema
    {
        textelement(PurchaseOrder)
        {
            textelement(ContainerBatchRefHeader)
            {
                XmlName = 'ContainerBatchRef';
            }
            textelement(PurchaseOrderNumberHeader)
            {
                XmlName = 'PurchaseOrderNumber';
            }
            textelement(VendorNumber) { }
            textelement(VendorName) { }
            textelement(BuyerName) { }
            //textelement(AllowBackOrder) { }
            //textelement(ClientName) { }
            //textelement(SpecialInstructions1) { }
            //textelement(SpecialInstructions2) { }
            //textelement(SpecialInstructions3) { }
            //textelement(SpecialInstructions4) { }
            //textelement(SpecialInstructions5) { }
            //textelement(SpecialInstructions6) { }
            //textelement(SpecialInstructions7) { }
            //textelement(BackOrder) { }
            textelement(RMA) { }
            textelement(DueDate) { }
            textelement(Extra1Header)
            {
                XmlName = 'Extra1';
            }
            textelement(Extra2Header)
            {
                XmlName = 'Extra2';
            }
            textelement(Extra3Header)
            {
                XmlName = 'Extra3';
            }
            textelement(Extra4Header)
            {
                XmlName = 'Extra4';
            }
            textelement(Extra5Header)
            {
                XmlName = 'Extra5';
            }
            //textelement(WarehouseTransferLocation) { }
            //textelement(PoType) { }
            //textelement(RequisitionNumber) { }
            //textelement(Email) { }
            //textelement(Packslip) { }
            //textelement(RequestPOD) { }
            //textelement(RequestSH) { }
            //textelement(NoSHReship) { }
            //textelement(OrderSource) { }
            textelement(IntegrationUDF1) { }
            //textelement(IntegrationUDF2) { }
            //textelement(IntegrationUDF3) { }
            //textelement(IntegrationUDF4) { }
            //textelement(IntegrationUDF5) { }
            //textelement(IntegrationUDF6) { }
            //textelement(IntegrationUDF7) { }
            //textelement(IntegrationUDF8) { }
            //textelement(IntegrationUDF9) { }
            //textelement(IntegrationUDF10) { }
            //textelement(IntegrationUDF11) { }
            //textelement(IntegrationUDF12) { }
            //textelement(IntegrationUDF13) { }
            //textelement(IntegrationUDF14) { }
            //textelement(IntegrationUDF15) { }
            //textelement(IntegrationUDF16) { }
            //textelement(IntegrationUDF17) { }
            //textelement(IntegrationUDF18) { }
            //textelement(IntegrationUDF19) { }
            //textelement(IntegrationUDF20) { }
            //textelement(IntegrationUDF21) { }
            //textelement(IntegrationUDF22) { }
            //textelement(IntegrationUDF23) { }
            //textelement(IntegrationUDF24) { }
            //textelement(IntegrationUDF25) { }
            textelement(Lines)
            {
                tableelement(PurchaseOrderLine; Integer)
                {
                    textelement(Warehouse) { }
                    textelement(text_element_Location)
                    {
                        XmlName = 'Location';
                    }
                    textelement(ContainerBatchRefLine)
                    {
                        XmlName = 'ContainerBatchRef';
                    }
                    textelement(PurchaseOrderNumberLine)
                    {
                        XmlName = 'PurchaseOrderNumber';
                    }
                    textelement(LineNumber) { }
                    textelement(ProductCode) { }
                    //textelement(PrimaryLocation) { }
                    textelement(Description) { }
                    textelement(VendorProductNumber) { }
                    textelement(UnitOfMeasureMultiplier) { }
                    textelement(ProductClass) { }
                    textelement(UPC) { }
                    textelement(QuantityExpected) { }
                    //textelement(IsSpecial) { }
                    //textelement(CustomerNumber) { }
                    //textelement(CustomerName) { }
                    //textelement(SalesOrderNumber) { }
                    //textelement(SalesOrderLineNumber) { }
                    //textelement(Attributes) { }
                    //textelement(ReceiveAttributeTracking) { }
                    //textelement(ExpiryDate) { }
                    //textelement(StockItemIndicator) { }
                    //textelement(UnitPrice) { }
                    //textelement(Discount) { }
                    //textelement(CostPrice) { }
                    textelement(Extra1Line)
                    {
                        XmlName = 'Extra1';
                    }
                    textelement(Extra2Line)
                    {
                        XmlName = 'Extra2';
                    }
                    textelement(Extra3Line)
                    {
                        XmlName = 'Extra3';
                    }
                    textelement(Extra4Line)
                    {
                        XmlName = 'Extra4';
                    }
                    textelement(Extra5Line)
                    {
                        XmlName = 'Extra5';
                    }
                    textelement(ExpectedRequiredDate) { }
                    //textelement(SpecialInstructions1) { }
                    //textelement(SpecialInstructions2) { }
                    //textelement(SpecialInstructions3) { }
                    //textelement(SpecialInstructions4) { }
                    //textelement(SpecialInstructions5) { }
                    //textelement(SpecialInstructions6) { }
                    //textelement(SpecialInstructions7) { }
                    textelement(UnitOfMeasureText) { }
                    textelement(CountryOfOrigin) { }
                    //textelement(ContainerStatus) { }
                    //textelement(HostLineReference) { }
                    //textelement(RMAReason) { }
                    //textelement(RMARestockCharge) { }
                    //textelement(CreditNow) { }
                    //textelement(Reship) { }
                    //textelement(ReInvoice) { }
                    //textelement(OverReceiptPercentage) { }
                    textelement(line_IntegrationUDF1)
                    {
                        XmlName = 'IntegrationUDF1';
                    }
                    //textelement(IntegrationUDF2) { }
                    //textelement(IntegrationUDF3) { }
                    //textelement(IntegrationUDF4) { }
                    //textelement(IntegrationUDF5) { }
                    //textelement(IntegrationUDF6) { }
                    //textelement(IntegrationUDF7) { }
                    //textelement(IntegrationUDF8) { }
                    //textelement(IntegrationUDF9) { }
                    //textelement(IntegrationUDF10) { }
                    //textelement(IntegrationUDF11) { }
                    //textelement(IntegrationUDF12) { }
                    //textelement(IntegrationUDF13) { }
                    //textelement(IntegrationUDF14) { }
                    //textelement(IntegrationUDF15) { }
                    //textelement(IntegrationUDF16) { }
                    //textelement(IntegrationUDF17) { }
                    //textelement(IntegrationUDF18) { }
                    //textelement(IntegrationUDF19) { }
                    //textelement(IntegrationUDF20) { }
                    //textelement(IntegrationUDF21) { }
                    //textelement(IntegrationUDF22) { }
                    //textelement(IntegrationUDF23) { }
                    //textelement(IntegrationUDF24) { }
                    //textelement(IntegrationUDF25) { }

                    trigger OnPreXmlItem()
                    begin
                        PurchaseOrderLine.SetRange(Number,1,TempBuf.Count());
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then
                            TempBuf.FindSet(false)
                        else
                            if TempBuf.Next() = 0 then;

                        GetItem(CopyStr(TempBuf."Code 01",1,20),'',CopyStr(TempBuf."Code 04",1,10));
                        KorberMgt.GetLocation(CopyStr(TempBuf."Code 02",1,10),Location);
                        Warehouse := CopyStr(Location."ARC Korber Location Code",1,MaxStrLen(Warehouse));
                        if Warehouse = '' then
                            Warehouse := CopyStr(Location.Code,1,MaxStrLen(Warehouse));
                        ProductCode := CopyStr(KorberMgt.GetStripText(Item."No."),1,MaxStrLen(ProductCode));
                        LineNumber := CopyStr(KorberMgt.GetFormattedWholeValue(TempBuf."Integer 01"),1,MaxStrLen(LineNumber));
                        // ContainerBatchRefLine := CopyStr(ContainerBatchRefHeader + '-' + LineNumber,1,MaxStrLen(ContainerBatchRefLine));
                        ContainerBatchRefLine := CopyStr(ContainerBatchRefHeader,1,MaxStrLen(ContainerBatchRefLine));
                        Extra1Line := CopyStr(ContainerBatchRefLine + '-' + LineNumber,1,MaxStrLen(Extra1Line));
                        Extra2Line := CopyStr(KorberMgt.GetFormattedWholeValue(TempBuf."BigInteger 01"),1,MaxStrLen(Extra2Line));
                        Description := CopyStr(KorberMgt.GetStripText(TempBuf."Text 01"),1,MaxStrLen(Description));
                        UPC := CopyStr(KorberMgt.GetStripText(ItemCrossRefUPC."Cross-Reference Type No."),1,MaxStrLen(UPC));
                        //QuantityOrdered := CopyStr(DelChr(Format(TempBuf."Decimal 01"),'=',','),1,MaxStrLen(QuantityOrdered));
                        //QuantityToPick := CopyStr(DelChr(Format(TempBuf."Decimal 02"),'=',','),1,MaxStrLen(QuantityToPick));
                        //CustomerXRef := CopyStr(TempBuf."Code 03",1,MaxStrLen(CustomerXRef));
                        //Weight := CopyStr(DelChr(Format(ItemUom.Weight),'=',','),1,MaxStrLen(Weight));
                        //Cube := CopyStr(DelChr(Format(ItemUom.Cubage),'=',','),1,MaxStrLen(Cube));
                        UnitOfMeasureText := CopyStr(KorberMgt.GetStripText(TempBuf."Code 04"),1,MaxStrLen(UnitOfMeasureText));
                        CountryOfOrigin := CopyStr(KorberMgt.GetStripText(Item."Country/Region of Origin Code"),1,MaxStrLen(CountryOfOrigin));
                        VendorProductNumber := CopyStr(KorberMgt.GetStripText(TempBuf."Code 03"),1,MaxStrLen(VendorProductNumber));
                        QuantityExpected := CopyStr(KorberMgt.GetFormattedWholeValue(TempBuf."Decimal 02"),1,MaxStrLen(QuantityExpected));
                        ExpectedRequiredDate := CopyStr(Format(CreateDateTime(TempBuf."Date 01",0T),0,9),1,MaxStrLen(ExpectedRequiredDate));
                        UnitOfMeasureMultiplier := CopyStr('1',1,MaxStrLen(UnitOfMeasureMultiplier));
                    end;
                }
            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
    
        actions
        {
            area(processing)
            {
            }
        }
    }

    var
        Item: Record Item;
        ItemCrossRefUPC: Record "Item Cross Reference";
        ItemCrossRefCustXRef: Record "Item Cross Reference";
        ItemUom: Record "Item Unit of Measure";
        Location: Record Location;
        KorberMgt: Codeunit "ARC KorberMgt";
        TempBuf: Record "ARC Buffer" temporary;
        EntryNo: BigInteger;
        Initialized: Boolean;
        DateTimeText: Text;
        Text000Err: Label 'Xmlport was not properly initialized.';

    trigger OnPreXmlPort()
    begin
        if not Initialized then
            Error(Text000Err);
    end;

    procedure GetContainerBatchRefHeader(): Text
    begin
        exit(ContainerBatchRefHeader);
    end;

    local procedure GetItem(_No: Code[20]; _CustNo: Code[20]; _UomCode: Code[10])
    begin
        if Item."No." <> _No then
            Item.Get(_No);
        Clear(ItemCrossRefUPC);
        ItemCrossRefUPC.Reset();
        ItemCrossRefUPC.SetRange("Item No.",_No);
        ItemCrossRefUPC.SetRange("Cross-Reference Type",ItemCrossRefUPC."Cross-Reference Type"::"Bar Code");
        if not ItemCrossRefUPC.FindFirst() then
            Clear(ItemCrossRefUPC);
        Clear(ItemCrossRefCustXRef);
        ItemCrossRefCustXRef.Reset();
        ItemCrossRefCustXRef.SetRange("Item No.",_No);
        ItemCrossRefCustXRef.SetRange("Cross-Reference Type",ItemCrossRefCustXRef."Cross-Reference Type"::Customer);
        ItemCrossRefCustXRef.SetRange("Cross-Reference Type No.",_CustNo);
        if not ItemCrossRefCustXRef.FindFirst() then
            Clear(ItemCrossRefCustXRef);
        Clear(ItemUom);
        ItemUom.Reset();
        ItemUom.SetRange("Item No.",_No);
        ItemUom.SetRange(Code,_UomCode);
        if not ItemUom.FindFirst() then
            Clear(ItemUom);
        if ItemUom.Weight = 0 then
            ItemUom.Weight := Item."Gross Weight";
        if ItemUom.Weight = 0 then
            ItemUom.Weight := 1;
        if ItemUom.Cubage = 0 then
            ItemUom.Cubage := 1;
        ProductClass := CopyStr(KorberMgt.GetStripText(KorberMgt.GetProductClass(_No)),1,MaxStrLen(ProductClass));
    end;

    procedure LoadRecordset(var _tempBuf: Record "ARC Buffer" temporary)
    begin
        // codeunit 50104 "ARC KorberRcptMgt" calls this method to load the lines intended for Korber Edge WMS
        TempBuf.DeleteAll();
        _tempBuf.FindSet(false);
        // search on "Expected Rcpt Date" in this file for an explanation of why DueDate is set here
        DueDate := CopyStr(Format(CreateDateTime(_tempBuf."Date 01",0T),0,9),1,MaxStrLen(DueDate));
        repeat
            TempBuf := _tempBuf;
            TempBuf.Insert();
        until _tempBuf.Next() = 0;
        DateTimeText := CopyStr(KorberMgt.GetFormattedDateTime(),1,MaxStrLen(DateTimeText));
        ContainerBatchRefHeader := CopyStr('RCPT_' + DateTimeText,1,MaxStrLen(ContainerBatchRefHeader));
        Extra1Header := CopyStr(ContainerBatchRefHeader,1,MaxStrLen(Extra1Header));
        // finished with initialization
        Initialized := true;
    end;

    procedure SetPurchaseOrder(_PurchaseHeader: Record "Purchase Header")
    var
        _Salesperson: Record "Salesperson/Purchaser";
        _Vendor: Record Vendor;
        _Text000Err: Label 'Method SetPurchaseOrder() was called without initializing a temporary recordset; be sure to load the document lines first with method LoadRecordset().';
    begin
        // codeunit 50104 "ARC KorberRcptMgt" calls this method to load the lines intended for Korber Edge WMS
        if not Initialized then
            Error(_Text000Err);
        ContainerBatchRefHeader := CopyStr('PO_' + DateTimeText,1,MaxStrLen(ContainerBatchRefHeader));
        _PurchaseHeader.TestField("Document Type",_PurchaseHeader."Document Type"::Order);
        _Vendor.Get(_PurchaseHeader."Buy-from Vendor No.");
        if _PurchaseHeader."Purchaser Code" <> '' then
            if _Salesperson.Get(_PurchaseHeader."Purchaser Code") then
                BuyerName := CopyStr(KorberMgt.GetStripText(_Salesperson.Name),1,MaxStrLen(BuyerName));
        // header fields
        VendorNumber := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."Buy-from Vendor No."),1,MaxStrLen(VendorNumber));
        VendorName := CopyStr(KorberMgt.GetStripText(_Vendor.Name),1,MaxStrLen(VendorName));
        PurchaseOrderNumberHeader := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."No."),1,MaxStrLen(PurchaseOrderNumberHeader));
        PurchaseOrderNumberLine := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."No."),1,MaxStrLen(PurchaseOrderNumberLine));
        // line fields
        TempBuf.FindSet(true);
        repeat
            GetItem(TempBuf."Code 01",_PurchaseHeader."Buy-from Vendor No.",TempBuf."Code 04");
            TempBuf."Code 03" := CopyStr(KorberMgt.GetStripText(Item."Vendor Item No."),1,MaxStrLen(TempBuf."Code 03"));
            TempBuf.Modify();
        until TempBuf.Next() = 0;
    end;

    procedure SetSalesOrder(_SalesHeader: Record "Sales Header")
    var
        _Customer: Record Customer;
        _Text000Err: Label 'Method SetSalesOrder() was called without initializing a temporary recordset; be sure to load the document lines first with method LoadRecordset().';
    begin
        if not Initialized then
            Error(_Text000Err);
        ContainerBatchRefHeader := CopyStr('RMA_' + DateTimeText,1,MaxStrLen(ContainerBatchRefHeader));
        _SalesHeader.TestField("Document Type",_SalesHeader."Document Type"::"Return Order");
        _Customer.Get(_SalesHeader."Sell-to Customer No.");
        // header fields
        VendorNumber := CopyStr(KorberMgt.GetStripText(_Customer."No."),1,MaxStrLen(VendorNumber));
        VendorName := CopyStr(KorberMgt.GetStripText(_Customer.Name),1,MaxStrLen(VendorName));
        PurchaseOrderNumberHeader := CopyStr(KorberMgt.GetStripText(_SalesHeader."No."),1,MaxStrLen(PurchaseOrderNumberHeader));
        PurchaseOrderNumberLine := CopyStr(KorberMgt.GetStripText(_SalesHeader."No."),1,MaxStrLen(PurchaseOrderNumberLine));
        RMA := CopyStr('Y',1,MaxStrLen(RMA));
       // line fields
        TempBuf.FindSet(true);
        repeat
            GetItem(TempBuf."Code 01",'',TempBuf."Code 04");
            TempBuf."Code 03" := CopyStr(KorberMgt.GetStripText(Item."Vendor Item No."),1,MaxStrLen(TempBuf."Code 03"));
            TempBuf.Modify();
        until TempBuf.Next() = 0;
    end;
    procedure SetTransferOrder(_TransferHeader: Record "Transfer Header")
    var
        _Location: Record Location;
        _continue: Boolean;
        _Text000Err: Label 'Method SetTransferOrder() was called without initializing a temporary recordset; be sure to load the document lines first with method LoadRecordset().';
    begin
        if not Initialized then
            Error(_Text000Err);
        ContainerBatchRefHeader := CopyStr('PO_' + DateTimeText,1,MaxStrLen(ContainerBatchRefHeader));
        _Location.Get(_TransferHeader."Transfer-from Code");
        // header fields
        PurchaseOrderNumberHeader := CopyStr(KorberMgt.GetStripText(_TransferHeader."No."),1,MaxStrLen(PurchaseOrderNumberHeader));
        PurchaseOrderNumberLine := CopyStr(KorberMgt.GetStripText(_TransferHeader."No."),1,MaxStrLen(PurchaseOrderNumberLine));
        VendorNumber := CopyStr(KorberMgt.GetStripText(_Location.Code),1,MaxStrLen(VendorNumber));
        VendorName := CopyStr(KorberMgt.GetStripText(_Location.Name),1,MaxStrLen(VendorName));
        // next two lines commented due to wkshop Wed 26 Oct 2022 at 12pm Eastern
        //PurchaseOrderNumberHeader := CopyStr(KorberMgt.GetStripText(_TransferHeader."External Document No."),1,MaxStrLen(PurchaseOrderNumberHeader));
        //PurchaseOrderNumberLine := CopyStr(KorberMgt.GetStripText(_TransferHeader."External Document No."),1,MaxStrLen(PurchaseOrderNumberLine));
    end;
}
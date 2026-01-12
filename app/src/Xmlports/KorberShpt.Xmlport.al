xmlport 50103 "ARC KorberShpt"
{
    // SOW11 Körber Edge WMS Integration

    Encoding = UTF8;
    Direction = Export;
    UseRequestPage = false;
    Caption = 'Korber Edge WMS Shipment Export';

    schema
    {
        textelement(Packslip)
        {
            //textelement(RecordType) { }
            //textelement(BatchControlNumber) { }
            textelement(CustomerNumber) { }
            textelement(OrderNumber) { }
            //textelement(BackOrderNumber) { }
            textelement(CustomerPONumber) { }
            //textelement(CustomerLabel) { }
            //textelement(CrystalPackingSlip) { }
            //textelement(CustomerGroup) { }
            //textelement(LabelText) { }
            textelement(ShipName) { }
            textelement(ShipAddressName1) { }
            textelement(ShipAddressName2) { }
            textelement(ShipCity) { }
            textelement(ShipProviceState) { }
            textelement(ShipPostalZipCode) { }
            textelement(ShipCountry) { }
            textelement(ShipAttnTo) { }
            textelement(ShipTelephoneNumber) { }
            //textelement(BillName) { }
            //textelement(BillAddress1) { }
            //textelement(BillAddress2) { }
            //textelement(BillCity) { }
            //textelement(BillProvinceState) { }
            //textelement(BillPostalZip) { }
            //textelement(BillCoutry) { }
            textelement(ShipDateRequired) { }
            //textelement(ShipTimeRequired) { }
            //textelement(TruckRoute) { }
            textelement(Priority) { }
            textelement(ShipmentPaymentType) { }
            textelement(ShipViaPreferred) { }
            //textelement(ShipPayAccountNumber) { }
            textelement(OrderDate) { }
            //textelement(CancelDate) { }
            textelement(PurchaseOrderType) { }
            //textelement(Consolidate) { }  // remove - wkshop - Mon 24 Oct 2022 at 10am - Paola
            textelement(ShipCompleteOnly) { }
            //textelement(ClientMH10Number) { }
            //textelement(ClientName) { }
            textelement(SpecialInstructions1Header)
            {
                XmlName = 'SpecialInstructions1';
            }
            textelement(SpecialInstructions2Header)
            {
                XmlName = 'SpecialInstructions2';
            }
            textelement(SpecialInstructions3Header)
            {
                XmlName = 'SpecialInstructions3';
            }
            textelement(SpecialInstructions4Header)
            {
                XmlName = 'SpecialInstructions4';
            }
            textelement(SpecialInstructions5Header)
            {
                XmlName = 'SpecialInstructions5';
            }
            textelement(SpecialInstructions6Header)
            {
                XmlName = 'SpecialInstructions6';
            }
            textelement(SpecialInstructions7Header)
            {
                XmlName = 'SpecialInstructions7';
            }
            //textelement(CostCenter) { }
            //textelement(ShipToNumber) { }
            textelement(IsCustomerAcceptsBackorders) { }
            //textelement(TruckStop) { }
            //textelement(TruckDeliveryTime) { }
            //textelement(ShipperName) { }
            //textelement(ShipperAddress1) { }
            //textelement(ShipperAddress2) { }
            //textelement(ShipperCity) { }
            //textelement(ShipperProvinceState) { }
            //textelement(ShipperPostalZipCode) { }
            //textelement(PackingSlip) { }
            //textelement(IncludePickZones) { }
            //textelement(ExcludePickZones) { }
            //textelement(IncludeReplenishmentZones) { }
            //textelement(ShipWithOtherGoods) { }  // remove - wkshop - Mon 24 Oct 2022 at 10am - Paola
            //textelement(DontSplitExpiryDates) { }
            //textelement(ShipmentOptions) { }
            //textelement(ShipmentActions) { }
            //textelement(ShipmentMessage) { }
            //textelement(ManifestReportName) { }
            //textelement(COD) { }
            //textelement(ShipmentConsolidation) { }
            //textelement(PricingTicket) { }
            //textelement(DontShipBeforeDate) { }
            //textelement(ShipToFaxNumber) { }
            //textelement(WaveNumber) { }
            //textelement(ReplenishmentGroup) { }
            //textelement(GiftCertificateNumber) { }
            //textelement(GiftCertificateAmount) { }
            //textelement(GiftCertificateAmountUsed) { }
            //textelement(BusinessTelephoneNumber) { }
            textelement(Email) { }
            //textelement(CreditCardNumber) { }
            //textelement(CreditCardExpiry) { }
            //textelement(CreditCardStatus) { }
            //textelement(TotalInvoiceAmmountCharge) { }
            //textelement(TotalTaxToCharge1) { }
            //textelement(TotalFreightToCharge) { }
            //textelement(TotalShippingHandlingCharge) { }
            //textelement(PromoAmount) { }
            //textelement(PromoDiscount) { }
            //textelement(EndOfLineProcess) { }
            //textelement(PurchaseOrderNumber) { }
            //textelement(MinimumDaysOfExpiry) { }
            //textelement(MixedLotIndicator) { }
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
            //textelement(Handle) { }
            //textelement(CustomerCartonContentLabel) { }
            textelement(CartonType) { }
            textelement(WarehouseTransitLocation) { }
            textelement(WarehouseDestinationLocation) { }
            //textelement(DestinationBinLocation) { }
            //textelement(PlannerID) { }
            //textelement(ControlBuyerID) { }
            //textelement(SchedulledStartDate) { }
            //textelement(FinishedGoodItemNumber) { }
            //textelement(FinishedGoodDescription) { }
            //textelement(FinishedGoodClassID) { }
            //textelement(MOENdingQuantity) { }
            //textelement(FirstWorkCenter) { }
            //textelement(MODescription) { }
            //textelement(PrimaryBillToAddress) { }
            //textelement(WorkArea) { }
            //textelement(ShipperEIN) { }
            //textelement(ShipToEIN) { }
            //textelement(Shipper) { }
            //textelement(OrderSource) { }
            textelement(Lines)
            {
                tableelement(PackslipLine; Integer)
                {
                    textelement(Warehouse) { }
                    //textelement(LocationName)  // commented due to wkshop Tue 25 Oct 2022 at 9a Eastern
                    //{
                    //    XmlName = 'Location';
                    //}
                    //textelement(CustomerNumber) { }
                    textelement(OrderNumberLine)
                    {
                        XmlName = 'OrderNumber';
                    }
                    //textelement(BackOrderNumber) { }
                    //textelement(StoreNumber) { }
                    //textelement(DepartmentNumber) { }
                    //textelement(PromoNumber) { }
                    textelement(OrderSequenceNumber) { }
                    textelement(CustomerLineReference) { }
                    textelement(ProductCode) { }
                    //textelement(PrimaryLocation) { }
                    textelement(Description) { }
                    textelement(UnitOfMeasureMultiplier) { }
                    textelement(ProductClass) { }
                    textelement(UPC) { }
                    textelement(QuantityOrdered) { }
                    textelement(QuantityToPick) { }
                    textelement(HazmatCode) { }
                    textelement(CustomerXRef) { }
                    //textelement(CommentIndicator) { }
                    textelement(UnitPrice) { }
                    textelement(Weight) { }
                    textelement(Cube) { }
                    //textelement(CustomerPoNumber) { }
                    //textelement(Discount) { }
                    //textelement(RetailPrice) { }
                    //textelement(ValuePrice) { }
                    //textelement(PriceTicketDescription) { }
                    //textelement(DaysToExpire) { }
                    //textelement(VendorNumber) { }
                    textelement(CountryOfOrigin) { }
                    //textelement(SellPrice) { }
                    //textelement(StockItem) { }
                    //textelement(PurchaseOrderNumber) { }
                    //textelement(PurchaseOrderLineNumber) { }
                    //textelement(EDPNumber) { }
                    //textelement(Commitment) { }
                    textelement(SpecialInstructions1Line)
                    {
                        XmlName = 'SpecialInstructions1';
                    }
                    textelement(SpecialInstructions2Line)
                    {
                        XmlName = 'SpecialInstructions2';
                    }
                    textelement(SpecialInstructions3Line)
                    {
                        XmlName = 'SpecialInstructions3';
                    }
                    textelement(SpecialInstructions4Line)
                    {
                        XmlName = 'SpecialInstructions4';
                    }
                    textelement(SpecialInstructions5Line)
                    {
                        XmlName = 'SpecialInstructions5';
                    }
                    textelement(SpecialInstructions6Line)
                    {
                        XmlName = 'SpecialInstructions6';
                    }
                    textelement(SpecialInstructions7Line)
                    {
                        XmlName = 'SpecialInstructions7';
                    }
                    // data stored in flds Extra1..Extra5 w/b echoed back unmodified ... allows host interfaces to associate extra fields
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
                    //textelement(VariableLengthProduct) { }
                    //textelement(KitType) { }
                    //textelement(InnerPacksize) { }
                    //textelement(MiddlePacksize) { }
                    textelement(UnitOfMeasureTextDescription) { }
                    //textelement(ReservationType) { }
                    //textelement(CommodityCode) { }
                    //textelement(LicensePlate) { }
                    //textelement(PackClass) { }
                    //textelement(BackflushFlag) { }
                    //textelement(Salesman) { }
                    //textelement(MinimumDaysOfExpiry) { }
                    textelement(IntegrationUDF1) { }
                    textelement(IntegrationUDF2) { }

                    trigger OnPreXmlItem()
                    begin
                        PackslipLine.SetRange(Number,1,TempBuf.Count());
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then
                            TempBuf.FindSet(false)
                        else
                            if TempBuf.Next() = 0 then;

                        GetItem(CopyStr(TempBuf."Code 01",1,20),'','',CopyStr(TempBuf."Code 04",1,10));
                        UnitOfMeasureTextDescription := CopyStr(UnitOfMeasure.Description,1,MaxStrLen(UnitOfMeasureTextDescription));
                        if UnitOfMeasureTextDescription = '' then
                            UnitOfMeasureTextDescription := CopyStr('Each',1,MaxStrLen(UnitOfMeasureTextDescription));
                        KorberMgt.GetLocation(CopyStr(TempBuf."Code 02",1,10),Location);
                        Warehouse := CopyStr(KorberMgt.GetStripText(Location."ARC Korber Location Code"),1,MaxStrLen(Warehouse));
                        if Warehouse = '' then
                            Warehouse := CopyStr(KorberMgt.GetStripText(Location.Code),1,MaxStrLen(Warehouse));
                        //LocationName := CopyStr(KorberMgt.GetStripText(Location.Name),1,MaxStrLen(LocationName));  // commented due to wkshop Tue 25 Oct 2022 at 9a Eastern
                        ProductCode := CopyStr(KorberMgt.GetStripText(Item."No."),1,MaxStrLen(ProductCode));
                        OrderSequenceNumber := CopyStr(KorberMgt.GetFormattedWholeValue(TempBuf."Integer 01"),1,MaxStrLen(CustomerLineReference));
                        CustomerLineReference := CopyStr(KorberMgt.GetFormattedWholeValue(TempBuf."Integer 01"),1,MaxStrLen(CustomerLineReference));
                        Description := CopyStr(KorberMgt.GetStripText(TempBuf."Text 01"),1,MaxStrLen(Description));
                        UnitOfMeasureMultiplier := CopyStr(KorberMgt.GetFormattedWholeValue(1),1,MaxStrLen(UnitOfMeasureMultiplier));
                        UPC := CopyStr(KorberMgt.GetStripText(ItemCrossRefUPC."Cross-Reference Type No."),1,MaxStrLen(UPC));
                        //QuantityOrdered := CopyStr(KorberMgt.GetFormattedWholeValue(TempBuf."Decimal 01"),1,MaxStrLen(QuantityOrdered));
                        QuantityOrdered := CopyStr(KorberMgt.GetFormattedWholeValue(TempBuf."Decimal 02"),1,MaxStrLen(QuantityOrdered));
                        QuantityToPick := CopyStr(KorberMgt.GetFormattedWholeValue(TempBuf."Decimal 02"),1,MaxStrLen(QuantityToPick));
                        CustomerXRef := CopyStr(KorberMgt.GetStripText(TempBuf."Code 03"),1,MaxStrLen(CustomerXRef));
                        Weight := CopyStr(KorberMgt.GetFormattedWholeValue(ItemUom.Weight),1,MaxStrLen(Weight));
                        Cube := CopyStr(KorberMgt.GetFormattedWholeValue(ItemUom.Cubage),1,MaxStrLen(Cube));
                        CountryOfOrigin := CopyStr(KorberMgt.GetStripText(Item."Country/Region of Origin Code"),1,MaxStrLen(CountryOfOrigin));
                        // ContainerBatchRefLine := CopyStr(ContainerBatchRefHeader + '-' + CustomerLineReference,1,MaxStrLen(ContainerBatchRefLine));
                        ContainerBatchRefLine := CopyStr(ContainerBatchRefHeader,1,MaxStrLen(ContainerBatchRefLine));
                        Extra1Line := CopyStr(KorberMgt.GetStripText(ContainerBatchRefLine + '-' + CustomerLineReference),1,MaxStrLen(Extra1Line));
                        Extra2Line := CopyStr(KorberMgt.GetFormattedWholeValue(TempBuf."BigInteger 01"),1,MaxStrLen(Extra2Line));
                        // BEGIN - email fr Erik sent Sun 16 Oct 2022 at 154pm Eastern - file "SOxmlToWMS.xlsx"
                        if TempBuf."Decimal 03" <> 0 then  // UnitPrice tag must not be empty - wkshop Tue 25 Oct 2022
                            UnitPrice := CopyStr(KorberMgt.GetFormattedWholeValue(TempBuf."Decimal 03"),1,MaxStrLen(UnitPrice));
                        // END - email fr Erik sent Sun 16 Oct 2022 at 154pm Eastern - file "SOxmlToWMS.xlsx"
                        // load line comments
                        if LoadSalesLineComments then
                            SetSpecialInstructionsLine(OrderNumber,TempBuf."Integer 01");
                        SetUserDefinedFields(Item);  // ref concall Wed 16 Nov 2022 at 12pm Eastern
                    end;
                }
            }
        }
    }

    var
        Item: Record Item;
        ItemCrossRefUPC: Record "Item Cross Reference";
        ItemCrossRefCustXRef: Record "Item Cross Reference";
        ItemUom: Record "Item Unit of Measure";
        KorberSetup: Record "ARC Korber Setup";
        Location: Record Location;
        UnitOfMeasure: Record "Unit of Measure";
        KorberMgt: Codeunit "ARC KorberMgt";
        TempBuf: Record "ARC Buffer" temporary;
        EntryNo: BigInteger;
        Initialized: Boolean;
        LoadSalesLineComments: Boolean;
        ContainerBatchRefHeader: Text;
        ContainerBatchRefLine: Text;
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

    local procedure GetItem(_No: Code[20]; _CustNo: Code[20]; _VendNo: Code[20]; _UomCode: Code[10])
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
        if _CustNo <> '' then begin
            ItemCrossRefCustXRef.SetRange("Cross-Reference Type",ItemCrossRefCustXRef."Cross-Reference Type"::Customer);
            ItemCrossRefCustXRef.SetRange("Cross-Reference Type No.",_CustNo);
        end else
        if _VendNo <> '' then begin
            ItemCrossRefCustXRef.SetRange("Cross-Reference Type",ItemCrossRefCustXRef."Cross-Reference Type"::Vendor);
            ItemCrossRefCustXRef.SetRange("Cross-Reference Type No.",_VendNo);
        end;
        if not ItemCrossRefCustXRef.FindFirst() then
            Clear(ItemCrossRefCustXRef);
        Clear(UnitOfMeasure);
        UnitOfMeasure.Reset();
        if not UnitOfMeasure.Get(_UomCode) then
            Clear(UnitOfMeasure);
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
        // codeunit 50103 "ARC KorberShptMgt" calls this method to load the lines intended for Korber Edge WMS
        TempBuf.DeleteAll();
        _tempBuf.FindSet(false);
        repeat
            TempBuf := _tempBuf;
            TempBuf.Insert();
        until _tempBuf.Next() = 0;
        DateTimeText := CopyStr(KorberMgt.GetFormattedDateTime(),1,MaxStrLen(DateTimeText));
        ContainerBatchRefHeader := CopyStr(KorberMgt.GetStripText('SO_' + DateTimeText),1,MaxStrLen(ContainerBatchRefHeader));
        Extra1Header := CopyStr(ContainerBatchRefHeader,1,MaxStrLen(Extra1Header));
        // BEGIN - email fr Erik sent Sun 16 Oct 2022 at 154pm Eastern - file "SOxmlToWMS.xlsx"
        ShipmentPaymentType := CopyStr('NotSpecified',1,MaxStrLen(ShipmentPaymentType));
        PurchaseOrderType := CopyStr('NotSpecified',1,MaxStrLen(PurchaseOrderType));
        // Consolidate := CopyStr('true',1,MaxStrLen(Consolidate));  // remove - wkshop - Mon 24 Oct 2022 at 10am - Paola
        // change ShipCompleteOnly based on wkshop Wed 26 Oct 2022 - default s/b false
        ShipCompleteOnly := CopyStr('false',1,MaxStrLen(ShipCompleteOnly));
        IsCustomerAcceptsBackorders := CopyStr('true',1,MaxStrLen(IsCustomerAcceptsBackorders));
        // ShipWithOtherGoods := CopyStr('true',1,MaxStrLen(ShipWithOtherGoods));  // remove - wkshop - Mon 24 Oct 2022 at 10am - Paola
        CartonType := CopyStr('NotSpecified',1,MaxStrLen(CartonType));
        // END - email fr Erik sent Sun 16 Oct 2022 at 154pm Eastern - file "SOxmlToWMS.xlsx"
        if not KorberSetup.Get() then
            Clear(KorberSetup);
        Initialized := true;
    end;

    procedure SetPurchaseReturn(_PurchaseHeader: Record "Purchase Header")
    var
        _PurchaseLine: Record "Purchase Line";
        _Vendor: Record Vendor;
        _continue: Boolean;
        _Text000Err: Label 'Method SetPurchaseReturn() was called without initializing a temporary recordset; be sure to load the document lines first with method LoadRecordset().';
    begin
        if not Initialized then
            Error(_Text000Err);
        _PurchaseHeader.TestField("Document Type",_PurchaseHeader."Document Type"::"Return Order");
        _Vendor.Get(_PurchaseHeader."Buy-from Vendor No.");
        // header fields
        CustomerNumber := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."Buy-from Vendor No."),1,MaxStrLen(CustomerNumber));
        OrderNumber := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."No."),1,MaxStrLen(OrderNumber));
        OrderNumberLine := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."No."),1,MaxStrLen(OrderNumber));
        CustomerPONumber := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."Your Reference"),1,MaxStrLen(CustomerPONumber));
        ShipName := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."Ship-to Name"),1,MaxStrLen(ShipName));
        ShipAddressName1 := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."Ship-to Address"),1,MaxStrLen(ShipAddressName1));
        ShipAddressName2 := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."Ship-to Address 2"),1,MaxStrLen(ShipAddressName2));
        ShipCity := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."Ship-to City"),1,MaxStrLen(ShipCity));
        ShipProviceState := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."Ship-to County"),1,MaxStrLen(ShipProviceState));
        ShipPostalZipCode := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."Ship-to Post Code"),1,MaxStrLen(ShipPostalZipCode));
        ShipCountry := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."Ship-to Country/Region Code"),1,MaxStrLen(ShipCountry));
        ShipAttnTo := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."Ship-to Contact"),1,MaxStrLen(ShipAttnTo));
        ShipTelephoneNumber := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."Ship-to Phone No. -CL-"),1,MaxStrLen(ShipTelephoneNumber));
        ShipViaPreferred := CopyStr(KorberMgt.GetStripText(_PurchaseHeader."Shipment Method Code"),1,MaxStrLen(ShipViaPreferred));
        OrderDate := CopyStr(Format(CreateDateTime(_PurchaseHeader."Order Date",0T),0,9),1,MaxStrLen(OrderDate));
        Email := CopyStr(KorberMgt.GetStripText(_Vendor."E-Mail"),1,MaxStrLen(Email));
        // Paola requested ShipDateRequired be populated on Purchase Return Orders - Mon 23 Jan 2023 at 641pm -- Erik specified Document Date today, Mon 30 Jan 2023 at 1059am Eastern
        if (_PurchaseHeader."Document Date" = 0D) or (_PurchaseHeader."Document Date" < Today()) then
            ShipDateRequired := CopyStr(Format(CreateDateTime(Today(),0T),0,9),1,MaxStrLen(ShipDateRequired))
        else
            ShipDateRequired := CopyStr(Format(CreateDateTime(_PurchaseHeader."Document Date",0T),0,9),1,MaxStrLen(ShipDateRequired));
        // line fields
        TempBuf.FindSet(true);
        repeat
            GetItem(TempBuf."Code 01",'',_Vendor."No.",TempBuf."Code 04");
            TempBuf."Code 03" := CopyStr(KorberMgt.GetStripText(Item."Vendor Item No."),1,MaxStrLen(TempBuf."Code 03"));
            TempBuf.Modify();
        until TempBuf.Next() = 0;
    end;

    procedure SetSalesOrder(_SalesHeader: Record "Sales Header")
    var
        _Customer: Record Customer;
        _continue: Boolean;
        _Text000Err: Label 'Method SetSalesOrder() was called without initializing a temporary recordset; be sure to load the document lines first with method LoadRecordset().';
    begin
        if not Initialized then
            Error(_Text000Err);
        _SalesHeader.TestField("Document Type",_SalesHeader."Document Type"::Order);
        _Customer.Get(_SalesHeader."Sell-to Customer No.");
        // header fields
        CustomerNumber := CopyStr(KorberMgt.GetStripText(_SalesHeader."Sell-to Customer No."),1,MaxStrLen(CustomerNumber));
        OrderNumber := CopyStr(KorberMgt.GetStripText(_SalesHeader."No."),1,MaxStrLen(OrderNumber));
        OrderNumberLine := CopyStr(KorberMgt.GetStripText(_SalesHeader."No."),1,MaxStrLen(OrderNumber));
        CustomerPONumber := CopyStr(KorberMgt.GetStripText(_SalesHeader."External Document No."),1,MaxStrLen(CustomerPONumber));
        ShipName := CopyStr(KorberMgt.GetStripText(_SalesHeader."Ship-to Name"),1,MaxStrLen(ShipName));
        ShipAddressName1 := CopyStr(KorberMgt.GetStripText(_SalesHeader."Ship-to Address"),1,MaxStrLen(ShipAddressName1));
        ShipAddressName2 := CopyStr(KorberMgt.GetStripText(_SalesHeader."Ship-to Address 2"),1,MaxStrLen(ShipAddressName2));
        ShipCity := CopyStr(KorberMgt.GetStripText(_SalesHeader."Ship-to City"),1,MaxStrLen(ShipCity));
        ShipProviceState := CopyStr(KorberMgt.GetStripText(_SalesHeader."Ship-to County"),1,MaxStrLen(ShipProviceState));
        ShipPostalZipCode := CopyStr(KorberMgt.GetStripText(_SalesHeader."Ship-to Post Code"),1,MaxStrLen(ShipPostalZipCode));
        ShipCountry := CopyStr(KorberMgt.GetStripText(_SalesHeader."Ship-to Country/Region Code"),1,MaxStrLen(ShipCountry));
        ShipAttnTo := CopyStr(KorberMgt.GetStripText(_SalesHeader."Ship-to Contact"),1,MaxStrLen(ShipAttnTo));
        ShipTelephoneNumber := CopyStr(KorberMgt.GetStripText(_SalesHeader."Ship-to Phone No. -CL-"),1,MaxStrLen(ShipTelephoneNumber));
        ShipViaPreferred := CopyStr(KorberMgt.GetStripText(_SalesHeader."Shipment Method Code"),1,MaxStrLen(ShipViaPreferred));
        OrderDate := CopyStr(Format(CreateDateTime(_SalesHeader."Order Date",0T),0,9),1,MaxStrLen(OrderDate));
        if (_SalesHeader."Requested Delivery Date" = 0D) or (_SalesHeader."Requested Delivery Date" < Today()) then
            ShipDateRequired := CopyStr(Format(CreateDateTime(Today(),0T),0,9),1,MaxStrLen(ShipDateRequired))
        else
            ShipDateRequired := CopyStr(Format(CreateDateTime(_SalesHeader."Requested Delivery Date",0T),0,9),1,MaxStrLen(ShipDateRequired));
        Email := CopyStr(KorberMgt.GetStripText(_Customer."E-Mail"),1,MaxStrLen(Email));
        // BEGIN - email fr Erik sent Sun 16 Oct 2022 at 154pm Eastern - file "SOxmlToWMS.xlsx"
        if _SalesHeader."Shipment Method Code" = KorberSetup."Hazmat Shpt. Method Code" then
            HazmatCode := CopyStr('H',1,MaxStrLen(HazmatCode));
        // END - email fr Erik sent Sun 16 Oct 2022 at 154pm Eastern - file "SOxmlToWMS.xlsx"
        // change ShipCompleteOnly based on wkshop Wed 26 Oct 2022 - default s/b false - s/b true if Shipping Advice is Complete
        if _SalesHeader."Shipping Advice" = _SalesHeader."Shipping Advice"::Complete then
            ShipCompleteOnly := CopyStr('true',1,MaxStrLen(ShipCompleteOnly));
        //SK1.0 
        Priority := CopyStr(KorberMgt.GetStripText(_SalesHeader.Priority_Korber),1,MaxStrLen(Priority));
        // line fields
        TempBuf.FindSet(true);
        repeat
            GetItem(TempBuf."Code 01",_SalesHeader."Sell-to Customer No.",'',TempBuf."Code 04");
            TempBuf."Code 03" := CopyStr(KorberMgt.GetStripText(Item."Vendor Item No."),1,MaxStrLen(TempBuf."Code 03"));
            TempBuf.Modify();
        until TempBuf.Next() = 0;
        // load header comments from sales order
        SetSpecialInstructions(_SalesHeader);
        LoadSalesLineComments := true;
    end;

    local procedure SetSpecialInstructions(_SalesHeader: Record "Sales Header")
    var
        _SalesCommentLine: Record "Sales Comment Line";
        _CommentNo: Integer;
    begin
        // gather header comments
        _CommentNo := 1;
        _SalesCommentLine.SetRange("Document Type",_SalesHeader."Document Type");
        _SalesCommentLine.SetRange("No.",_SalesHeader."No.");
        _SalesCommentLine.SetRange("Document Line No.",0);
        _SalesCommentLine.SetFilter(Comment,'<>%1','');
        if _SalesCommentLine.FindSet(false) then
            repeat
                if _SalesCommentLine."Print On Pick Ticket" or _SalesCommentLine."Print On Shipment" then begin
                    case _CommentNo of
                        1: SpecialInstructions1Header := CopyStr(CopyStr(_SalesCommentLine.Comment,1,46) + ' -- ',1,MaxStrLen(SpecialInstructions1Header));
                        2: SpecialInstructions2Header := CopyStr(CopyStr(_SalesCommentLine.Comment,1,46) + ' -- ',1,MaxStrLen(SpecialInstructions2Header));
                        3: SpecialInstructions3Header := CopyStr(CopyStr(_SalesCommentLine.Comment,1,46) + ' -- ',1,MaxStrLen(SpecialInstructions3Header));
                        4: SpecialInstructions4Header := CopyStr(CopyStr(_SalesCommentLine.Comment,1,46) + ' -- ',1,MaxStrLen(SpecialInstructions4Header));
                        5: SpecialInstructions5Header := CopyStr(CopyStr(_SalesCommentLine.Comment,1,46) + ' -- ',1,MaxStrLen(SpecialInstructions5Header));
                        6: SpecialInstructions6Header := CopyStr(CopyStr(_SalesCommentLine.Comment,1,46) + ' -- ',1,MaxStrLen(SpecialInstructions6Header));
                        7: SpecialInstructions7Header := CopyStr(CopyStr(_SalesCommentLine.Comment,1,46) + ' -- ',1,MaxStrLen(SpecialInstructions7Header));
                    end;
                    _CommentNo += 1;
                end;
            until (_SalesCommentLine.Next() = 0) or (_CommentNo > 7);
    end;

    local procedure SetSpecialInstructionsLine(_DocNo: Code[20]; _DocLineNo: Integer)
    var
        _SalesCommentLine: Record "Sales Comment Line";
        _CommentNo: Integer;
    begin
        Clear(SpecialInstructions1Line);
        Clear(SpecialInstructions2Line);
        Clear(SpecialInstructions3Line);
        Clear(SpecialInstructions4Line);
        Clear(SpecialInstructions5Line);
        Clear(SpecialInstructions6Line);
        Clear(SpecialInstructions7Line);
        // gather line comments
        _CommentNo := 1;
        _SalesCommentLine.SetRange("Document Type",_SalesCommentLine."Document Type"::Order);
        _SalesCommentLine.SetRange("No.",_DocNo);
        _SalesCommentLine.SetRange("Document Line No.",_DocLineNo);
        _SalesCommentLine.SetFilter(Comment,'<>%1','');
        if _SalesCommentLine.FindSet(false) then
            repeat
                if _SalesCommentLine."Print On Pick Ticket" or _SalesCommentLine."Print On Shipment" then begin
                    case _CommentNo of
                        1: SpecialInstructions1Line := CopyStr(CopyStr(_SalesCommentLine.Comment,1,46) + ' -- ',1,MaxStrLen(SpecialInstructions1Line));
                        2: SpecialInstructions2Line := CopyStr(CopyStr(_SalesCommentLine.Comment,1,46) + ' -- ',1,MaxStrLen(SpecialInstructions2Line));
                        3: SpecialInstructions3Line := CopyStr(CopyStr(_SalesCommentLine.Comment,1,46) + ' -- ',1,MaxStrLen(SpecialInstructions3Line));
                        4: SpecialInstructions4Line := CopyStr(CopyStr(_SalesCommentLine.Comment,1,46) + ' -- ',1,MaxStrLen(SpecialInstructions4Line));
                        5: SpecialInstructions5Line := CopyStr(CopyStr(_SalesCommentLine.Comment,1,46) + ' -- ',1,MaxStrLen(SpecialInstructions5Line));
                        6: SpecialInstructions6Line := CopyStr(CopyStr(_SalesCommentLine.Comment,1,46) + ' -- ',1,MaxStrLen(SpecialInstructions6Line));
                        7: SpecialInstructions7Line := CopyStr(CopyStr(_SalesCommentLine.Comment,1,46) + ' -- ',1,MaxStrLen(SpecialInstructions7Line));
                    end;
                    _CommentNo += 1;
                end;
            until (_SalesCommentLine.Next() = 0) or (_CommentNo > 7);
    end;

    procedure SetTransferOrder(_TransferHeader: Record "Transfer Header")
    var
        _Location: Record Location;
        _LocationTo: Record Location;
        _continue: Boolean;
        _Text000Err: Label 'Method SetTransferOrder() was called without initializing a temporary recordset; be sure to load the document lines first with method LoadRecordset().';
    begin
        if not Initialized then
            Error(_Text000Err);
        _Location.Get(_TransferHeader."Transfer-from Code");
        _LocationTo.Get(_TransferHeader."Transfer-to Code");
        // header fields
        //CustomerNumber := CopyStr(_SalesHeader."Sell-to Customer No.",1,MaxStrLen(CustomerNumber));
        OrderNumber := CopyStr(KorberMgt.GetStripText(_TransferHeader."No."),1,MaxStrLen(OrderNumber));
        OrderNumberLine := CopyStr(KorberMgt.GetStripText(_TransferHeader."No."),1,MaxStrLen(OrderNumber));
        CustomerPONumber := CopyStr(KorberMgt.GetStripText(_TransferHeader."External Document No."),1,MaxStrLen(CustomerPONumber));
        ShipName := CopyStr(KorberMgt.GetStripText(_LocationTo.Name),1,MaxStrLen(ShipName));
        ShipAddressName1 := CopyStr(KorberMgt.GetStripText(_LocationTo.Address),1,MaxStrLen(ShipAddressName1));
        ShipAddressName2 := CopyStr(KorberMgt.GetStripText(_LocationTo."Address 2"),1,MaxStrLen(ShipAddressName2));
        ShipCity := CopyStr(KorberMgt.GetStripText(_LocationTo.City),1,MaxStrLen(ShipCity));
        ShipProviceState := CopyStr(KorberMgt.GetStripText(_LocationTo.County),1,MaxStrLen(ShipProviceState));
        ShipPostalZipCode := CopyStr(KorberMgt.GetStripText(_LocationTo."Post Code"),1,MaxStrLen(ShipPostalZipCode));
        ShipCountry := CopyStr(KorberMgt.GetStripText(_LocationTo."Country/Region Code"),1,MaxStrLen(ShipCountry));
        ShipAttnTo := CopyStr(KorberMgt.GetStripText(_LocationTo.Contact),1,MaxStrLen(ShipAttnTo));
        ShipTelephoneNumber := CopyStr(KorberMgt.GetStripText(_LocationTo."Phone No."),1,MaxStrLen(ShipTelephoneNumber));
        ShipViaPreferred := CopyStr(KorberMgt.GetStripText(_TransferHeader."Shipment Method Code"),1,MaxStrLen(ShipViaPreferred));
        OrderDate := CopyStr(Format(CreateDateTime(_TransferHeader."Shipment Date",0T),0,9),1,MaxStrLen(OrderDate));
        Email := CopyStr(KorberMgt.GetStripText(_Location."E-Mail"),1,MaxStrLen(Email));
        /*
        ** send xfer shpts as SOs so Edge shpt XML acknowledgments will resemble SO shpts; see concall Mon 1 Nov 2022 at 12pm Eastern
        **
        PurchaseOrderType := CopyStr('Transfer',1,MaxStrLen(PurchaseOrderType));
        WarehouseTransitLocation := CopyStr('98',1,MaxStrLen(WarehouseTransitLocation));
        WarehouseDestinationLocation := CopyStr(_LocationTo."ARC Korber Location Code",1,MaxStrLen(WarehouseDestinationLocation));
        */
        // populate ShipDateRequired - Erik, Wed 7 Dec 2022 at 1232pm Eastern - Jennifer, Wed 7 Dec 2022 at 515pm Eastern
        if _TransferHeader."Shipment Date" < Today() then
            ShipDateRequired := CopyStr(Format(CreateDateTime(Today(),0T),0,9),1,MaxStrLen(ShipDateRequired))
        else
            ShipDateRequired := CopyStr(Format(CreateDateTime(_TransferHeader."Shipment Date",0T),0,9),1,MaxStrLen(ShipDateRequired));
    end;

    local procedure SetUserDefinedFields(_Item: Record Item)
    var
        _NAPC_BOL: Record "ARC NAPC BOL";
        _NAPC_BOL_CommentLine: Record "ARC NAPC BOL Comment Line";
        _CommentLineNo: Integer;
    begin
        // requirement arose out of a concall Wed 16 Nov 2022 at 12pm Eastern
        //   concall re [RENT] SOW11 Körber Edge WMS Integration -- UAT/WMS - End to End Testing - Paola Montgomery
        // reference also email fr Erik Holmberg sent Wed 16 Nov 2022 at 230pm Eastern - "Requested Date"
        Clear(IntegrationUDF1);
        Clear(IntegrationUDF2);
        _Item.CalcFields("ARC BOL/UN/Ground Code");
        if _Item."ARC BOL/UN/Ground Code" = '' then
            exit;
        if not _NAPC_BOL.Get(_Item."ARC BOL/UN/Ground Code") then
            exit;
        _NAPC_BOL_CommentLine.SetRange(Code,_NAPC_BOL.Code);
        _NAPC_BOL_CommentLine.SetFilter(Comment,'<>%1','');
        if _NAPC_BOL_CommentLine.FindSet(false) then
            repeat
                _CommentLineNo += 1;
                case _CommentLineNo of
                    1: IntegrationUDF1 := CopyStr(_NAPC_BOL_CommentLine.Comment,1,MaxStrLen(IntegrationUDF1));
                    2: IntegrationUDF2 := CopyStr(_NAPC_BOL_CommentLine.Comment,1,MaxStrLen(IntegrationUDF2));
                end;
            until _NAPC_BOL_CommentLine.Next() = 0;
    end;
}
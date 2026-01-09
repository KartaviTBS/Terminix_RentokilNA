report 50068 "ARC Purchase Order Line Import"
{
    Caption = 'Purchase Order Line Import';
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
        while not StreamInFile.EOS do begin
            ClearVariables;
            StreamInFile.ReadText(Buffer);
            //Evaluate(CustomerVendorNo, GetSubString(Buffer, 1));
            Evaluate(DocumentNo, GetSubString(Buffer, 2));
            Evaluate(LineNo, GetSubString(Buffer, 3));
            Evaluate(Type, GetSubString(Buffer, 4));        
            Evaluate(ItemNo, GetSubString(Buffer, 5));
            Evaluate(LocationCode, GetSubString(Buffer, 6));
            Evaluate(ShipmentReceiptDate, GetSubString(Buffer, 7)); 
            Evaluate(Description, GetSubString(Buffer, 8));
            Evaluate(Quantity, GetSubString(Buffer, 9));
            Evaluate(UnitPrice, GetSubString(Buffer, 10));
            Evaluate(UnitCost, GetSubString(Buffer, 11));
            Evaluate(LineDiscountPct, GetSubString(Buffer, 12));
            Evaluate(LineDiscountAmt, GetSubString(Buffer, 13));  
            Evaluate(DimCode1, GetSubString(Buffer, 14));
            Evaluate(DimCode2, GetSubString(Buffer, 15));
            Evaluate(DropShip, GetSubString(Buffer, 16));
            Evaluate(PurchSalesOrderNo, GetSubString(Buffer, 17));
            Evaluate(PurchSalesOrderLineno, GetSubString(Buffer, 18));
            Evaluate(UOMCode, GetSubString(Buffer, 19));
            Evaluate(QtyperUOM, GetSubString(Buffer, 20));
            Evaluate(PurchasingCode, GetSubString(Buffer, 21));
            Evaluate(SpecialOrder, GetSubString(Buffer, 22));
            Evaluate(SpecialOrderPurchSalesNo, GetSubString(Buffer, 23));
            Evaluate(SpecialOrderPurchSalesLineNo, GetSubString(Buffer, 24));
            Evaluate(RequestedDeliveryReceiptDate, GetSubString(Buffer, 25));
            Evaluate(PromisedDeliveryReceiptDate, GetSubString(Buffer, 26));
            Evaluate(LeadTimeCalculation, GetSubString(Buffer, 27));
            Evaluate(PlannedDeliveryReceiptDate, GetSubString(Buffer, 28));
            Evaluate(SafetyLeadTime, GetSubString(Buffer, 29));
            Evaluate(DimCode3, GetSubString(Buffer, 30));
            Window.Update(1, DocumentNo);
            ImportData;
        end;
        ImpFile.Close;
    end;

    local procedure ImportData();
    var
        PurchHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        Resource: Record Resource;       
        Location: Record Location;
        UnitofMeasureRec: Record "Unit of Measure";
        ItemUOMRec: Record "Item Unit of Measure";
        DimMgt: Codeunit DimensionManagement;
    begin
        OrdError := false;
        if DocumentNo <> '' then
            IF not PurchHeader.Get(PurchHeader."Document Type"::Order,DocumentNo) then
                SaveOrderErrors('POLine00','Header');     
        
        //if DimCode1 <> '' then
        //    IF not DimMgt.CheckDimValue(GLSetup."Global Dimension 1 Code", DimCode1) then
        //        SaveOrderErrors('POLine01','Dim2 Value');

        //if DimCode2 <> '' then
        //    IF not DimMgt.CheckDimValue(GLSetup."Global Dimension 2 Code", DimCode2) then
        //        SaveOrderErrors('POLine02','Dim1 Value');

        //if DimCode3 <> '' then
        //    IF not DimMgt.CheckDimValue(GLSetup."Shortcut Dimension 3 Code", DimCode3) then
        //        SaveOrderErrors('POLine03','Dim3 Value');


        if LocationCode <> '' then begin
            LocationCode := GetMapping('Location', LocationCode);
            IF not Location.Get(LocationCode) then
                SaveOrderErrors('POLine05','Location');
        end;
        
        case Type of
            Type::Item :
                begin
                    ItemNo := GetMapping('Item', ItemNo);            
                    if not Item.GET(ItemNo) then
                        SaveOrderErrors('POLine06','Item')
                    else begin
                    if not ItemUOMRec.Get(ItemNo,Item."Base Unit of Measure") then
                          SaveOrderErrors('POLine06','Item UOM');
  
                    if Item."Sales Unit of Measure" <> '' then
                        if not ItemUOMRec.Get(ItemNo,Item."Sales Unit of Measure") then
                            SaveOrderErrors('POLine06','Sales UOM');
                   
                    if Item."Purch. Unit of Measure" <> '' then
                        if not ItemUOMRec.Get(ItemNo,Item."Purch. Unit of Measure") then
                            SaveOrderErrors('POLine06','Purch UOM');
                    end;
                end;
            Type::Resource :
                if not Resource.GET(ItemNo) then
                    SaveOrderErrors('POLine07','Resource');
        end; 
         
        if type = type::Item then begin
            ItemUOMRec.SetRange("Item No.",ItemNo);
            ItemUOMRec.SetRange("Qty. per Unit of Measure" ,QtyperUOM);
            if ItemUOMRec.FindFirst then
                UOMCode := ItemUOMRec.Code
            else
                SaveOrderErrors('POLine09','Item UOM');
        end;

        if not OrdError then begin
            Clear(PurchaseLine);
            PurchaseLine.Validate("Document Type", PurchaseLine."Document Type"::Order);
            PurchaseLine.Validate("Document No.", DocumentNo);
            PurchaseLine.Validate("Line No.", LineNo);
            PurchaseLine.Insert(true);
            PurchaseLine.Validate(Type, Type);
            if ItemNo = '' then 
              PurchaseLine.Description := Description
            else begin
                PurchaseLine.Validate("No.", ItemNo);
                PurchaseLine.Validate("Location Code", LocationCode);
                PurchaseLine.Validate("Expected Receipt Date", ShipmentReceiptDate);
                PurchaseLine.Validate(Quantity, Quantity);
                PurchaseLine.Validate("Qty. to Receive",0);
                PurchaseLine.Validate("Qty. to Invoice",0);
                if Type = Type::Item then begin
                    PurchaseLine.Validate("Unit of Measure Code", UOMCode);
                    PurchaseLine.Validate("Qty. per Unit of Measure", QtyperUOM); 
                end;              
                PurchaseLine.Validate("Direct Unit Cost", UnitCost);
                PurchaseLine.Validate("Unit Price (LCY)",UnitPrice);
                PurchaseLine.Validate("Line Discount %", LineDiscountPct);
                //PurchaseLine.Validate("Line Discount Amount", LineDiscountAmt);
                PurchaseLine."Drop Shipment" := DropShip;
                PurchaseLine."Sales Order No." := PurchSalesOrderNo;
                PurchaseLine."Sales Order Line No." := PurchSalesOrderLineno;
                PurchaseLine."Purchasing Code" := PurchasingCode;
                PurchaseLine."Special Order" := SpecialOrder;
                PurchaseLine."Special Order Sales No." := SpecialOrderPurchSalesNo;
                PurchaseLine."Special Order Sales Line No." := SpecialOrderPurchSalesLineNo;
                PurchaseLine.Validate("Requested Receipt Date", RequestedDeliveryReceiptDate);
                PurchaseLine.Validate("Promised Receipt Date", PromisedDeliveryReceiptDate);
                PurchaseLine.Validate("Planned Receipt Date", PlannedDeliveryReceiptDate);
                PurchaseLine.Validate("Lead Time Calculation", LeadTimeCalculation);
                PurchaseLine.Validate("Safety Lead Time", SafetyLeadTime);
                PurchaseLine."Return Reason Code" := 'IMPORT';
                //PurchaseLine.Validate("Shortcut Dimension 1 Code", DimCode1);
                //PurchaseLine.Validate("Shortcut Dimension 2 Code", DimCode2);
                //PurchaseLine.ValidateShortcutDimCode(3, DimCode3);  
            end;
            PurchaseLine.Modify(true); 
            TotalAmount += PurchaseLine."Line Amount";             
        end;
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
        OrderErrors.SETRANGE("Document Type",'POLine00','POLine99');
        OrderErrors.DELETEALL;
    end;

    trigger OnPostReport()
    var
    begin
        Message('Total PO Line Amt = %1, Total PO ErrorS(Qty*UCost) = %2',TotalAmount,TotalError);
    end;
    local procedure ClearVariables();
    var
    begin
        Clear(DocumentNo);
        Clear(LineNo);
        Clear(Type);        
        Clear(ItemNo);
        Clear(LocationCode);
        Clear(ShipmentReceiptDate); 
        Clear(Description);
        Clear(Quantity);
        Clear(UnitPrice);
        Clear(UnitCost);
        Clear(LineDiscountPct);
        Clear(LineDiscountAmt);  
        Clear(DimCode2);
        Clear(DimCode1);
        Clear(DropShip);
        Clear(PurchSalesOrderNo);
        Clear(PurchSalesOrderLineno);
        Clear(UOMCode);
        Clear(QtyperUOM);
        Clear(PurchasingCode);
        Clear(SpecialOrder);
        Clear(SpecialOrderPurchSalesNo);
        Clear(SpecialOrderPurchSalesLineNo);
        Clear(RequestedDeliveryReceiptDate);
        Clear(PromisedDeliveryReceiptDate);
        Clear(LeadTimeCalculation);
        Clear(PlannedDeliveryReceiptDate);
        Clear(PlannedShipmentReceiptDate);
        Clear(SafetyLeadTime);
        Clear(DimCode3);
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
        OrderErrors."Document No." := DocumentNo;
        OrderErrors."Line No." := LineNo;
        OrderErrors."Type" := Type;        
        OrderErrors."No." := ItemNo;
        OrderErrors."Location Code" := LocationCode;
        OrderErrors."Shipment/Exp.Receipt Date" := ShipmentReceiptDate; 
        OrderErrors.Description := Description;
        OrderErrors."Quantity" := Quantity;
        OrderErrors."Unit Price" := UnitPrice;
        OrderErrors."Unit Cost" := UnitCost;
        OrderErrors."Line Discount %" := LineDiscountPct;
        OrderErrors."Line Discount Amount" := LineDiscountAmt;  
        OrderErrors."Dim Code1" := DimCode1;
        OrderErrors."Dim Code2" := DimCode2;
        OrderErrors."Drop Shipment" := DropShip;
        OrderErrors."Purch/Sales Order No." := PurchSalesOrderNo;
        OrderErrors."Purch/Sales Order Line No." := PurchSalesOrderLineno;
        OrderErrors."UOM Code" := UOMCode;
        OrderErrors."Qty. per Unit of Measure" := QtyperUOM;
        OrderErrors."Purchasing Code" := PurchasingCode;
        OrderErrors."Special Order" := SpecialOrder;
        OrderErrors."Special Order Purch/Sales No." := SpecialOrderPurchSalesNo;
        OrderErrors."Special Order Purch/Sales Line No." := SpecialOrderPurchSalesLineNo;
        OrderErrors."Requested Delivery/Receipt Date" := RequestedDeliveryReceiptDate;
        OrderErrors."Promised Delivery/Receipt Date" := PromisedDeliveryReceiptDate;
        OrderErrors."Lead Time Calculation" := LeadTimeCalculation;
        OrderErrors."Planned Delivery/Receipt Date" := PlannedDeliveryReceiptDate;
        OrderErrors."Planned Shipment/Receipt Date" := PlannedShipmentReceiptDate;
        OrderErrors."Safety Lead Time" := SafetyLeadTime;
        OrderErrors."Dim Code3" := DimCode3;
        OrderErrors."Reason Code" := ErrReasonCode;
        if NOT OrderErrors.Insert then;
        OrdError := true;
        TotalError += (OrderErrors.Quantity * OrderErrors."Unit Cost");
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

    var
        GLSetup: Record "General Ledger Setup";
        OrderErrors: Record "ARC Import Order Line Errors";
        OrdError: Boolean;
        DropShip: Boolean;
        SpecialOrder: Boolean;
        LocationCode: Code[10];
        PurchasingCode: Code[10];
        UOMCode: Code[10];
        DimCode1: Code[20];
        DimCode2: Code[20];
        DimCode3: Code[20];
        DocumentNo: Code[20];
        ItemNo: Code[20];
        PurchSalesOrderNo: Code[20];
        SpecialOrderPurchSalesNo: Code[20];
        ClientTypeMgt: Codeunit ClientTypeManagement;
        FileManagement: Codeunit "File Management";
        PlannedDeliveryReceiptDate: Date;
        PromisedDeliveryReceiptDate: Date;
        RequestedDeliveryReceiptDate: Date;
        ShipmentReceiptDate: Date;
        PlannedShipmentReceiptDate: Date; 
        LeadTimeCalculation: DateFormula;  
        SafetyLeadTime: DateFormula; 
        ShippingTime: DateFormula;  
        LineDiscountPct: Decimal;  
        LineDiscountAmt: Decimal;
        MinimumPrice: Decimal;
        QtyperUOM: Decimal;
        Quantity: Decimal;
        UnitCost: Decimal;
        UnitPrice: Decimal;
        TotalAmount: Decimal;
        TotalError: Decimal;
        Window: Dialog;
        RecInfo: File;
        LineNo: Integer;
        PurchSalesOrderLineno: Integer;
        SpecialOrderPurchSalesLineNo: Integer;
        ProcessComplete: Label 'Import Complete';
        Text031: Label 'Import from Text File';
        Text000: Label 'Enter the file name.';
        SourceSystem: Option NAV2009, GreatPlains, Sage; 
        Type: Option " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";          
        DocumentType: Text[10];
        Description: Text[50];
        FileName: Text;
        FilePath: Text;
        ServerFileName: Text;

        [InDataSet]
        OnWebClient: Boolean;

}
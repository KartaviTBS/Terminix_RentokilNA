codeunit 50001 "2Ship Integration Mgmt."
{
    Permissions = tabledata "Sales Header" = RM,tabledata "Sales Shipment Header" = RM,tabledata "Transfer Shipment Header" = RM;
    TableNo = "DSHIP API Integration Param";
    trigger OnRun()
    var
        lrecWhseShipLine:Record "Warehouse Shipment Line";
    begin
        Window.Open('Processing 2Ship.....\Current process status... #1#########');
        IntParam := Rec;
        CASE IntParam."Document Type"  OF
            IntParam."Document Type"::"Sales Order":
                BEGIN
                    IF ( SalesHdr.GET(1, IntParam."Document No.") ) THEN
                        Submit2ShipOrderRequest(SalesHdr);
                END;
            IntParam."Document Type"::"Sales Return Order":
                BEGIN
                    IF ( SalesHdr.GET(5, IntParam."Document No.") ) THEN
                        Submit2ShipOrderRequest(SalesHdr);
                END;                
            IntParam."Document Type"::"Outbound Transfer":
                BEGIN
                    IF ( TransferHdr.GET(IntParam."Document No.") ) THEN
                        Submit2ShipOrderRequest(TransferHdr);                
                END;
            // if using whse shipments
            IntParam."Document Type"::"Warehouse Shipment":
                BEGIN
                    lrecWhseShipLine.SETRANGE("No.", IntParam."Document No.");
                    IF ( lrecWhseShipLine.FINDFIRST ) THEN BEGIN
                        CASE lrecWhseShipLine."Source Document" OF
                            lrecWhseShipLine."Source Document"::"Sales Order":
                                BEGIN                
                                    IF ( SalesHdr.GET(1, lrecWhseShipLine."Source No.") ) THEN
                                        Submit2ShipOrderRequest(SalesHdr);                        
                                END;  
                            lrecWhseShipLine."Source Document"::"Sales Return Order":
                                BEGIN                
                                    IF ( SalesHdr.GET(5, lrecWhseShipLine."Source No.") ) THEN
                                        Submit2ShipOrderRequest(SalesHdr);                        
                                END;                                 
                            lrecWhseShipLine."Source Document"::"Outbound Transfer":
                                BEGIN                
                                    IF ( TransferHdr.GET(lrecWhseShipLine."Source No.") ) THEN
                                        Submit2ShipOrderRequest(TransferHdr);                     
                                END;                                                   
                        END; // case lrecwhseshipline
                    END; // if lrecwhseshipline.findfirst
                END;
        END; // case IntParam
            
        Rec := IntParam;
        Window.close();
    end;
    var
        IntParam:Record "DSHIP API Integration Param";
        SalesHdr:Record "Sales Header";
        TransferHdr:Record "Transfer Header";
        Recref:RecordRef;                
        Window:Dialog;
        TotalWeight:Decimal;


    procedure CreateBody(var Variant:Variant; var OrderShipBody: Text)
    var
        PackagesDetails: JsonArray;
        CustomerMarkupDetails: JsonArray;
        OrderDetails: JsonObject;
        ContentsDetails: JsonObject;
        RecipientDetails: JsonObject;
        SenderDetails: JsonObject;
        OutStrm: OutStream;
        RequestText: Text;
        IntnSetup: Record "2Ship Integration Setup";
    begin
        Window.Update(1,'Creating request body');
        Recref.GetTable(Variant);
        case Recref.Number of
            Database::"Sales Header": 
                begin
                    Recref.SetTable(SalesHdr);
                end;
            Database::"Transfer Header":   
                begin
                    Recref.SetTable(TransferHdr);
                end;
        end;
        IntnSetup.Get();
        Clear(OrderDetails);
        OrderDetails.Add('WS_Key', IntnSetup.WS_Key);
        if SalesHdr."Shipping Agent Code" <> '' then
            OrderDetails.Add('CarrierId', SalesHdr."Shipping Agent Code")
        else if TransferHdr."Shipping Agent Code" <> '' then
            OrderDetails.Add('CarrierId', TransferHdr."Shipping Agent Code");
        
        GetSenderDetails(SenderDetails);
        OrderDetails.Add('Sender', SenderDetails);
        GetRecipientDetails(RecipientDetails);
        OrderDetails.Add('Recipient', RecipientDetails);
        GetPackagesDetails(PackagesDetails);
        OrderDetails.Add('Packages', PackagesDetails);
        GetCustomerMarkup(CustomerMarkupDetails);
        GetContentsDetails(ContentsDetails);
        OrderDetails.Add('Contents', ContentsDetails);        
        if SalesHdr."Document Type" = SalesHdr."Document Type"::"Return Order" then
            OrderDetails.Add('IsReturn',true);
        OrderDetails.Add('CustomerMarkup', CustomerMarkupDetails);
        if SalesHdr."Shipping Agent Code" <> '' then
            OrderDetails.Add('ServiceCode', SalesHdr."Shipping Agent Service Code")
        else if TransferHdr."Shipping Agent Code" <> '' then
            OrderDetails.Add('ServiceCode', TransferHdr."Shipping Agent Service Code");

        OrderDetails.WriteTo(OrderShipBody);
    end;

    procedure GetPackagesDetails(var DetailsJsonArray: JsonArray)
    var
        DetailsJson: JsonObject;
        LicensePlateHeader:Record "IWX License Plate Header";
        ShippingAgent:Record "Shipping Agent";
    begin
        Clear(DetailsJsonArray);
        Clear(TotalWeight);

        if SalesHdr."Shipping Agent Code" <> '' then
            ShippingAgent.Get(SalesHdr."Shipping Agent Code")
        else if TransferHdr."Shipping Agent Code" <> '' then
            ShippingAgent.Get(TransferHdr."Shipping Agent Code")
        else
            ShippingAgent.Init();

        LicensePlateHeader.Reset();
        case IntParam."Document Type" of 
            IntParam."Document Type"::"Sales Order": 
                begin
                    LicensePlateHeader.SetRange("Source Document Type",LicensePlateHeader."Source Document Type"::"Sales Order");
                    LicensePlateHeader.SetRange("Source Document No.",SalesHdr."No.");
                end;
            IntParam."Document Type"::"Warehouse Shipment":
                begin
                    LicensePlateHeader.SetRange("Source Document Type",LicensePlateHeader."Source Document Type"::Shipment);
                    LicensePlateHeader.SetRange("Source Document No.",IntParam."Document No.");
                end;  
            IntParam."Document Type"::"Outbound Transfer":
                begin
                    LicensePlateHeader.SetRange("Source Document Type",LicensePlateHeader."Source Document Type"::"Outbound Transfer");
                    LicensePlateHeader.SetRange("Source Document No.",TransferHdr."No.");
                end;   
            IntParam."Document Type"::"Sales Return Order":
                LicensePlateHeader.SetRange("Source Document No.",SalesHdr."No.");
        end;

        if LicensePlateHeader.FindSet then          
            repeat    
                Clear(DetailsJson);  
                TotalWeight += LicensePlateHeader."Shipment Gross Weight";  
                DetailsJson.Add('Weight', LicensePlateHeader."Shipment Gross Weight");
                DetailsJson.Add('Width', LicensePlateHeader."Shipment Width");
                DetailsJson.Add('Length', LicensePlateHeader."Shipment Length");
                DetailsJson.Add('Height', LicensePlateHeader."Shipment Height");
                if LicensePlateHeader."Weight Unit of Measure" = 'KG' then
                    DetailsJson.Add('WeightType', 1)
                else
                    DetailsJson.Add('WeightType', 0); 
                if LicensePlateHeader."Shpt. Dim. Unit of Measure" = 'CENTIMETER' then
                    DetailsJson.Add('DimensionType', 1)
                else
                    DetailsJson.Add('DimensionType', 0); 
                if ShippingAgent."Freight Class ID" <> 0 then
                    DetailsJson.Add('FreightClassId',ShippingAgent."Freight Class ID");
                DetailsJsonArray.Add(DetailsJson);
            until LicensePlateHeader.Next() = 0;
        
    end;

    procedure GetCustomerMarkup(var DetailsJsonArray: JsonArray)
    var
        DetailsJson: JsonObject;
        LicensePlateHeader:Record "IWX License Plate Header";
    begin
        LicensePlateHeader.Reset();
        if IntParam."Document Type" = IntParam."Document Type"::"Sales Order" then begin
            LicensePlateHeader.SetRange("Source Document Type",LicensePlateHeader."Source Document Type"::"Sales Order");
            LicensePlateHeader.SetRange("Source Document No.",SalesHdr."No.");
        end else if IntParam."Document Type" = IntParam."Document Type"::"Warehouse Shipment" then begin
            LicensePlateHeader.SetRange("Source Document Type",LicensePlateHeader."Source Document Type"::Shipment);
            LicensePlateHeader.SetRange("Source Document No.",IntParam."Document No.");
        end else if IntParam."Document Type" = IntParam."Document Type"::"Outbound Transfer" then begin
            LicensePlateHeader.SetRange("Source Document Type",LicensePlateHeader."Source Document Type"::Shipment);
            LicensePlateHeader.SetRange("Source Document No.",TransferHdr."No.");
        end else if IntParam."Document Type" = IntParam."Document Type"::"Sales Return Order" then begin
            //LicensePlateHeader.SetRange("Source Document Type",LicensePlateHeader."Source Document Type"::"Sales Return Order");
            LicensePlateHeader.SetRange("Source Document No.",SalesHdr."No.");
        end;

        if not LicensePlateHeader.FindFirst then
            LicensePlateHeader.Init();
        Clear(DetailsJsonArray);
        Clear(DetailsJson);
        
        DetailsJson.Add('MarkupValue', LicensePlateHeader.MarkupValue);
        DetailsJson.Add('MarkupType', LicensePlateHeader.MarkupType); 
        DetailsJsonArray.Add(DetailsJson);
    end;

    procedure GetRecipientDetails(var DetailsJson: JsonObject)
    var
        ShipToAddress: Record "Ship-to Address";
        PostCodes:Record "Post Code";
        Id:Text[50];
        CompanyName:Text[50];
        Country:Text[50];
        State:Text[50];
        City:Text[50];
        PostalCode:Text[50];
        Telephone:Text[50];
        Address1:Text[50];
        Address2:Text[50];
    begin
        Clear(DetailsJson);
        if SalesHdr."No." <> '' then begin
            if ShipToAddress.Get(SalesHdr."Sell-to Customer No.", SalesHdr."Ship-to Code") then begin
                Id := ShipToAddress.Code;
                CompanyName := copystr(ShipToAddress.Name,1,30);
                Country := ShipToAddress."Country/Region Code";
                State := ShipToAddress.County;
                City := ShipToAddress.City;
                PostalCode := ShipToAddress."Post Code";
                if ShipToAddress."Phone No." <> '' then        
                    Telephone := ShipToAddress."Phone No."; //Phone No.
                Address1 := ShipToAddress.Address;
                Address2 := ShipToAddress."Address 2";
            end else begin
                Id := SalesHdr."Ship-to Code";
                CompanyName := copystr(SalesHdr."Ship-to Name",1,30);
                Country := SalesHdr."Ship-to Country/Region Code";
                State := SalesHdr."Ship-to County";
                City := SalesHdr."Ship-to City";
                PostalCode := SalesHdr."Ship-to Post Code";
                if SalesHdr."Ship-to Phone No. -CL-" <> '' then        
                    Telephone := SalesHdr."Ship-to Phone No. -CL-"; //Phone No.
                Address1 := SalesHdr."Ship-to Address";
                Address2 := SalesHdr."Ship-to Address 2";
            end;
        end else if TransferHdr."No." <> '' then begin
            Id := TransferHdr."Transfer-to Code";
            CompanyName := copystr(TransferHdr."Transfer-to Name",1,30);
            if PostCodes.Get(TransferHdr."Transfer-to Post Code",TransferHdr."Transfer-to City") then
                Country := PostCodes."Country/Region Code";
            State := TransferHdr."Transfer-to County";
            City := TransferHdr."Transfer-to City";
            PostalCode := TransferHdr."Transfer-to Post Code";
            if TransferHdr."Transfer-to Phone No. -CL-" <> '' then        
                Telephone := TransferHdr."Transfer-to Phone No. -CL-"; //Phone No.
            Address1 := TransferHdr."Transfer-to Address";
            Address2 := TransferHdr."Transfer-to Address 2";
        end;


        DetailsJson.Add('Id', Id);
        DetailsJson.Add('CompanyName', CompanyName);
        DetailsJson.Add('Country', Country);
        DetailsJson.Add('State', State);
        DetailsJson.Add('City', City);
        DetailsJson.Add('PostalCode', PostalCode);
        if Telephone <> '' then        
            DetailsJson.Add('Telephone', Telephone); //Phone No.
        DetailsJson.Add('Address1', Address1);
        DetailsJson.Add('Address2', Address2);        
    end;

    procedure GetSenderDetails(var DetailsJson: JsonObject)
    var
        Location: Record Location;
    begin
        if SalesHdr."Location Code" <> '' then
            Location.Get(SalesHdr."Location Code")
        else if TransferHdr."Transfer-from Code" <> '' then
            Location.Get(TransferHdr."Transfer-from Code");

        Clear(DetailsJson);
        
        DetailsJson.Add('Id', Location.Code);
        DetailsJson.Add('CompanyName', copystr(Location.Name,1,30));
        DetailsJson.Add('Country', Location."Country/Region Code");
        DetailsJson.Add('State', Location.County);
        DetailsJson.Add('City', Location.City);
        DetailsJson.Add('PostalCode', Location."Post Code");
        if Location."Phone No." <> '' then        
            DetailsJson.Add('Telephone', Location."Phone No."); //Phone No.
        DetailsJson.Add('Address1', Location.Address);
        DetailsJson.Add('Address2', Location."Address 2");
    end;
    procedure GetContentsDetails(var ContentsDetails: JsonObject)
    var
        Item:Record Item;
        SalesLine:Record "Sales Line";
        TransferLine:Record "Transfer Line";
        WarehouseShipLine:Record "Warehouse Shipment Line";
        HasDangerousGoods:Boolean;
        CommoditiesJsonArray: JsonArray;
        DetailsJson: JsonObject;
    begin
        Clear(DetailsJson);
        Clear(HasDangerousGoods);
        case IntParam."Document Type" of 
            IntParam."Document Type"::"Sales Order": 
                begin
                    SalesLine.Reset();
                    SalesLine.SetRange("Document Type",SalesLine."Document Type"::Order);
                    SalesLine.SetRange("Document No.",SalesHdr."No.");
                    SalesLine.SetRange(Type,SalesLine.Type::Item);
                    if SalesLine.FindSet() then 
                        repeat
                            if (Item.Get(SalesLine."No.")) and (Item."Updated In 2Ship")  then begin
                                HasDangerousGoods := true;
                                DetailsJson.Add('ID',Item."No."); 
                                DetailsJson.Add('Description',CopyStr(Item.Description,1,35)); 
                                DetailsJson.Add('Quantity',SalesLine.Quantity);
                                DetailsJson.Add('TotalWeight',TotalWeight);
                                DetailsJson.Add('QuantityUnitOfMeasure',SalesLine."Unit of Measure Code");
                                DetailsJson.Add('UnitValue',SalesLine."Unit Price");
                            end;                   
                        until SalesLine.Next() = 0;
                    if HasDangerousGoods then begin
                        CommoditiesJsonArray.Add(DetailsJson);
                        ContentsDetails.Add('Commodities',CommoditiesJsonArray);                        
                    end;
                end;
            IntParam."Document Type"::"Warehouse Shipment":
                begin
                    WarehouseShipLine.Reset();                    
                    WarehouseShipLine.SetRange("No.",IntParam."Document No.");
                    if WarehouseShipLine.FindSet() then 
                        repeat
                            if (Item.Get(WarehouseShipLine."Item No.")) and (Item."Updated In 2Ship")  then begin
                                HasDangerousGoods := true;
                                DetailsJson.Add('ID',Item."No."); 
                                DetailsJson.Add('Description',CopyStr(Item.Description,1,35)); 
                                CASE WarehouseShipLine."Source Document" OF
                                    WarehouseShipLine."Source Document"::"Sales Order":
                                        BEGIN                
                                            IF ( SalesLine.GET(1, WarehouseShipLine."Source No.",WarehouseShipLine."Source Line No.") ) THEN begin
                                                DetailsJson.Add('UnitValue',SalesLine."Unit Price"); 
                                                DetailsJson.Add('TotalWeight',TotalWeight); 
                                            END;                       
                                        END;                                                                                                                                                       
                                END;                                 
                                DetailsJson.Add('Quantity',WarehouseShipLine.Quantity);
                                DetailsJson.Add('QuantityUnitOfMeasure',WarehouseShipLine."Unit of Measure Code");
                                                             
                            end;                   
                        until WarehouseShipLine.Next() = 0;
                    if HasDangerousGoods then begin
                        CommoditiesJsonArray.Add(DetailsJson);
                        ContentsDetails.Add('Commodities',CommoditiesJsonArray);                        
                    end; 
                end;  
            IntParam."Document Type"::"Outbound Transfer":
                begin
                    TransferLine.Reset();                    
                    TransferLine.SetRange("Document No.",TransferHdr."No.");
                    if TransferLine.FindSet() then 
                        repeat
                            if (Item.Get(TransferLine."Item No.")) and (Item."Updated In 2Ship")  then begin
                                HasDangerousGoods := true;
                                DetailsJson.Add('ID',Item."No.");   
                                DetailsJson.Add('Description',CopyStr(Item.Description,1,35)); 
                                DetailsJson.Add('Quantity',TransferLine.Quantity);
                                DetailsJson.Add('TotalWeight',TotalWeight);
                                DetailsJson.Add('QuantityUnitOfMeasure',TransferLine."Unit of Measure Code");
                                //DetailsJson.Add('UnitValue',TransferLine.pric);                                 
                            end;                   
                        until TransferLine.Next() = 0;
                    if HasDangerousGoods then begin
                        CommoditiesJsonArray.Add(DetailsJson);
                        ContentsDetails.Add('Commodities',CommoditiesJsonArray);                        
                    end;                  
                end;   
            IntParam."Document Type"::"Sales Return Order":
                Begin
                    SalesLine.Reset();
                    SalesLine.SetRange("Document Type",SalesLine."Document Type"::"Return Order");
                    SalesLine.SetRange("Document No.",SalesHdr."No.");
                    SalesLine.SetRange(Type,SalesLine.Type::Item);
                    if SalesLine.FindSet() then 
                        repeat
                            if (Item.Get(SalesLine."No.")) and (Item."Updated In 2Ship")  then begin
                                HasDangerousGoods := true;
                                DetailsJson.Add('ID',Item."No.");  
                                DetailsJson.Add('Description',CopyStr(Item.Description,1,35)); 
                                DetailsJson.Add('Quantity',SalesLine.Quantity);
                                DetailsJson.Add('TotalWeight',TotalWeight);
                                DetailsJson.Add('QuantityUnitOfMeasure',SalesLine."Unit of Measure Code");
                                DetailsJson.Add('UnitValue',SalesLine."Unit Price");                                  
                            end;                   
                        until SalesLine.Next() = 0;
                    if HasDangerousGoods then begin
                        CommoditiesJsonArray.Add(DetailsJson);
                        ContentsDetails.Add('Commodities',CommoditiesJsonArray);                        
                    end;                    
                End;
        end;        
    end;
    procedure SendRequestForSubmission(var Content: HttpContent; var Request: HttpRequestMessage;RequestText:text)
    var
        ToShipIntnLogEntries: Record "2Ship Integration Log";
        IntnSetup: Record "2Ship Integration Setup";
        Client: HttpClient;
        Response: HttpResponseMessage;
        ErrorText: label 'Something Wrong. Please retry.';
        Outstream2: OutStream;
    begin
        //Sending Request>>
        IntnSetup.Get();
        Request.Method := 'POST';
        Request.SetRequestUri(IntnSetup."Ship URL");
        Request.Content := Content;
        Window.Update(1,'Send 2Ship request');
        if not Client.Send(Request, Response) then 
            ResponseAndLogEntries(Response, RequestText, false)
        else 
            ResponseAndLogEntries(Response, RequestText, true);            
    end;

    Procedure Submit2ShipOrderRequest(Variant:Variant)
    var
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        InvoiceSubmissionRequest: HttpRequestMessage;
        OrderDetails: Text;
    begin
        CreateBody(Variant, OrderDetails);
        Content.WriteFrom(OrderDetails);
        ContentHeaders.Clear();
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');
        SendRequestForSubmission(Content, InvoiceSubmissionRequest,OrderDetails); //Sending request
    end;

    procedure ResponseAndLogEntries(Var Response: HttpResponseMessage; RequestText: text;IsSuccess:Boolean)
    var
        SalesHeader:Record "Sales Header";
        TransferHeader:Record "Transfer Header";
        ResponceJson: JsonObject;       
        ResponseText: text;       
        DocNameText: text[250];
        StatusToken2: JsonToken;        
        ShipDocumentsToken: JsonToken;
        ShipDocumentsToken2: JsonToken;
        ShipDocumentsArray: JsonArray;
        ShipDocumentsJson: JsonObject;
        ServiceToken: JsonToken;
        ServiceJson: JsonObject;
        ClientPriceToken: JsonToken;       
        ClientPriceJson: JsonObject;
        TotalToken:JsonToken;
        FreightCostValue:Decimal;
        ErrorToken: JsonToken;
        ErrorText:Text;
        Text001: Label 'Shipping has been success in 2Ship';
        Text002: Label 'Download the Response jSON to see the errors';
        i: Integer;
        TrackingToken: JsonToken;
        HrefToken: JsonToken;      
        LabelHref:Text;
        BillOfLadingHref:Text;
        DGDeclarationHref:Text;
        TrackingNo: Text;
        ToShipIntnLogEntries: Record "2Ship Integration Log";
        DShipLabelData:Record "DSHIP Label Data";
        OutStrm: OutStream;
        Outstream2: Outstream;
        ErrOutStrm: OutStream;
    begin
        Window.Update(1,'Reading 2Ship response');
        Response.Content.ReadAs(ResponseText);
        ResponceJson.ReadFrom(ResponseText);
         
        if ResponceJson.get('ShipDocuments', ShipDocumentsToken) then begin
            ShipDocumentsArray := ShipDocumentsToken.AsArray();
            For i := 1 to (ShipDocumentsArray.Count) do begin
                Clear(ShipDocumentsToken2);
                Clear(DocNameText);
                ShipDocumentsArray.Get((i - 1), ShipDocumentsToken2);
                ShipDocumentsJson := ShipDocumentsToken2.AsObject();                  
                if ShipDocumentsJson.Get('DocumentName', StatusToken2) then begin
                    DocNameText := StatusToken2.AsValue().AsText();
                    if ShipDocumentsJson.get('Href', HrefToken) and (DocNameText = 'Label') then
                        LabelHref := HrefToken.AsValue().AsText();                      
                    if ShipDocumentsJson.get('Href', HrefToken) and (DocNameText = 'Bill Of Lading') then
                        BillOfLadingHref := HrefToken.AsValue().AsText();
                    if ShipDocumentsJson.get('Href', HrefToken) and (DocNameText = 'Dangerous Goods Declaration') then                        
                        DGDeclarationHref := HrefToken.AsValue().AsText();
                end;
            end;
            if ResponceJson.Get('TrackingNumber',TrackingToken) then
                TrackingNo :=  TrackingToken .AsValue().AsText();
            if ResponceJson.Get('Service', ServiceToken) then begin
                ServiceJson := ServiceToken.AsObject(); 
                if ServiceJson.Get('ClientPrice',ClientPriceToken) then
                    ClientPriceJson := ClientPriceToken.AsObject();
                if ClientPriceJson.Get('Total',TotalToken) then
                    FreightCostValue :=  TotalToken.AsValue().AsDecimal;                
            end;

            if SalesHdr."No." <> '' then begin
                //InsertFreightLineResource(SalesHdr,FreightCostValue);
                if not SalesHeader.Get(1,SalesHdr."No.") then
                    if not SalesHeader.Get(5,SalesHdr."No.") then
                        SalesHeader.Init();
                SalesHeader."2Ship Tracking No." :=  TrackingNo;
                SalesHeader."2Ship Label Link" := LabelHref;
                SalesHeader."2Ship BOL Link" := BillOfLadingHref;
                SalesHeader.Modify();
            end else if TransferHdr."No." <> '' then begin
                TransferHeader.Get(TransferHdr."No.");
                TransferHeader."2Ship Tracking No." :=  TrackingNo;
                TransferHeader."2Ship Label Link" := LabelHref;
                TransferHeader."2Ship BOL Link" := BillOfLadingHref;
                TransferHeader.Modify();
            end;

           
            IntParam."Package Tracking No." :=  TrackingNo;
            IntParam."Package Carrier Label URL" := LabelHref;
            DShipLabelData.Reset();
            DShipLabelData.SetRange("License Plate No.",IntParam."License Plate No.");
            if DShipLabelData.IsEmpty then begin             
                DShipLabelData.Init();
                DShipLabelData."Entry No." := 0;
                DShipLabelData."License Plate No." := IntParam."License Plate No.";
                DShipLabelData."Package Tracking No." := TrackingNo;
                DShipLabelData."Label URL" := CopyStr(LabelHref,1,MaxStrLen(DShipLabelData."Label URL"));
                DShipLabelData."BOL URL" := CopyStr(BillOfLadingHref,1,MaxStrLen(DShipLabelData."BOL URL"));
                DShipLabelData."DG Declaration URL" := CopyStr(DGDeclarationHref,1,MaxStrLen(DShipLabelData."DG Declaration URL"));
                DShipLabelData."2Ship Tracking No." := TrackingNo;
                DShipLabelData.Insert(true);
            end else if DShipLabelData.FindFirst then begin
                DShipLabelData."Label URL" := CopyStr(LabelHref,1,MaxStrLen(DShipLabelData."Label URL"));
                DShipLabelData."BOL URL" := CopyStr(BillOfLadingHref,1,MaxStrLen(DShipLabelData."BOL URL"));
                DShipLabelData."DG Declaration URL" := CopyStr(DGDeclarationHref,1,MaxStrLen(DShipLabelData."DG Declaration URL"));
                DShipLabelData."2Ship Tracking No." := TrackingNo;
                DShipLabelData.Modify(true);
            end;
        end else
            if ResponceJson.get('ExceptionMessage', ErrorToken) then                
                ErrorText :=  ErrorToken .AsValue().AsText();
            
        
        
        ToShipIntnLogEntries.INIT;
        if SalesHdr."No." <> '' then
            ToShipIntnLogEntries."Document No." := SalesHdr."No."
        else if TransferHdr."No." <> '' then
            ToShipIntnLogEntries."Document No." := TransferHdr."No.";
        ToShipIntnLogEntries."Request Type" := ToShipIntnLogEntries."Request Type"::Ship;
        ToShipIntnLogEntries."Date & Time" := CURRENTDATETIME;
        ToShipIntnLogEntries."User Id" := USERID;
        if Response.IsSuccessStatusCode then
            ToShipIntnLogEntries.Status := ToShipIntnLogEntries.Status::Success
        else
            ToShipIntnLogEntries.Status := ToShipIntnLogEntries.Status::Failed;
        ToShipIntnLogEntries.Error.CreateOutStream(ErrOutStrm);
        ErrOutStrm.WriteText(ErrorText);
        ToShipIntnLogEntries."JSON Response Blob".CreateOutStream(OutStrm);
        OutStrm.WriteText(ResponseText);
        ToShipIntnLogEntries."Json Request Blob".CreateOutStream(Outstream2);
        Outstream2.WriteText(RequestText);
        ToShipIntnLogEntries.INSERT(true);
        if Response.IsSuccessStatusCode then
            Message('%1', Text001)
        else
            Message('%1', Errortext);
    end;

     Procedure Submit2ShipCancelRequest(DocumentNo:Code[20]; TrackingNo:Text)
    var
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        InvoiceSubmissionRequest: HttpRequestMessage;
        OrderDetails: Text;
    begin
        Window.Open('Processing 2Ship.....\Current process status... #1#########');
        CreateCancelBody(TrackingNo, OrderDetails);
        Content.WriteFrom(OrderDetails);
        ContentHeaders.Clear();
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');
        SendRequestForDeletion(Content, InvoiceSubmissionRequest,OrderDetails,DocumentNo); //Sending request
        Window.Close();
    end;
    procedure CreateCancelBody(TrackingNo:Text; var OrderShipBody: Text)
    var
        PackagesDetails: JsonArray;
        OrderDetails: JsonObject;
        RecipientDetails: JsonObject;
        SenderDetails: JsonObject;
        OutStrm: OutStream;
        RequestText: Text;
        IntnSetup: Record "2Ship Integration Setup";
    begin
        Window.Update(1,'Creating request body');
        IntnSetup.Get();
        Clear(OrderDetails);
        OrderDetails.Add('WS_Key', IntnSetup.WS_Key);
        OrderDetails.Add('TrackingNumber', TrackingNo);        
        OrderDetails.Add('DeleteType', '1');
        OrderDetails.Add('DeleteFromOnHold', 'true');     
        OrderDetails.WriteTo(OrderShipBody);
    end;
    procedure SendRequestForDeletion(var Content: HttpContent; var Request: HttpRequestMessage;RequestText:text; DocumentNo:Code[20])
    var
        ToShipIntnLogEntries: Record "2Ship Integration Log";
        IntnSetup: Record "2Ship Integration Setup";
        Client: HttpClient;
        Response: HttpResponseMessage;      
        Outstream2: OutStream;
    begin
        //Sending Request>>
        IntnSetup.Get();
        Request.Method := 'POST';
        Request.SetRequestUri(IntnSetup."Delete Shipment URL");
        Request.Content := Content;
        Window.Update(1,'Sending cancel 2Ship request');
        if not Client.Send(Request, Response) then 
            SaveResponseAndLogEntries(Response, RequestText, false,DocumentNo)
        else 
            SaveResponseAndLogEntries(Response, RequestText, true,DocumentNo);            
    end;
    procedure SaveResponseAndLogEntries(Var Response: HttpResponseMessage; RequestText: text;IsSuccess:Boolean;  DocumentNo:Code[20])
    var
        ResponceJson: JsonObject;       
        ResponseText: text;               
        ErrorToken: JsonToken;
        ErrorText:Text; 
        SuccessToken: JsonToken;  
        SuccesValueTxt: Text[20];
        SuccesValue: Boolean    ;
        Text001: Label 'Shipment has been cancelled in 2Ship.Response value %1.';
        ToShipIntnLogEntries: Record "2Ship Integration Log";
        SalesShipHeader:Record "Sales Shipment Header";
        TransferShipmentHeader:Record "Transfer Shipment Header";
        OutStrm: OutStream;
        Outstream2: Outstream;
        ErrOutStrm: OutStream;
    begin
        Window.Update(1,'Reading 2Ship response');
        Response.Content.ReadAs(ResponseText);
        ResponceJson.ReadFrom(ResponseText);
         
        
        if ResponceJson.Get('Success',SuccessToken) then begin
            SuccesValueTxt :=  SuccessToken .AsValue().AsText();
            Evaluate(SuccesValue,SuccesValueTxt);
            if SuccesValue then begin
                if SalesShipHeader.Get(DocumentNo) then begin
                    SalesShipHeader."2Ship Tracking No." := '';
                    SalesShipHeader.Modify;
                end else if TransferShipmentHeader.Get(DocumentNo) then begin
                    TransferShipmentHeader."2Ship Tracking No." := '';
                    TransferShipmentHeader.Modify;
                end;
            end;
        end else
            if ResponceJson.get('ExceptionMessage', ErrorToken) then                
                ErrorText :=  ErrorToken .AsValue().AsText();
                    
        ToShipIntnLogEntries.INIT;
        ToShipIntnLogEntries."Document No." := DocumentNo;
        ToShipIntnLogEntries."Request Type" := ToShipIntnLogEntries."Request Type"::DeleteShipment;
        ToShipIntnLogEntries."Date & Time" := CURRENTDATETIME;
        ToShipIntnLogEntries."User Id" := USERID;
        if Response.IsSuccessStatusCode then
            ToShipIntnLogEntries.Status := ToShipIntnLogEntries.Status::Success
        else
            ToShipIntnLogEntries.Status := ToShipIntnLogEntries.Status::Failed;
        ToShipIntnLogEntries.Error.CreateOutStream(ErrOutStrm);
        ErrOutStrm.WriteText(ErrorText);
        ToShipIntnLogEntries."JSON Response Blob".CreateOutStream(OutStrm);
        OutStrm.WriteText(ResponseText);
        ToShipIntnLogEntries."Json Request Blob".CreateOutStream(Outstream2);
        Outstream2.WriteText(RequestText);
        ToShipIntnLogEntries.INSERT(true);
        if Response.IsSuccessStatusCode then
            Message(Text001,SuccesValueTxt)
        else
            Message('%1', Errortext);
    end;
    [EventSubscriber(ObjectType::Table, database::"Transfer Shipment Header", 'OnAfterCopyFromTransferHeader', '', false, false)]
    local procedure OnAfterCopyFromTransferHeader(VAR TransferShipmentHeader : Record "Transfer Shipment Header";TransferHeader : Record "Transfer Header")
    var
    begin
       TransferShipmentHeader."2Ship Tracking No." := TransferHeader."2Ship Tracking No.";
       TransferShipmentHeader."2Ship BOL Link" := TransferHeader."2Ship BOL Link";
       TransferShipmentHeader."2Ship Label Link" := TransferHeader."2Ship Label Link";
    end;
    /*local procedure InsertFreightLineResource(Var SalesHeaderP:Record "Sales Header";Freight:Decimal);
    var
        SalesLine:Record "Sales Line";
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeaderP."Document Type");
        SalesLine.SetRange("Document No.",SalesHeaderP."No.");
        if SalesLine.FindFirst() then
            SalesLine.InsertFreightLineResource(Freight);     
    end; */  

    Procedure Submit2ShipRateShopRequest(Variant:Variant;IsReturn:Boolean)
    var
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        InvoiceSubmissionRequest: HttpRequestMessage;
        OrderDetails: Text;
    begin
        Window.Open('Processing 2Ship.....\Current process status... #1#########');
        CreateBodyRateShop(Variant, OrderDetails,IsReturn);
        Content.WriteFrom(OrderDetails);
        ContentHeaders.Clear();
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');
        SendRequestForRateShopSubmission(Content, InvoiceSubmissionRequest,OrderDetails); //Sending request
        window.Close();
    end;

    procedure CreateBodyRateShop(var Variant:Variant; var OrderShipBody: Text;IsReturn:Boolean)
    var
        PackagesDetails: JsonArray;
        OrderDetails: JsonObject;
        RecipientDetails: JsonObject;
        SenderDetails: JsonObject;
        OutStrm: OutStream;
        RequestText: Text;
        IntnSetup: Record "2Ship Integration Setup";
    begin
        Window.Update(1,'Creating request body');
        Recref.GetTable(Variant);
        case Recref.Number of
            Database::"Sales Header": 
                begin
                    Recref.SetTable(SalesHdr);
                end;
            Database::"Transfer Header":   
                begin
                    Recref.SetTable(TransferHdr);
                end;
        end;
        IntnSetup.Get();
        Clear(OrderDetails);
        OrderDetails.Add('WS_Key', IntnSetup.WS_Key);
        if SalesHdr."Shipping Agent Code" <> '' then
            OrderDetails.Add('CarrierId', SalesHdr."Shipping Agent Code")
        else if TransferHdr."Shipping Agent Code" <> '' then
            OrderDetails.Add('CarrierId', TransferHdr."Shipping Agent Code");
        GetSenderDetails(SenderDetails);
        OrderDetails.Add('Sender', SenderDetails);
        GetRecipientDetails(RecipientDetails);
        OrderDetails.Add('Recipient', RecipientDetails);
        //GetPackagesDetails(SalesHeader, PackagesDetails);
        OrderDetails.Add('Packages', PackagesDetails);
        if IsReturn then
          OrderDetails.Add('IsReturn',true);
        if SalesHdr."Shipping Agent Code" <> '' then
            OrderDetails.Add('ServiceCode', SalesHdr."Shipping Agent Service Code")
        else if TransferHdr."Shipping Agent Code" <> '' then
            OrderDetails.Add('ServiceCode', TransferHdr."Shipping Agent Service Code");  
        OrderDetails.WriteTo(OrderShipBody);
    end;
    procedure SendRequestForRateShopSubmission(var Content: HttpContent; var Request: HttpRequestMessage;RequestText:text)
    var
        ToShipIntnLogEntries: Record "2Ship Integration Log";
        IntnSetup: Record "2Ship Integration Setup";
        Client: HttpClient;
        Response: HttpResponseMessage;
        ErrorText: label 'Something Wrong. Please retry.';
        Outstream2: OutStream;
    begin
        //Sending Request>>
        IntnSetup.Get();
        Request.Method := 'POST';
        Request.SetRequestUri(IntnSetup."Get Edit URL");
        Request.Content := Content;
        Window.Update(1,'Send 2Ship request');
        if not Client.Send(Request, Response) then 
            SaveResponseAndLogEntriesGetEditURL(Response, RequestText, false)
        else 
            SaveResponseAndLogEntriesGetEditURL(Response, RequestText, true);            
    end;    
    procedure SaveResponseAndLogEntriesGetEditURL(Var Response: HttpResponseMessage; RequestText: text;IsSuccess:Boolean)
    var
        ResponceJson: JsonObject;       
        ResponseText: text;               
        ErrorToken: JsonToken;
        ErrorText:Text; 
        TwoShipURLToken: JsonToken;  
        TwoShipURLValueTxt: Text[250];        
        Text001: Label 'Shipment has been cancelled in 2Ship.Response value %1.';
        ToShipIntnLogEntries: Record "2Ship Integration Log";
        SalesHeader:Record "Sales Header";
        TransferHeader:Record "Transfer Header";
        OutStrm: OutStream;
        Outstream2: Outstream;
        ErrOutStrm: OutStream;
    begin
        Window.Update(1,'Reading 2Ship response');
        Response.Content.ReadAs(ResponseText);
        ResponceJson.ReadFrom(ResponseText);
         
        

        if ResponceJson.Get('TwoShipURL',TwoShipURLToken) then begin
            TwoShipURLValueTxt :=  TwoShipURLToken .AsValue().AsText();                  
        end else
            if ResponceJson.get('ExceptionMessage', ErrorToken) then                
                ErrorText :=  ErrorToken .AsValue().AsText();

        if SalesHdr."No." <> '' then begin
                //InsertFreightLineResource(SalesHdr,FreightCostValue);
            if not SalesHeader.Get(1,SalesHdr."No.") then
                if not SalesHeader.Get(5,SalesHdr."No.") then
                    SalesHeader.Init();        
            SalesHeader."2Ship Get Edit URL" := TwoShipURLValueTxt;
            SalesHeader.Modify();
        end else if TransferHdr."No." <> '' then begin
            TransferHeader.Get(TransferHdr."No.");        
            TransferHeader."2Ship Get Edit URL" := TwoShipURLValueTxt;
            TransferHeader.Modify();
        end;

        ToShipIntnLogEntries.INIT;
         if SalesHdr."No." <> '' then
            ToShipIntnLogEntries."Document No." := SalesHdr."No."
        else if TransferHdr."No." <> '' then
            ToShipIntnLogEntries."Document No." := TransferHdr."No.";
        ToShipIntnLogEntries."Request Type" := ToShipIntnLogEntries."Request Type"::GetEditUrl;
        ToShipIntnLogEntries."Date & Time" := CURRENTDATETIME;
        ToShipIntnLogEntries."User Id" := USERID;
        if Response.IsSuccessStatusCode then
            ToShipIntnLogEntries.Status := ToShipIntnLogEntries.Status::Success
        else
            ToShipIntnLogEntries.Status := ToShipIntnLogEntries.Status::Failed;
        ToShipIntnLogEntries.Error.CreateOutStream(ErrOutStrm);
        ErrOutStrm.WriteText(ErrorText);
        ToShipIntnLogEntries."JSON Response Blob".CreateOutStream(OutStrm);
        OutStrm.WriteText(ResponseText);
        ToShipIntnLogEntries."Json Request Blob".CreateOutStream(Outstream2);
        Outstream2.WriteText(RequestText);
        ToShipIntnLogEntries.INSERT(true);      
    end;    
}

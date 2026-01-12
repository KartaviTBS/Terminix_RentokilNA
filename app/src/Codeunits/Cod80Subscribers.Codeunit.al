codeunit 50003 "ARC Codeunit 80 Subscribers"
{
    trigger OnRun();
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterSalesInvLineInsert', '', false, false)]
    local procedure OnAfterSalesInvLineInsert(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean)
    begin
        CreateAGDataEntry(SalesInvHeader, SalesInvLine);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure "Sales-Post_OnBeforePostSalesDoc"(var SalesHeader: Record "Sales Header")
    var 
        WorkWaveMgt: Codeunit "ARC Workwave Management";
    begin
        If SalesHeader."ARC Workwave Order" then 
            WorkWaveMgt.MakePaymentOnBeforeSalesPost(SalesHeader)
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure "Sales-Post_OnAfterPostSalesDoc"
    (
        var SalesHeader: Record "Sales Header";
		var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
		SalesShptHdrNo: Code[20];
		RetRcpHdrNo: Code[20];
		SalesInvHdrNo: Code[20];
		SalesCrMemoHdrNo: Code[20];
		var SalesInvHdr: Record "Sales Invoice Header";
		var SalesCrMemoHdr: Record "Sales Cr.Memo Header"
    )
    var 
        WorkWaveMgt: Codeunit "ARC Workwave Management";
        WorkWaveACHMgt: Codeunit "ARC Workwave ACH Management";
    begin
        If (SalesHeader."ARC Workwave Order") and (not SalesHeader."ARC ACH Order") then begin 
            WorkWaveMgt.UpdatePaymentOnSalesOrder(SalesHeader,SalesInvHdrNo);
        end;    
        If (SalesHeader."ARC Workwave Order") and (SalesHeader."ARC ACH Order") then begin 
            WorkWaveACHMgt.MarkWorkwaveEntryToProcess(SalesInvHdrNo);
        end; 
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterSalesCrMemoLineInsert', '', false, false)]
    local procedure OnAfterSalesCrMemoLineInsert(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesHeader: Record "Sales Header")
    begin
        CreateAGDataEntry(SalesCrMemoHeader, SalesCrMemoLine);
    end;

    local procedure CreateAGDataEntry(HeaderVariant: Variant; LineVariant: Variant)
    var
        AGDataEntry: Record "ARC AG Data Entry";
        ItemVendor: Record "Item Vendor";
        Location: Record Location;
        RecRef: RecordRef;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesPerson: Record "Salesperson/Purchaser";
        Item: Record Item;
    begin
        RecRef.GetTable(HeaderVariant);
        Case RecRef.Number of
         DATABASE::"Sales Invoice Header" :
            begin
                SalesInvoiceHeader := HeaderVariant;
                SalesInvoiceLine := LineVariant;
                SalesHeader.transferfields(SalesInvoiceHeader);
                SalesLine.TransferFields(SalesInvoiceLine);
            end;
         DATABASE::"Sales Cr.Memo Header" :
            begin
                SalesCrMemoHeader := HeaderVariant;
                SalesCrMemoLine := LineVariant;
                SalesHeader.transferfields(SalesCrMemoHeader);
                SalesLine.TransferFields(SalesCrMemoLine);
            end;
        end;


        with AGDataEntry do
            begin
                Init;
                "ARC Invoice No." := SalesHeader."No.";
                "ARC Invoice Date" := SalesHeader."Posting Date";

                ItemVendor.Reset;
                ItemVendor.SetRange("Item No.", SalesLine."No.");
                if ItemVendor.FindFirst then begin
                    "ARC Manufacturer IC Code " := ItemVendor."ARC Manufacturer IC Code";
                    "ARC Distributor IC Code" := ItemVendor."ARC Distributor IC Code";
                end;

                if Location.Get(SalesLine."Location Code") then begin
                    "ARC Location IC Code" := Location."ARC Location IC Code";
                    "ARC Location City" := Location.City;
                    "ARC Location State" := Location.County;
                end;

                if SalesPerson.GET(SalesHeader."Salesperson Code") then
                    "ARC Salesperson Name" := SalesPerson.Name;

                if SalesLine.Type = SalesLine.Type::Item then begin
                  if Item.Get(SalesLine."No.") then
                    "ARC Agency" := Item."ARC Agency Item";
                end;

                "ARC Customer No." := SalesHeader."Sell-to Customer No.";
                "ARC Customer Address 1" := SalesHeader."Sell-to Address";
                "ARC Customer Address 2" := SalesHeader."Sell-to Address 2";
                "ARC Customer City" := SalesHeader."Sell-to City";
                "ARC Customer State" := SalesHeader."Sell-to County";
                "ARC Customer Address" := SalesHeader."Sell-to Post Code";
                "ARC Bill To" := SalesHeader."Bill-to Customer No.";
                "ARC Bill To Name" := SalesHeader."Bill-to Name";
                "ARC Bill To Address 1" := SalesHeader."Bill-to Address";
                "ARC Bill To Address 2" := SalesHeader."Bill-to Address 2";
                "ARC Bill To City" := SalesHeader."Bill-to City";
                "ARC Bill To State" := SalesHeader."Bill-to County";
                "ARC Bill To ZipCode" := SalesHeader."Bill-to Post Code";
                "ARC Ship To Code" := SalesHeader."Ship-to Code";
                "ARC Ship To Name" := SalesHeader."Ship-to Name";
                "ARC Ship To Address 1" := SalesHeader."Ship-to Address";
                "ARC Ship To Address 2" := SalesHeader."Ship-to Address 2";
                "ARC Ship To City" := SalesHeader."Ship-to City";
                "ARC Ship To State" := SalesHeader."Ship-to County";
                "ARC Ship To ZipCode" := SalesHeader."Ship-to Post Code";
                "ARC Sales Type" := 'EN';
                "ARC Item No." := SalesLine."No.";
                "ARC Item Description" := SalesLine.Description;
                "ARC Quantity" := SalesLine.Quantity;
                "ARC Unit of Measure Code" := SalesLine."Unit of Measure Code";
                "ARC Return Reason Code" := SalesLine."Return Reason Code";
                "ARC Unit UOM" := SalesLine."Unit of Measure";
                "ARC Created By" := UserId;
                "ARC Created Date" := Today;
                "ARC Created Time" := Time;
                "ARC SalesPerson Code" := SalesHeader."Salesperson Code";
                "ARC Bill To Unit of Measure" := SalesLine."Unit of Measure Code"; 
                "ARC Unit Price" := SalesLine."Unit Price";
                 Insert(true);
            end;
        end; 

        [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterSalesShptLineInsert', '', false, false)]
        local procedure OnAfterShipmentLineInsert(var SalesShipmentLine: Record "Sales Shipment Line"; SalesLine: Record "Sales Line")
        var
            ARCSalesMgt: Codeunit ARCSalesMgt;
        begin
            ARCSalesMgt.CreateCOIEntryLine(SalesShipmentLine,SalesLine);
        end;


}
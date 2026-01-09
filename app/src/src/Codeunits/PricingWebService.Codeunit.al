codeunit 50018 "ARC Pricing WebService"
{
    trigger OnRun();
    begin
    end;

    procedure CreatePriceEntry(var createPriceEntry:XmlPort "ARC Create Price Entry"; RequestType: Text[50]; SalesPersonCode: Code[20])
    begin
        if SalesPersonCode = '' then
            Error(SalesPersonNotFound);
        if not (RequestType in ['MODIFY','INSERT']) then
            Error(ValidOperations);
        createPriceEntry.SetSalesPersonCode(SalesPersonCode);
        createPriceEntry.SetRequestType(RequestType);
        createPriceEntry.Import;
    end;
    
    procedure GetItemNetPrice(CustomerNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal; 
            UOMCode: Code[20]; VariantCode: Code[20]; CustPriceGrCode: Code[20]; CustPostGrCode: Code[20]; CurrencyCode: Code[20]; OrderDateText: Text[30]; var PriceEntryNo: Integer): Decimal
        var 
        PriceEntryMgt: Codeunit "ARC Price Management";    
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        Customer: Record Customer;       
        OrderDate: Date;
    begin
        If Not Item.Get(ItemNo) then
            Error(ItemNotFound,ItemNo);
        If Not Customer.Get(CustomerNo) then
            Error(CustNotFound,CustomerNo);
        If UOMCode <> '' then begin
            If not ItemUOM.Get(ItemNo,UOMCode) then
                Error(ItemUOMNotFound,UOMCode);
            PriceEntryMgt.SetUoM(Quantity,ItemUOM."Qty. per Unit of Measure");
        end else
            PriceEntryMgt.SetUoM(Quantity,1);
        OrderDate := ConvertDateTextToDate(OrderDateText);
        PriceEntryMgt.setGlobalItemNo(ItemNo);
        PriceEntryMgt.SetSalesLine(SalesLine);  // SOW11 Körber Edge WMS - CO3 MCP Pricing
        PriceEntryMgt.FindSalesPrice(
                TempPriceEntry, CustomerNo, CustPriceGrCode,ItemNo, VariantCode, UOMCode,CustPriceGrCode
                , CurrencyCode, OrderDate);
        If TempPriceEntry.IsEmpty then        
            Error(PriceEntryNoFound,ItemNo);
        PriceEntryMgt.CalcBestPrice(TempPriceEntry,CustomerNo);
        PriceEntryNo := TempPriceEntry."Entry No.";
        exit(TempPriceEntry."Net Unit Price");       
        
    end;

    procedure SetSalesLine(_SalesLine: Record "Sales Line")
    begin
        // SOW11 Körber Edge WMS - CO3 MCP Pricing - for details refer to email sent Wed 9 Mar 2022 at 806am to Erik Holmberg
        SalesLine := _SalesLine;
    end;

    local procedure ConvertDateTextToDate(DateText: Text[30]) Date: Date  // YYYYMMDD
    var
        Month: Integer;
        Day: Integer;
        Year: Integer;
    begin
        Evaluate(Year, CopyStr(DateText, 1, 4));
        Evaluate(Month, CopyStr(DateText, 5, 2));
        Evaluate(Day, CopyStr(DateText, 7, 2));
        Date := DMY2Date(Day, Month, Year);
    end;
        
    
    var
      SalesLine: Record "Sales Line";
      TempPriceEntry: Record "ARC Price Entry" temporary;  
      ItemNotFound: Label 'Item %1 not found';
      CustNotFound: Label 'Customer %1 not found';
      ItemUOMNotFound: Label 'Item Unit of Measure %1 not found';
      PriceEntryNoFound: Label 'There are not price entries for this item %1';
      SalesPersonNotFound: Label 'Sales Person cannot be blank';
      ValidOperations: Label 'The only valid operations are MODIFY and INSERT';
}
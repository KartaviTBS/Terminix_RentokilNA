report 50005 "ARC Reserve Back Orders"
{
    
    Caption = 'Reserve Back Orders';
    UsageCategory = Lists;
    ProcessingOnly = true;

    dataset
    {
        
            dataitem("Sales Line";"Sales Line")
            {

                DataItemTableView = sorting("Document Type",Type,"No.","Variant Code","Drop Shipment","Location Code","Shipment Date") 
                        where ("Document Type" = Const(Order),Type = const(item), "Outstanding Quantity" = filter(<>0), "Shipment Date" = filter(<>''));
                RequestFilterFields = "Document No.","Sell-to Customer No.","No.","Location Code";

                column(Document_No_; "Document No.") {}
                column(Line_No_;"Line No."){}
                column(No_;"No."){}
                column(Quantity;Quantity){}
                column(Reserved_Quantity;"Reserved Quantity") {}

                trigger OnAfterGetRecord();
                var
                    AvailQty: Decimal;
                    Item: Record Item;
                begin
                    CalcFields("Reserved Quantity");
                    If "Outstanding Quantity" = "Reserved Quantity" then 
                        CurrReport.Skip;
                    Item.Get("No.");
                   
                    AvailQty := CalcAvailableInventory(Item);
                    if (AvailQty <= 0) then
                        CurrReport.Skip;
                    TempSalesLine := "Sales Line";    
                    TempSalesLine."Quantity (Base)" := "Reserved Quantity"; // Before
                    ReserveItems("Sales Line");
                    CalcFields("Reserved Quantity");
                    TempSalesLine."Quantity Shipped" := "Reserved Quantity"; // After
                    TempSalesLine."Quantity Invoiced" := Abs(TempSalesLine."Quantity (Base)" - TempSalesLine."Quantity Shipped");

                    TempSalesLine.Insert;
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
                    field(ExportToExcel; ExportToExcel)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Export to Excel';                       
                    }

                }
            }

        }
    }
    
    trigger OnPostReport()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        SalesHeader: Record "Sales Header";
    begin
        Commit;
        TempExcelBuffer.SetUseInfoSheet;
        TempExcelBuffer.AddInfoColumn(Format('Company Name'), false, true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        //TempExcelBuffer.AddInfoColumn(CompanyInformation.Name, false, false, false, false, '', ExcelBuf."Cell Type"::Text);
        TempExcelBuffer.ClearNewRow;
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn('Order No.', false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Req. Shipment Date', false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Line No.', false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Item No.', false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Description', false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Quantity', false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Old Reserved Quantity', false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('New Reserved Quantity', false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Reserved', false, '', true, false, true, '', TempExcelBuffer."Cell Type"::Text);
        TempSalesLine.Reset;
        If TempSalesLine.FindSet then 
            repeat
                TempExcelBuffer.NewRow;
                TempExcelBuffer.AddColumn(TempSalesLine."Document No.",false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(TempSalesLine."Requested Delivery Date",false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(TempSalesLine."Line No.",false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(TempSalesLine."No.",false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(TempSalesLine."Description",false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(TempSalesLine.Quantity,false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(TempSalesLine."Quantity (Base)",false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(TempSalesLine."Quantity Shipped",false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(TempSalesLine."Quantity Invoiced",false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            until TempSalesLine.Next =0;
        TempExcelBuffer.CreateBookAndOpenExcel('', 'Data', 'Test', CompanyName, UserId);
        Error('');

    end;

    procedure ReserveItems(SalesLine: Record "Sales Line");
    var
        ReserveSalesLine : Codeunit "Sales Line-Reserve";
        ReservMgt: Codeunit "Reservation Management";
        QtyToReserve: Decimal;
        QtyToReserveBase: Decimal;
        FullAutoReservation: Boolean;
    begin
        ReserveSalesLine.ReservQuantity(SalesLine,QtyToReserve,QtyToReserveBase);
        IF QtyToReserveBase <> 0 THEN BEGIN
            ReservMgt.SetSalesLine(SalesLine);
            ReservMgt.AutoReserve(FullAutoReservation,'',SalesLine."Shipment Date",QtyToReserve,QtyToReserveBase);
        END;
    end;    

    procedure CalcAvailableInventory(var Item: Record Item): Decimal
    var
        AvailableInventory: Decimal;
    begin
        Item.CalcFields(Inventory, "Reserved Qty. on Inventory");
        AvailableInventory := Item.Inventory - Item."Reserved Qty. on Inventory";
        exit(AvailableInventory);
    end;

    
    var
        TempSalesLine : Record "Sales Line" temporary;
        ExportToExcel: Boolean;
}
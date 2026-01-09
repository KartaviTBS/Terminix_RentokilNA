report 50008 "Update Contract Price"
{
    ApplicationArea = All;
    Caption = 'Update Contract Price';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;

    dataset
    {
        dataitem(ARCPriceEntry; "ARC Price Entry")
        {
            RequestFilterFields = "Entry No.";

            trigger OnAfterGetRecord();          
            begin
                if GuiAllowed then
                    Window.Update(1,"Entry No.");
                OldNetUnitPrice := 0;
                CalcNetUnitPrice(ARCPriceEntry);
            end;

            trigger OnPreDataItem();       
            begin
                SetFilter(Status,'%1|%2',Status::" ",Status::Approved);
                SetFilter(Type,'%1|%2',Type::"All Items",Type::Item);     
                SetFilter("Expiration Date", '%1|>=%2', 0D, Today);
                SetRange(Method,Method::MarkUp);
                if GuiAllowed then
                    Window.Open('Updating Entry....##1#######')                
            end;
            trigger OnPostDataItem();
            begin
                if GuiAllowed then
                    Window.Close();
            end;
        }
    }    

    local procedure CalcNetUnitPrice(var PriceEntry: Record "ARC Price Entry");
    var 
        CustPostingGroup: Record "Customer Posting Group";
        Customer: Record Customer;
        PriceMgt:Codeunit "ARC Price Management";
    begin
        if not(Item.Get(PriceEntry."No.")) then 
          exit;  
        OldNetUnitPrice := PriceEntry."Net Unit Price";
        Case PriceEntry.Method of
            PriceEntry.Method::Discount :
            begin
                PriceEntry."Net Unit Price" := Item."Unit Price" - ((PriceEntry."Method Value" / 100) * Item."Unit Price");
            end;
            PriceEntry.Method::Fixed :
            begin
                PriceEntry."Net Unit Price" := PriceEntry."Method Value";
            end;
            PriceEntry.Method::MarkUp :
            begin
                If PriceEntry."Method Value" = 0 then
                    PriceEntry."Net Unit Price" := 0
                else begin                                
                    PriceEntry."Net Unit Price" := ROUND(Item."ARC Sales Cost" / (1 - (PriceEntry."Method Value" / 100)));
                    ///
                    if PriceEntry."Entity Type" = PriceEntry."Entity Type"::"Customer Posting Group" then begin 
                        if CustPostingGroup.Get(PriceEntry."Entity No.") and (CustPostingGroup."ARC Internal Customer") then begin 
                            PriceEntry."Net Unit Price" := Item."Unit Cost" + ((Item."Unit Cost" * 1) * (PriceEntry."Method Value" / 100));
                            PriceEntry."Markup Value" := ((Item."Unit Cost" * 1) * (PriceEntry."Method Value" / 100));
                        end;    
                    end;   
                    if PriceEntry."Entity Type" = PriceEntry."Entity Type"::"Customer" then begin 
                        if PriceMgt.IsInternalCustomer(PriceEntry."Entity No.") then begin 
                            PriceEntry."Net Unit Price" := Item."Unit Cost" + ((Item."Unit Cost") * (PriceEntry."Method Value" / 100));
                            PriceEntry."Markup Value" := ((Item."Unit Cost") * (PriceEntry."Method Value" / 100));
                        end;    
                    end; 
                    ///
                end;  
            end;
        end;
        if OldNetUnitPrice <> PriceEntry."Net Unit Price" then    
            PriceEntry.Modify(true);
    end;

    var
        Item:Record Item;
        Window:Dialog;
        OldNetUnitPrice:Decimal;
}

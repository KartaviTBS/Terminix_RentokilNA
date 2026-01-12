report 50517 "ARC Korber Transmit Items"
{
    // SOW11 Körber Edge WMS Integration
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;
    Caption = 'Korber WMS Transmit Items';

    dataset
    {
        dataitem(Item;Item)
        {
            RequestFilterFields = "No.",Description,Blocked,"Gen. Prod. Posting Group","Item Category Code";

            column(No_;"No.")
            {
            }

            trigger OnPreDataItem()
            var
                _count: Integer;
                _Text000Qst: Label 'Items to be enqueued: %1.  Are you SURE you want to continue?';
            begin
                _count := Item.Count();
                if _count > 100 then
                    if GuiAllowed() then
                        if not Confirm(_Text000Qst,false,_count) then
                            CurrReport.Quit();
            end;

            trigger OnAfterGetRecord()
            begin
                TotalCount += 1;
                if TransmitItems then
                    KorberItemMgt.EnqueueItem(Item,'TRANSMIT')
                else
                Item.Mark(true);
            end;

            trigger OnPostDataItem()
            begin
                if TransmitItems then
                    Message(Text000Msg,TotalCount)
                else begin
                    Message(Text001Msg,TotalCount);
                    Item.MarkedOnly(true);
                    Page.Run(Page::"Item List",Item);
                end;
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
                    field(TransmitItems; TransmitItems)
                    {
                        ToolTip = 'Leave this switch off to get a count of items that would be transmitted to Korber Edge';
                        Caption = 'Transmit to WMS';
                    }
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
        KorberItemMgt: Codeunit "ARC KorberItemMgt";
        TransmitItems: Boolean;
        TotalCount: Integer;
        Text000Msg: Label 'Items enqueued for transmission: %1';
        Text001Msg: Label 'Items matching filters: %1.  These items were not enqueued for transmission to WMS.';
}
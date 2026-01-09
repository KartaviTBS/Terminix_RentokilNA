report 50003 "ARC Update Expiration Date"
{
    Caption = 'Update Contract Price Exp. Date';
    ProcessingOnly = true;
    UsageCategory = Lists;
    Permissions = TableData "ARC Price Entry" = rimd;

    dataset
    {
        dataitem(ARCPriceEntry; "ARC Price Entry")
        {
            DataItemTableView = sorting ("Entry No.");
            RequestFilterFields = "Entity No.", "No.", "Expiration Date";


            trigger OnPreDataItem();
            begin            
                if not preview then 
                    if not confirm(strsubstno(Text004,newExpDate),true) then
                        exit;
                OpenWindow(Text003,ARCPriceEntry.Count);
            end;

            trigger OnAfterGetRecord()
            begin
                if not preview then begin 
                    Validate("Expiration Date", newExpDate);
                    Modify(true);
                end;
                If PriceEntry.Get(ARCPriceEntry."Entry No.") then
                    PriceEntry.Mark(true);
                UpdateWindow();
            end;

            trigger OnPostDataItem();
            var
                PriceEntryList: Page "ARC Price Entry List";
            begin
                Window.Close;
               
                PriceEntry.MarkedOnly(true);
                PriceEntryList.SetTableView(PriceEntry);
                PriceEntryList.LookupMode := true;
                PriceEntryList.Run;
                
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

                    field(newExpirationDate; newExpDate)
                    {
                        Caption = 'New Expiration Date';
                    }
                    field(preview; preview)
                    {
                        Caption = 'Preview';
                    }

                }
            }
        }


    }

    trigger OnPreReport();
    begin
        If newExpDate = 0D then
            Error(Text001);
        
    end;

    trigger OnPostReport();
    begin
        
    end;

    local procedure OpenWindow(DisplayText: Text[250]; NoOfRecords2: Integer)
    begin
        i := 0;
        NoOfRecords := NoOfRecords2;
        WindowUpdateDateTime := CurrentDateTime;
        Window.Open(DisplayText);
    end;

    local procedure UpdateWindow()
    begin
        i := i + 1;
        if CurrentDateTime - WindowUpdateDateTime >= 300 then begin
            WindowUpdateDateTime := CurrentDateTime;
            Window.Update(1, Round(i / NoOfRecords * 10000, 1));
        end;
    end;


    var
        PriceEntry: Record "ARC Price Entry";
        newExpDate: Date;
        Text001: label 'Please enter new expiration date';
        Text002: Label 'The new expiration date is earlier then current expiration date for entry no. %1';
        Text003: Label 'Updating Price Entries @1@@@@@@@@@@\';
        Text004: Label 'Do you want to update expiration date to %1?';
        Window: Dialog;
        TotalCount: Integer;
        WindowUpdateDateTime: DateTime;
        NoOfRecords: Integer;
        preview: Boolean;
        i: Integer;
}
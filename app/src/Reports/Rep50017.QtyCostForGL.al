report 50017 "Qty & Cost For GL"
{
    Caption = 'Qty & Cost For GL Entries';
    ProcessingOnly = true;
    ApplicationArea = all;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(GLEntry; "G/L Entry")
        {
            DataItemTableView = SORTING("Posting Date");
            trigger OnPreDataItem()
            begin
                GLEntry.SETFILTER(GLEntry."Posting Date", '%1..%2', StartingDate, EndingDate);
                GLEntry.SetRange("Source Type",GLEntry."Source Type"::Customer);
                GLEntry.SetFilter("Source No.",'<>%1','');
                Window.OPEN(Text000Lbl);
                MakeExcelDataHeader();
            end;

            trigger OnAfterGetRecord()
            begin            
                GLItemLedgerRelation.Reset();
                GLItemLedgerRelation.SetRange("G/L Entry No.", "Entry No.");
                if not GLItemLedgerRelation.FindFirst() then
                    GLItemLedgerRelation.Init();

                if not ValueEntry.Get(GLItemLedgerRelation."Value Entry No.") then
                    ValueEntry.Init();
                GLEntry.CalcFields("G/L Account Name");

                if not Item.Get(ValueEntry."Item No.") then
                    Item.Init();

                TempExcelBuf.NewRow();
                TempExcelBuf.AddColumn(GLEntry."Entry No.", FALSE, '', FALSE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
                TempExcelBuf.AddColumn(GLEntry."Posting Date", FALSE, '', FALSE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Date);
                TempExcelBuf.AddColumn(GLEntry."Document No.", FALSE, '', FALSE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
                TempExcelBuf.AddColumn(GLEntry."G/L Account No.", FALSE, '', FALSE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
                TempExcelBuf.AddColumn(GLEntry."G/L Account Name", FALSE, '', FALSE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
                TempExcelBuf.AddColumn(GLEntry.Description, FALSE, '', FALSE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
                TempExcelBuf.AddColumn(ValueEntry."Item No.", FALSE, '', FALSE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
                TempExcelBuf.AddColumn(Item.Description, FALSE, '', FALSE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
                TempExcelBuf.AddColumn(ValueEntry."Item Ledger Entry Quantity", FALSE, '', FALSE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Number);
                TempExcelBuf.AddColumn(ValueEntry."Cost per Unit", FALSE, '', FALSE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Number);
                TempExcelBuf.AddColumn(GLEntry."Debit Amount", FALSE, '', FALSE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Number);
                TempExcelBuf.AddColumn(GLEntry."Credit Amount", FALSE, '', FALSE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Number);
                TempExcelBuf.AddColumn(GLEntry.Amount, FALSE, '', FALSE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Number);
            end;
        }
    }
    requestpage
    {

        layout
        {
            area(Content)
            {
                field(StartingDateV; StartingDate)
                {
                    Caption = 'Starting Date';
                    ApplicationArea = All;
                    ToolTip = 'Specify Start Date.';
                }
                field(EndingDateV; EndingDate)
                {
                    Caption = 'Ending Date';
                    ApplicationArea = All;
                    ToolTip = 'Specify End Date.';
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        TempExcelBuf.DeleteAll();
        if StartingDate = 0D then
            error(gtextDateFilterErr);

        if EndingDate = 0D then
            EndingDate := Today();

    end;

    trigger OnPostReport()
    begin
        CreateExcelBook();
    end;

    local procedure MakeExcelDataHeader()
    begin
        TempExcelBuf.SetUseInfoSheet;
        TempExcelBuf.AddInfoColumn(Format('Company Name'), false, true, false, false, '', TempExcelBuf."Cell Type"::Text);
        TempExcelBuf.ClearNewRow;
        TempExcelBuf.NewRow();
        TempExcelBuf.AddColumn('Entry No.', FALSE, '', TRUE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
        TempExcelBuf.AddColumn('Posting Date', FALSE, '', TRUE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
        TempExcelBuf.AddColumn('Document No.', FALSE, '', TRUE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
        TempExcelBuf.AddColumn('G/L Account No', FALSE, '', TRUE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
        TempExcelBuf.AddColumn('G/L Account Name', FALSE, '', TRUE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
        TempExcelBuf.AddColumn('Description', FALSE, '', TRUE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
        TempExcelBuf.AddColumn('Item No.', FALSE, '', TRUE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
        TempExcelBuf.AddColumn('Item Description', FALSE, '', TRUE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
        TempExcelBuf.AddColumn('Quantity', FALSE, '', TRUE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
        TempExcelBuf.AddColumn('Unit Cost', FALSE, '', TRUE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
        TempExcelBuf.AddColumn('Debit Amount (LCY)', FALSE, '', TRUE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
        TempExcelBuf.AddColumn('Credit Amount (LCY)', FALSE, '', TRUE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
        TempExcelBuf.AddColumn('Amount (LCY)', FALSE, '', TRUE, FALSE, FALSE, '', TempExcelBuf."Cell Type"::Text);
    end;

    local procedure CreateExcelBook()
    begin       
        TempExcelBuf.CreateBookAndOpenExcel('', 'Data', '', CompanyName, UserId);
    end;

    var
        TempExcelBuf: Record "Excel Buffer" temporary;
        GLItemLedgerRelation: Record "G/L - Item Ledger Relation";
        ValueEntry: Record "Value Entry";
        Item: Record Item;
        StartingDate: Date;
        EndingDate: Date;
        Window: Dialog;
        Text000Lbl: Label 'Reading Records    #1##########', Comment = 'For Window Update #1##########';
        gtextDateFilterErr: Label 'Starting Date should be filled in.';    
}
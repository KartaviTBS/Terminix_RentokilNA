report 50002 "ARC Post Inter Company"
{
    Caption = 'Post Inter Company';
    ProcessingOnly = true;
    UsageCategory = Lists;
    Permissions = TableData "Cust. Ledger Entry" = rimd;

    dataset
    {
        dataitem(CustLedgEntry; "Cust. Ledger Entry")
        {
            DataItemTableView = sorting ("Customer No.",Open,Positive,"Due Date","Currency Code") where (Open = const (true));
            RequestFilterFields = "Customer No.","Customer Posting Group", "Entry No.";

            trigger OnPreDataItem();
            begin
               RNASetup.Get;
               RNASetup.TestField("Journal Batch Name");
               RNASetup.TestField("Journal Template Name");
               GLSetup.Get;
            end;

            trigger OnAfterGetRecord()
            var
            begin
                DeleteExistingEntries;
                PostEliminationEntries();
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
                    
                    field(PostingDate; PostDate)
                    {
                        Caption = 'Posting Date';
                    }
                    field(DocumentDate; DocDate)
                    {
                        Caption = 'Document Date';
                    }
                }
            }
        }     
    }

    local procedure PostEliminationEntries();
    var
        GenJnlLine: Record "Gen. Journal Line";
        CustomerPostingGroup: Record "Customer Posting Group";
        Customer: Record Customer;
    begin
 
        Clear(CustomerPostingGroup);
        Customer.Get(CustLedgEntry."Customer No.");
        CustomerPostingGroup.Get(CustLedgEntry."Customer Posting Group");
        If (not CustomerPostingGroup."ARC Internal Customer") and (not Customer."ARC Internal Customer") then
            exit;
        
        CustomerPostingGroup.TestField("ARC Material Expense Account");
        CustLedgEntry.CalcFields("Original Amt. (LCY)","Original Amount");
        
         case CustLedgEntry."Document Type" of
            CustLedgEntry."Document Type"::Invoice: PostInvEntries;
            CustLedgEntry."Document Type"::"Credit Memo": PostCrMemoEntries;
        end;      
    end;

    local procedure PostInvEntries();
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if not SalesInvHeader.Get(CustLedgEntry."Document No.") then
            exit;
        LineNo += 10000;    
        CreateCustGenJnlLines(SalesInvHeader."Currency Factor");
        CreateInvGenEntries(SalesInvHeader);
        SalesInvHeader.CalcFields("Amount Including VAT",Amount);
        CreateTaxGenEntries(SalesInvHeader."Currency Factor",SalesInvHeader."Amount Including VAT" - SalesInvHeader.Amount);
        PostGLEntries();
    end;

    local procedure DeleteExistingEntries();
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.Reset;
        GenJnlLine.SetRange("Journal Template Name", RNASetup."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", RNASetup."Journal Batch Name");
        GenJnlLine.DeleteAll;
    end;
    
    local procedure PostGLEntries();
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
    begin
        Commit;
        Clear(GenJnlPostBatch);
        ClearLastError;
        GenJnlLine.Reset;
        GenJnlLine.SetRange("Journal Template Name",RNASetup."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name",RNASetup."Journal Batch Name");
        if GenJnlLine.FindFirst then begin  
            Clear(GenJnlPostBatch);
            if not GenJnlPostBatch.Run(GenJnlLine) then begin 
                CustLedgEntry."Error Code" := '0000';
                CustLedgEntry."Error Description" := CopyStr(GetLastErrorText,1,250);
                CustLedgEntry.Modify;
            end else begin 
                DeleteExistingEntries;
            end;
        end;
        LineNo := 10000;        
    end;

    local procedure PostCrMemoEntries();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if not SalesCrMemoHeader.Get(CustLedgEntry."Document No.") then
            exit;
        CreateCustGenJnlLines(SalesCrMemoHeader."Currency Factor");
        CreateCrMemoGenEntries(SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT",Amount);
        CreateTaxGenEntries(SalesCrMemoHeader."Currency Factor",-(SalesCrMemoHeader."Amount Including VAT" - SalesCrMemoHeader.Amount));
        PostGLEntries();
    end;

    local procedure CreateCustGenJnlLines(CurrFactor: Decimal);
    var
        GenJnlLine: Record "Gen. Journal Line";
        DefaultDimension: Record "Default Dimension";
        
        CustomerPostingGroup: Record "Customer Posting Group"; 
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DimMgt: Codeunit DimensionManagement;
    begin
        TempDimSetEntry.Reset;
        TempDimSetEntry.DeleteAll;
        GLSetup.Get;
        CustomerPostingGroup.Get(CustLedgEntry."Customer Posting Group");
        LineNo += 10000;
        GenJnlLine.Init();
        
        GenJnlLine."Journal Template Name" := RNASetup."Journal Template Name";
        GenJnlLine."Journal Batch Name" := RNASetup."Journal Batch Name";
        GenJnlLine."Line No." := LineNo;
        GenJnlLine."Posting Date" := PostDate;
        GenJnlLine."Document Date" := DocDate;
        GenJnlLine.Description := CustLedgEntry.Description;
        Clear(DefaultDimension);
        DefaultDimension.SetRange("Table ID",Database::Customer);
        DefaultDimension.SetRange("No.",CustLedgEntry."Customer No.");
        DefaultDimension.SetRange("Dimension Code",GLSetup."Global Dimension 1 Code");
        if DefaultDimension.FindFirst() then begin
            GenJnlLine."Shortcut Dimension 1 Code" := DefaultDimension."Dimension Value Code";
            CreateTempDimSetEntry(GLSetup."Shortcut Dimension 1 Code",DefaultDimension."Dimension Value Code",GenJnlLine."Dimension Set ID");           
        end;

        DefaultDimension.SetRange("Dimension Code",GLSetup."Global Dimension 2 Code");
        if DefaultDimension.FindFirst() then begin
            GenJnlLine."Shortcut Dimension 2 Code" := DefaultDimension."Dimension Value Code";
            CreateTempDimSetEntry(GLSetup."Shortcut Dimension 2 Code",DefaultDimension."Dimension Value Code",GenJnlLine."Dimension Set ID");
        end;
        GenJnlLine."Reason Code" := CustLedgEntry."Reason Code";
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine."Account No." := CustLedgEntry."Customer No.";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
        GenJnlLine."Document No." := CustLedgEntry."Document No.";
        GenJnlLine."External Document No." := CustLedgEntry."External Document No.";
        GenJnlLine."Currency Code" := CustLedgEntry."Currency Code";
        GenJnlLine.Amount := -CustLedgEntry."Original Amount";
        GenJnlLine."Source Currency Code" := CustLedgEntry."Currency Code";
        GenJnlLine."Source Currency Amount" := -CustLedgEntry."Original Amount";
        GenJnlLine."Amount (LCY)" := -CustLedgEntry."Original Amt. (LCY)";
        if CustLedgEntry."Currency Code" = '' then
            GenJnlLine."Currency Factor" := 1
        else
            GenJnlLine."Currency Factor" := CurrFactor;
        GenJnlLine.Correction := false;
        GenJnlLine."Sales/Purch. (LCY)" := -CustLedgEntry."Original Amt. (LCY)";
        GenJnlLine."Profit (LCY)" := 0;
        GenJnlLine."Inv. Discount (LCY)" := 0;
        GenJnlLine."Sell-to/Buy-from No." := CustLedgEntry."Sell-to Customer No.";
        GenJnlLine."Bill-to/Pay-to No." := CustLedgEntry."Customer No.";
        GenJnlLine."Salespers./Purch. Code" := CustLedgEntry."Salesperson Code";
        GenJnlLine."System-Created Entry" := true;
        GenJnlLine."On Hold" := CustLedgEntry."On Hold";
        GenJnlLine."Applies-to Doc. Type" := CustLedgEntry."Document Type";
        GenJnlLine."Applies-to Doc. No." := CustLedgEntry."Document No.";
        GenJnlLine."Applies-to ID" := '';
        GenJnlLine."Allow Application" := CustLedgEntry."Bal. Account No." = '';
        GenJnlLine."Due Date" := PostDate;
        GenJnlLine."Payment Terms Code" := '';
        GenJnlLine."Pmt. Discount Date" := 0D;
        GenJnlLine."Payment Discount %" := 0;
        GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
        GenJnlLine."Source No." := CustLedgEntry."Customer No.";
        GenJnlLine."Posting No. Series" := '';
        GenJnlLine."IC Partner Code" := '';
        GenJnlLine."Bal. Account No." := '';
        GenJnlLine."Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
        GenJnlLine.Insert;  
    end;
    
    local procedure CreateInvGenEntries(SalesInvHeader: Record "Sales Invoice Header");
    var
        SalesInvLine: Record "Sales Invoice Line";
        GenJnlLine: Record "Gen. Journal Line";
        DefaultDimension: Record "Default Dimension";
        CustomerPostingGroup: Record "Customer Posting Group";
        CurrExchRate: Record "Currency Exchange Rate";
        DimSetEntry: Record "Dimension Set Entry";
        DimMgt: Codeunit DimensionManagement;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        GLSetup.Get;
        CustomerPostingGroup.Get(CustLedgEntry."Customer Posting Group");
        SalesInvLine.Reset;
        SalesInvLine.SetRange("Document No.",SalesInvHeader."No.");
        SalesInvLine.SetFilter(Quantity,'<>0');
        if SalesInvLine.FindSet then
            repeat
                TempDimSetEntry.Reset;
                TempDimSetEntry.DeleteAll;
                LineNo += 10000;
                GenJnlLine.Init();
                GenJnlLine."Journal Template Name" := RNASetup."Journal Template Name";
                GenJnlLine."Journal Batch Name" := RNASetup."Journal Batch Name";
                GenJnlLine."Line No." := LineNo;
                GenJnlLine."Posting Date" := PostDate;
                GenJnlLine."Document Date" := DocDate;
                GenJnlLine.Description := CustLedgEntry.Description;
                Clear(DefaultDimension);
                DefaultDimension.SetRange("Table ID",Database::Customer);
                DefaultDimension.SetRange("No.",CustLedgEntry."Customer No.");
                DefaultDimension.SetRange("Dimension Code",GLSetup."Global Dimension 1 Code");
                if DefaultDimension.FindFirst() then begin
                    GenJnlLine."Shortcut Dimension 1 Code" := DefaultDimension."Dimension Value Code";
                    CreateTempDimSetEntry(GLSetup."Shortcut Dimension 1 Code",DefaultDimension."Dimension Value Code",GenJnlLine."Dimension Set ID");           
                end;

                DefaultDimension.SetRange("Dimension Code",GLSetup."Global Dimension 2 Code");
                if DefaultDimension.FindFirst() then begin
                    GenJnlLine."Shortcut Dimension 2 Code" := DefaultDimension."Dimension Value Code";
                    CreateTempDimSetEntry(GLSetup."Shortcut Dimension 2 Code",DefaultDimension."Dimension Value Code",GenJnlLine."Dimension Set ID");
                end;
                
                GenJnlLine."Reason Code" := CustLedgEntry."Reason Code";
                GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                GenJnlLine."Account No." := CustomerPostingGroup."ARC Material Expense Account";
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
                GenJnlLine."Document No." := CustLedgEntry."Document No.";
                GenJnlLine."External Document No." := CustLedgEntry."External Document No.";
                GenJnlLine."Currency Code" := CustLedgEntry."Currency Code";
                GenJnlLine.Amount := SalesInvLine.Amount;
                GenJnlLine."Source Currency Code" := CustLedgEntry."Currency Code";
                GenJnlLine."Source Currency Amount" := SalesInvLine.Amount;
                IF CustledgEntry."Currency Code" = '' THEN
                    GenJnlLine."Amount (LCY)" := SalesInvLine.Amount
                ELSE
                    GenJnlLine."Amount (LCY)" :=
                    ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        CustLedgEntry."Posting Date",CustLedgEntry."Currency Code",
                        SalesInvLine.Amount,SalesInvHeader."Currency Factor"));
                IF CustLedgEntry."Currency Code" = '' THEN
                    GenJnlLine."Currency Factor" := 1
                ELSE
                    GenJnlLine."Currency Factor" := SalesInvHeader."Currency Factor";
                GenJnlLine.Correction := FALSE;
                GenJnlLine."Sales/Purch. (LCY)" := GenJnlLine."Amount (LCY)";
                GenJnlLine."Profit (LCY)" := 0;
                GenJnlLine."Inv. Discount (LCY)" := 0;
                GenJnlLine."Sell-to/Buy-from No." := CustLedgEntry."Sell-to Customer No.";
                GenJnlLine."Bill-to/Pay-to No." := CustLedgEntry."Customer No.";
                GenJnlLine."Salespers./Purch. Code" := CustLedgEntry."Salesperson Code";
                GenJnlLine."System-Created Entry" := TRUE;
                GenJnlLine."On Hold" := CustLedgEntry."On Hold";
                GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::" ";
                
                GenJnlLine."Applies-to Doc. No." := '';
                GenJnlLine."Applies-to ID" := '';
                GenJnlLine."Allow Application" := CustLedgEntry."Bal. Account No." = '';
                GenJnlLine."Due Date" := PostDate;
                GenJnlLine."Payment Terms Code" := '';
                GenJnlLine."Pmt. Discount Date" := 0D;
                GenJnlLine."Payment Discount %" := 0;
                GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
                GenJnlLine."Source No." := CustLedgEntry."Customer No.";
                GenJnlLine."Posting No. Series" := '';
                GenJnlLine."IC Partner Code" := '';
                GenJnlLine."Bal. Account No." := '';
                Case SalesInvLine.Type of
                    SalesInvLine.Type::Item : begin 
                        DefaultDimension.Reset;
                        DefaultDimension.SetRange("Table ID",Database::Item);
                        DefaultDimension.SetRange("No.",SalesInvLine."No.");
                        DefaultDimension.SetFilter("Dimension Code",'<>%1&<>%2',GlSetup."Shortcut Dimension 1 Code",GLSetup."Shortcut Dimension 2 Code");
                        if DefaultDimension.FindSet() then
                            repeat 
                                CreateTempDimSetEntry(DefaultDimension."Dimension Code",DefaultDimension."Dimension Value Code",GenJnlLine."Dimension Set ID");           
                            until DefaultDimension.Next = 0;
                        // Code added to update LOB Dimension from Posted Sales Invoice lines
                        DimSetEntry.Reset;
                        DimSetEntry.SetRange("Dimension Set ID",SalesInvLine."Dimension Set ID");
                        if DimSetEntry.FindSet then
                            repeat
                                CreateTempDimSetEntry(DimSetEntry."Dimension Code",DimSetEntry."Dimension Value Code",GenJnlLine."Dimension Set ID");
                            until DimSetEntry.Next = 0;
                    end;
                    SalesInvLine.Type::"G/L Account",SalesInvLine.Type::"Resource" : begin 
                        CreateTempDimSetEntry(GLSetup."Shortcut Dimension 3 Code",GLSetup."ARC Default Pest LOB Code",GenJnlLine."Dimension Set ID");
                    end;
                end;
                GenJnlLine."Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
                GenJnlLine.Insert;     
            until SalesInvLine.Next = 0;
    end;

    local procedure CreateCrMemoGenEntries(SalesCrMemoHeader: Record "Sales Cr.Memo Header");
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        GenJnlLine: Record "Gen. Journal Line";
        DefaultDimension: Record "Default Dimension";
        CustomerPostingGroup: Record "Customer Posting Group";
        CurrExchRate: Record "Currency Exchange Rate";
        DimSetEntry:Record "Dimension Set Entry";
        DimMgt: Codeunit DimensionManagement;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        GLSetup.Get;
        CustomerPostingGroup.Get(CustLedgEntry."Customer Posting Group");
        SalesCrMemoLine.Reset;
        SalesCrMemoLine.SetRange("Document No.",SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetFilter(Quantity,'<>0');
        if SalesCrMemoLine.FindSet then
            repeat
                TempDimSetEntry.Reset;
                TempDimSetEntry.DeleteAll;
                LineNo += 10000;
                GenJnlLine.Init();
                GenJnlLine."Journal Template Name" := RNASetup."Journal Template Name";
                GenJnlLine."Journal Batch Name" := RNASetup."Journal Batch Name";
                GenJnlLine."Line No." := LineNo;
                GenJnlLine."Posting Date" := PostDate;
                GenJnlLine."Document Date" := DocDate;
                GenJnlLine.Description := CustLedgEntry.Description;
                Clear(DefaultDimension);
                DefaultDimension.SetRange("Table ID",Database::Customer);
                DefaultDimension.SetRange("No.",CustLedgEntry."Customer No.");
                DefaultDimension.SetRange("Dimension Code",GLSetup."Global Dimension 1 Code");
                if DefaultDimension.FindFirst() then begin
                    GenJnlLine."Shortcut Dimension 1 Code" := DefaultDimension."Dimension Value Code";
                    CreateTempDimSetEntry(GLSetup."Shortcut Dimension 1 Code",DefaultDimension."Dimension Value Code",GenJnlLine."Dimension Set ID");           
                end;

                DefaultDimension.SetRange("Dimension Code",GLSetup."Global Dimension 2 Code");
                if DefaultDimension.FindFirst() then begin
                    GenJnlLine."Shortcut Dimension 2 Code" := DefaultDimension."Dimension Value Code";
                    CreateTempDimSetEntry(GLSetup."Shortcut Dimension 2 Code",DefaultDimension."Dimension Value Code",GenJnlLine."Dimension Set ID");
                end;
                
                GenJnlLine."Reason Code" := CustLedgEntry."Reason Code";
                GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                GenJnlLine."Account No." := CustomerPostingGroup."ARC Material Expense Account";
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
                GenJnlLine."Document No." := CustLedgEntry."Document No.";
                GenJnlLine."External Document No." := CustLedgEntry."External Document No.";
                GenJnlLine."Currency Code" := CustLedgEntry."Currency Code";
                GenJnlLine.Amount := -SalesCrMemoLine.Amount;
                GenJnlLine."Source Currency Code" := CustLedgEntry."Currency Code";
                GenJnlLine."Source Currency Amount" := -SalesCrMemoLine.Amount;
                IF CustledgEntry."Currency Code" = '' THEN
                    GenJnlLine."Amount (LCY)" := -SalesCrMemoLine.Amount
                ELSE
                    GenJnlLine."Amount (LCY)" :=
                    ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        CustLedgEntry."Posting Date",CustLedgEntry."Currency Code",
                        -SalesCrMemoLine.Amount,SalesCrMemoHeader."Currency Factor"));
                IF CustLedgEntry."Currency Code" = '' THEN
                    GenJnlLine."Currency Factor" := 1
                ELSE
                    GenJnlLine."Currency Factor" := SalesCrMemoHeader."Currency Factor";
                GenJnlLine.Correction := FALSE;
                GenJnlLine."Sales/Purch. (LCY)" := GenJnlLine."Amount (LCY)";
                GenJnlLine."Profit (LCY)" := 0;
                GenJnlLine."Inv. Discount (LCY)" := 0;
                GenJnlLine."Sell-to/Buy-from No." := CustLedgEntry."Sell-to Customer No.";
                GenJnlLine."Bill-to/Pay-to No." := CustLedgEntry."Customer No.";
                GenJnlLine."Salespers./Purch. Code" := CustLedgEntry."Salesperson Code";
                GenJnlLine."System-Created Entry" := TRUE;
                GenJnlLine."On Hold" := CustLedgEntry."On Hold";
                GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::" ";
                
                GenJnlLine."Applies-to Doc. No." := '';
                GenJnlLine."Applies-to ID" := '';
                GenJnlLine."Allow Application" := CustLedgEntry."Bal. Account No." = '';
                GenJnlLine."Due Date" := PostDate;
                GenJnlLine."Payment Terms Code" := '';
                GenJnlLine."Pmt. Discount Date" := 0D;
                GenJnlLine."Payment Discount %" := 0;
                GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
                GenJnlLine."Source No." := CustLedgEntry."Customer No.";
                GenJnlLine."Bal. Account No." := '';
                GenJnlLine."Posting No. Series" := '';
                GenJnlLine."IC Partner Code" := '';
                Case SalesCrMemoLine.Type of
                    SalesCrMemoLine.Type::Item : begin 
                        DefaultDimension.Reset;
                        DefaultDimension.SetRange("Table ID",Database::Item);
                        DefaultDimension.SetRange("No.",SalesCrMemoLine."No.");
                        DefaultDimension.SetFilter("Dimension Code",'<>%1&<>%2',GlSetup."Shortcut Dimension 1 Code",GLSetup."Shortcut Dimension 2 Code");
                        if DefaultDimension.FindSet() then
                            repeat 
                                CreateTempDimSetEntry(DefaultDimension."Dimension Code",DefaultDimension."Dimension Value Code",GenJnlLine."Dimension Set ID");           
                            until DefaultDimension.Next = 0;
                        // Code added to update LOB Dimension from Posted Sales Invoice lines
                        DimSetEntry.Reset;
                        DimSetEntry.SetRange("Dimension Set ID",SalesCrMemoLine."Dimension Set ID");
                        if DimSetEntry.FindSet then
                            repeat
                                CreateTempDimSetEntry(DimSetEntry."Dimension Code",DimSetEntry."Dimension Value Code",GenJnlLine."Dimension Set ID");
                            until DimSetEntry.Next = 0;
                    end;
                    SalesCrMemoLine.Type::"G/L Account",SalesCrMemoLine.Type::"Resource" : begin 
                        CreateTempDimSetEntry(GLSetup."Shortcut Dimension 3 Code",GLSetup."ARC Default Pest LOB Code",GenJnlLine."Dimension Set ID");         
                    end;
                end;
                GenJnlLine."Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
                GenJnlLine.Insert;
            until SalesCrMemoLine.Next = 0;        
    end;   
    
    local procedure CreateTaxGenEntries(CurrFactor: Decimal; TaxAmount: Decimal);
    var
        GenJnlLine: Record "Gen. Journal Line";
        DefaultDimension: Record "Default Dimension";
        CustomerPostingGroup: Record "Customer Posting Group";
        CurrExchRate: Record "Currency Exchange Rate";
        DimMgt: Codeunit DimensionManagement;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        If TaxAmount = 0 then
            exit;
        GLSetup.Get;
        CustomerPostingGroup.Get(CustLedgEntry."Customer Posting Group");
        
        TempDimSetEntry.Reset;
        TempDimSetEntry.DeleteAll;
        LineNo += 10000;
        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := RNASetup."Journal Template Name";
        GenJnlLine."Journal Batch Name" := RNASetup."Journal Batch Name";
        GenJnlLine."Line No." := LineNo;
        GenJnlLine."Posting Date" := PostDate;
        GenJnlLine."Document Date" := DocDate;
        GenJnlLine.Description := CustLedgEntry.Description;
        Clear(DefaultDimension);
        DefaultDimension.SetRange("Table ID",Database::Customer);
        DefaultDimension.SetRange("No.",CustLedgEntry."Customer No.");
        DefaultDimension.SetRange("Dimension Code",GLSetup."Global Dimension 1 Code");
        if DefaultDimension.FindFirst() then begin
            GenJnlLine."Shortcut Dimension 1 Code" := DefaultDimension."Dimension Value Code";
            CreateTempDimSetEntry(GLSetup."Shortcut Dimension 1 Code",DefaultDimension."Dimension Value Code",GenJnlLine."Dimension Set ID");           
        end;

        DefaultDimension.SetRange("Dimension Code",GLSetup."Global Dimension 2 Code");
        if DefaultDimension.FindFirst() then begin
            GenJnlLine."Shortcut Dimension 2 Code" := DefaultDimension."Dimension Value Code";
            CreateTempDimSetEntry(GLSetup."Shortcut Dimension 2 Code",DefaultDimension."Dimension Value Code",GenJnlLine."Dimension Set ID");
        end;
        
        GenJnlLine."Reason Code" := CustLedgEntry."Reason Code";
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := CustomerPostingGroup."ARC Material Expense Account";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
        GenJnlLine."Document No." := CustLedgEntry."Document No.";
        GenJnlLine."External Document No." := CustLedgEntry."External Document No.";
        GenJnlLine."Currency Code" := CustLedgEntry."Currency Code";
        GenJnlLine.Amount := TaxAmount;
        GenJnlLine."Source Currency Code" := CustLedgEntry."Currency Code";
        GenJnlLine."Source Currency Amount" := TaxAmount;
        IF CustledgEntry."Currency Code" = '' THEN
            GenJnlLine."Amount (LCY)" := TaxAmount
        ELSE
            GenJnlLine."Amount (LCY)" :=
            ROUND(
                CurrExchRate.ExchangeAmtFCYToLCY(
                CustLedgEntry."Posting Date",CustLedgEntry."Currency Code",
                TaxAmount,CurrFactor));
        IF CustLedgEntry."Currency Code" = '' THEN
            GenJnlLine."Currency Factor" := 1
        ELSE
            GenJnlLine."Currency Factor" := CurrFactor;
        GenJnlLine.Correction := FALSE;
        GenJnlLine."Sales/Purch. (LCY)" := GenJnlLine."Amount (LCY)";
        GenJnlLine."Profit (LCY)" := 0;
        GenJnlLine."Inv. Discount (LCY)" := 0;
        GenJnlLine."Sell-to/Buy-from No." := CustLedgEntry."Sell-to Customer No.";
        GenJnlLine."Bill-to/Pay-to No." := CustLedgEntry."Customer No.";
        GenJnlLine."Salespers./Purch. Code" := CustLedgEntry."Salesperson Code";
        GenJnlLine."System-Created Entry" := TRUE;
        GenJnlLine."On Hold" := CustLedgEntry."On Hold";
        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::" ";
        
        GenJnlLine."Applies-to Doc. No." := '';
        GenJnlLine."Applies-to ID" := '';
        GenJnlLine."Allow Application" := CustLedgEntry."Bal. Account No." = '';
        GenJnlLine."Due Date" := PostDate;
        GenJnlLine."Payment Terms Code" := '';
        GenJnlLine."Pmt. Discount Date" := 0D;
        GenJnlLine."Payment Discount %" := 0;
        GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
        GenJnlLine."Source No." := CustLedgEntry."Customer No.";
        GenJnlLine."Bal. Account No." := '';
        GenJnlLine."Posting No. Series" := '';
        GenJnlLine."IC Partner Code" := '';
        GLSetup.TestField("ARC Default Tax LOB Code");
        CreateTempDimSetEntry(GLSetup."Shortcut Dimension 3 Code",GLSetup."ARC Default Tax LOB Code",GenJnlLine."Dimension Set ID");
        GenJnlLine."Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
        GenJnlLine.Insert;        
    end;
    local procedure CreateTempDimSetEntry(DimCode: Code[20]; DimValue: Code[20]; DimSetId: Integer);
    var
        DimVal: Record "Dimension Value";
    begin
        DimVal.Get(DimCode,DimValue);
        if not TempDimSetEntry.Get(DimSetId,DimCode) then begin
            TempDimSetEntry.Init();
            TempDimSetEntry."Dimension Set ID" := DimSetId;
            TempDimSetEntry."Dimension Code" := DimCode;
            TempDimSetEntry."Dimension Value Code" := DimVal.Code;
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.Insert();        
        end;
    end;

    trigger OnInitReport()
    begin
        If PostDate = 0D then
           PostDate := WorkDate;
        If DocDate = 0D then
            DocDate := WorkDate;   
    end;

    var       
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        GLSetup: Record "General Ledger Setup";
        RNASetup: Record "ARC RNA Setup";
        PostDate: Date;
        DocDate: Date;
        LineNo: Integer;
}
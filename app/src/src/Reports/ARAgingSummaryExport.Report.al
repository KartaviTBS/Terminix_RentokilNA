report 50031 "ARC AR Aging Summary Export"
{
    Caption = 'AR Aging Summary Export';
    ProcessingOnly = true;
    UsageCategory = Lists;

    dataset
    {
        dataitem("Dimension Value"; "Dimension Value")
        {
            DataItemTableView = SORTING (Code,"Global Dimension No.") WHERE ("Global Dimension No." = CONST (1));
            RequestFilterFields = Code;

                dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
                {
                    DataItemTableView = SORTING ("Global Dimension 1 Code","Posting Date",Open,Positive,"Due Date","Currency Code");
                    DataItemLinkReference = "Dimension Value";
                    DataItemLink = "Global Dimension 1 Code"=field(Code);
                    RequestFilterFields = "Customer No.";

                    trigger OnPreDataItem();
                    var
                    begin
                        // Find ledger entries which are posted before the date of the aging
                        SETRANGE("Posting Date",0D,PeriodEndingDate[1]);
                    end;   

                    trigger OnAfterGetRecord()
                    var
                    begin
                        SETRANGE("Date Filter",0D,PeriodEndingDate[1]);
                        CALCFIELDS("Remaining Amount");
                        IF ("Remaining Amount" <> 0) OR ("Posting Date" >= BegDate) THEN
                            InsertTemp("Cust. Ledger Entry");
                        CurrReport.SKIP;    //  this fools the system into thinking that no details "printed"...yet
                    end;              
                }             
                dataitem(Totals; Integer)
                
                {
                    DataItemTableView = SORTING (Number);

                    trigger OnPreDataItem();
                    var
                    begin
                        SETRANGE(Number,1,TempCustLedgEntry.COUNT);
                        TempCustLedgEntry.SETCURRENTKEY("Customer No.","Posting Date");
                        IF ISSERVICETIER THEN begin
                            CLEAR(BalanceDue);
                            CLEAR(CustTotAmountDue);
                            CustTotAmountDueToPrint := 0;
                        end;
                    end;

                    trigger OnAfterGetRecord()
                    var
                    begin

                        IF Number = 1 THEN
                            TempCustLedgEntry.FIND('-')
                        ELSE
                            TempCustLedgEntry.NEXT;

                        IF GUIALLOWED THEN
                            Window.UPDATE(1,TempCustLedgEntry."Document No.");

                        TempCustLedgEntry.SETRANGE("Date Filter",0D,PeriodEndingDate[1]);
                        TempCustLedgEntry.CALCFIELDS("Remaining Amount","Remaining Amt. (LCY)");
                        IF TempCustLedgEntry."Remaining Amount" = 0 THEN
                            CurrReport.SKIP;
                        IF TempCustLedgEntry."Currency Code" <> '' THEN
                            TempCustLedgEntry."Remaining Amt. (LCY)" :=
                            ROUND(
                            CurrExchRate.ExchangeAmtFCYToFCY(
                                PeriodEndingDate[1],
                                TempCustLedgEntry."Currency Code",
                                '',
                                TempCustLedgEntry."Remaining Amount"));
                            AmountDueToPrint := TempCustLedgEntry."Remaining Amt. (LCY)";

                        CASE AgingMethod OF
                            AgingMethod::"Due Date" :
                                AgingDate := TempCustLedgEntry."Due Date";
                            AgingMethod::"Trans Date" :
                                AgingDate := TempCustLedgEntry."Posting Date";
                            AgingMethod::"Document Date" :
                                AgingDate := TempCustLedgEntry."Document Date";
                        END;
                        j := 0;
                        WHILE AgingDate < PeriodEndingDate[j+1] DO
                            j := j + 1;
                            IF j = 0 THEN
                                j := 1;

                            AmountDue[j] := AmountDueToPrint;
                            BalanceDue[j] := BalanceDue[j] + TempCustLedgEntry."Remaining Amt. (LCY)";


                        IF j =1 THEN
                            DaysAgedBucket := 0
                        ELSE
                        IF j = 2 THEN
                            DaysAgedBucket := 30
                        ELSE
                            IF j = 3 THEN
                                DaysAgedBucket := 60
                            ELSE
                            IF j = 4 THEN
                                DaysAgedBucket := 90
                            ELSE
                                IF (j = 5) OR (j = 6) THEN
                                    DaysAgedBucket := 120
                                ELSE
                                IF j = 7 THEN
                                    DaysAgedBucket := 180
                                ELSE
                                    DaysAgedBucket := 365;

                        IF TempCustLedgEntry."Remaining Amt. (LCY)" > 0 THEN BEGIN
                            if TempARAgingSummRec.GET(TempARAgingSummRec."Account type"::Debit,DaysAgedBucket,TempCustLedgEntry."Global Dimension 1 Code") then begin
                                TempARAgingSummRec.Amount := TempARAgingSummRec.Amount + TempCustLedgEntry."Remaining Amt. (LCY)";
                                TempARAgingSummRec.MODIFY;
                            end else begin
                                TempARAgingSummRec."Account type" := TempARAgingSummRec."Account type"::Debit;
                                TempARAgingSummRec."Aging Days" := DaysAgedBucket;    
                                case DaysAgedBucket of
                                    0 :
                                        TempARAgingSummRec.Account := RNASetup."AR Aging Summary 0D Account";                                  
                                    30 :
                                        TempARAgingSummRec.Account := RNASetup."AR Aging Summary 30D Account";
                                    60 :
                                        TempARAgingSummRec.Account := RNASetup."AR Aging Summary 60D Account";
                                    90 :
                                        TempARAgingSummRec.Account := RNASetup."AR Aging Summary 90D Account";
                                    120 :
                                        TempARAgingSummRec.Account := RNASetup."AR Aging Summary 120D Account";
                                    180 :
                                        TempARAgingSummRec.Account := RNASetup."AR Aging Summary 180D Account";
                                    365 :
                                        TempARAgingSummRec.Account :=RNASetup."AR Aging Summary 365D Account";
                                end;                                                           
                                TempARAgingSummRec."Global Dimension 1 Code" := TempCustLedgEntry."Global Dimension 1 Code";
                                TempARAgingSummRec.Amount := TempCustLedgEntry."Remaining Amt. (LCY)";
                                TempARAgingSummRec.INSERT;
                            end;
                        end else begin
                            if TempARAgingSummRec.GET(TempARAgingSummRec."Account type"::Credit,DaysAgedBucket,TempCustLedgEntry."Global Dimension 1 Code") then begin
                                TempARAgingSummRec.Amount := TempARAgingSummRec.Amount + TempCustLedgEntry."Remaining Amt. (LCY)";
                                TempARAgingSummRec.MODIFY;
                            end else begin
                                TempARAgingSummRec."Account type" := TempARAgingSummRec."Account type"::Credit;
                                TempARAgingSummRec."Aging Days" := DaysAgedBucket;
                            case DaysAgedBucket of
                                0 :
                                    TempARAgingSummRec.Account := RNASetup."AR Aging Summary 0D Credit Account";                                  
                                30 :
                                    TempARAgingSummRec.Account := RNASetup."AR Aging Summary 30D Credit Account";
                                60 :
                                    TempARAgingSummRec.Account := RNASetup."AR Aging Summary 60D Credit Account";
                                90 :
                                    TempARAgingSummRec.Account := RNASetup."AR Aging Summary 90D Credit Account";
                                120 :
                                    TempARAgingSummRec.Account := RNASetup."AR Aging Summary 120D Credit Account";
                                180 :
                                    TempARAgingSummRec.Account := RNASetup."AR Aging Summary 180D Credit Account";
                                365 :
                                    TempARAgingSummRec.Account :=RNASetup."AR Aging Summary 365D Credit Account";
                            end;                                
                                TempARAgingSummRec."Global Dimension 1 Code" := TempCustLedgEntry."Global Dimension 1 Code";
                                TempARAgingSummRec.Amount := TempCustLedgEntry."Remaining Amt. (LCY)";
                                TempARAgingSummRec.INSERT;
                            end;
                        END;

                        IF ISSERVICETIER THEN BEGIN
                            CustTotAmountDue[j] := CustTotAmountDue[j] + AmountDueToPrint;
                            CustTotAmountDueToPrint := CustTotAmountDueToPrint + AmountDueToPrint;

                            TotalBalanceDue := 0;
                            FOR j := 1 TO 7 DO  
                                TotalBalanceDue := TotalBalanceDue + BalanceDue[j];
                        END;

                    end; 

                    trigger OnPostDataItem();
                    var
                    begin
                        IF TempCustLedgEntry.COUNT > 0 THEN BEGIN
                            IF ISSERVICETIER THEN BEGIN
                                FOR j := 1 TO 7 DO
                                AmountDue[j] := CustTotAmountDue[j];
                                AmountDueToPrint := CustTotAmountDueToPrint;
                            END;
                        END;
                    end;                                       
                } 

            trigger OnAfterGetRecord() //For Each Dimension Value Record Get MTD total billing
            var
            begin
                BillingTot := 0;
                SIHRec.RESET;
                SIHRec.SETFILTER("Posting Date",'%1..%2',BegDate,AsOfDate);
                SIHRec.SETFILTER("Customer Posting Group",'EXTERNAL');
                SIHRec.SETFILTER("Shortcut Dimension 1 Code",Code);
                if CustFilter <> '' then
                    SIHRec.SetFilter("Bill-to Customer No.",CustFilter);
                if DimFilter <> '' then
                    SIHRec.SetFilter("Shortcut Dimension 1 Code",DimFilter);
                IF SIHRec.FINDFIRST THEN
                REPEAT
                    SIHRec.CALCFIELDS("Amount Including VAT");
                    BillingTot := BillingTot + SIHRec."Amount Including VAT";
                UNTIL SIHRec.NEXT = 0;

                SCMRec.RESET;
                SCMRec.SETFILTER("Posting Date",'%1..%2',BegDate,AsOfDate);
                SCMRec.SETFILTER("Customer Posting Group",'EXTERNAL');
                SCMRec.SETFILTER("Shortcut Dimension 1 Code",Code);
                if CustFilter <> '' then
                    SCMRec.SetFilter("Bill-to Customer No.",CustFilter);
                if DimFilter <> '' then
                    SCMRec.SetFilter("Shortcut Dimension 1 Code",DimFilter);                
                IF SCMRec.FINDFIRST THEN
                REPEAT
                    SCMRec.CALCFIELDS("Amount Including VAT");
                    BillingTot := BillingTot - SCMRec."Amount Including VAT";
                UNTIL SCMRec.NEXT = 0;

                TempARAgingSummRec."Account type" := TempARAgingSummRec."Account type"::Total;
                TempARAgingSummRec."Aging Days" := 0;
                TempARAgingSummRec.Account := RNASetup."AR Aging Summary Billing Account";
                TempARAgingSummRec."Global Dimension 1 Code" := "Dimension Value".Code;      
                TempARAgingSummRec.Amount := BillingTot;
                TempARAgingSummRec.Insert;
                
                //After each dimension reset CLE
                TempCustLedgEntry.Reset;
                TempCustLedgEntry.DeleteAll
            end;                
            }


        dataitem(ARAgingSummary; Integer)
        {
            DataItemTableView = SORTING (Number); 

            trigger OnPreDataItem();
            var
            begin
                SETRANGE(Number,1,TempARAgingSummRec.COUNT);
                TempARAgingSummRec.SetCurrentKey(Account);
                txtChar := 'X';
                txtChar[1] := 9;

                CLEAR(ExportFile);
                ExportFile.TEXTMODE := TRUE;
                ExportFile.WRITEMODE := TRUE;
                ExportFile.CREATE(ServerFileName);

                ExportFile.WRITE('Accounts' + txtChar +
                                'Versions' + txtChar +
                                'Measures' + txtChar +
                                'LOB' + txtChar +
                                'Function' + txtChar +
                                'Currency' + txtChar +
                                'Branch Code' + txtChar +
                                'Amount' );

            end;  
            
            trigger OnAfterGetRecord()
            var
            begin
                IF Number = 1 THEN
                    TempARAgingSummRec.FIND('-')
                ELSE
                    TempARAgingSummRec.NEXT;

                IF GUIALLOWED THEN
                    Window.UPDATE(2,TempARAgingSummRec.Account + '  ' + TempARAgingSummRec."Global Dimension 1 Code");

                IF TempARAgingSummRec.Amount <> 0 THEN
                    ExportFile.WRITE(TempARAgingSummRec.Account + txtChar +
                                RNASetup."AR Aging Summary Versions" + txtChar +
                                RNASetup."AR Aging Summary Measures" + txtChar +
                                RNASetup."AR Aging Summary LOB" + txtChar +
                                RNASetup."AR Aging Summary Function" + txtChar +
                                RNASetup."AR Aging Summary Currency" + txtChar +
                                TempARAgingSummRec."Global Dimension 1 Code" + txtChar +
                                FORMAT(TempARAgingSummRec.Amount));
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
                    field(PeriodEndingDate;PeriodEndingDate[1])
                    {
                        Caption = 'As of Date';
                    }
                    field(FileNameControl; ClientFileName)
                    {
                        ApplicationArea = Suite;
                        Caption = 'File Name';
                        ToolTip = 'Specifies the name of the file that you want Export';
                        AssistEdit = true;

                        trigger OnAssistEdit()
                        var
                        ExportFileTxt: Label 'Export to Text File';
                        begin
                            ClientFileName := FileManagement.SaveFileDialog(ExportFileTxt,ClientFileName,FileManagement.GetToFilterText('','.txt'));
                        end;
                    }
                    field(AgingMethod;AgingMethod)
                    {
                        Caption = 'Aging Method';
                        Editable = false;
                    } 
                     field(PeriodCalculation;PeriodCalculation)
                    {
                        Caption = 'Period Calculation';
                        Editable = false;
                    }                        

                                       
                }
            }
        }

        trigger OnInit()
        var
        begin
            PeriodEndingDate[1] := WorkDate;
            PeriodCalculation := '30D';
            AgingMethod := AgingMethod::"Trans Date";
            ShowOnlyOverDueBy := '';
            ShowAllForOverdue := FALSE;  
            PrintAmountsInLocal := FALSE;                     
        end;        
    }
        
        trigger OnPreReport()
        var
        begin
            GLSetup.GET;
            if not VJobQ then begin //must enter a Branch or Customer filter
              DimFilter := "Dimension Value".GetFilter(Code);
              if DimFilter <> '' then
                if  not DimValue.Get(GLSetup."Global Dimension 1 Code",DimFilter) then
                  Error(DimValErr);
              CustFilter := "Cust. Ledger Entry".GetFilter("Customer No.");                
              if CustFilter <> '' then
                if not Customer.GET(Custfilter) then
                  Error(CustErr);
              if (DimFilter = '') and (CustFilter = '') then
                Error(DimCustErr);
            end;

            ServerFileName := FileManagement.ServerTempFileName('txt');
            TempARAgingSummRec.Reset;
            TempArAgingSummRec.DeleteAll;
            TempCustLedgEntry.Reset;
            TempCustLedgEntry.DeleteAll;
            LedgEntryLast := 0;         
            RNASetup.GET;
            AsOfDate := PeriodEndingDate[1];
            CalculatedDate := PeriodEndingDate[1];
            BegDate := DMY2DATE(1,DATE2DMY(AsOfDate,2),DATE2DMY(AsOfDate,3));

            IF AgingMethod = AgingMethod::"Due Date" THEN BEGIN
                  PeriodEndingDate[2] := PeriodEndingDate[1];
                  FOR j := 3 TO 7 DO
                      PeriodEndingDate[j] := CALCDATE('-('+PeriodCalculation+')',PeriodEndingDate[j-1]);
            END ELSE BEGIN
                  FOR j := 2 TO 7 DO
                      PeriodEndingDate[j] := CALCDATE('-('+PeriodCalculation+')',PeriodEndingDate[j-1]);
             END;
             PeriodEndingDate[8] := 0D;

            CompanyInformation.GET;
            FilterString := Format(AsofDate);

            IF GUIALLOWED THEN
            Window.OPEN(
                'Processing Document No  #1##################\\'   +
                'Exporting Record        #2##################');   
        end;

       trigger OnPostReport()
        var
        begin
            ExportFile.CLOSE;
            IF IsWebClient THEN BEGIN
                FileManagement.DownloadHandler(ServerFileName,'','','',ClientFileName);
            END ELSE
                FileManagement.DownloadToFile(ServerFileName,ClientFileName);

        end;
    local procedure InsertTemp(CustLedgEntry: Record "Cust. Ledger Entry");
    begin
        WITH TempCustLedgEntry DO BEGIN
            IF GET(CustLedgEntry."Entry No.") THEN
                EXIT;
            TempCustLedgEntry := CustLedgEntry;
            CASE AgingMethod OF
                AgingMethod::"Due Date" :
                    "Posting Date" := "Due Date";
                AgingMethod::"Document Date" :
                    "Posting Date" := "Document Date";
            END;
            INSERT;
        END;   
    end;
    local procedure IsWebClient() : boolean;
    begin
        Exit(FileManagement.IsWebClient)
    end;
    procedure RunFromJobQ(PJobQ: boolean);
    var
    begin
        VJobQ := PJobQ;
    end; 
    procedure SetAsofDate(PAsofDate: Date);
    var
    begin
        PeriodEndingDate[1] := PAsofDate;
    end;  
    procedure SetExportFilePath(PFilePath: Text);
    var
    begin
        ClientFileName := PFilePath;
    end;  

    var
      CompanyInformation: Record "Company Information";
      Currency: Record Currency;
      CurrExchRate: Record "Currency Exchange Rate";
      Customer: Record Customer;
      DimValue: Record "Dimension Value";
      GLSetup: Record "General Ledger Setup";
      RNASetup: Record "ARC RNA Setup";
      SIHRec: Record "Sales Invoice Header";
      SCMRec: Record "Sales Cr.Memo Header"; 
      TempARAgingSummRec: Record "ARC AR Aging Summary" temporary;        
      TempCustLedgEntry: Record "Cust. Ledger Entry" temporary;

      PrintAmountsInLocal: Boolean;
      ShowAllForOverdue: Boolean;  
      VJobQ: boolean;     

      DimFilter: Code[100];
      CustFilter: Code[100];
      PeriodCalculation: Code[10];
      ShowOnlyOverDueBy: Code[10];

      ClientTypeMgt: Codeunit ClientTypeManagement;
      FileManagement: Codeunit "File Management";

      PeriodEndingDate: ARRAY [8] OF Date;
      AgingDate: Date;  
      CalculatedDate: Date;
      BegDate: Date;
      AsOfDate: Date; 
      LedgEntryDate: ARRAY [9999] OF Date;

      LedgEntryRemAmt: ARRAY [9999] OF Decimal;   
      CustTotAmountDue: ARRAY [7] OF Decimal;          
      AmountDue: ARRAY [7] OF Decimal;
      BalanceDue: ARRAY [7] OF Decimal;
      ClosingAmount: Decimal;
      Percent: Decimal;
      TotalBalanceDue: Decimal;
      AmountDueToPrint: Decimal;
      CurrencyFactor: Decimal;      
      CustTotAmountDueToPrint: Decimal;
      BillingTot: Decimal;     
      
      Window: Dialog;
      
      ExportFile: File;

      DaysAged: Integer;
      DaysAgedBucket: Integer;
      j: Integer;      
      LedgEntryNo: ARRAY [9999] OF Integer;
      LedgEntryLast: Integer;      
 
      Text001: Label 'ENU=Amounts are in %1';
      ASofDateBlank: Label 'Please enter an As of Date';
      ProcessComplete: Label 'Export Complete';
      Text031: Label 'Export from Text File';
      Text000: Label 'Enter the file name.';  
      DimValErr: Label 'You must select one valid Branch';
      CustErr: Label 'You must select one valid Customer';
      DimCustErr: Label 'You must select a Branch or a Customer filter'; 
              
      AgingMethod: Option "Trans Date","Due Date","Document Date";

      PercentString: ARRAY [7] OF Text[10];
      FilterString: Text[250];
      SubTitle: Text[88];
      DateTitle: Text[20];
      ShortDateTitle: Text[20];
      txtChar: Text[10];
      BranchFilter: Text[250];
      BranchCode: Text[20];
      ClientFileName: Text;
      FilePath: Text;
      ServerFileName: Text;      
    
}
codeunit 50062 "ARC Export AP Sweep Data"
{
    Permissions = TableData "Vendor Ledger Entry" = rim;

    trigger OnRun();
    begin
        ExportAPData;
    end;

    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        PurchSetup: Record "Purchases & Payables Setup";
        APSweepReg: Record "ARC AP Sweep Register";
        CurrRec: Record Currency;
        ExpStream: OutStream;
        ExpFile: File;
        EntryAmountLCY: Decimal;
        CurrFact: Decimal;
        EntryNo: Integer;
        EntryCount: Integer;
        FirstEntry: Integer;
        LastEntry: Integer;
        FileName: Text[250];
        ToFile: Text[30];
        BlankText: Text[1];
        VendText: Text[10];
        GLText: Text[15];
        AcctText: Text[15];

    procedure RunManual();
    begin
        ExportAPData;
    end;

    procedure ExportAPData();
    begin
        APSweepReg.RESET;
        APSweepReg.LOCKTABLE;

        IF APSweepReg.FINDLAST THEN
            EntryNo := APSweepReg."Entry No." + 1
        ELSE
            EntryNo := 1;

        PurchSetup.GET;
        PurchSetup.TESTFIELD(PurchSetup."ARC AP Sweep Folder");

        //P&P Setup field values
        //ARC AP Sweep file name = 'APSweep18_Exp_'  
        //ARC AP Sweep Account type = 'Vendor'
        //ARC AP Sweep Bal. Account Type = 'G/L Account'
        //ARC AP Sweep Bal. Account No. = '931060'
        FileName := PurchSetup."ARC AP Sweep Folder" + PurchSetup."ARC AP Sweep File Name" + FORMAT(EntryNo) + '_' +
                                                                 FORMAT(TODAY, 0, '<Day,2><Month,2><Year,2>') + '.txt';

        VendText := PurchSetup."ARC AP Sweep Account Type";
        GLText := PurchSetup."ARC AP Sweep Bal. Account Type";
        AcctText := PurchSetup."ARC AP Sweep Bal. Account No.";


        CLEAR(ExpFile);
        ExpFile.TEXTMODE := TRUE;
        ExpFile.WRITEMODE := TRUE;
        ExpFile.CREATE(FileName);

        CreateHeader;

        VendLedgEntry.SETCURRENTKEY("Entry No.");
        VendLedgEntry.SETFILTER("ARC Exported for Financials", '%1', FALSE);
        VendLedgEntry.SETFILTER(Amount, '<>%1', 0);
        IF VendLedgEntry.FINDSET THEN BEGIN
            REPEAT
                CurrFact := 0;
                IF CurrRec.GET(VendLedgEntry."Currency Code") THEN
                    CurrFact := CurrRec."Currency Factor";

                VendLedgEntry.CALCFIELDS(Amount, "Amount (LCY)");

                CreateLine;

                EntryCount += 1;
                EntryAmountLCY += VendLedgEntry."Amount (LCY)";
                VendLedgEntry."ARC Exported for Financials" := TRUE;
                IF EntryCount = 1 THEN
                    FirstEntry := VendLedgEntry."Entry No.";
                LastEntry := VendLedgEntry."Entry No.";
                VendLedgEntry.MODIFY;
            UNTIL VendLedgEntry.NEXT = 0;
        END;

        APSweepReg.INIT;
        APSweepReg."Entry No." := EntryNo;
        APSweepReg."Export Date" := WORKDATE;
        APSweepReg."Export Time" := TIME;
        APSweepReg."No. of Transactions" := EntryCount;
        APSweepReg."Transaction Amount (LCY)" := EntryAmountLCY;
        APSweepReg."From Entry No." := FirstEntry;
        APSweepReg."To Entry No." := LastEntry;
        APSweepReg.INSERT;
    end;

    procedure CreateHeader();
    begin
        ExpFile.WRITE(
          '"' + 'Posting Date' + '",' +
          '"' + 'Document Date' + '",' +
          '"' + 'Document Type' + '",' +
          '"' + 'Document No.' + '",' +
          '"' + 'External Document No.' + '",' +
          '"' + 'Account Type' + '",' +
          '"' + 'Account No.' + '",' +
          '"' + 'Description' + '",' +
          '"' + 'Currency Code' + '",' +
          '"' + 'Amount' + '",' +
          '"' + 'Bal. Account Type' + '",' +
          '"' + 'Bal. Account No.' + '",' +
          '"' + 'Applies-to Doc. Type' + '",' +
          '"' + 'Applies-to Doc. No.' + '",' +
          '"' + 'Line of Business' + '",' +
          '"' + 'Branch' + '",' +
          '"' + 'Function' + '",' +
          '"' + 'Project' + '",' +
          '"' + '",' +
          '"' + '",' +
          '"' + '",' +
          '"' + '",' +
          '"' + 'Gen. Posting Type' + '",' +
          '"' + 'Gen. Bus. Posting Group' + '",' +
          '"' + 'Gen. Prod. Posting Group' + '",' +
          '"' + 'VAT Bus. Posting Group' + '",' +
          '"' + 'VAT Prod. Posting Group' + '",' +
          '"' + 'VAT Amount' + '",' +
          '"' + 'Amount (LCY)' + '",' +
          '"' + 'Currency Factor' + '",' +
          '"' + 'Due Date' + '"'
          );

        ExpFile.WRITE(',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,');
    end;

    procedure CreateLine();
    begin
        if VendLedgEntry."Currency Code" = '' then
            CurrFact := 0
        else
            CurrFact := VendLedgEntry."Adjusted Currency Factor";

        ExpFile.WRITE(
          '"' + FORMAT(VendLedgEntry."Posting Date") + '",' +
          '"' + FORMAT(VendLedgEntry."Document Date") + '",' +
          '"' + FORMAT(VendLedgEntry."Document Type") + '",' +
          '"' + VendLedgEntry."Document No." + '",' +
          '"' + VendLedgEntry."External Document No." + '",' +
          '"' + VendText + '",' +
          '"' + VendLedgEntry."Vendor No." + '",' +
          '"' + VendLedgEntry.Description + '",' +
          '"' + VendLedgEntry."Currency Code" + '",' +
          '"' + FORMAT(VendLedgEntry.Amount) + '",' +
          '"' + GLText + '",' +
          '"' + AcctText + '",' +
          '"' + BlankText + '",' +
          '"' + BlankText + '",' +
          '"' + BlankText + '",' +
          '"' + BlankText + '",' +
          '"' + BlankText + '",' +
          '"' + BlankText + '",' +
          '"' + BlankText + '",' +
          '"' + BlankText + '",' +
          '"' + BlankText + '",' +
          '"' + BlankText + '",' +
          '"' + BlankText + '",' +
          '"' + BlankText + '",' +
          '"' + BlankText + '",' +
          '"' + BlankText + '",' +
          '"' + BlankText + '",' +
          '"' + BlankText + '",' +
          '"' + FORMAT(VendLedgEntry."Amount (LCY)") + '",' +
          '"' + FORMAT(CurrFact) + '",' +
          '"' + FORMAT(VendLedgEntry."Due Date") + '"'
          );
    end;

    procedure VendorLedgEntryExportToggle(Var VendorLedgerEntry: Record "Vendor Ledger Entry");
    var
    begin
        IF VendorLedgerEntry."ARC Exported for Financials" then
            VendorLedgerEntry."ARC Exported for Financials" := false
        else
            VendorLedgerEntry."ARC Exported for Financials" := true;
        VendorLedgerEntry.Modify;
    end;
}


codeunit 50008 "ARC Export OnGuard Data"
{
   
    TableNo = "Job Queue Entry";

    trigger OnRun();
    begin
        Initialise;
        ExportCustomers;
        ExportCustTransactions(IsReExport);
    end;

    
    procedure RunManual();
    begin
        Initialise;
        ExportCustomers;
        ExportCustTransactions(IsReExport);
    end;

    [Scope('Personalization')]
    procedure ExportCustomers();
    begin
        OnGuardSetup.Get();
        OnGuardSetup.TestField(OnGuardSetup."Customer File Export Path");

        FileName := OnGuardSetup."Customer File Export Path" + CustFileName;
        ExpFile.Create(FileName);
        ExpFile.CreateOutStream(oStream);
        
        GLSetup.Get();
        CompanyInfo.Get();
        if OGTR.FindLast() then
          LastDateModified := OGTR."Export Date"
        else
          LastDateModified := 0D;

        ExpCustHeader;
        ExpCustDetail;

        ExpFile.Close();
    end;

    procedure ExpCustHeader();
    var
        H10Text : Label 'Address 4';
        H11Text : Label 'Address 5';
        H12Text : Label 'Address 6';
        H18Text : Label 'Credit Limit Currency Code';
        H20Text : Label 'Contact Name';
        H21Text : Label 'Contact Person Job';
        H22Text : Label 'Contact Phone No.';
        H23Text : Label 'Contact Fax No.';
        H24Text : Label 'Contact E-mail';
        H25Text : Label 'Account Number';
        H26Text : Label 'AC1 (Business Region)';
        H27Text : Label 'AC2 (Controller)';
        H28Text : Label 'AC3 (Business Owner)';
        H29Text : Label 'AC4 (Cycles)';
        H30Text : Label 'Direct Debit (Y/N)';
        H31Text : Label 'IBAN / BIC';
        H32Text : Label 'Bank Account Number';
        H33Text : Label 'Sort Code';
        H34Text : Label 'Agency Credit Limit';
        H35Text : Label 'Existing Customer (Y/N)';
        H36Text : Label 'Current Risk Category';
        H37Text : Label 'Previous Risk Category';
        H38Text : Label 'Delphi Score';
        H39Text : Label 'Previous Delphi Score';
        H40Text : Label 'Parent Name';
        H41Text : Label 'Parent Agency Credit Limit';
        H42Text : Label 'Parent Agency Failure Odds';
        H43Text : Label 'Parent Delphi Score';
        H44Text : Label 'Days Beyond Terms';
        H45Text : Label 'Days Beyond Terms Trend';
        H46Text : Label 'Agency Days Beyond Terms';
        H47Text : Label '6 Month Average DBT';
        H48Text : Label 'Limited / Non Limited';
        H49Text : Label 'Agency SIC Code';
        H50Text : Label 'Agency SIC Code Description';
        H51Text : Label 'CCJ Last 6 Years';
        H52Text : Label 'Overdue Debt';
        H53Text : Label 'Account Status';
        H54Text : Label 'Customer on CMS (Y/N)';
        H55Text : Label 'Account on CMS (Y/N)';
        H56Text : Label 'Customer has Portfolio (Y/N)';
        H57Text : Label 'Jobs Exist for Customer (Y/N)';
        H58Text : Label 'Customer Portfolio Value';
        H59Text : Label 'Account has Portfolio (Y/N)';
        H60Text : Label 'Contracts Exist for Customer (Y/N)';
        H61Text : Label 'Jobs Exist for Account (Y/N)';
        H62Text : Label 'Account Portfolio Value';
        H63Text : Label 'Contracts Exist for Account (Y/N)';
        H64Text : Label 'Credit Control Status (one time)';
        H65Text : Label 'OA Company Number';
        H66Text : Label 'Ledger / AR / IR';
        H67Text : Label 'Group Number';
        H68Text : Label 'OA Customer Number';
        H69Text : Label 'Global Dimension 1 Code';
        H70Text : Label 'Global Dimension 2 Code';
        H71Text : Label 'Customer Type';
        H72Text : Label 'Payment Method';
        H73Text : Label 'Customer Posting Group';
        H74Text : Label 'Annual Revenue';
        H75Text : Label 'Payment Terms';
        H76Text : Label 'Group Account No.';
        H77Text : Label 'Group Account Name';
        H78Text : Label 'Contact Position';
        H79Text : Label 'Contact Department';
        H80Text : Label 'Contact Mobile';
        H81Text : Label 'Responsibility Center';
        H82Text : Label 'Customer Type Description';
        H83Text : Label 'Salesperson Code';
        H84Text : Label 'Service Technician';
        H85Text : Label 'Service Technician Name';
        H86Text : Label 'Portfolio Value';
        H87Text : Label 'Job/Product Sales Value';
        H88Text : Label 'Live/Terminated';
        H89Text : Label 'Contract/Job';
        H90Text : Label 'Invoice Text 1';
        H91Text : Label 'Invoice Text 2';
        H92Text : Label 'Invoice Text 3';
        H93Text : Label 'Invoice Text 4';
        H94Text : Label 'Invoice Text 5';
        H95Text : Label 'Company No.';
        H96Text : Label 'Registration No.';
        H97Text : Label 'Parent Customer No';
    begin
        oStream.WRITETEXT(
                      '"' + Customer.FieldCaption("No.") + '","' +
                      Customer.FieldCaption(Name) + '","' +
                      Customer.FieldCaption(Address) + '","' +
                      Customer.FieldCaption("Post Code") + '","' +
                      Customer.FieldCaption(City) + '","' +
                      Customer.FieldCaption(County) + '","' +
                      Customer.FieldCaption("Country/Region Code") + '","' +
                      Customer.FieldCaption("Address 2") + '","' +
                      Customer.FieldCaption("Name 2") + '","' +
                      Format(H10Text) + '","' +
                      Format(H11Text) + '","' +
                      Format(H12Text) + '","' +
                      Customer.FieldCaption("Phone No.") + '","' +
                      Customer.FieldCaption("E-Mail") + '","' +
                      Customer.FieldCaption("Fax No.") + '","' +
                      Customer.FieldCaption("Search Name") + '","' +
                      Customer.FieldCaption("Credit Limit (LCY)") + '","' +
                      Format(H18Text) + '","' +
                      Customer.FieldCaption("VAT Registration No.") + '","' +
                      Format(H20Text) + '","' +
                      Format(H21Text) + '","' +
                      Format(H22Text) + '","' +
                      Format(H23Text) + '","' +
                      Format(H24Text) + '","' +
                      Format(H25Text) + '","' +
                      Format(H26Text) + '","' +
                      Format(H27Text) + '","' +
                      Format(H28Text) + '","' +
                      Format(H29Text) + '","' +
                      Format(H30Text) + '","' +
                      Format(H31Text) + '","' +
                      Format(H32Text) + '","' +
                      Format(H33Text) + '","' +
                      Format(H34Text) + '","' +
                      Format(H35Text) + '","' +
                      Format(H36Text) + '","' +
                      Format(H37Text) + '","' +
                      Format(H38Text) + '","' +
                      Format(H39Text) + '","' +
                      Format(H40Text) + '","' +
                      Format(H41Text) + '","' +
                      Format(H42Text) + '","' +
                      Format(H43Text) + '","' +
                      Format(H44Text) + '","' +
                      Format(H45Text) + '","' +
                      Format(H46Text) + '","' +
                      Format(H47Text) + '","' +
                      Format(H48Text) + '","' +
                      Format(H49Text) + '","' +
                      Format(H50Text) + '","');

        oStream.WRITETEXT(
                      Format(H51Text) + '","' +
                      Format(H52Text) + '","' +
                      Format(H53Text) + '","' +
                      Format(H54Text) + '","' +
                      Format(H55Text) + '","' +
                      Format(H56Text) + '","' +
                      Format(H57Text) + '","' +
                      Format(H58Text) + '","' +
                      Format(H59Text) + '","' +
                      Format(H60Text) + '","' +
                      Format(H61Text) + '","' +
                      Format(H62Text) + '","' +
                      Format(H63Text) + '","' +
                      Format(H64Text) + '","' +
                      Format(H65Text) + '","' +
                      Format(H66Text) + '","' +
                      Format(H67Text) + '","' +
                      Format(H68Text) + '","' +
                      Format(H69Text) + '","' +
                      Format(H70Text) + '","' +
                      Format(H71Text) + '","' +
                      Format(H72Text) + '","' +
                      Format(H73Text) + '","' +
                      Format(H74Text) + '","' +
                      Format(H75Text) + '","' +
                      Format(H76Text) + '","' +
                      Format(H77Text) + '","' +
                      Format(H78Text) + '","' +
                      Format(H79Text) + '","' +
                      Format(H80Text) + '","' +
                      Format(H81Text) + '","' +
                      Format(H82Text) + '","' +
                      Format(H83Text) + '","' +
                      Format(H84Text) + '","' +
                      Format(H85Text) + '","' +
                      Format(H86Text) + '","' +
                      Format(H87Text) + '","' +
                      Format(H88Text) + '","' +
                      Format(H89Text) + '","' +
                      Format(H90Text) + '","' +
                      Format(H91Text) + '","' +
                      Format(H92Text) + '","' +
                      Format(H93Text) + '","' +
                      Format(H94Text) + '","' +
                      Format(H95Text) + '","' +
                      Format(H96Text) + '","' +
                      Format(H97Text) + '"');

        oStream.WRITETEXT(Format(CR) + Format(LF));
    end;

    procedure ExpCustDetail();
    var
        Location: Record Location;
        CustNo : Code[20];
        CustSearchName : Text[20];
        LCYCode : Text[10];
        ContactName : Text[30];
        ContactPersonalJob : Text[30];
        ContactPhoneNo : Text[30];
        ContactFaxNo : Text[30];
        ContactEmail : Text[30];
        Position : Integer;
        ParentCustomer : Text[30];
        F10 : Text[1];
        F11 : Text[1];
        F12 : Text[1];
        F25 : Text[1];
        F26 : Text[1];
        F27 : Text[1];
        F28 : Text[1];
        F29 : Text[1];
        F30 : Text[1];
        F31 : Text[1];
        F32 : Text[1];
        F33 : Text[1];
        F34 : Text[1];
        F35 : Text[1];
        F36 : Text[1];
        F37 : Text[1];
        F38 : Text[1];
        F39 : Text[1];
        F40 : Text[1];
        F41 : Text[1];
        F42 : Text[1];
        F43 : Text[1];
        F44 : Text[1];
        F45 : Text[1];
        F46 : Text[1];
        F47 : Text[1];
        F48 : Text[1];
        F49 : Text[1];
        F50 : Text[1];
        F51 : Text[1];
        F52 : Text[1];
        F53 : Text[1];
        F54 : Text[1];
        F55 : Text[1];
        F56 : Text[1];
        F57 : Text[1];
        F58 : Text[1];
        F59 : Text[1];
        F60 : Text[1];
        F61 : Text[1];
        F62 : Text[1];
        F63 : Text[1];
        F64 : Text[1];
        F65 : Text[1];
        F66 : Text[1];
        F67 : Text[1];
        F68 : Text[1];
    begin
        EntryCount := 0;
        Customer.Reset;
        Customer.SetFilter(Name,'<>%1','');
        if Customer.FindFirst() then
          repeat
            if not OnGuardSetup."Incremental Export"
               or ((OnGuardSetup."Incremental Export") and (Customer."Last Date Modified" >= LastDateModified)) then begin

              EntryCount += 1;

              if OnGuardSetup."Use Company Prefix" then
                CustNo := CompanyInfo."ARC Company Identifier" + '-' + Customer."No."
              else
                CustNo := Customer."No.";

              CustSearchName := CopyStr(Customer."Search Name",1,20);
              LCYCode := GLSetup."LCY Code";

              Position := STRPOS(Customer."No.", '-');

              if Customer."No." <> Customer."Bill-to Customer No." then begin 
                if Position > 0 then
                  ParentCustomer := CopyStr(Customer."Bill-to Customer No.",1,Position - 1)
                else
                  ParentCustomer := Customer."Bill-to Customer No.";
              end;

              ContBusRel.SETCURRENTKEY("Link to Table","No.");
              ContBusRel.SetRange("Link to Table",ContBusRel."Link to Table"::Customer);
              ContBusRel.SetRange("No.",Customer."No.");
              if ContBusRel.FindFirst() then begin
                Contact.SETCURRENTKEY("Company Name","Company No.",Type,Name);
                Contact.SetRange("Company No.",ContBusRel."Contact No.");
                Contact.SetRange("ARC Credit Control",true);
                if not Contact.FindFirst() then
                  Contact.Init();
                ContactName := Contact.Name;
                ContactPersonalJob := Contact."ARC Person Job";
                ContactPhoneNo := Contact."Phone No.";
                ContactFaxNo := Contact."Fax No.";
                ContactEmail := Contact."E-Mail";
              end;
              if Location.Get(Customer."Location Code") then;

              oStream.WRITETEXT('"' + CustNo + '","' +
                                Customer.Name + '","' +
                                Customer.Address + '","' +
                                Customer."Post Code" + '","' +
                                Customer.City + '","' +
                                Customer.County + '","' +
                                Customer."Country/Region Code" + '","' +
                                Customer."Address 2" + '","' +
                                Customer."Name 2" + '","' +
                                F10 + '","' +
                                F11 + '","' +
                                F12 + '","' +
                                Customer."Phone No." + '","' +
                                Customer."E-Mail" + '","' +
                                Customer."Fax No." + '","' +
                                Customer."Search Name" + '","' +
                                Format(Customer."Credit Limit (LCY)",0,'<Precision,2:5><Standard Format,1>') + '","' +
                                LCYCode + '","' +
                                Customer."VAT Registration No." + '","' +
                                ContactName + '","' +
                                ContactPersonalJob + '","' +
                                ContactPhoneNo + '","' +
                                ContactFaxNo + '","' +
                                ContactEmail + '","' +
                                F25 + '","' +
                                F26 + '","' +
                                F27 + '","' +
                                F28 + '","' +
                                F29 + '","' +
                                F30 + '","' +
                                F31 + '","' +
                                F32 + '","' +
                                F33 + '","' +
                                F34 + '","' +
                                F35 + '","' +
                                F36 + '","' +
                                F37 + '","' +
                                F38 + '","' +
                                F39 + '","' +
                                F40 + '","' +
                                F41 + '","' +
                                F42 + '","' +
                                F43 + '","' +
                                F44 + '","' +
                                F45 + '","' +
                                F46 + '","' +
                                F47 + '","' +
                                F48 + '","' +
                                F49 + '","' +
                                F50 + '","');

              oStream.WRITETEXT(F51 + '","' +
                                F52 + '","' +
                                F53 + '","' +
                                F54 + '","' +
                                F55 + '","' +
                                F56 + '","' +
                                F57 + '","' +
                                F58 + '","' +
                                F59 + '","' +
                                F60 + '","' +
                                F61 + '","' +
                                F62 + '","' +
                                F63 + '","' +
                                F64 + '","' +
                                F65 + '","' +
                                F66 + '","' +
                                F67 + '","' +
                                F68 + '","' +
                                Location."Shortcut Dimension 1 Code" + '","' +
                                Customer."Global Dimension 2 Code" + '","' +
                                Customer."ARC Customer Type" + '","' +
                                Customer."Payment Method Code" + '","' +
                                Customer."Customer Posting Group" + '","' +
                                Format(Customer."ARC Annual Revenue",0,'<Precision,2:5><Standard Format,1>') + '","' +
                                Customer."Payment Terms Code" + '","' +
                                Customer."Chain Name" + '","' +
                                Customer."ARC Group Account Name" + '","' +
                                Customer."ARC Contact Position" + '","' +
                                Customer."ARC Contact Department" + '","' +
                                Customer."ARC Contact Mobile" + '","' +
                                Customer."Location Code" + '","' +
                                Customer."ARC Customer Type Description" + '","' +
                                Customer."ARC Sales Employee Name" + '","' +
                                Customer."ARC Service Technician" + '","' +
                                Customer."ARC Service Technician Name" + '","' +
                                Format(Customer."ARC Portfolio Value",0,'<Precision,2:5><Standard Format,1>') + '","' +
                                Format(Customer."ARC Job/Product Sales Value",0,'<Precision,2:5><Standard Format,1>') + '","' +
                                Customer."ARC Live/Terminated" + '","' +
                                Customer."ARC Contract/Job" + '","' +
                                Customer."ARC Invoice Text 1" + '","' +
                                Customer."ARC Invoice Text 2" + '","' +
                                Customer."ARC Invoice Text 3" + '","' +
                                Customer."ARC Invoice Text 4" + '","' +
                                Customer."ARC Invoice Text 5" + '","' +
                                Customer."ARC Company No." + '","' +
                                Customer."ARC Registration No." + '","' +
                                ParentCustomer + '"');

              oStream.WRITETEXT(Format(CR) + Format(LF));

            end;

          until Customer.Next = 0;

        oStream.WRITETEXT(Format(EntryCount) + Format(CR) + Format(LF));
    end;

    procedure SetParams(NewOnGuardTransReg : Record "ARC OnGuard Trans. Register");
    begin
        OnGuardTransReg := NewOnGuardTransReg;
        IsReExport := true;
    end;

    procedure ExportCustTransactions(IsReExport : Boolean);
    begin
        OnGuardSetup.Get();
        OnGuardSetup.TestField("Transaction File Export Path");
        OnGuardSetup.TestField("Migration Date");
        GLSetup.Get();
        CompanyInfo.Get();
        OnGuardSetup.Get(); //M41.n, SS

        FileName := OnGuardSetup."Transaction File Export Path" + TransFileName;
        ExpFile.CREATE(FileName);
        ExpFile.CREATEOUTSTREAM(oStream);

        if not IsReExport then begin
          OnGuardTransReg.Reset();
          OnGuardTransReg.LOCKTABLE;
          if OnGuardTransReg.FindLast() then
            EntryNo := OnGuardTransReg."Entry No." + 1
          else
            EntryNo := 1;
        end else
          EntryNo := OnGuardTransReg."Entry No.";
        SequenceNoText := Format(EntryNo);

        ExpTransHeader;
        ExpTransDetail;

        ExpFile.Close();

        if not IsReExport then begin
          OnGuardSetup.Get();
          if OnGuardSetup."Increase Sequence Number" or (not OnGuardSetup."Increase Sequence Number" and (EntryCount > 0)) then begin
            //LastRegEntryTo := OnGuardTransReg."To Entry No.";
            OnGuardTransReg.Init();
            OnGuardTransReg."Entry No." := EntryNo;
            OnGuardTransReg."Export Date" := WORKDATE;
            OnGuardTransReg."Export Time"  := Time;
            OnGuardTransReg."No. of Transactions" := EntryCount;
            if EntryCount = 0 then begin
              OnGuardTransReg."From Entry No." := FromRegEntryNo;
              OnGuardTransReg."To Entry No." := FromRegEntryNo;
            end else begin
              OnGuardTransReg."From Entry No." := FromRegEntryNo;
              OnGuardTransReg."To Entry No." := ToRegEntryNo;
            end;
            OnGuardTransReg.Insert();
            OnGuardSetup."Last Sequence No." := EntryNo;
            OnGuardSetup.Modify();
          end;
        end;
    end;

    procedure ExpTransHeader();
    var
        TransDate : Label 'Transaction Date';
        OutsAmount : Label 'Outstanding Amount';
        DatePaidText : Label 'Date Paid';
        PartPayDescr : Label 'Partial Payment Description';
        InvoiceURL : Label 'Invoice URL';
        TransType : Label 'Transaction Type';
        TAC1 : Label 'TAC 1';
        TAC2 : Label 'TAC 2';
        TAC3 : Label 'TAC 3';
        TAC4 : Label 'TAC 4';
        InvoicePDF : Label 'Invoice PDF';
        InitialEntryDescr : Label 'FIRST';
        H19Text : Label 'Global Dimension 1 Code';
        H20Text : Label 'Global Dimension 2 Code';
        H21Text : Label 'External Document No.';
        H22Text : Label 'DocNo';
        H23Text : Label 'Sell-to Customer No.';
        H24Text : Label 'Salesperson Code';
        H25Text : Label 'Contract No.';
        H26Text : Label 'Contract Commence Date';
        H27Text : Label 'Contract Renew Date';
        H28Text : Label 'Invoice Type';
        H29Text : Label 'Invoice Period Start';
        H30Text : Label 'Invoice Period End';
        H31Text : Label 'Service Branch No.';
        H32Text : Label 'Service Technician';
        H33Text : Label 'Service Employee Name';
    begin
        oStream.WRITETEXT(SequenceNoText + Format(CR) + Format(LF));

        oStream.WRITETEXT('"' + DetCustLedgEntry.FieldCaption("Customer No.") + '","' +
                          DetCustLedgEntry.FieldCaption("Document No.") + '","' +
                          Format(TransDate) + '","' +
                          DetCustLedgEntry.FieldCaption(Amount) + '","' +
                          Format(OutsAmount) + '","' +
                          CustLedgEntry.FieldCaption(Description) + '","' +
                          CustLedgEntry.FieldCaption("Due Date") + '","' +
                          Format(DatePaidText) + '","' +
                          CustLedgEntry.FieldCaption("Currency Code") + '","' +
                          Format(PartPayDescr) + '","' +
                          Format(InvoiceURL) + '","' +
                          CustLedgEntry.FieldCaption("Document Type") + '","' +
                          Format(TransType) + '","' +
                          Format(TAC1) + '","' +
                          Format(TAC2) + '","' +
                          Format(TAC3) + '","' +
                          Format(TAC4) + '","' +
                          Format(InvoicePDF) + '","' +
                          Format(H19Text) + '","' +
                          Format(H20Text) + '","' +
                          Format(H21Text) + '","' +
                          Format(H22Text) + '","' +
                          Format(H23Text) + '","' +
                          Format(H24Text) + '","' +
                          Format(H25Text) + '","' +
                          Format(H26Text) + '","' +
                          Format(H27Text) + '","' +
                          Format(H28Text) + '","' +
                          Format(H29Text) + '","' +
                          Format(H30Text) + '","' +
                          Format(H31Text) + '","' +
                          Format(H32Text) + '","' +
                          Format(H33Text) + '"');

        oStream.WRITETEXT(Format(CR) + Format(LF));
    end;

    procedure ExpTransDetail();
    var
        OGTReg : Record "ARC OnGuard Trans. Register";
        SeqNo : Integer;
        CustNo : Code[20];
        DocNo : Text[100];
        TransactionDate : Text[30];
        OriginalAmount : Text[30];
        OutstandingAmount : Text[30];
        Description : Text[50];
        DueDate : Text[30];
        DatePaid : Text[30];
        CurrCode : Text[30];
        PartPayDescription : Text[100];
        DocType : Text[30];
        Global1Code : Text[30];
        Global2Code : Text[30];
        ExternalDocNo : Text[35];
        DocumentNo : Text[30];
        SellToCustNo : Text[30];
        SalesPersonCode : Text[30];
        ContractNo : Text[30];
        ContractComDate : Text[30];
        ContractRenewDate : Text[30];
        InvType : Text[30];
        InvPeriodStart : Text[30];
        InvPeriodEnd : Text[30];
        ServBranchNo : Text[30];
        ServTech : Text[30];
        ServEmpName : Text[30];
        F11 : Text[1];
        F13 : Text[1];
        F14 : Text[1];
        F15 : Text[1];
        F16 : Text[1];
        F17 : Text[1];
        F18 : Text[1];
    begin
        EntryCount := 0;

        if not IsReExport then begin

          //If OnGuardTransReg."To Entry No." = 0 then begin
          if OGTReg.FindLast() then begin
            if OGTReg."To Entry No." = 0 then begin
              repeat
                SeqNo := OGTReg."Entry No.";
              until (OGTReg."To Entry No." <> 0) or (OGTReg.Next(-1) = 0);
            end else SeqNo := OGTReg."Entry No.";
          end;
          if OGTReg.Get(SeqNo) then
            DetCustLedgEntry.SetFilter("Entry No.",'>%1', OGTReg."To Entry No.")
          else
             DetCustLedgEntry.SetFilter("Entry No.",'>%1', 0)
        end else
          DetCustLedgEntry.SetRange("Entry No.",OnGuardTransReg."From Entry No.",OnGuardTransReg."To Entry No.");

        if DetCustLedgEntry.FindFirst() then
          repeat
            if FromRegEntryNo = 0 then
              FromRegEntryNo := DetCustLedgEntry."Entry No.";

            CustLedgEntry.Get(DetCustLedgEntry."Cust. Ledger Entry No.");
            Clear(IsApplication);
            IsApplication := ((DetCustLedgEntry."Entry Type" = DetCustLedgEntry."Entry Type"::Application) or
                              (DetCustLedgEntry."Entry Type" = DetCustLedgEntry."Entry Type"::"Payment Discount"));
            if FromEntryNo = 0 then
              FromEntryNo := DetCustLedgEntry."Entry No.";
            ToEntryNo := DetCustLedgEntry."Entry No.";

            GetLinkedInfo := false;
            if DetCustLedgEntry."Document Type" in [DetCustLedgEntry."Document Type"::Invoice,
                              DetCustLedgEntry."Document Type"::"Credit Memo"] then begin
              if DetCustLedgEntry."Document Type" = DetCustLedgEntry."Document Type"::Invoice then begin
                if not SalesInvHeader.Get(DetCustLedgEntry."Document No.") then
                  SalesInvHeader.Init();
              end else begin
                if not SalesCrMemo.Get(DetCustLedgEntry."Document No.") then
                  SalesCrMemo.Init();
              end;
              GetLinkedInfo := true;
            end;

            CustNo := CompanyInfo."ARC Company Identifier" + '-' + DetCustLedgEntry."Customer No.";
            if OnGuardSetup."Use Company Prefix" then
              CustNo := CompanyInfo."ARC Company Identifier" + '-' + DetCustLedgEntry."Customer No."
            else
              CustNo := DetCustLedgEntry."Customer No.";

            DocNo := Format(DetCustLedgEntry."Document Type") + DetCustLedgEntry."Document No.";
            DocumentNo := DetCustLedgEntry."Document No.";
            if IsApplication then begin
              if DetCustLedgEntry."Cust. Ledger Entry No."<>DetCustLedgEntry."Applied Cust. Ledger Entry No." then begin
                ApplCustLedgEntry.Get(DetCustLedgEntry."Cust. Ledger Entry No.");
                DocNo := Format(ApplCustLedgEntry."Document Type") + ApplCustLedgEntry."Document No.";
                DocumentNo := ApplCustLedgEntry."Document No.";
              end else begin
                ApplCustLedgEntry.Get(DetCustLedgEntry."Applied Cust. Ledger Entry No.");
                DocNo := Format(ApplCustLedgEntry."Document Type") + ApplCustLedgEntry."Document No.";
                DocumentNo := ApplCustLedgEntry."Document No.";
              end;
            end;

            if DetCustLedgEntry."Initial Document Type" in
               [DetCustLedgEntry."Initial Document Type"::Payment,
               DetCustLedgEntry."Initial Document Type"::" ",
               DetCustLedgEntry."Initial Document Type"::Refund] then
              DocNo := DocNo + '-' + Format(DetCustLedgEntry."Cust. Ledger Entry No.");

            TransactionDate := FormatDate(DetCustLedgEntry."Posting Date");
            if IsApplication then begin
              ApplCustLedgEntry.Get(DetCustLedgEntry."Cust. Ledger Entry No.");
              TransactionDate := FormatDate(ApplCustLedgEntry."Posting Date");
            end;

            If DetCustLedgEntry."Posting Date" = OnGuardSetup."Migration Date" then 
              TransactionDate := FormatDate(CustLedgEntry."Document Date");

            OriginalAmount := Format(DetCustLedgEntry.Amount,0,'<Precision,2:5><Standard Format,1>');
            if IsApplication then begin
              ApplCustLedgEntry.Get(DetCustLedgEntry."Cust. Ledger Entry No.");
              ApplCustLedgEntry.CalcFields("Original Amount");
              OriginalAmount := Format(ApplCustLedgEntry."Original Amount",0,'<Precision,2:5><Standard Format,1>');
            end;

            OutstandingAmount := Format(DetCustLedgEntry.Amount,0,'<Precision,2:5><Standard Format,1>');
            if IsApplication then begin
              Outstanding := 0;
              DtldCustLedgEntry.SetFilter("Entry No.",'<=%1',DetCustLedgEntry."Entry No.");
              DtldCustLedgEntry.SetRange("Cust. Ledger Entry No.",DetCustLedgEntry."Cust. Ledger Entry No.");
              if DtldCustLedgEntry.FindSet() then
                repeat
                  Outstanding += DtldCustLedgEntry.Amount;
                until DtldCustLedgEntry.Next = 0;
              OutstandingAmount := Format(Outstanding,0,'<Precision,2:5><Standard Format,1>');
            end;
            if DetCustLedgEntry."Entry Type" = DetCustLedgEntry."Entry Type"::"Payment Discount" then
              OutstandingAmount := '0';

            Description := CustLedgEntry.Description;
            DueDate := FormatDate(CustLedgEntry."Due Date");

            Clear(DatePaid);
            if IsApplication then
              DatePaid := FormatDate(DetCustLedgEntry."Posting Date");

            if DetCustLedgEntry."Currency Code" = '' then
              CurrCode := GLSetup."LCY Code"
            else
              CurrCode := DetCustLedgEntry."Currency Code";

            Clear(PartPayDescription);
            PartPayDescription := '';  //InitialEntryDescr;
            if IsApplication then begin
              if DetCustLedgEntry."Cust. Ledger Entry No."=DetCustLedgEntry."Applied Cust. Ledger Entry No." then
            begin
                DCLE.Get(DetCustLedgEntry."Entry No." - 1);
                ApplCustLedgEntry.Get(DCLE."Cust. Ledger Entry No.");
                PartPayDescription := Format(ApplCustLedgEntry."Document Type") + ApplCustLedgEntry."Document No.";
              end
              else begin
                if DetCustLedgEntry."Applied Cust. Ledger Entry No." <> 0 then begin
                  ApplCustLedgEntry.Get(DetCustLedgEntry."Applied Cust. Ledger Entry No.");
                  if ApplCustLedgEntry."Document Type" = ApplCustLedgEntry."Document Type"::Payment then
                    PartPayDescription := Format(ApplCustLedgEntry."Document Type") + ApplCustLedgEntry."Document No." +
                                         '-' + Format(DetCustLedgEntry."Applied Cust. Ledger Entry No.")
                  else
                    PartPayDescription := Format(ApplCustLedgEntry."Document Type") + ApplCustLedgEntry."Document No.";
                end;
              end;
            end;

            DocType := Format(DetCustLedgEntry."Document Type");

            Global1Code := Format(CustLedgEntry."Global Dimension 1 Code");
            Global2Code := Format(CustLedgEntry."Global Dimension 2 Code");
            ExternalDocNo := Format(CustLedgEntry."External Document No.");

            if GetLinkedInfo then begin
              if DetCustLedgEntry."Document Type" = DetCustLedgEntry."Document Type"::Invoice then begin
                SellToCustNo := Format(SalesInvHeader."Sell-to Customer No.");
                SalesPersonCode := Format(SalesInvHeader."Salesperson Code");
                ContractNo := Format(SalesInvHeader."ARC Contract No.");
                ContractComDate := FormatDate(SalesInvHeader."ARC Contract Commence Date");
                ContractRenewDate := FormatDate(SalesInvHeader."ARC Contract Renew Date");
                InvType := Format(SalesInvHeader."ARC Invoice Type");
                InvPeriodStart := FormatDate(SalesInvHeader."ARC Invoice Period Start");
                InvPeriodEnd := FormatDate(SalesInvHeader."ARC Invoice Period Start");
                ServBranchNo := Format(SalesInvHeader."ARC Service Branch No.");
                ServTech := Format(SalesInvHeader."ARC Service Technician");
                ServEmpName := Format(SalesInvHeader."ARC Service Employee Name");
              end else begin
                SellToCustNo := Format(SalesCrMemo."Sell-to Customer No.");
                SalesPersonCode := Format(SalesCrMemo."Salesperson Code");
                ContractNo := Format(SalesCrMemo."ARC Contract No.");
                ContractComDate := FormatDate(SalesCrMemo."ARC Contract Commence Date");
                ContractRenewDate := FormatDate(SalesCrMemo."ARC Contract Renew Date");
                InvType := Format(SalesCrMemo."ARC Invoice Type");
                InvPeriodStart := FormatDate(SalesCrMemo."ARC Invoice Period Start");
                InvPeriodEnd := FormatDate(SalesCrMemo."ARC Invoice Period End");
                ServBranchNo := Format(SalesCrMemo."ARC Service Branch No.");
                ServTech := Format(SalesCrMemo."ARC Service Technician");
                ServEmpName := Format(SalesCrMemo."ARC Service Employee Name");
              end;
            end else begin
              SellToCustNo := '';
              SalesPersonCode := '';
              ContractNo := '';
              ContractComDate := '';
              ContractRenewDate := '';
              InvType := '';
              InvPeriodStart := '';
              InvPeriodEnd := '';
              ServBranchNo := '';
              ServTech := '';
              ServEmpName := '';
            end;


            oStream.WRITETEXT('"' + CustNo + '","' +
                              DocNo + '","' +
                              TransactionDate + '","' +
                              OriginalAmount + '","' +
                              OutstandingAmount + '","' +
                              Description + '","' +
                              DueDate + '","' +
                              DatePaid + '","' +
                              CurrCode + '","' +
                              PartPayDescription + '","' +
                              F11 + '","' +
                              DocType + '","' +
                              F13 + '","' +
                              F14 + '","' +
                              F15 + '","' +
                              F16 + '","' +
                              F17 + '","' +
                              F18 + '","' +
                              Global1Code + '","' +
                              Global2Code + '","' +
                              ExternalDocNo + '","' +
                              DocumentNo + '","' +
                              SellToCustNo + '","' +
                              SalesPersonCode + '","' +
                              ContractNo + '","' +
                              ContractComDate + '","' +
                              ContractRenewDate + '","' +
                              InvType + '","' +
                              InvPeriodStart + '","' +
                              InvPeriodEnd + '","' +
                              ServBranchNo + '","' +
                              ServTech + '","' +
                              ServEmpName + '"');

            oStream.WRITETEXT(Format(CR) + Format(LF));
            EntryCount += 1;

            //END;  // FOR OPEN ONLY
          until DetCustLedgEntry.Next = 0;

        ToRegEntryNo := DetCustLedgEntry."Entry No.";

        oStream.WRITETEXT(Format(EntryCount) + Format(CR) + Format(LF));
    end;

    procedure Initialise();
    begin
        CR := 13;
        LF := 10;
    end;

    procedure FormatDate(OldDate : Date) : Text[10];
    begin
        if OldDate = 0D then
          exit('');

        exit(Format(OldDate,10,'<Day,2>/<Month,2>/<Year4>'));
    end;

    var
        
        OnGuardSetup : Record "ARC OnGuard Setup";
        OnGuardTransReg : Record "ARC OnGuard Trans. Register";
        GLSetup : Record "General Ledger Setup";
        CompanyInfo : Record "Company Information";
        Customer : Record Customer;
        Contact : Record Contact;
        ContBusRel : Record "Contact Business Relation";
        CustLedgEntry : Record "Cust. Ledger Entry";
        DetCustLedgEntry : Record "Detailed Cust. Ledg. Entry";
        SalesInvHeader : Record "Sales Invoice Header";
        SalesCrMemo : Record "Sales Cr.Memo Header";
        ApplCustLedgEntry : Record "Cust. Ledger Entry";
        DtldCustLedgEntry : Record "Detailed Cust. Ledg. Entry";
        DCLE : Record "Detailed Cust. Ledg. Entry";
        NextOnGuardTrans : Record "ARC OnGuard Trans. Register";
        OGTR : Record "ARC OnGuard Trans. Register";
        RBMngt : Codeunit "File Management";
        Outstanding : Decimal;
        oStream : OutStream;
        ExpFile : File;
        FileName : Text[250];
        ToFile : Text[250];
        TransFileName : Label 'INVOICES.CSV';
        CustFileName : Label 'CUSTOMERS.CSV';
        IsReExport : Boolean;
        CR : Char;
        LF : Char;
        QT : Char;
        CM : Char;
        LastLineText : Text[50];
        LastDateModified : Date;
        EntryCount : Integer;
        SequenceNoText : Text[250];
        FirstLineText : Text[250];
        EntryNo : Integer;
        IsApplication : Boolean;
        FromEntryNo : Integer;
        ToEntryNo : Integer;
        GetLinkedInfo : Boolean;
        FromRegEntryNo : Integer;
        ToRegEntryNo : Integer;

}


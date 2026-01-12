codeunit 50004 "ARC Regulatory Management"
{

    trigger OnRun();
    begin
    end;

    var
        RegulatoryHoldBuffer: Record "ARC Regulatory Hold Buffer" temporary;
        LineNo: Integer;

    procedure GetCustomerLicenses(var TempCustLicense: Record "ARC Customer License" temporary; CustNo: Code[20]; ShipToCode: Code[10]; ShipToCountry: Code[10]; ShipToCounty: Text[30]; ShipToPostCode: Code[20]; ShipToLocality: Code[20]);
    var
        CustomerLicense: Record "ARC Customer License";
    begin
        CustomerLicense.SetRange("Customer No.", CustNo);
        CustomerLicense.SetFilter("Ship-to Code", '%1|%2', '', ShipToCode);
        CustomerLicense.SetFilter("Country/Region Code", '%1|%2', '', ShipToCountry);
        CustomerLicense.SetFilter(County, '%1|%2', '', ShipToCounty);
        CustomerLicense.SetFilter("Locality Code", '%1|%2', '', ShipToLocality);
        TempCustLicense.Reset();
        TempCustLicense.DeleteAll();
        if not CustomerLicense.IsEmpty() then begin
            CustomerLicense.FindSet(false, false);
            repeat
                TempCustLicense := CustomerLicense;
                TempCustLicense.Insert();
            until CustomerLicense.Next = 0;
        end;
    end;

    procedure IsSDSRegionBlocked(SDSCode: Code[20]; ShipToCountry: Code[10]; ShipToCounty: Text[30]; ShipToPostCode: Code[20]; ShipToLocality: Code[20]): Boolean;
    var
        SDSRegionBlock: Record "ARC SDS Region Block";
        SDSProduct: Record "ARC SDS Product";
    begin
        SDSProduct.Get(SDSCode);
        if SDSProduct."Product Use" = SDSProduct."Product Use"::" " then
            exit(false);
        SDSRegionBlock.SetRange("SDS Code", SDSCode);
        SDSRegionBlock.SetFilter("Country/Region Code", '%1|%2', '', ShipToCountry);
        SDSRegionBlock.SetFilter(County, '%1|%2', '', ShipToCounty);
        SDSRegionBlock.SetFilter("Post Code", '%1|%2', '', ShipToPostCode);
        SDSRegionBlock.SetFilter("Locality Code", '%1|%2', '', ShipToLocality);
        exit(not SDSRegionBlock.IsEmpty());
    end;

    procedure IsSDSShipFromBlocked(SDSCode: Code[20]; LocationCode: Code[10]; ShipToCountry: Code[10]; ShipToCounty: Text[30]; ProductUse: Option " ", TO_AG, Structural, Dual, Other; CASCode: Code[30]; ShipToLocality: Code[20]): Boolean;
    var
        SDSShipfromBlock: Record "ARC SDS Ship-from Block";
        CASRestriction: Record "ARC CAS Restriction";
        SDSProduct: Record "ARC SDS Product";
    begin
        SDSProduct.Get(SDSCode);
        if SDSProduct."Product Use" = SDSProduct."Product Use"::" " then
            exit(false);
        SDSShipfromBlock.Reset();
        if CASCode = '' then begin
            SDSShipfromBlock.SetRange("SDS Code", SDSCode);
            SDSShipfromBlock.SetFilter("Location Code", '%1|%2', '', LocationCode);
            SDSShipfromBlock.SetFilter("Ship-to Country/Region Code", '%1|%2', '', ShipToCountry);
            SDSShipfromBlock.SetFilter("Ship-to County", '%1|%2', '', ShipToCounty);
            SDSShipfromBlock.SetFilter("Product Use", '%1|%2', 0, ProductUse);
            SDSShipfromBlock.SetRange("Product Type Restriction Code", '');
            if not SDSShipfromBlock.IsEmpty() then
                exit(true)
            else begin
                SDSShipfromBlock.SetRange("SDS Code", '');
                if not SDSShipfromBlock.IsEmpty() then
                    exit(true);
            end;
        end else begin
            CASRestriction.SetRange("CAS Code", CASCode);
            CASRestriction.SetFilter("Country/Region Code", '%1|%2', '', ShipToCountry);
            CASRestriction.SetFilter(County, '%1|%2', '', ShipToCounty);
            CASRestriction.SetFilter("Locality Code", '%1|%2', '', ShipToLocality);
            if CASRestriction.FindSet(false, false) then repeat
            SDSShipfromBlock.SetRange("SDS Code", SDSCode);
                SDSShipfromBlock.SetFilter("Location Code", '%1|%2', '', LocationCode);
                SDSShipfromBlock.SetFilter("Ship-to Country/Region Code", '%1|%2', '', ShipToCountry);
                SDSShipfromBlock.SetFilter("Ship-to County", '%1|%2', '', ShipToCounty);
                SDSShipfromBlock.SetFilter("Product Use", '%1|%2', 0, ProductUse);
                SDSShipfromBlock.SetFilter("Product Type Restriction Code", '%1|%2', '', CASRestriction."Product Type Restriction Code");
                if not SDSShipfromBlock.IsEmpty() then
                    exit(true)
                else begin
                    SDSShipfromBlock.SetRange("SDS Code", '');
                    if not SDSShipfromBlock.IsEmpty() then
                        exit(true);
                end;
                until CASRestriction.Next = 0;
        end;
    end;

    procedure IsCASRestricted(CASCode: Code[30]; ShipToCountry: Code[10]; ShipToCounty: Text[30]; ShipToPostCode: Code[20]; ShipToLocality: Code[20]): Boolean;
    var
        CASRestriction: Record "ARC CAS Restriction";
    begin
        CASRestriction.SetRange("CAS Code", CASCode);
        CASRestriction.SetFilter("Country/Region Code", '%1|%2', '', ShipToCountry);
        CASRestriction.SetFilter(County, '%1|%2', '', ShipToCounty);
        CASRestriction.SetFilter("Locality Code", '%1|%2', '', ShipToLocality);
        exit(not CASRestriction.IsEmpty());
    end;

    procedure IsAerosolShipAllowed(SDSMatterState: Option Solid, Liquid, Gas, Other; ShippingAgentCode: Code[10]; EshipAgentServiceCode: Code[30]; WorldWideService: Boolean): Boolean;
    var
        EShipAgentService: Record "E-Ship Agent Service";
    begin

        if EShipAgentService.Get(ShippingAgentCode, EshipAgentServiceCode, WorldWideService) then
            if SDSMatterState = SDSMatterState::Gas then
                exit(EShipAgentService."Transport Method Type" <> EShipAgentService."Transport Method Type"::Air);
        exit(true);
    end;

    procedure IsLicenseExpired(CustNo: Code[20]; ShipToCode: Code[10]; ShipToCountry: Code[10]; ShipToCounty: Text[30]; ShipToLocality: Code[20]; BusinessType: Code[10]; LicenseType: Code[20]; LicenseNo: Text[30]; orderDate: Date): Boolean;
    var
        CustomerLicense: Record "ARC Customer License";
    begin
        if CustomerLicense.Get(CustNo, ShipToCode, ShipToCountry, ShipToCounty, ShipToLocality, BusinessType, LicenseType, LicenseNo) then
            exit(CustomerLicense."Expiration Date" < orderDate)
        else
            exit(true);
    end;

    procedure IsCustCASLevelRestricted(ProductTypeRestrictionCode: Code[20]): Boolean;
    var
        ProductTypeRestriction: Record "ARC Product Type Restriction";
    begin
        ProductTypeRestriction.Get(ProductTypeRestrictionCode);
        exit(ProductTypeRestriction."CAS Level Restriction");
    end;

    procedure GetSDSCAS(var TempSDSProductCAS: Record "ARC SDS Product CAS" temporary; SDSCode: Code[20]);
    var
        SDSProductCAS: Record "ARC SDS Product CAS";
    begin
        TempSDSProductCAS.Reset();
        TempSDSProductCAS.DeleteAll();
        SDSProductCAS.SetRange("SDS Product Code", SDSCode);
        if not SDSProductCAS.IsEmpty() then begin
            SDSProductCAS.FindSet(false, false);
            repeat
            TempSDSProductCAS := SDSProductCAS;
            if TempSDSProductCAS.Insert() then;
            until SDSProductCAS.Next = 0;
        end;
    end;

    procedure GetCASRestriction(var TempCASRestriction: Record "ARC CAS Restriction" temporary; CASCode: Code[30]; ShipToCountry: Code[10]; ShipToCounty: Text[30]; ShipToLocality: Code[20]);
    var
        CASRestriction: Record "ARC CAS Restriction";
    begin
        CASRestriction.SetRange("CAS Code", CASCode);
        CASRestriction.SetFilter("Country/Region Code", '%1|%2', '', ShipToCountry);
        CASRestriction.SetFilter(County, '%1|%2', '', ShipToCounty);
        CASRestriction.SetFilter("Locality Code", '%1|%2', '', ShipToLocality);
        TempCASRestriction.Reset();
        TempCASRestriction.DeleteAll();
        if not CASRestriction.IsEmpty() then begin
            CASRestriction.FindSet(false, false);
            repeat
            TempCASRestriction := CASRestriction;
            TempCASRestriction.Insert();
            until CASRestriction.Next = 0;
        end;
    end;

    procedure GetProductUseLicenseTypes(var TempLicenseType: Record "ARC License Type" temporary; ProductUse: Integer; ShipToCountry: Code[10]; ShipToCounty: Text[30]; ShipToPostCode: Code[20]; ShipToLocality: Code[20]; BusinessType: Code[10]);
    var
        ProductUseLicenseType: Record "ARC Product Use License Type";
    begin
        ProductUseLicenseType.SetRange("Product Use", ProductUse);
        ProductUseLicenseType.SetFilter("Country/Region Code", '%1|%2', '', ShipToCountry);
        ProductUseLicenseType.SetFilter(County, '%1|%2', '', ShipToCounty);
        ProductUseLicenseType.SetFilter("Post Code", '%1|%2', '', ShipToPostCode);
        ProductUseLicenseType.SetFilter("Locality Code", '%1|%2', '', ShipToLocality);
        ProductUseLicenseType.SetFilter("Business Type Code", '%1|%2', '', BusinessType);
        TempLicenseType.Reset();
        TempLicenseType.DeleteAll();
        if not ProductUseLicenseType.IsEmpty() then begin
            ProductUseLicenseType.FindSet(false, false);
            repeat
                if not TempLicenseType.Get(ProductUseLicenseType."License Type Code", '', '', '', '') then begin
                TempLicenseType.Init();
                TempLicenseType.Code := ProductUseLicenseType."License Type Code";
                TempLicenseType.Insert();
            end;
            until ProductUseLicenseType.Next = 0;
        end;
    end;

    procedure GetCustomerBusinessType(var TempCustomerBusinessType: Record "ARC Customer Business Type" temporary; CustNo: Code[20]; ShipToCode: Code[10]; ShipToCountry: Code[10]; ShipToCounty: Text[30]; ShipToPostCode: Code[20]; ShipToLocality: Code[20]);
    var
        CustomerBusinessType: Record "ARC Customer Business Type";
    begin
        CustomerBusinessType.SetRange("Customer No.", CustNo);
        CustomerBusinessType.SetFilter("Ship-to Code", '%1|%2', '', ShipToCode);
        CustomerBusinessType.SetFilter("Country/Region Code", '%1|%2', '', ShipToCountry);
        CustomerBusinessType.SetFilter(County, '%1|%2', '', ShipToCounty);
        CustomerBusinessType.SetFilter("Post Code", '%1|%2', '', ShipToPostCode);
        CustomerBusinessType.SetFilter("Locality Code", '%1|%2', '', ShipToLocality);
        TempCustomerBusinessType.Reset();
        TempCustomerBusinessType.DeleteAll();
        if not CustomerBusinessType.IsEmpty() then begin
            CustomerBusinessType.FindSet(false, false);
            repeat
                TempCustomerBusinessType := CustomerBusinessType;
                TempCustomerBusinessType.Insert();
            until CustomerBusinessType.Next = 0;
        end;
    end;

    procedure GetCustLicenseCAS(var TempCustLicenseCAS: Record "ARC Customer License CAS Code" temporary; CustNo: Code[20]; ShipToCode: Code[10]; ShipToCountry: Code[10]; ShipToCounty: Text[30]; ShipToPostCode: Code[20]; ShipToLocality: Code[20]; BusinessType: Code[10]; LicenseType: Code[20]; ProductTypeRestriction: Code[20]; LicenseNo: Text[30]);
    var
        CustLicenseCAS: Record "ARC Customer License CAS Code";
    begin
        CustLicenseCAS.SetRange("Customer No.", CustNo);
        CustLicenseCAS.SetFilter("Ship-to Code", '%1|%2', '', ShipToCode);
        CustLicenseCAS.SetFilter("Country/Region Code", '%1|%2', '', ShipToCountry);
        CustLicenseCAS.SetFilter(County, '%1|%2', '', ShipToCounty);
        CustLicenseCAS.SetFilter("Locality Code", '%1|%2', '', ShipToLocality);
        CustLicenseCAS.SetFilter("Business Type Code", '%1|%2', '', BusinessType);
        CustLicenseCAS.SetFilter("Product Type Restriction Code", '%1|%2', '', ProductTypeRestriction);
        CustLicenseCAS.SetRange("License Type Code", LicenseType);
        CustLicenseCAS.SetRange("License No.", LicenseNo);
        TempCustLicenseCAS.Reset();
        TempCustLicenseCAS.DeleteAll();
        if not CustLicenseCAS.IsEmpty() then begin
            CustLicenseCAS.FindSet(false, false);
            repeat
                TempCustLicenseCAS := CustLicenseCAS;
                TempCustLicenseCAS.Insert();
            until CustLicenseCAS.Next = 0;
        end;
    end;

    procedure GetCASCustLicense(var TempCustLicenseCAS: Record "ARC Customer License CAS Code" temporary; CustNo: Code[20]; ShipToCode: Code[10]; ShipToCountry: Code[10]; ShipToCounty: Text[30]; ShipToLocality: Code[20]; BusinessType: Code[10]; CASCode: Code[30]);
    var
        CustLicenseCAS: Record "ARC Customer License CAS Code";
    begin
        CustLicenseCAS.SetRange("Customer No.", CustNo);
        CustLicenseCAS.SetFilter("Ship-to Code", '%1|%2', '', ShipToCode);
        CustLicenseCAS.SetFilter("Country/Region Code", '%1|%2', '', ShipToCountry);
        CustLicenseCAS.SetFilter(County, '%1|%2', '', ShipToCounty);
        CustLicenseCAS.SetFilter("Locality Code", '%1|%2', '', ShipToLocality);
        CustLicenseCAS.SetFilter("Business Type Code", '%1|%2', '', BusinessType);
        CustLicenseCAS.SetRange("CAS Code", CASCode);
        TempCustLicenseCAS.Reset();
        TempCustLicenseCAS.DeleteAll();
        if not CustLicenseCAS.IsEmpty() then begin
            CustLicenseCAS.FindSet(false, false);
            repeat
                TempCustLicenseCAS := CustLicenseCAS;
                TempCustLicenseCAS.Insert();
            until CustLicenseCAS.Next = 0;
        end;
    end;

    procedure GetRestrictedProdLicTypes(var TempLicType: Record "ARC License Type" temporary; BusinessType: Code[10]; ShipToCountry: Code[10]; ShipToCounty: Text[30]; ShipToPostCode: Code[20]; ShipToLocality: Code[20]; ProdTypeRestrictionCode: Code[20]);
    var
        RestrictedProductLicType: Record "ARC Restricted Prod. Lic. Type";
    begin
        RestrictedProductLicType.SetFilter("Business Type Code", '%1|%2', '', BusinessType);
        RestrictedProductLicType.SetFilter("Country/Region Code", '%1|%2', '', ShipToCountry);
        RestrictedProductLicType.SetFilter(County, '%1|%2', '', ShipToCounty);
        RestrictedProductLicType.SetFilter("Post Code", '%1|%2', '', ShipToPostCode);
        RestrictedProductLicType.SetFilter("Locality Code", '%1|%2', '', ShipToLocality);
        RestrictedProductLicType.SetRange("Product Type Restriction Code", ProdTypeRestrictionCode);
        TempLicType.Reset();
        TempLicType.DeleteAll();
        if not RestrictedProductLicType.IsEmpty() then begin
            RestrictedProductLicType.FindSet(false, false);
            repeat
            if not TempLicType.Get(RestrictedProductLicType."License Type Code", '', '', '', '') then begin
                TempLicType.Init();
                TempLicType.Code := RestrictedProductLicType."License Type Code";
                TempLicType.Insert();
            end;
            until RestrictedProductLicType.Next = 0;
        end;
    end;

    procedure CreateSOApprovalEntry(RegulatoryHoldBuffer: Record "ARC Regulatory Hold Buffer" temporary);
    var
        ApprovalEntry: Record "Approval Entry";
        SalesHeader: Record "Sales Header";
        UserSetup: Record "User Setup";
        ApproverId: Code[20];
        LText002: Label '"No Approval Template setup for Sales %1 Approval Code %2 "';
        ProductTypeRestriction: Record "ARC Product Type Restriction";
    begin
        /*
        if not SalesHeader.GET(RegulatoryHoldBuffer."Document Type",RegulatoryHoldBuffer."Document No.") then
          EXIT;
        ApprovalSetup.GET;
        UserSetup.SetRange("User ID",USERID);
        ApproverId := '';
        if not UserSetup.FINDFIRST then
          ERRor(LText001,USERID);
        if ProductTypeRestriction.GET(RegulatoryHoldBuffer."Product Type Restriction Code") then
          RegulatoryHoldBuffer."Sales order Approval Code" := ProductTypeRestriction."Sales order Approval Code";
        if not ApprovalTemplates.GET(RegulatoryHoldBuffer."Sales order Approval Code",ApprovalTemplates."Approval Type"::"2",
                                     SalesHeader."Document Type",ApprovalTemplates."Limit Type"::"4") then
          ERRor(LText002,SalesHeader."Document Type",RegulatoryHoldBuffer."Sales order Approval Code");
        if not ApprovalTemplates.Enabled then
          EXIT;
        
        ApprovalsManagement.MakeApprovalEntry(36,SalesHeader."Document Type",SalesHeader."No.",SalesHeader."Salesperson Code",
                                              ApprovalSetup,ApproverId,RegulatoryHoldBuffer."Sales order Approval Code",UserSetup,0,0,'',
                                              ApprovalTemplates,0);
        */

    end;


    procedure TestRestriction(var SalesHeader: Record "Sales Header"; ShowHolds: Boolean): Boolean;
    var
        SalesLine: Record "Sales Line";
        TempSDSProductCAS: Record "ARC SDS Product CAS" temporary;
        Item: Record Item;
        RegulatoryHoldBuffer2: Record "ARC Regulatory Hold Buffer" temporary;
        TempCustLicense: Record "ARC Customer License" temporary;
        TempCustLicenseCAS: Record "ARC Customer License CAS Code" temporary;
        TempLicType: Record "ARC License Type" temporary;
        SDSProduct: Record "ARC SDS Product";
        ProductTypeRestriction: Record "ARC Product Type Restriction";
        TempCASRestriction: Record "ARC CAS Restriction" temporary;
        TempRestrictedProdLicType: Record "ARC Restricted Prod. Lic. Type" temporary;
        TempProductUseLicType: Record "ARC Product Use License Type" temporary;
        TempLicTypes4ProductUse: Record "ARC License Type" temporary;
        TempLicTypes4RestrictedProd: Record "ARC License Type" temporary;
        RegulatoryHoldEntries: Page "ARC Regulatory Hold Entries";        
        RequirementFound: Boolean;
        LicenseFound: Boolean;
        UnExpiredLicense: Boolean;
        LText001: Label 'License not found for restricted item';
        LText002: Label 'License %1 %2 expired %3';
        LText003: Label 'not all overrides have been handled';
        LText005: Label 'Item %1 %2 cannot be purchased by Business Type %3';
        LText004: Label 'License not found for non-restricted item';
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.IsEmpty() then
            exit(true)
        else begin
            if SalesLine.FindSet(false, false) then 
                repeat
                    TestSDS(SalesHeader, SalesLine);
                until SalesLine.Next = 0
        end;

        RegulatoryHoldBuffer.DeleteAll();

        GetCustomerLicenses(TempCustLicense,
                            SalesHeader."Sell-to Customer No.",
                            SalesHeader."Ship-to Code",
                            SalesHeader."Ship-to Country/Region Code",
                            SalesHeader."Ship-to County",
                            SalesHeader."Ship-to Post Code",
                            SalesHeader."ARC Locality Code");

        // 1 >>
        if SalesLine.FindSet(false, false) then repeat
          LineNo := 100;
            TempLicTypes4ProductUse.Reset();
            TempLicTypes4ProductUse.DeleteAll();
            TempSDSProductCAS.Reset();
            TempSDSProductCAS.DeleteAll();
            TempCustLicenseCAS.Reset();
            TempCustLicenseCAS.DeleteAll();
            TempCASRestriction.Reset();
            TempCASRestriction.DeleteAll();
            TempLicTypes4RestrictedProd.Reset();
            TempLicTypes4RestrictedProd.DeleteAll();

            Item.Get(SalesLine."No.");
            // 2 >>
            if Item."ARC SDS Product Code" <> '' then begin
                SDSProduct.Get(Item."ARC SDS Product Code");
                SDSProduct.CalcFields("License Types");
                // 2a >>
                if not((SDSProduct."License Types" = 0) or (SDSProduct."Product Use" = SDSProduct."Product Use"::" ")) then begin
                    // 2b >>
                    if IsBusTypeLicType(SalesHeader, SalesLine, SDSProduct) then begin
                        // Get Lic Types for Product Use
                        GetProductUseLicenseTypes(TempLicTypes4ProductUse,
                                                SDSProduct."Product Use",
                                                SalesHeader."Ship-to Country/Region Code",
                                                SalesHeader."Ship-to County",
                                                SalesHeader."Ship-to Post Code",
                                                SalesHeader."ARC Locality Code",
                                                SalesLine."ARC Business Type Code");

                        GetSDSCAS(TempSDSProductCAS, Item."ARC SDS Product Code");
                        // Restricted CAS
                        TempSDSProductCAS.SetRange(Restricted, true);

                        // 3 >>
                        if not TempSDSProductCAS.IsEmpty() then begin
                            // 4a >>
                            if TempSDSProductCAS.Find('-') then repeat
                                LicenseFound := false;
                                RequirementFound := false;
                                GetCASCustLicense(TempCustLicenseCAS,
                                              SalesHeader."Sell-to Customer No.",
                                              SalesHeader."Ship-to Code",
                                              SalesHeader."Ship-to Country/Region Code",
                                              SalesHeader."Ship-to County",
                                              SalesHeader."ARC Locality Code",
                                              SalesLine."ARC Business Type Code",
                                              TempSDSProductCAS."CAS Code");

                                GetCASRestriction(TempCASRestriction,
                                              TempSDSProductCAS."CAS Code",
                                              SalesHeader."Ship-to Country/Region Code",
                                              SalesHeader."Ship-to County",
                                              SalesHeader."ARC Locality Code");

                                // 5 >>
                                if TempCASRestriction.Find('-') then begin 
                                    repeat
                                    // 6 >>
                                    // Get Lic Types from Restricted Product Lic. Types for the CAS Restriction Product Type Restriction Code
                                    GetRestrictedProdLicTypes(TempLicTypes4RestrictedProd,
                                                              SalesLine."ARC Business Type Code",
                                                              SalesHeader."Ship-to Country/Region Code",
                                                              SalesHeader."Ship-to County",
                                                              SalesHeader."Ship-to Post Code",
                                                              SalesHeader."ARC Locality Code",
                                                              TempCASRestriction."Product Type Restriction Code");
                                    // if CAS Level Restriction, if yes then look at cust lic. cas records
                                    // 7 >>
                                    if IsCustCASLevelRestricted(TempCASRestriction."Product Type Restriction Code") then begin
                                        // 8 >>
                                        // Find Customer License with CAS allowed
                                        LicenseFound := false;
                                        if TempLicTypes4RestrictedProd.Find('-') then repeat
                                        RequirementFound := true;
                                            UnExpiredLicense := false;
                                            TempCustLicenseCAS.Reset();
                                            TempCustLicenseCAS.SetRange("License Type Code", TempLicTypes4RestrictedProd.Code);
                                            if TempCustLicenseCAS.Find('-') then begin
                                                repeat
                                                UnExpiredLicense := not IsLicenseExpired(TempCustLicenseCAS."Customer No.",
                                                                                         TempCustLicenseCAS."Ship-to Code",
                                                                                         TempCustLicenseCAS."Country/Region Code",
                                                                                         TempCustLicenseCAS.County,
                                                                                         TempCustLicenseCAS."Locality Code",
                                                                                         TempCustLicenseCAS."Business Type Code",
                                                                                         TempCustLicenseCAS."License Type Code",
                                                                                         TempCustLicenseCAS."License No.",
                                                                                         SalesHeader."order Date");
                                                until(TempCustLicenseCAS.Next = 0) or(UnExpiredLicense);
                                                LicenseFound := UnExpiredLicense;
                                            end;
                                            until(TempLicTypes4RestrictedProd.Next = 0) or LicenseFound;

                                        if TempLicTypes4RestrictedProd.Find('-') and(not LicenseFound) then begin
                                            RequirementFound := true;
                                            // 9 >>
                                            repeat
                                            UnExpiredLicense := false;
                                            TempCustLicenseCAS.Reset();
                                            TempCustLicenseCAS.SetRange("License Type Code", TempLicTypes4RestrictedProd.Code);
                                            // 10 >>
                                            if TempCustLicenseCAS.Find('-') then repeat
                                              UnExpiredLicense := not IsLicenseExpired(TempCustLicenseCAS."Customer No.",
                                                                                       TempCustLicenseCAS."Ship-to Code",
                                                                                       TempCustLicenseCAS."Country/Region Code",
                                                                                       TempCustLicenseCAS.County,
                                                                                       TempCustLicenseCAS."Locality Code",
                                                                                       TempCustLicenseCAS."Business Type Code",
                                                                                       TempCustLicenseCAS."License Type Code",
                                                                                       TempCustLicenseCAS."License No.",
                                                                                       SalesHeader."order Date");
                                                if not UnExpiredLicense then begin
                                                    TempCustLicense.Get(TempCustLicenseCAS."Customer No.",
                                                                      TempCustLicenseCAS."Ship-to Code",
                                                                      TempCustLicenseCAS."Country/Region Code",
                                                                      TempCustLicenseCAS.County,
                                                                      TempCustLicenseCAS."Locality Code",
                                                                      TempCustLicenseCAS."Business Type Code",
                                                                      TempCustLicenseCAS."License Type Code",
                                                                      TempCustLicenseCAS."License No.");
                                                    CreateRestrictedHoldBuffer(SalesLine."Document Type",
                                                                             SalesLine."Document No.",
                                                                             SalesLine."Line No.",
                                                                             SalesLine."No.",
                                                                             TempCustLicenseCAS."CAS Code",
                                                                             TempSDSProductCAS."SDS Product Code",
                                                                             SalesHeader."Sell-to Customer No.",
                                                                             SalesHeader."Ship-to Code",
                                                                             TempCustLicenseCAS."License Type Code",
                                                                             SalesLine."ARC Business Type Code",
                                                                             TempCustLicenseCAS."Product Type Restriction Code",
                                                                             SDSProduct."Product Use",
                                                                             StrSubstNo(LText002, TempCustLicenseCAS."License Type Code",
                                                                                        TempCustLicenseCAS."License No.",
                                                                                        TempCustLicense."Expiration Date"),1, true);
                                                end else begin
                                                    RegulatoryHoldBuffer.Reset();
                                                end;
                                                until(TempCustLicenseCAS.Next = 0) or (UnExpiredLicense);
                                            // 10 >>
                                            if not UnExpiredLicense then begin
                                                CreateRestrictedHoldBuffer(SalesLine."Document Type",
                                                                         SalesLine."Document No.",
                                                                         SalesLine."Line No.",
                                                                         SalesLine."No.",
                                                                         TempSDSProductCAS."CAS Code",
                                                                         TempSDSProductCAS."SDS Product Code",
                                                                         SalesHeader."Sell-to Customer No.",
                                                                         SalesHeader."Ship-to Code",
                                                                         TempLicTypes4RestrictedProd.Code,
                                                                         SalesLine."ARC Business Type Code",
                                                                         TempCASRestriction."Product Type Restriction Code",
                                                                         SDSProduct."Product Use",
                                                                         LText001,1, true);
                                            end;
                                            until(TempLicTypes4RestrictedProd.Next = 0) or(UnExpiredLicense);
                                            // 9 <<
                                        end;
                                        // 8 <<
                                    end else begin
                                        // 7 --
                                        // not a CAS Level Restricted Product Type so only look for Customer License for the Restricted Product
                                        // 11a >>
                                        LicenseFound := false;
                                        if TempLicTypes4RestrictedProd.Find('-') then repeat
                                        RequirementFound := true;
                                            UnExpiredLicense := false;
                                            TempCustLicense.Reset();
                                            TempCustLicense.SetRange("License Type Code", TempLicTypes4RestrictedProd.Code);
                                            if TempCustLicense.Find('-') then begin
                                                repeat
                                                UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                         TempCustLicense."Ship-to Code",
                                                                                         TempCustLicense."Country/Region Code",
                                                                                         TempCustLicense.County,
                                                                                         TempCustLicense."Locality Code",
                                                                                         TempCustLicense."Business Type Code",
                                                                                         TempCustLicense."License Type Code",
                                                                                         TempCustLicense."License No.",
                                                                                         SalesHeader."order Date");
                                                until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                                LicenseFound := UnExpiredLicense;
                                            end;
                                            until(TempLicTypes4RestrictedProd.Next = 0) or LicenseFound;

                                        if TempLicTypes4RestrictedProd.Find('-') and(not LicenseFound) then begin
                                            RequirementFound := true;
                                            repeat
                                            UnExpiredLicense := false;
                                            TempCustLicense.Reset();
                                            TempCustLicense.SetRange("License Type Code", TempLicTypes4RestrictedProd.Code);
                                            if TempCustLicense.Find('-') then repeat
                                              UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                       TempCustLicense."Ship-to Code",
                                                                                       TempCustLicense."Country/Region Code",
                                                                                       TempCustLicense.County,
                                                                                       TempCustLicense."Locality Code",
                                                                                       TempCustLicense."Business Type Code",
                                                                                       TempCustLicense."License Type Code",
                                                                                       TempCustLicense."License No.",
                                                                                       SalesHeader."order Date");
                                                if not UnExpiredLicense then begin
                                                    TempCustLicense.Get(TempCustLicense."Customer No.",
                                                                      TempCustLicense."Ship-to Code",
                                                                      TempCustLicense."Country/Region Code",
                                                                      TempCustLicense.County,
                                                                      TempCustLicense."Locality Code",
                                                                      TempCustLicense."Business Type Code",
                                                                      TempCustLicense."License Type Code",
                                                                      TempCustLicense."License No.");
                                                    CreateRestrictedHoldBuffer(SalesLine."Document Type",
                                                                             SalesLine."Document No.",
                                                                             SalesLine."Line No.",
                                                                             SalesLine."No.",
                                                                             TempSDSProductCAS."CAS Code",
                                                                             TempSDSProductCAS."SDS Product Code",
                                                                             SalesHeader."Sell-to Customer No.",
                                                                             SalesHeader."Ship-to Code",
                                                                             TempCustLicense."License Type Code",
                                                                             SalesLine."ARC Business Type Code",
                                                                             TempCASRestriction."Product Type Restriction Code",
                                                                             SDSProduct."Product Use",
                                                                             StrSubstNo(LText002, TempCustLicense."License Type Code",
                                                                                        TempCustLicense."License No.",
                                                                                        TempCustLicense."Expiration Date"),1, true);
                                                end else begin
                                                    RegulatoryHoldBuffer.Reset();
                                                end;
                                                until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                            if not UnExpiredLicense then begin
                                                CreateRestrictedHoldBuffer(SalesLine."Document Type",
                                                                         SalesLine."Document No.",
                                                                         SalesLine."Line No.",
                                                                         SalesLine."No.",
                                                                         TempSDSProductCAS."CAS Code",
                                                                         TempSDSProductCAS."SDS Product Code",
                                                                         SalesHeader."Sell-to Customer No.",
                                                                         SalesHeader."Ship-to Code",
                                                                         TempLicTypes4RestrictedProd.Code,
                                                                         SalesLine."ARC Business Type Code",
                                                                         TempCASRestriction."Product Type Restriction Code",
                                                                         SDSProduct."Product Use",
                                                                         LText001,1, true);
                                            end;
                                            until(TempLicTypes4RestrictedProd.Next = 0) or(UnExpiredLicense);
                                        end;
                                        // 11a <<
                                        // 11b >>
                                        if not RequirementFound then begin
                                            // 12 >>
                                            // then check for Product Use CAS Licenses that do not require customer CAS on the licence
                                            LicenseFound := false;
                                            if TempLicTypes4ProductUse.Find('-') then repeat
                                            UnExpiredLicense := false;
                                                TempCustLicense.Reset();
                                                TempCustLicense.SetFilter("Business Type Code", '%1|%2', '', SalesLine."ARC Business Type Code");
                                                TempCustLicense.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                                if TempCustLicense.Find('-') then begin
                                                    repeat
                                                    UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                             TempCustLicense."Ship-to Code",
                                                                                             TempCustLicense."Country/Region Code",
                                                                                             TempCustLicense.County,
                                                                                             TempCustLicense."Locality Code",
                                                                                             TempCustLicense."Business Type Code",
                                                                                             TempCustLicense."License Type Code",
                                                                                             TempCustLicense."License No.",
                                                                                             SalesHeader."order Date");
                                                    until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                                    LicenseFound := UnExpiredLicense;
                                                end;
                                                until(TempLicTypes4ProductUse.Next = 0) or LicenseFound;

                                            if TempLicTypes4ProductUse.Find('-') and(not LicenseFound) then begin
                                                RequirementFound := true;
                                                repeat
                                                UnExpiredLicense := false;
                                                TempCustLicense.Reset();
                                                TempCustLicense.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                                if TempCustLicense.Find('-') then repeat
                                                  UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                           TempCustLicense."Ship-to Code",
                                                                                           TempCustLicense."Country/Region Code",
                                                                                           TempCustLicense.County,
                                                                                           TempCustLicense."Locality Code",
                                                                                           TempCustLicense."Business Type Code",
                                                                                           TempCustLicense."License Type Code",
                                                                                           TempCustLicense."License No.",
                                                                                           SalesHeader."order Date");
                                                    if not UnExpiredLicense then begin
                                                        CreateRestrictedHoldBuffer(SalesLine."Document Type",
                                                                                 SalesLine."Document No.",
                                                                                 SalesLine."Line No.",
                                                                                 SalesLine."No.",'',
                                                                                 TempSDSProductCAS."SDS Product Code",
                                                                                 SalesHeader."Sell-to Customer No.",
                                                                                 SalesHeader."Ship-to Code",
                                                                                 TempCustLicense."License Type Code",
                                                                                 SalesLine."ARC Business Type Code",
                                                                                 TempCASRestriction."Product Type Restriction Code",
                                                                                 SDSProduct."Product Use",
                                                                                 StrSubstNo(LText002, TempCustLicense."License Type Code",
                                                                                            TempCustLicense."License No.",
                                                                                            TempCustLicense."Expiration Date"),1, true);
                                                    end else begin
                                                        RegulatoryHoldBuffer.Reset();
                                                    end;
                                                    until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                                if not UnExpiredLicense then begin
                                                    CreateRestrictedHoldBuffer(SalesLine."Document Type",
                                                                             SalesLine."Document No.",
                                                                             SalesLine."Line No.",
                                                                             SalesLine."No.",'',
                                                                             TempSDSProductCAS."SDS Product Code",
                                                                             SalesHeader."Sell-to Customer No.",
                                                                             SalesHeader."Ship-to Code",
                                                                             TempLicTypes4ProductUse.Code,
                                                                             SalesLine."ARC Business Type Code",
                                                                             TempCASRestriction."Product Type Restriction Code",
                                                                             SDSProduct."Product Use",
                                                                             LText001,1, true);
                                                end else begin
                                                    RegulatoryHoldBuffer.Reset();
                                                end;
                                                until TempLicTypes4ProductUse.Next = 0;
                                            end;
                                            // 12 <<
                                        end;
                                        // 11b >>
                                    end;
                                    // 7 <<
                                    until TempCASRestriction.Next = 0;
                                    // 6 >>
                                end else begin
                                    // 5 --
                                    // then check for Product Use CAS Licenses that do not require customer CAS on the licence
                                    LicenseFound := false;
                                    if TempLicTypes4ProductUse.Find('-') then repeat
                                        UnExpiredLicense := false;
                                        TempCustLicense.Reset();
                                        TempCustLicense.SetFilter("Business Type Code", '%1|%2', '', SalesLine."ARC Business Type Code");
                                        TempCustLicense.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                        if TempCustLicense.Find('-') then begin
                                            repeat
                                            UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                     TempCustLicense."Ship-to Code",
                                                                                     TempCustLicense."Country/Region Code",
                                                                                     TempCustLicense.County,
                                                                                     TempCustLicense."Locality Code",
                                                                                     TempCustLicense."Business Type Code",
                                                                                     TempCustLicense."License Type Code",
                                                                                     TempCustLicense."License No.",
                                                                                     SalesHeader."order Date");
                                            until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                            LicenseFound := UnExpiredLicense;
                                        end;
                                        until(TempLicTypes4ProductUse.Next = 0) or LicenseFound;

                                    if TempLicTypes4ProductUse.Find('-') and(not LicenseFound) then begin
                                        RequirementFound := true;
                                        repeat
                                        UnExpiredLicense := false;
                                        TempCustLicense.Reset();
                                        TempCustLicense.SetFilter("Business Type Code", '%1|%2', '', SalesLine."ARC Business Type Code");
                                        TempCustLicense.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                        if TempCustLicense.Find('-') then repeat
                                          UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                   TempCustLicense."Ship-to Code",
                                                                                   TempCustLicense."Country/Region Code",
                                                                                   TempCustLicense.County,
                                                                                   TempCustLicense."Locality Code",
                                                                                   TempCustLicense."Business Type Code",
                                                                                   TempCustLicense."License Type Code",
                                                                                   TempCustLicense."License No.",
                                                                                   SalesHeader."order Date");
                                            if not UnExpiredLicense then begin
                                                CreateRestrictedHoldBuffer(SalesLine."Document Type",
                                                                         SalesLine."Document No.",
                                                                         SalesLine."Line No.",
                                                                         SalesLine."No.",'',
                                                                         TempSDSProductCAS."SDS Product Code",
                                                                         SalesHeader."Sell-to Customer No.",
                                                                         SalesHeader."Ship-to Code",
                                                                         TempCustLicense."License Type Code",
                                                                         SalesLine."ARC Business Type Code",'',
                                                                         SDSProduct."Product Use",
                                                                         StrSubstNo(LText002, TempCustLicense."License Type Code",
                                                                                    TempCustLicense."License No.",
                                                                                    TempCustLicense."Expiration Date"),1, false);
                                            end else begin
                                                RegulatoryHoldBuffer.Reset();
                                            end;
                                            until(TempCustLicense.Next = 0) or UnExpiredLicense;
                                        if not UnExpiredLicense then begin
                                            CreateRestrictedHoldBuffer(SalesLine."Document Type",
                                                                     SalesLine."Document No.",
                                                                     SalesLine."Line No.",
                                                                     SalesLine."No.",'',
                                                                     TempSDSProductCAS."SDS Product Code",
                                                                     SalesHeader."Sell-to Customer No.",
                                                                     SalesHeader."Ship-to Code",
                                                                     TempLicTypes4ProductUse.Code,
                                                                     SalesLine."ARC Business Type Code",'',
                                                                     SDSProduct."Product Use",
                                                                     LText001,1, false);
                                        end else begin
                                            RegulatoryHoldBuffer.Reset();
                                        end;
                                        until TempLicTypes4ProductUse.Next = 0;
                                    end;
                                end;
                                // 5 <<
                                until TempSDSProductCAS.Next = 0;
                            // 4a <<
                            // Did not find any needed license for the restricted CAS's, so now check the non-restricted CAS Product Use requirements
                            // 4b >>
                            if not RequirementFound then begin
                                TempSDSProductCAS.SetRange(Restricted, false);
                                if TempSDSProductCAS.Find('-') then repeat
                                LicenseFound := false;
                                    if TempLicTypes4ProductUse.FindSet() then repeat
                                  UnExpiredLicense := false;
                                        TempCustLicense.Reset();
                                        TempCustLicense.SetFilter("Business Type Code", '%1|%2', '', SalesLine."ARC Business Type Code");
                                        TempCustLicense.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                        if TempCustLicense.Find('-') then begin
                                            repeat
                                            UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                     TempCustLicense."Ship-to Code",
                                                                                     TempCustLicense."Country/Region Code",
                                                                                     TempCustLicense.County,
                                                                                     TempCustLicense."Locality Code",
                                                                                     TempCustLicense."Business Type Code",
                                                                                     TempCustLicense."License Type Code",
                                                                                     TempCustLicense."License No.",
                                                                                     SalesHeader."order Date");
                                            until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                            LicenseFound := UnExpiredLicense;
                                        end;
                                        until(TempLicTypes4ProductUse.Next = 0) or LicenseFound;

                                    if TempLicTypes4ProductUse.Find('-') and(not LicenseFound) then begin
                                        repeat
                                        // Find needed customer licenses
                                        UnExpiredLicense := false;
                                        TempCustLicense.Reset();
                                        TempCustLicense.SetFilter("Business Type Code", '%1|%2', '', SalesLine."ARC Business Type Code");
                                        TempCustLicense.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                        if TempCustLicense.Find('-') then begin
                                            repeat
                                            UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                     TempCustLicense."Ship-to Code",
                                                                                     TempCustLicense."Country/Region Code",
                                                                                     TempCustLicense.County,
                                                                                     TempCustLicense."Locality Code",
                                                                                     TempCustLicense."Business Type Code",
                                                                                     TempCustLicense."License Type Code",
                                                                                     TempCustLicense."License No.",
                                                                                     SalesHeader."order Date");
                                            if not UnExpiredLicense then begin
                                                RegulatoryHoldBuffer.Reset();
                                                RegulatoryHoldBuffer.SetRange("Document Type", SalesLine."Document Type");
                                                RegulatoryHoldBuffer.SetRange("Document No.", SalesLine."Document No.");
                                                RegulatoryHoldBuffer.SetRange("Doc. Line No.", SalesLine."Line No.");
                                                RegulatoryHoldBuffer.SetRange("Item No.", SalesLine."No.");
                                                RegulatoryHoldBuffer.SetRange("License Type Code", TempCustLicense."License Type Code");
                                                RegulatoryHoldBuffer.SetRange("Business Type Code", TempCustLicense."Business Type Code");
                                                if not RegulatoryHoldBuffer.FindFirst() then begin
                                                    CreateRestrictedHoldBuffer(SalesLine."Document Type",
                                                                             SalesLine."Document No.",
                                                                             SalesLine."Line No.",
                                                                             SalesLine."No.",'',
                                                                             Item."ARC SDS Product Code",
                                                                             SalesHeader."Sell-to Customer No.",
                                                                             SalesHeader."Ship-to Code",
                                                                             TempCustLicense."License Type Code",
                                                                             SalesLine."ARC Business Type Code",'',
                                                                             SDSProduct."Product Use",
                                                                             StrSubstNo(LText002, TempCustLicense."License Type Code",
                                                                                        TempCustLicense."License No.",
                                                                                        TempCustLicense."Expiration Date"),1, false);
                                                end;
                                            end else begin
                                                RegulatoryHoldBuffer.Reset();
                                            end;
                                            until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                        end;
                                        if not UnExpiredLicense then begin
                                            RegulatoryHoldBuffer.Reset();
                                            RegulatoryHoldBuffer.SetRange("Document Type", SalesLine."Document Type");
                                            RegulatoryHoldBuffer.SetRange("Document No.", SalesLine."Document No.");
                                            RegulatoryHoldBuffer.SetRange("Doc. Line No.", SalesLine."Line No.");
                                            RegulatoryHoldBuffer.SetRange("Item No.", SalesLine."No.");
                                            RegulatoryHoldBuffer.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                            RegulatoryHoldBuffer.SetRange("Business Type Code", SalesLine."ARC Business Type Code");
                                            if not RegulatoryHoldBuffer.FindFirst() then begin
                                                CreateRestrictedHoldBuffer(SalesLine."Document Type",
                                                                         SalesLine."Document No.",
                                                                         SalesLine."Line No.",
                                                                         SalesLine."No.",'',
                                                                         Item."ARC SDS Product Code",
                                                                         SalesHeader."Sell-to Customer No.",
                                                                         SalesHeader."Ship-to Code",
                                                                         TempLicTypes4ProductUse.Code,
                                                                         SalesLine."ARC Business Type Code",'',
                                                                         SDSProduct."Product Use",
                                                                         LText004,1, false);
                                            end;
                                        end;
                                        until TempLicTypes4ProductUse.Next = 0;
                                    end;
                                    until TempSDSProductCAS.Next = 0;
                            end;
                            // 4b <<
                        end else begin
                            // 3 --
                            // Only run this if Product does not have any Restricted CAS
                            TempSDSProductCAS.SetRange(Restricted, false);
                            if TempSDSProductCAS.Find('-') then repeat
                          // Found some non-restrictive CAS for the product that does not have any restricted CAS
                          // Check each CAS for Product Use Lic requirements
                          // if a License is found for the CAS then go to next, if not then create an override for each License needed
                          LicenseFound := false;
                                if TempLicTypes4ProductUse.Find('-') then repeat
                                    UnExpiredLicense := false;
                                    TempCustLicense.Reset();
                                    TempCustLicense.SetFilter("Business Type Code", '%1|%2', '', SalesLine."ARC Business Type Code");
                                    TempCustLicense.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                    if TempCustLicense.Find('-') then begin
                                        repeat
                                        UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                 TempCustLicense."Ship-to Code",
                                                                                 TempCustLicense."Country/Region Code",
                                                                                 TempCustLicense.County,
                                                                                 TempCustLicense."Locality Code",
                                                                                 TempCustLicense."Business Type Code",
                                                                                 TempCustLicense."License Type Code",
                                                                                 TempCustLicense."License No.",
                                                                                 SalesHeader."order Date");
                                        until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                        LicenseFound := UnExpiredLicense;
                                    end;
                                    until(TempLicTypes4ProductUse.Next = 0) or LicenseFound;

                                if TempLicTypes4ProductUse.Find('-') and(not LicenseFound) then begin
                                    repeat
                                    // Did not find a Customer Lice for this CAS
                                    // Create Override records
                                    UnExpiredLicense := false;
                                    TempCustLicense.Reset();
                                    TempCustLicense.SetFilter("Business Type Code", '%1|%2', '', SalesLine."ARC Business Type Code");
                                    TempCustLicense.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                    if TempCustLicense.Find('-') then begin
                                        repeat
                                        UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                 TempCustLicense."Ship-to Code",
                                                                                 TempCustLicense."Country/Region Code",
                                                                                 TempCustLicense.County,
                                                                                 TempCustLicense."Locality Code",
                                                                                 TempCustLicense."Business Type Code",
                                                                                 TempCustLicense."License Type Code",
                                                                                 TempCustLicense."License No.",
                                                                                 SalesHeader."order Date");
                                        if not UnExpiredLicense then begin
                                            RegulatoryHoldBuffer.Reset();
                                            RegulatoryHoldBuffer.SetRange("Document Type", SalesLine."Document Type");
                                            RegulatoryHoldBuffer.SetRange("Document No.", SalesLine."Document No.");
                                            RegulatoryHoldBuffer.SetRange("Doc. Line No.", SalesLine."Line No.");
                                            RegulatoryHoldBuffer.SetRange("Item No.", SalesLine."No.");
                                            RegulatoryHoldBuffer.SetRange("License Type Code", TempCustLicense."License Type Code");
                                            RegulatoryHoldBuffer.SetRange("Business Type Code", TempCustLicense."Business Type Code");
                                            if not RegulatoryHoldBuffer.FindFirst() then begin
                                                CreateRestrictedHoldBuffer(SalesLine."Document Type",
                                                                         SalesLine."Document No.",
                                                                         SalesLine."Line No.",
                                                                         SalesLine."No.",'',
                                                                         Item."ARC SDS Product Code",
                                                                         SalesHeader."Sell-to Customer No.",
                                                                         SalesHeader."Ship-to Code",
                                                                         TempCustLicense."License Type Code",
                                                                         SalesLine."ARC Business Type Code",'',
                                                                         SDSProduct."Product Use",
                                                                         StrSubstNo(LText002, TempCustLicense."License Type Code",
                                                                                    TempCustLicense."License No.",
                                                                                    TempCustLicense."Expiration Date"),1, false);
                                            end;
                                        end else begin
                                            RegulatoryHoldBuffer.Reset();
                                        end;
                                        until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                    end;
                                    if not UnExpiredLicense then begin
                                        RegulatoryHoldBuffer.Reset();
                                        RegulatoryHoldBuffer.SetRange("Document Type", SalesLine."Document Type");
                                        RegulatoryHoldBuffer.SetRange("Document No.", SalesLine."Document No.");
                                        RegulatoryHoldBuffer.SetRange("Doc. Line No.", SalesLine."Line No.");
                                        RegulatoryHoldBuffer.SetRange("Item No.", SalesLine."No.");
                                        RegulatoryHoldBuffer.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                        RegulatoryHoldBuffer.SetRange("Business Type Code", SalesLine."ARC Business Type Code");
                                        if not RegulatoryHoldBuffer.FindFirst() then begin
                                            CreateRestrictedHoldBuffer(SalesLine."Document Type",
                                                                     SalesLine."Document No.",
                                                                     SalesLine."Line No.",
                                                                     SalesLine."No.",'',
                                                                     Item."ARC SDS Product Code",
                                                                     SalesHeader."Sell-to Customer No.",
                                                                     SalesHeader."Ship-to Code",
                                                                     TempLicTypes4ProductUse.Code,
                                                                     SalesLine."ARC Business Type Code",'',
                                                                     SDSProduct."Product Use",
                                                                     LText004,1, false);
                                        end;
                                    end;
                                    until TempLicTypes4ProductUse.Next = 0;
                                end;
                                until TempSDSProductCAS.Next = 0;
                        end;
                        // 3 <<
                    end else
                        Error(StrSubstNo(LText005, Item."No.", Item.Description, SalesLine."ARC Business Type Code"));
                    // 2b <<
                end;
                // 2a <<
            end;
            // 2 <<
            until SalesLine.Next = 0;
        // 1 <<

        RegulatoryHoldBuffer.Reset();
        if RegulatoryHoldBuffer.FindSet() then begin
            RegulatoryHoldBuffer2.DeleteAll();
            LineNo := 0;
            repeat
                RegulatoryHoldBuffer2.SetRange("License Type Code", RegulatoryHoldBuffer."License Type Code");
                RegulatoryHoldBuffer2.SetRange("Business Type Code", RegulatoryHoldBuffer."Business Type Code");
                RegulatoryHoldBuffer2.SetRange("Product Type Restriction Code", RegulatoryHoldBuffer."Product Type Restriction Code");
                RegulatoryHoldBuffer2.SetRange("Product Use", RegulatoryHoldBuffer2."Product Use");
                if not RegulatoryHoldBuffer2.FindFirst() then begin
                    RegulatoryHoldBuffer2.Reset();
                    RegulatoryHoldBuffer2.Init();
                    RegulatoryHoldBuffer2."Document Type" := RegulatoryHoldBuffer."Document Type";
                    RegulatoryHoldBuffer2."Document No." := RegulatoryHoldBuffer."Document No.";
                    RegulatoryHoldBuffer2."Line No." := 1;
                    RegulatoryHoldBuffer2."License Type Code" := RegulatoryHoldBuffer."License Type Code";
                    RegulatoryHoldBuffer2."Business Type Code" := RegulatoryHoldBuffer."Business Type Code";
                    RegulatoryHoldBuffer2."Product Type Restriction Code" := RegulatoryHoldBuffer."Product Type Restriction Code";
                    RegulatoryHoldBuffer2."Product Use" := RegulatoryHoldBuffer2."Product Use";
                    RegulatoryHoldBuffer2."Customer No." := RegulatoryHoldBuffer."Customer No.";
                    RegulatoryHoldBuffer2."Ship-to Code" := RegulatoryHoldBuffer."Ship-to Code";
                    RegulatoryHoldBuffer2.Indentation := 0;
                    RegulatoryHoldBuffer2.Comment := RegulatoryHoldBuffer.Comment;
                    RegulatoryHoldBuffer2.Restricted := RegulatoryHoldBuffer2.Restricted;
                    RegulatoryHoldBuffer2.Insert();
                end;   
            until RegulatoryHoldBuffer.Next = 0;
       
        RegulatoryHoldBuffer.Reset();
        RegulatoryHoldBuffer2.Reset();
        if RegulatoryHoldBuffer2.FindSet() then 
            repeat
                RegulatoryHoldBuffer.Init();
                RegulatoryHoldBuffer := RegulatoryHoldBuffer2;
                RegulatoryHoldBuffer.Insert();
            until RegulatoryHoldBuffer2.Next = 0;

        RegulatoryHoldBuffer.Reset();
        if RegulatoryHoldBuffer.FindFirst() then begin
            SalesHeader."ARC Regulatory Hold" := true;
            SalesHeader.Modify();
            Commit();

            if ShowHolds then begin 
                RegulatoryHoldBuffer.Reset();
                Clear(RegulatoryHoldEntries);
                RegulatoryHoldEntries.LoadRegHoldBufToTempDetail(RegulatoryHoldBuffer);
                RegulatoryHoldEntries.RunModal;
            end;
        end;
    end else begin  
        if not ShowHolds then begin
            SalesHeader."ARC Regulatory Hold" := false;
            SalesHeader.Status := SalesHeader.Status::Open;
            SalesHeader.Modify();
            Commit();
        end;
    end;
        exit(true);


    end;

    procedure CreateRestrictedHoldBuffer(DocType: Integer; DocNo: Code[20]; DocLineNo: Integer; ItemNo: Code[20]; CASCode: Code[30]; SDSCode: Code[20]; CustNo: Code[20]; ShipTo: Code[10]; LicType: Code[20]; BusType: Code[10]; ProdTypeRestriction: Code[20]; ProdUse: Integer; CommentLine: Text[100]; InDent: Integer; Restricted: Boolean);
    begin
        RegulatoryHoldBuffer.Reset();
        RegulatoryHoldBuffer.Init();
        RegulatoryHoldBuffer."License Type Code" := LicType;
        RegulatoryHoldBuffer."Business Type Code" := BusType;
        RegulatoryHoldBuffer."Product Type Restriction Code" := ProdTypeRestriction;
        RegulatoryHoldBuffer."Product Use" := ProdUse;
        RegulatoryHoldBuffer."Doc. Line No." := DocLineNo;
        RegulatoryHoldBuffer."Line No." := LineNo;
        RegulatoryHoldBuffer."Document Type" := DocType;
        RegulatoryHoldBuffer."Document No." := DocNo;
        RegulatoryHoldBuffer."Item No." := ItemNo;
        RegulatoryHoldBuffer."CAS Code" := CASCode;
        RegulatoryHoldBuffer."SDS Product Code" := SDSCode;
        RegulatoryHoldBuffer."Customer No." := CustNo;
        RegulatoryHoldBuffer."Ship-to Code" := ShipTo;
        RegulatoryHoldBuffer.Comment := CommentLine;
        RegulatoryHoldBuffer.Indentation := InDent;
        RegulatoryHoldBuffer.Restricted := Restricted;
        RegulatoryHoldBuffer.Insert();
        LineNo += 100;
    end;

    procedure IsBusTypeLicType(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var SDSProduct: Record "ARC SDS Product") RecordFound: Boolean;
    var
        TempLicTypes4ProductUse: Record "ARC License Type" temporary;
        RestrictedRecordFound: Boolean;
        TempSDSProductCAS: Record "ARC SDS Product CAS" temporary;
        TempCASRestriction: Record "ARC CAS Restriction" temporary;
        TempLicTypes4RestrictedProd: Record "ARC License Type" temporary;
    begin
        RecordFound := true;

        GetProductUseLicenseTypes(TempLicTypes4ProductUse,
                                  SDSProduct."Product Use",
                                  SalesHeader."Ship-to Country/Region Code",
                                  SalesHeader."Ship-to County",
                                  SalesHeader."Ship-to Post Code",
                                  SalesHeader."ARC Locality Code",
                                  SalesLine."ARC Business Type Code");

        RecordFound := TempLicTypes4ProductUse.FindFirst();

        if RecordFound then begin
            GetSDSCAS(TempSDSProductCAS, SDSProduct.Code);
            TempSDSProductCAS.SetRange(Restricted, true);
            if not TempSDSProductCAS.IsEmpty() then begin
                if TempSDSProductCAS.Find('-') then repeat
                GetCASRestriction(TempCASRestriction,
                                  TempSDSProductCAS."CAS Code",
                                  SalesHeader."Ship-to Country/Region Code",
                                  SalesHeader."Ship-to County",
                                  SalesHeader."ARC Locality Code");
                    RestrictedRecordFound := true;
                    if TempCASRestriction.Find('-') then repeat
                  GetRestrictedProdLicTypes(TempLicTypes4RestrictedProd,
                                            SalesLine."ARC Business Type Code",
                                            SalesHeader."Ship-to Country/Region Code",
                                            SalesHeader."Ship-to County",
                                            SalesHeader."Ship-to Post Code",
                                            SalesHeader."ARC Locality Code",
                                            TempCASRestriction."Product Type Restriction Code");
                        RestrictedRecordFound := not TempLicTypes4RestrictedProd.IsEmpty();
                        until(TempCASRestriction.Next = 0) or(not RestrictedRecordFound);
                    RecordFound := RestrictedRecordFound;
                    until TempSDSProductCAS.Next = 0;
            end;
        end;


    end;

    procedure DeleteRestrictedHoldBuffer(DocType: Integer; DocNo: Code[20]; DocLineNo: Integer);
    begin
        RegulatoryHoldBuffer.Reset();
        RegulatoryHoldBuffer.SetRange("Document Type", DocType);
        RegulatoryHoldBuffer.SetRange("Document No.", DocNo);
        RegulatoryHoldBuffer.SetRange("Doc. Line No.", DocLineNo);
        RegulatoryHoldBuffer.DeleteAll();
        RegulatoryHoldBuffer.Reset();
    end;

    procedure TestSDS(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line");
    var
        LText001: Label 'Item %1 is not registered in %2';
        LText002: Label 'Item %1 is not allowed to be shipped by %2';
        SDSProductCAS: Record "ARC SDS Product CAS";
        LText003: Label 'Item %1 is not allowed to be shipped to %3 from %2';
        LText004: Label 'Locality code must have a value, please select Alternate Ship To.';
        LText005: Label 'Business Type code must have a value, please select Alternate Ship To.';
        Item: Record Item;
        SDSProduct: Record "ARC SDS Product";
        Location: Record Location;
    begin
        Item.Get(SalesLine."No.");
        if Item."ARC SDS Product Code" = '' then
            exit;

        if (SalesHeader."ARC Locality Code" = '') then
            Error(LText004);

        if (SalesHeader."ARC Business Type Code" = '') then
            Error(LText005);        

        SDSProduct.Get(Item."ARC SDS Product Code");

        Location.Get(SalesLine."Location Code");
        if IsSDSRegionBlocked(Item."ARC SDS Product Code",
                              SalesHeader."Ship-to Country/Region Code",
                              SalesHeader."Ship-to County",
                              SalesHeader."Ship-to Post Code",
                              SalesHeader."ARC Locality Code") then
            Error(StrSubstNo(LText001, SalesLine."No.", SalesHeader."Ship-to County" + ' ' + SalesHeader."Ship-to Country/Region Code"));

        if IsSDSShipFromBlocked(Item."ARC SDS Product Code",
                                SalesLine."Location Code",
                                SalesHeader."Ship-to Country/Region Code",
                                SalesHeader."Ship-to County",
                                SDSProduct."Product Use", '',
                                SalesHeader."ARC Locality Code") then
            Error(StrSubstNo(LText003, SalesLine."No.", Location.County + ' ' + Location."Country/Region Code",
                           SalesHeader."Ship-to County" + ' ' + SalesHeader."Ship-to Country/Region Code"));

        if not IsAerosolShipAllowed(SDSProduct."Matter State", SalesHeader."Shipping Agent Code",
                                    SalesHeader."E-Ship Agent Service",
                                    SalesHeader."World Wide Service") then
            Error(StrSubstNo(LText002, SalesLine."No.", SalesHeader."Shipping Agent Code" + ' ' + SalesHeader."E-Ship Agent Service"));

        SDSProductCAS.SetRange("SDS Product Code", SDSProduct.Code);
        if SDSProductCAS.FindSet(false, false) then repeat
          if IsSDSShipFromBlocked(Item."ARC SDS Product Code",
                                  SalesLine."Location Code",
                                  SalesHeader."Ship-to Country/Region Code",
                                  SalesHeader."Ship-to County",
                                  SDSProduct."Product Use",
                                  SDSProductCAS."CAS Code",
                                  SalesHeader."ARC Locality Code") then
                Error(StrSubstNo(LText003, SalesLine."No.", Location.County + ' ' + Location."Country/Region Code",
                             SalesHeader."Ship-to County" + ' ' + SalesHeader."Ship-to Country/Region Code"));
            until SDSProductCAS.Next = 0;

    end;

    procedure DeleteOverrides(var SalesHeader: Record "Sales Header");
    var
    //SalesLineOverride : Record "Sales Line Override";
    begin
        //SalesLineOverride.SetRange("Document Type",SalesHeader."Document Type");
        //SalesLineOverride.SetRange("Document No.",SalesHeader."No.");
        //SalesLineOverride.DELETEALL(true);
    end;

    procedure PortalTest(
        TestNo: Integer; 
        CustNo: Code[20]; 
        ShipToCode: Code[10]; 
        ShipToCountry: Code[10]; 
        ShipToCounty: Text[30]; 
        ShipToPostCode: Code[20]; 
        LocalityCode: Code[20]; 
        BusTypeCode: Code[10]; 
        ItemNo: Code[20]; 
        UOM: Code[10]; 
        LocationCode: Code[10]; 
        ReqQty: Decimal): Text[1000];
    var
        Item: Record Item;
        TempSDSProductCAS: Record "ARC SDS Product CAS" temporary;
        LText001: Label 'Item %1 is not registered in %2';
        LText002: Label 'Item %1 is not allowed to be shipped by %2';
        LText003: Label 'Item %1 is not allowed to be shipped to %3 from %2';
        LText004: Label 'Restricted Item %1 requires a restricted license.Contact local Target branch to process.';
        SDSProduct: Record "ARC SDS Product";
        TempLicTypes4ProductUse: Record "ARC License Type" temporary;
        Cust: Record Customer;
        Location: Record Location;
        LText005: Label 'Quantity requested not available at %1';
        LText006: Label 'Only partial Quantity requested is available at %1';
        QtyAvailable: Decimal;
        IUOM: Record "Item Unit of Measure";
        LText007: Label 'Restricted Item %1 %2 requires a restricted license to be submitted. Contact local Target branch to process.';
        TempCustLicense: Record "ARC Customer License" temporary;
        UnExpiredLicense: Boolean;
        TempCustLicenseCAS: Record "ARC Customer License CAS Code" temporary;
        TempLicType: Record "ARC License Type" temporary;
        ProductTypeRestriction: Record "ARC Product Type Restriction";
        TempCASRestriction: Record "ARC CAS Restriction" temporary;
        LicenseFound: Boolean;
        TempRestrictedProdLicType: Record "ARC Restricted Prod. Lic. Type" temporary;
        TempProductUseLicType: Record "ARC Product Use License Type" temporary;
        TempLicTypes4RestrictedProd: Record "ARC License Type" temporary;
        RequirementFound: Boolean;
        LText008: Label 'Quantity %1 not available at %2';
        LText009: Label 'Only Quantity %1 available at %2';
        LText010: Label 'Quantity requested not available at primary location. Consider a substitute or contact Target to check other locations.';
        LText011: Label 'NO LICENSE ON FILE and/or RESTRICTED ITEM ON orDER.  PLEASE CONTACT YOUR LOCAL TARGET SERVICE CENTER TO PROVIDE YOUR APPLICATor''S LICENSE TO PROCESS.';
    begin
        case TestNo of
        1 :
        begin
            Cust.Get(CustNo);
            //Location.Get(Cust."Location Code");
            If not Location.Get(LocationCode) then
                Location.Get(Cust."Location Code");

            GetCustomerLicenses(TempCustLicense, CustNo, ShipToCode, ShipToCountry, ShipToCounty, ShipToPostCode, LocalityCode);
            if Item.Get(ItemNo) then begin
                if Item."ARC SDS Product Code" = '' then
                    exit('OK');
                if SDSProduct.Get(Item."ARC SDS Product Code") then begin
                    if IsSDSRegionBlocked(Item."ARC SDS Product Code",
                                        ShipToCountry,
                                        ShipToCounty,
                                        ShipToPostCode,
                                        LocalityCode) then
                        exit(StrSubstNo(LText001, ItemNo, ShipToCounty + ' ' + ShipToCountry));

                    if IsSDSShipFromBlocked(Item."ARC SDS Product Code",
                                          Cust."Location Code",
                                          ShipToCountry,
                                          ShipToCounty,
                                          SDSProduct."Product Use", '',
                                          LocalityCode) then
                        exit(StrSubstNo(LText003, ItemNo, Location.County + ' ' + Location."Country/Region Code",
                                    ShipToCounty + ' ' + ShipToCountry));

                    TempLicTypes4ProductUse.Reset();
                    TempLicTypes4ProductUse.DeleteAll();
                    TempSDSProductCAS.Reset();
                    TempSDSProductCAS.DeleteAll();
                    TempCustLicenseCAS.Reset();
                    TempCustLicenseCAS.DeleteAll();
                    TempCASRestriction.Reset();
                    TempCASRestriction.DeleteAll();
                    TempLicTypes4RestrictedProd.Reset();
                    TempLicTypes4RestrictedProd.DeleteAll();
                    SDSProduct.CalcFields("License Types");
                    // 2a >>
                    if not((SDSProduct."License Types" = 0) or(SDSProduct."Product Use" = SDSProduct."Product Use"::" ")) then begin
                        // 2b >>
                        GetProductUseLicenseTypes(TempLicTypes4ProductUse,
                                                SDSProduct."Product Use",
                                                ShipToCountry,
                                                ShipToCounty,
                                                ShipToPostCode,
                                                LocalityCode,
                                                BusTypeCode);

                        GetSDSCAS(TempSDSProductCAS, Item."ARC SDS Product Code");
                        // Restricted CAS
                        TempSDSProductCAS.SetRange(Restricted, true);

                        // 3 >>
                        if not TempSDSProductCAS.IsEmpty() then begin
                            // 4a >>
                            if TempSDSProductCAS.Find('-') then repeat
                                LicenseFound := false;
                                RequirementFound := false;
                                if ShipToCode in ['', ' '] then
                                    exit('01: ' + LText011);
                                GetCASCustLicense(TempCustLicenseCAS,
                                              CustNo,
                                              ShipToCode,
                                              ShipToCountry,
                                              ShipToCounty,
                                              LocalityCode,
                                              BusTypeCode,
                                              TempSDSProductCAS."CAS Code");

                                GetCASRestriction(TempCASRestriction,
                                              TempSDSProductCAS."CAS Code",
                                              ShipToCountry,
                                              ShipToCounty,
                                              LocalityCode);

                                // 5 >>
                                if TempCASRestriction.Find('-') then begin
                                    repeat
                                    // 6 >>
                                    // Get Lic Types from Restricted Product Lic. Types for the CAS Restriction Product Type Restriction Code
                                    GetRestrictedProdLicTypes(TempLicTypes4RestrictedProd,
                                                              BusTypeCode,
                                                              ShipToCountry,
                                                              ShipToCounty,
                                                              ShipToPostCode,
                                                              LocalityCode,
                                                              TempCASRestriction."Product Type Restriction Code");
                                    // if CAS Level Restriction, if yes then look at cust lic. cas records
                                    // 7 >>
                                    if IsCustCASLevelRestricted(TempCASRestriction."Product Type Restriction Code") then begin
                                        // 8 >>
                                        // Find Customer License with CAS allowed
                                        LicenseFound := false;
                                        if TempLicTypes4RestrictedProd.Find('-') then repeat
                                        RequirementFound := true;
                                            UnExpiredLicense := false;
                                            TempCustLicenseCAS.Reset();
                                            TempCustLicenseCAS.SetRange("License Type Code", TempLicTypes4RestrictedProd.Code);
                                            if TempCustLicenseCAS.Find('-') then begin
                                                repeat
                                                UnExpiredLicense := not IsLicenseExpired(TempCustLicenseCAS."Customer No.",
                                                                                         TempCustLicenseCAS."Ship-to Code",
                                                                                         TempCustLicenseCAS."Country/Region Code",
                                                                                         TempCustLicenseCAS.County,
                                                                                         TempCustLicenseCAS."Locality Code",
                                                                                         TempCustLicenseCAS."Business Type Code",
                                                                                         TempCustLicenseCAS."License Type Code",
                                                                                         TempCustLicenseCAS."License No.",
                                                                                         WorKDATE);
                                                until(TempCustLicenseCAS.Next = 0) or(UnExpiredLicense);
                                                LicenseFound := UnExpiredLicense;
                                            end;
                                            until(TempLicTypes4RestrictedProd.Next = 0) or LicenseFound;
                                        if TempLicTypes4RestrictedProd.Find('-') and(not LicenseFound) then begin
                                            RequirementFound := true;
                                            // 9 >>
                                            repeat
                                            UnExpiredLicense := false;
                                            TempCustLicenseCAS.Reset();
                                            TempCustLicenseCAS.SetRange("License Type Code", TempLicTypes4RestrictedProd.Code);
                                            // 10 >>
                                            if TempCustLicenseCAS.Find('-') then repeat
                                              UnExpiredLicense := not IsLicenseExpired(TempCustLicenseCAS."Customer No.",
                                                                                       TempCustLicenseCAS."Ship-to Code",
                                                                                       TempCustLicenseCAS."Country/Region Code",
                                                                                       TempCustLicenseCAS.County,
                                                                                       TempCustLicenseCAS."Locality Code",
                                                                                       TempCustLicenseCAS."Business Type Code",
                                                                                       TempCustLicenseCAS."License Type Code",
                                                                                       TempCustLicenseCAS."License No.",
                                                                                       WorKDATE);
                                                if not UnExpiredLicense then begin
                                                    //EXIT(STRSUBSTNO(LText007,Item."No.",Item.Description));
                                                    exit('02: ' + LText011);
                                                end;
                                                until(TempCustLicenseCAS.Next = 0) or(UnExpiredLicense);
                                            // 10 <<
                                            if not UnExpiredLicense then begin
                                                //EXIT(STRSUBSTNO(LText007,Item."No.",Item.Description));
                                                exit('03: ' + LText011);
                                            end;
                                            until(TempLicTypes4RestrictedProd.Next = 0) or(UnExpiredLicense);
                                            // 9 <<
                                        end;
                                        // 8 <<
                                    end else begin
                                        // 7 --
                                        // not a CAS Level Restricted Product Type so only look for Customer License for the Restricted Product
                                        // 11a >>
                                        LicenseFound := false;
                                        if TempLicTypes4RestrictedProd.Find('-') then repeat
                                        RequirementFound := true;
                                            UnExpiredLicense := false;
                                            TempCustLicense.Reset();
                                            TempCustLicense.SetRange("License Type Code", TempLicTypes4RestrictedProd.Code);
                                            if TempCustLicense.Find('-') then begin
                                                repeat
                                                UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                         TempCustLicense."Ship-to Code",
                                                                                         TempCustLicense."Country/Region Code",
                                                                                         TempCustLicense.County,
                                                                                         TempCustLicense."Locality Code",
                                                                                         TempCustLicense."Business Type Code",
                                                                                         TempCustLicense."License Type Code",
                                                                                         TempCustLicense."License No.",
                                                                                         WorKDATE);
                                                until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                                LicenseFound := UnExpiredLicense;
                                            end;
                                            until(TempLicTypes4RestrictedProd.Next = 0) or LicenseFound;
                                        if TempLicTypes4RestrictedProd.Find('-') and(not LicenseFound) then begin
                                            RequirementFound := true;
                                            repeat
                                            UnExpiredLicense := false;
                                            TempCustLicense.Reset();
                                            TempCustLicense.SetRange("License Type Code", TempLicTypes4RestrictedProd.Code);
                                            if TempCustLicense.Find('-') then repeat
                                              UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                       TempCustLicense."Ship-to Code",
                                                                                       TempCustLicense."Country/Region Code",
                                                                                       TempCustLicense.County,
                                                                                       TempCustLicense."Locality Code",
                                                                                       TempCustLicense."Business Type Code",
                                                                                       TempCustLicense."License Type Code",
                                                                                       TempCustLicense."License No.",
                                                                                       WorKDATE);
                                                if not UnExpiredLicense then begin
                                                    //EXIT(STRSUBSTNO(LText007,Item."No.",Item.Description));
                                                    exit('04: ' + LText011);
                                                end;
                                                until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                            if not UnExpiredLicense then begin
                                                //EXIT(STRSUBSTNO(LText007,Item."No.",Item.Description));
                                                exit('05: ' + LText011);
                                            end;
                                            until(TempLicTypes4RestrictedProd.Next = 0) or(UnExpiredLicense);
                                        end;
                                        // 11a <<
                                        // 11b >>
                                        if not RequirementFound then begin
                                            // 12 >>
                                            // then check for Product Use CAS Licenses that do not require customer CAS on the licence
                                            LicenseFound := false;
                                            if TempLicTypes4ProductUse.Find('-') then repeat
                                            UnExpiredLicense := false;
                                                TempCustLicense.Reset();
                                                TempCustLicense.SetFilter("Business Type Code", '%1|%2', '', BusTypeCode);
                                                TempCustLicense.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                                if TempCustLicense.Find('-') then begin
                                                    repeat
                                                    UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                             TempCustLicense."Ship-to Code",
                                                                                             TempCustLicense."Country/Region Code",
                                                                                             TempCustLicense.County,
                                                                                             TempCustLicense."Locality Code",
                                                                                             TempCustLicense."Business Type Code",
                                                                                             TempCustLicense."License Type Code",
                                                                                             TempCustLicense."License No.",
                                                                                             WorKDATE);
                                                    until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                                    LicenseFound := UnExpiredLicense;
                                                end;
                                                until(TempLicTypes4ProductUse.Next = 0) or LicenseFound;
                                            if TempLicTypes4ProductUse.Find('-') and(not LicenseFound) then begin
                                                RequirementFound := true;
                                                repeat
                                                UnExpiredLicense := false;
                                                TempCustLicense.Reset();
                                                TempCustLicense.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                                if TempCustLicense.Find('-') then repeat
                                                  UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                           TempCustLicense."Ship-to Code",
                                                                                           TempCustLicense."Country/Region Code",
                                                                                           TempCustLicense.County,
                                                                                           TempCustLicense."Locality Code",
                                                                                           TempCustLicense."Business Type Code",
                                                                                           TempCustLicense."License Type Code",
                                                                                           TempCustLicense."License No.",
                                                                                           WorKDATE);
                                                    if not UnExpiredLicense then begin
                                                        //EXIT(STRSUBSTNO(LText007,Item."No.",Item.Description));
                                                        exit('06: ' + LText011);
                                                    end;
                                                    until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                                if not UnExpiredLicense then begin
                                                    //EXIT(STRSUBSTNO(LText007,Item."No.",Item.Description));
                                                    exit('07: ' + LText011);
                                                end;
                                                until TempLicTypes4ProductUse.Next = 0;
                                            end;
                                            // 12 <<
                                        end;
                                        // 11b >>
                                    end;
                                    // 7 <<
                                    until TempCASRestriction.Next = 0;
                                    // 6 >>
                                end else begin
                                    // 5 --
                                    // then check for Product Use CAS Licenses that do not require customer CAS on the licence
                                    LicenseFound := false;
                                    if TempLicTypes4ProductUse.Find('-') then repeat
                                UnExpiredLicense := false;
                                        TempCustLicense.Reset();
                                        TempCustLicense.SetFilter("Business Type Code", '%1|%2', '', BusTypeCode);
                                        TempCustLicense.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                        if TempCustLicense.Find('-') then begin
                                            repeat
                                            UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                     TempCustLicense."Ship-to Code",
                                                                                     TempCustLicense."Country/Region Code",
                                                                                     TempCustLicense.County,
                                                                                     TempCustLicense."Locality Code",
                                                                                     TempCustLicense."Business Type Code",
                                                                                     TempCustLicense."License Type Code",
                                                                                     TempCustLicense."License No.",
                                                                                     WorKDATE);
                                            until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                            LicenseFound := UnExpiredLicense;
                                        end;
                                        until(TempLicTypes4ProductUse.Next = 0) or LicenseFound;
                                    if TempLicTypes4ProductUse.Find('-') and(not LicenseFound) then begin
                                        RequirementFound := true;
                                        repeat
                                        UnExpiredLicense := false;
                                        TempCustLicense.Reset();
                                        TempCustLicense.SetFilter("Business Type Code", '%1|%2', '', BusTypeCode);
                                        TempCustLicense.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                        if TempCustLicense.Find('-') then repeat
                                          UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                   TempCustLicense."Ship-to Code",
                                                                                   TempCustLicense."Country/Region Code",
                                                                                   TempCustLicense.County,
                                                                                   TempCustLicense."Locality Code",
                                                                                   TempCustLicense."Business Type Code",
                                                                                   TempCustLicense."License Type Code",
                                                                                   TempCustLicense."License No.",
                                                                                   WorKDATE);
                                            if not UnExpiredLicense then begin
                                                //EXIT(STRSUBSTNO(LText007,Item."No.",Item.Description));
                                                exit('08: ' + LText011);
                                            end;
                                            until(TempCustLicense.Next = 0) or UnExpiredLicense;
                                        if not UnExpiredLicense then begin
                                            //EXIT(STRSUBSTNO(LText007,Item."No.",Item.Description));
                                            exit('09: ' + LText011);
                                        end;
                                        until TempLicTypes4ProductUse.Next = 0;
                                    end;
                                end;
                                // 5 <<
                                until TempSDSProductCAS.Next = 0;
                            // 4a <<
                            // Did not find any needed license for the restricted CAS's,
                            // so now check the non-restricted CAS Product Use requirements
                            // 4b >>
                            if not RequirementFound then begin
                                TempSDSProductCAS.SetRange(Restricted, false);
                                if TempSDSProductCAS.Find('-') then repeat
                                LicenseFound := false;
                                    if TempLicTypes4ProductUse.FindSet() then repeat
                                  UnExpiredLicense := false;
                                        TempCustLicense.Reset();
                                        TempCustLicense.SetFilter("Business Type Code", '%1|%2', '', BusTypeCode);
                                        TempCustLicense.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                        if TempCustLicense.Find('-') then begin
                                            repeat
                                            UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                     TempCustLicense."Ship-to Code",
                                                                                     TempCustLicense."Country/Region Code",
                                                                                     TempCustLicense.County,
                                                                                     TempCustLicense."Locality Code",
                                                                                     TempCustLicense."Business Type Code",
                                                                                     TempCustLicense."License Type Code",
                                                                                     TempCustLicense."License No.",
                                                                                     WorKDATE);
                                            until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                            LicenseFound := UnExpiredLicense;
                                        end;
                                        until(TempLicTypes4ProductUse.Next = 0) or LicenseFound;
                                    if TempLicTypes4ProductUse.Find('-') and(not LicenseFound) then begin
                                        repeat
                                        // Find needed customer licenses
                                        UnExpiredLicense := false;
                                        TempCustLicense.Reset();
                                        TempCustLicense.SetFilter("Business Type Code", '%1|%2', '', BusTypeCode);
                                        TempCustLicense.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                        if TempCustLicense.Find('-') then begin
                                            repeat
                                            UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                     TempCustLicense."Ship-to Code",
                                                                                     TempCustLicense."Country/Region Code",
                                                                                     TempCustLicense.County,
                                                                                     TempCustLicense."Locality Code",
                                                                                     TempCustLicense."Business Type Code",
                                                                                     TempCustLicense."License Type Code",
                                                                                     TempCustLicense."License No.",
                                                                                     WorKDATE);
                                            if not UnExpiredLicense then begin
                                                //EXIT(STRSUBSTNO(LText007,Item."No.",Item.Description));
                                                exit('10: ' + LText011);
                                            end;
                                            until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                        end;
                                        if not UnExpiredLicense then begin
                                            //EXIT(STRSUBSTNO(LText007,Item."No.",Item.Description));
                                            exit('11: ' + LText011);
                                        end;
                                        until TempLicTypes4ProductUse.Next = 0;
                                    end;
                                    until TempSDSProductCAS.Next = 0;
                            end;
                            // 4b <<
                            exit('OK');
                        end else begin
                            // 3 --
                            // Only run this if Product does not have any Restricted CAS
                            TempSDSProductCAS.SetRange(Restricted, false);
                            if TempSDSProductCAS.Find('-') then repeat
                          // Found some non-restrictive CAS for the product that does not have any restricted CAS
                          // Check each CAS for Product Use Lic requirements
                          // if a License is found for the CAS then go to next, if not then create an override for each License needed
                          LicenseFound := false;
                                if TempLicTypes4ProductUse.Find('-') then repeat
                            UnExpiredLicense := false;
                                    TempCustLicense.Reset();
                                    TempCustLicense.SetFilter("Business Type Code", '%1|%2', '', BusTypeCode);
                                    TempCustLicense.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                    if TempCustLicense.Find('-') then begin
                                        repeat
                                        UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                 TempCustLicense."Ship-to Code",
                                                                                 TempCustLicense."Country/Region Code",
                                                                                 TempCustLicense.County,
                                                                                 TempCustLicense."Locality Code",
                                                                                 TempCustLicense."Business Type Code",
                                                                                 TempCustLicense."License Type Code",
                                                                                 TempCustLicense."License No.",
                                                                                 WorKDATE);
                                        until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                        LicenseFound := UnExpiredLicense;
                                    end;
                                    until(TempLicTypes4ProductUse.Next = 0) or LicenseFound;
                                if TempLicTypes4ProductUse.Find('-') and(not LicenseFound) then begin
                                    repeat
                                    // Did not find a Customer Lice for this CAS
                                    // Create Override records
                                    UnExpiredLicense := false;
                                    TempCustLicense.Reset();
                                    TempCustLicense.SetFilter("Business Type Code", '%1|%2', '', BusTypeCode);
                                    TempCustLicense.SetRange("License Type Code", TempLicTypes4ProductUse.Code);
                                    if TempCustLicense.Find('-') then begin
                                        repeat
                                        UnExpiredLicense := not IsLicenseExpired(TempCustLicense."Customer No.",
                                                                                 TempCustLicense."Ship-to Code",
                                                                                 TempCustLicense."Country/Region Code",
                                                                                 TempCustLicense.County,
                                                                                 TempCustLicense."Locality Code",
                                                                                 TempCustLicense."Business Type Code",
                                                                                 TempCustLicense."License Type Code",
                                                                                 TempCustLicense."License No.",
                                                                                 WorKDATE);
                                        if not UnExpiredLicense then begin
                                            //EXIT(STRSUBSTNO(LText007,Item."No.",Item.Description));
                                            exit('12: ' + LText011);
                                        end;
                                        until(TempCustLicense.Next = 0) or(UnExpiredLicense);
                                    end;
                                    if not UnExpiredLicense then begin
                                        //EXIT(STRSUBSTNO(LText007,Item."No.",Item.Description));
                                        exit('13: ' + LText011);
                                    end;
                                    until TempLicTypes4ProductUse.Next = 0;
                                end;
                                until TempSDSProductCAS.Next = 0;
                        end;
                        exit('OK');
                        // 3 <<
                    end else
                        //EXIT(STRSUBSTNO(LText007,Item."No.",Item.Description));
                        exit('OK');
                    // 2b <<
                end else
                    exit('OK');
                // 2a <<
            end else
                exit('NOTOK');
        end;
2 :
        begin
            Cust.Get(CustNo);
            Location.Get(LocationCode);
            if Item.Get(ItemNo) then begin
                Item.Reset();
                Item.SetRange("Date Filter", 0D, WorKDATE);
                Item.SetRange("Variant Filter", '');
                Item.SetRange("Location Filter", LocationCode);
                Item.SetRange("Drop Shipment Filter", false);
                Item.CalcFields("Qty. on Sales order", Inventory);
                QtyAvailable := Item.Inventory - Item."Qty. on Sales order";
                if IUOM.Get(ItemNo, UOM) then begin
                    QtyAvailable := QtyAvailable * IUOM."Qty. per Unit of Measure";
                end;
                if QtyAvailable >= ReqQty then
                    exit('OK');
                if(QtyAvailable > 0) and(QtyAvailable < ReqQty) then
                    exit(LText010);
                //EXIT(STRSUBSTNO(LText006,Location.Name));
                //EXIT(STRSUBSTNO(LText009,ForMAT(QtyAvailable),Location.Name));
                if QtyAvailable < ReqQty then
                    exit(LText010);
                //EXIT(STRSUBSTNO(LText005,Location.Name));
                //EXIT(STRSUBSTNO(LText008,ForMAT(ReqQty),Location.Name));
            end else
                exit('OK');
        end;
        end;
    end;
}
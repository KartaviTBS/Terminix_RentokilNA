codeunit 50038 "ARC LOBLiftMgt"
{
    trigger OnRun();
    begin
    end;

    local procedure CalculateLift(_SalesHeader: Record "Sales Header"; var _TotalAmount: Decimal; var _ChargedLift: Decimal; TargetLOB: Code[20])
    var
        _SalesLine: Record "Sales Line";
        _SalesLine2: Record "Sales Line";
        LiftPer: Decimal;
        Item: Record Item;
        CalcCost: Decimal;
        RNASetup: Record "ARC RNA Setup";
    begin
        _SalesLine.Reset;
        _SalesLine.SetRange("Document Type", _SalesHeader."Document Type");
        _SalesLine.SetRange("Document No.", _SalesHeader."No.");
        _SalesLine.SetRange(Type, _SalesLine.Type::"G/L Account");
        _SalesLine.SetRange("No.", GenLedgSetup."ARC LOB Lift G/L Account");
        _SalesLine.SetRange("ARC Target LOB",TargetLOB);
        _SalesLine.SetRange("Quantity Shipped", 0);
        If _SalesLine.FindFirst then
            _SalesLine.Delete(true)
        else begin
            _SalesLine.SetRange("Quantity Shipped");
            if _SalesLine.FindSet then
                repeat
                    _ChargedLift += _SalesLine."Line Amount";
                until _SalesLine.Next = 0
        end;
        RNASetup.Get;
        _SalesLine.Reset;
        _SalesLine.SetRange("Document Type", _SalesHeader."Document Type");
        _SalesLine.SetRange("Document No.", _SalesHeader."No.");
        _SalesLine.SetRange(Type, _SalesLine.Type::Item);
        _SalesLine.SetRange("ARC Target LOB",TargetLOB);
        if _SalesLine.FindSet then
            repeat
                Item.Get(_SalesLine."No.");
            case RNASetup."LOB Lift Field Calculation" of
                RNASetup."LOB Lift Field Calculation"::"Unit Cost" :
                    CalcCost := Item."Unit Cost";
                RNASetup."LOB Lift Field Calculation"::"Sales Cost" :
                    CalcCost := Item."ARC Sales Cost";
                RNASetup."LOB Lift Field Calculation"::"Unit Price" :
                    CalcCost := Item."Unit Price";
            end;
            LiftPer := GetLiftPercent(_SalesHeader, _SalesLine);
            _TotalAmount += (CalcCost * _SalesLine.Quantity) * (LiftPer / 100);
            until _SalesLine.Next = 0;
    end;

    local procedure InitiateLift(_SalesHeader: Record "Sales Header";TargetLOB: Code[20])
    var
        _SalesLine: Record "Sales Line";
        _CalculatedLift: Decimal;
        _ChargedLift: Decimal;
        _TotalAmount: Decimal;
        _LineNo: Integer;
    begin
        CalculateLift(_SalesHeader, _TotalAmount, _ChargedLift,TargetLOB);
        TempDimSetEntry.Reset;
        TempDimSetEntry.DeleteAll;
        GenLedgSetup.Get;
        _CalculatedLift := _TotalAmount;
        if _ChargedLift >= _CalculatedLift then
            exit;
        _SalesLine.SetRange("Document Type", _SalesHeader."Document Type");
        _SalesLine.SetRange("Document No.", _SalesHeader."No.");
        if _SalesLine.FindLast then
            _LineNo := _SalesLine."Line No.";
        _LineNo += 10000;
        _SalesLine.SetHideValidationDialog(true);
        _SalesLine.Init;
        _SalesLine."Document Type" := _SalesHeader."Document Type";
        _SalesLine."Document No." := _SalesHeader."No.";
        _SalesLine."Line No." := _LineNo;
        _SalesLine.Insert(true);
        _SalesLine.Validate(Type, _SalesLine.Type::"G/L Account");
        _SalesLine.Validate("No.", GenLedgSetup."ARC LOB Lift G/L Account");
        _SalesLine.Validate(Quantity, 1);
        _SalesLine.Validate("Unit Price", _CalculatedLift - _ChargedLift);
        _SalesLine."ARC Target LOB" := TargetLOB;
        DimMgt.GetDimensionSet(TempDimSetEntry,_SalesLine."Dimension Set ID");
        TempDimSetEntry.Reset;
        TempDimSetEntry.SetRange("Dimension Code",GenLedgSetup."Shortcut Dimension 3 Code");
        if TempDimSetEntry.FindFirst then
            TempDimSetEntry.Delete;
        CreateTempDimSetEntry(GenLedgSetup."Shortcut Dimension 3 Code",TargetLOB,_SalesLine."Dimension Set ID");
        _SalesLine."Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
        
        _SalesLine.Modify(false);
    end;

    local procedure OnReleaseApplyLift(var SalesHeader: Record "Sales Header");
    var
        SalesLine: Record "Sales Line";
        TempLOBCodes: Record "Item Category" temporary;
        CustPostingGroup: Record "Customer Posting Group";
    begin
        If CustPostingGroup.Get(Customer."Customer Posting Group") then;
        If (not Customer."ARC Internal Customer") and (not CustPostingGroup."ARC Internal Customer") then
            exit;
        SalesLine.Reset;
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter(Quantity, '>%1', 0);
        If SalesLine.FindSet then
            repeat
                if Not TempLOBCodes.Get(SalesLine."ARC Target LOB") then begin
                    TempLobCodes.Init;
                    TempLobCOdes.Code := SalesLine."ARC Target LOB";
                    TempLobCodes.Insert;
                end;
            until SalesLine.Next = 0;
        TempLOBCodes.Reset;
        If TempLOBCodes.FindSet then 
            repeat
                CreateLiftLines(SalesHeader,TempLobCodes.Code);
            until TempLOBCodes.Next = 0;
    end;

    local procedure CreateLiftLines(var SalesHeader: Record "Sales Header"; TargetLOB: Code[20]);
    var
         SalesLine: Record "Sales Line";
    begin
        SalesLine.Reset;
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter(Quantity, '>%1', 0);
        SalesLine.SetRange("ARC Target LOB",TargetLOB);
        If SalesLine.Findset then
        repeat
            InitiateLift(SalesHeader,TargetLOB);
        until SalesLine.Next = 0;
        
    end;

    procedure OnAfterReopenSalesDoc(SalesHeader: Record "Sales Header")
    var
        _GenLedgSetup: Record "General Ledger Setup";
        _SalesLine: Record "Sales Line";
        _SalesLine2: Record "Sales Line";
    begin
        _GenLedgSetup.Get;
        _SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        _SalesLine.SetRange("Document No.", SalesHeader."No.");
        _SalesLine.SetRange(Type, _SalesLine.Type::"G/L Account");
        _SalesLine.SetRange("No.", _GenLedgSetup."ARC LOB Lift G/L Account");
        _SalesLine.SetRange("Quantity Shipped", 0);
        if _SalesLine.FindSet(false) then
            repeat
                Clear(_SalesLine2);
            _SalesLine2.Reset;
            _SalesLine2.LockTable;
            _SalesLine2.Get(_SalesLine."Document Type", _SalesLine."Document No.", _SalesLine."Line No.");
            _SalesLine2.Delete;
            until _SalesLine.Next = 0;
    end;

    procedure OnAfterValidateLOBLiftCustPostGrp(var Rec: Record Customer; var xRec: Record Customer; CurrFieldNo: Integer)
    var
        _CustPostingGroup: Record "Customer Posting Group";
    begin
        if _CustPostingGroup.Get(Rec."Customer Posting Group") then begin
            if _CustPostingGroup."ARC LOB Lift %" <> 0 then begin
                if Rec."ARC LOB Lift %" = 0 then begin
                    Rec."ARC LOB Lift %" := _CustPostingGroup."ARC LOB Lift %";
                end;
            end;
        end;
    end;

    local procedure GetLiftPercent(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"): Decimal
    var
        CustItemLift: Record "ARC Customer Item Lift";
        CustPostingGroup: Record "Customer Posting Group";
    begin
        If CustItemLift.Get(SalesHeader."Sell-to Customer No.", SalesLine."No.") then
            exit(CustItemLift."Lift %");

        If Customer.Get(SalesHeader."Sell-to Customer No.") and (Customer."ARC LOB Lift %" <> 0) then
            exit(Customer."ARC LOB Lift %");

        if CustPostingGroup.Get(Customer."Customer Posting Group")  then
            exit(CustPostingGroup."ARC LOB Lift %");
        exit(0);
    end;

    procedure OnBeforeReleaseSalesDoc(SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    begin
        if PreviewMode then
            exit;
        GenLedgSetup.Get();
        If GenLedgSetup."ARC LOB Lift G/L Account" = '' then
            exit;
        if SalesHeader."Sell-to Customer No." = '' then
            exit;
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            exit;
           
        OnReleaseApplyLift(SalesHeader);
    end;


    local procedure CreateTempDimSetEntry(DimCode: Code[20]; DimValue: Code[20]; DimSetId: Integer);
    var
        DimVal: Record "Dimension Value";
    begin
        DimVal.Get(DimCode,DimValue);
        TempDimSetEntry.Init();
        TempDimSetEntry."Dimension Set ID" := DimSetId;
        TempDimSetEntry."Dimension Code" := DimCode;
        TempDimSetEntry."Dimension Value Code" := DimVal.Code;
        TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
        TempDimSetEntry.Insert();        
    end;

    var
        Customer: Record Customer;
        GenLedgSetup: Record "General Ledger Setup";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
}
xmlport 50106 "ARC KorberItemAdjmt"
{
    // SOW11 Körber Edge WMS Integration

    Encoding = UTF8;
    Direction = Export;
    UseRequestPage = false;
    Caption = 'Korber Edge WMS Item Adjmt. Export';

    schema
    {
        textelement(AdjustmentsCA)
        {
            textelement(RowId) { }
            textelement(Quantity) { }
            //textelement(Attribute1) { }
            //textelement(Attribute2) { }
            //textelement(Attribute3) { }
            //textelement(Attribute4) { }
            //textelement(Attribute5) { }
            //textelement(Attribute6) { }
            //textelement(Attribute7) { }
            //textelement(Attribute8) { }
            //textelement(Attribute9) { }
            //textelement(Attribute10) { }
            //textelement(ExpiryDate) { }
            textelement(AdjustmentSubcode) { }
            textelement(ProductCode) { }
            textelement(Description) { }
            textelement(UnitOfMeasure) { }
            //textelement(ProductClass) { }
            //textelement(UPC) { }
            textelement(Packsize) { }
            textelement(PlusMinus) { }
            textelement(BinLocation) { }
            //textelement(ReplReservedStockFlagace) { }
            //textelement(PONumber) { }
            textelement(Comment) { }
            //textelement(ReceivingAttributeControl) { }
            //textelement(FIFODate) { }
            //textelement(ClientName) { }
            //textelement(InnerPack) { }
            //textelement(MinimumLevelOfReplenishment) { }
            //textelement(MaximumLevelOfReplenishment) { }
            //textelement(LicensePlate) { }
        }
    }

    var
        KorberMgt: Codeunit "ARC KorberMgt";
        Initialized: Boolean;
        ContainerBatchRefHeader: Text;
        DateTimeText: Text;
        Text000Err: Label 'Xmlport "ARC KorberItemAdjmt" was not properly initialized';

    trigger OnPreXmlPort()
    begin
        if not Initialized then
            Error(Text000Err);
    end;

    procedure GetContainerBatchRefHeader(): Text
    begin
        exit(ContainerBatchRefHeader);
    end;

    procedure SetEntryNo(_EntryNo: BigInteger)
    var
        _Item: Record Item;
        _ItemAdjmtEntry: Record "ARC Korber Item Adjmt. Entry";
        _ItemCrossRef: Record "Item Cross Reference";
        _ReasonCode: Record "Reason Code";
        _pos: Integer;
        _Username: Text;
    begin
        _ItemAdjmtEntry.Get(_EntryNo);
        _Item.Get(_ItemAdjmtEntry."Item No.");
        if _ItemAdjmtEntry."Reason Code" <> '' then
            if not _ReasonCode.Get(_ItemAdjmtEntry."Reason Code") then
                Clear(_ReasonCode);
        // username
        _Username := CopyStr(_ItemAdjmtEntry."Created by",1,MaxStrLen(_Username));
        _pos := StrPos(_Username,'\');
        if _pos <> 0 then
            _Username := CopyStr(_Username,_pos + 1);
        // from pg 72: _MH\_Clients\Rentokil\20220505 Korber\docs\_RobinHurst\K.Motion Warehouse Edge ERP Integration User Guide.pdf
        //   Computer Adjusts (CA) records allow the host to send stock adjustments to the warehouse
        //   MA—Miscellaneous adjustment
        DateTimeText := CopyStr(KorberMgt.GetFormattedDateTime(),1,MaxStrLen(DateTimeText));
        RowId := CopyStr(DateTimeText,1,MaxStrLen(RowId));
        Quantity := CopyStr(KorberMgt.GetFormattedWholeValue(_ItemAdjmtEntry.Quantity),1,MaxStrLen(Quantity));
        AdjustmentSubcode := CopyStr('MA',1,MaxStrLen(AdjustmentSubcode));
        ProductCode := CopyStr(_Item."No.",1,MaxStrLen(ProductCode));
        Description := CopyStr(_Item.Description,1,MaxStrLen(Description));
        //UnitOfMeasure := CopyStr(_ItemAdjmtEntry."Item Unit of Measure Code",1,MaxStrLen(UnitOfMeasure));
        UnitOfMeasure := CopyStr(KorberMgt.GetFormattedWholeValue(_ItemAdjmtEntry."Qty. per Unit of Measure"),1,MaxStrLen(UnitOfMeasure));
        // ProductClass := CopyStr(KorberMgt.GetProductClass(_ItemAdjmtEntry."Item No."),1,MaxStrLen(ProductClass));
        Packsize := CopyStr(KorberMgt.GetFormattedWholeValue(_ItemAdjmtEntry."Qty. per Unit of Measure"),1,MaxStrLen(Packsize));
        BinLocation := CopyStr('01RECV00',1,MaxStrLen(BinLocation));  // hardcoded for now - email fr Robin Hurst dated Wed 13 Jul 2022 at 1217pm Eastern
        if _ReasonCode.Code = '' then
            Comment := CopyStr(_Username,1,MaxStrLen(Comment))
        else
            Comment := CopyStr(_ReasonCode.Code + ' : ' + _Username,1,MaxStrLen(Comment));
        // barcode/UPC
        /*
        _ItemCrossRef.SetRange("Item No.",_Item."No.");
        _ItemCrossRef.SetRange("Cross-Reference Type",_ItemCrossRef."Cross-Reference Type"::"Bar Code");
        if _ItemCrossRef.FindFirst() then
            UPC := CopyStr(_ItemCrossRef."Cross-Reference Type No.",1,MaxStrLen(UPC));
        */
        ContainerBatchRefHeader := CopyStr('ADJMT_' + DateTimeText,1,MaxStrLen(ContainerBatchRefHeader));
        case _ItemAdjmtEntry."Entry Type" of
            _ItemAdjmtEntry."Entry Type"::"Positive Adjmt.": PlusMinus := CopyStr('+',1,MaxStrLen(PlusMinus));
            else                                             PlusMinus := CopyStr('-',1,MaxStrLen(PlusMinus));
        end;
        // data complete
        Initialized := true;
    end;
}
codeunit 50029 "ARC NAPC BOL Management"
{
    

    trigger OnRun();
    begin
    end;

    procedure GetSourceLines(SourceDocType : Option " ","Sales Order","Sales Return Order","Transfer Order","Purchase Return Order","Sales Shipment","Return Shipment","Return Receipt","Transfer Shipment";DocNo : Code[20];var NAPCBOLHeader : Record "ARC NAPC BOL Header");
    var
        SalesHeader : Record "Sales Header";
        SalesLine : Record "Sales Line";
        TransferLine : Record "Transfer Line";
        PurchaseReturnLine : Record "Purchase Line";
        SalesShipmentHeader : Record "Sales Shipment Header";
        SalesShipmentLine : Record "Sales Shipment Line";
        ReturnShipmentLine : Record "Return Shipment Line";
        ReturnReceiptLine : Record "Return Receipt Line";
        TransferShipmentHeader : Record "Transfer Shipment Header";
        TransferShipmentLine : Record "Transfer Shipment Line";
        NAPCBOLLine : Record "ARC NAPC BOL Line";
        LineNo : Integer;
        ItemNo : Code[20];
    begin
        if SourceDocType = SourceDocType::" " then
          exit;
        
        NAPCBOLLine.SetRange("Document No.",NAPCBOLHeader."No.");
        if NAPCBOLLine.FindLast() then
          LineNo := NAPCBOLLine."Line No." + 10000
        else
          LineNo := 10000;
        
        case SourceDocType of
          SourceDocType::"Sales Order":
            begin
              NAPCBOLLine.SetRange("Document No.",NAPCBOLHeader."No.");
              if NAPCBOLLine.FindSet() then begin
                NAPCBOLLine.DeleteAll;
                LineNo := 10000;
              END;
              SalesHeader.Get(SalesHeader."Document Type"::Order,DocNo);
              SalesHeader.TestField("Shipping Agent Code",NAPCBOLHeader."Shipping Agent Code");
              SalesHeader.TestField("E-Ship Agent Service",NAPCBOLHeader."E-Ship Agent Service");
              SalesLine.SetRange("Document Type",SalesLine."Document Type"::Order);
              SalesLine.SetRange("Document No.",DocNo);
              SalesLine.SetFilter(Type,'%1|%2',SalesLine.Type::Item,SalesLine.Type::Resource);
              SalesLine.SetFilter(Quantity,'<>%1',0);
              //SalesLine.SetRange("ARC NAPC Bill of Lading No.",''); //flowfield
              if SalesLine.FindSet(false,false) then repeat
                NAPCBOLLine.Init();
                NAPCBOLLine."Document No." := NAPCBOLHeader."No.";
                NAPCBOLLine."Line No." := LineNo;
                NAPCBOLLine."Manifest Code" := NAPCBOLHeader."Manifest No.";
                NAPCBOLLine."Source Doc. Type" := SourceDocType;
                NAPCBOLLine."Source Doc. No." := SalesLine."Document No.";
                NAPCBOLLine."Source Doc. Line No." := SalesLine."Line No.";
                case SalesLine.Type of
                  SalesLine.Type::Item: NAPCBOLLine.Type := NAPCBOLLine.Type::Item;
                  SalesLine.Type::Resource: NAPCBOLLine.Type := NAPCBOLLine.Type::Resource;
                end;
                NAPCBOLLine."No." := SalesLine."No.";
                NAPCBOLLine."Variant Code" := SalesLine."Variant Code";
                NAPCBOLLine.Description := SalesLine.Description;
                NAPCBOLLine."Unit of Measure Code" := SalesLine."Unit of Measure Code";
                NAPCBOLLine.Quantity := SalesLine.Quantity;
                NAPCBOLLine."Line Weight" := SalesLine."Gross Weight" * NAPCBOLLine.Quantity;
                NAPCBOLLine."Line Volume" := SalesLine."Unit Volume" * NAPCBOLLine.Quantity;
                if NAPCBOLLine.Type = NAPCBOLLine.Type::Item then
                  ItemNo := NAPCBOLLine."No."
                else
                  ItemNo := '';
                NAPCBOLLine."NAPC BOL Code" := GetNAPCBOL(ItemNo,NAPCBOLHeader."Shipping Agent Code",NAPCBOLHeader."E-Ship Agent Service",
                                                          SalesHeader."World Wide Service");
                NAPCBOLLine.Insert();
                LineNo += 10000;
              until SalesLine.Next = 0;
            end;        
          SourceDocType::"Sales Shipment":
            begin
              SalesShipmentHeader.Get(DocNo);
              SalesShipmentHeader.TestField("Shipping Agent Code",NAPCBOLHeader."Shipping Agent Code");
              SalesShipmentHeader.TestField("E-Ship Agent Service",NAPCBOLHeader."E-Ship Agent Service");
              SalesShipmentLine.SetRange("Document No.",DocNo);
              SalesShipmentLine.SetFilter(Type,'%1|%2',SalesShipmentLine.Type::Item,SalesShipmentLine.Type::Resource);
              SalesShipmentLine.SetFilter(Quantity,'<>%1',0);
              SalesShipmentLine.SetRange("ARC NAPC Bill of Lading No.",'');
              if SalesShipmentLine.FindSet(false,false) then repeat
                NAPCBOLLine.Init();
                NAPCBOLLine."Document No." := NAPCBOLHeader."No.";
                NAPCBOLLine."Line No." := LineNo;
                NAPCBOLLine."Manifest Code" := NAPCBOLHeader."Manifest No.";
                NAPCBOLLine."Source Doc. Type" := SourceDocType;
                NAPCBOLLine."Source Doc. No." := SalesShipmentLine."Document No.";
                NAPCBOLLine."Source Doc. Line No." := SalesShipmentLine."Line No.";
                case SalesShipmentLine.Type of
                  SalesShipmentLine.Type::Item: NAPCBOLLine.Type := NAPCBOLLine.Type::Item;
                  SalesShipmentLine.Type::Resource: NAPCBOLLine.Type := NAPCBOLLine.Type::Resource;
                end;
                NAPCBOLLine."No." := SalesShipmentLine."No.";
                NAPCBOLLine."Variant Code" := SalesShipmentLine."Variant Code";
                NAPCBOLLine.Description := SalesShipmentLine.Description;
                NAPCBOLLine."Unit of Measure Code" := SalesShipmentLine."Unit of Measure Code";
                NAPCBOLLine.Quantity := SalesShipmentLine.Quantity;
                NAPCBOLLine."Line Weight" := SalesShipmentLine."Gross Weight" * NAPCBOLLine.Quantity;
                NAPCBOLLine."Line Volume" := SalesShipmentLine."Unit Volume" * NAPCBOLLine.Quantity;
                if NAPCBOLLine.Type = NAPCBOLLine.Type::Item then
                  ItemNo := NAPCBOLLine."No."
                else
                  ItemNo := '';
                NAPCBOLLine."NAPC BOL Code" := GetNAPCBOL(ItemNo,NAPCBOLHeader."Shipping Agent Code",NAPCBOLHeader."E-Ship Agent Service",
                                                          SalesShipmentHeader."World Wide Service");
                NAPCBOLLine.Insert();
                LineNo += 10000;
              until SalesShipmentLine.Next = 0;
            end;
          SourceDocType::"Transfer Shipment":
            begin
              TransferShipmentHeader.Get(DocNo);
              TransferShipmentHeader.TestField("Shipping Agent Code",NAPCBOLHeader."Shipping Agent Code");
              TransferShipmentHeader.TestField("E-Ship Agent Service",NAPCBOLHeader."E-Ship Agent Service");
              TransferShipmentLine.SetRange("Document No.",DocNo);
              TransferShipmentLine.SetFilter(Quantity,'<>%1',0);
              TransferShipmentLine.SetRange("ARC NAPC Bill of Lading No.",'');
              if TransferShipmentLine.FindSet(false,false) then repeat
                NAPCBOLLine.Init();
                NAPCBOLLine."Document No." := NAPCBOLHeader."No.";
                NAPCBOLLine."Line No." := LineNo;
                NAPCBOLLine."Manifest Code" := NAPCBOLHeader."Manifest No.";
                NAPCBOLLine."Source Doc. Type" := SourceDocType;
                NAPCBOLLine."Source Doc. No." := TransferShipmentLine."Document No.";
                NAPCBOLLine."Source Doc. Line No." := TransferShipmentLine."Line No.";
                NAPCBOLLine.Type := NAPCBOLLine.Type::Item;
                NAPCBOLLine."No." := TransferShipmentLine."Item No.";
                NAPCBOLLine."Variant Code" := TransferShipmentLine."Variant Code";
                NAPCBOLLine.Description := TransferShipmentLine.Description;
                NAPCBOLLine."Unit of Measure Code" := TransferShipmentLine."Unit of Measure Code";
                NAPCBOLLine.Quantity := TransferShipmentLine.Quantity;
                NAPCBOLLine."Line Weight" := TransferShipmentLine."Gross Weight" * NAPCBOLLine.Quantity;
                NAPCBOLLine."Line Volume" := TransferShipmentLine."Unit Volume" * NAPCBOLLine.Quantity;
                if NAPCBOLLine.Type = NAPCBOLLine.Type::Item then
                  ItemNo := NAPCBOLLine."No."
                else
                  ItemNo := '';
                NAPCBOLLine."NAPC BOL Code" := GetNAPCBOL(ItemNo,NAPCBOLHeader."Shipping Agent Code",NAPCBOLHeader."E-Ship Agent Service",
                                                          TransferShipmentHeader."World Wide Service");

                NAPCBOLLine.Insert();
                LineNo += 10000;
              until TransferShipmentLine.Next = 0;
            end;
        end;
    end;

    procedure BuildBOLSummaryLines(DocNo : Code[20];var TempNAPCBOLSummaryLine : Record "ARC NAPC BOL Summary Line" temporary);
    var
        NAPCBOLHeader : Record "ARC NAPC BOL Header";
        NAPCBOLLine : Record "ARC NAPC BOL Line";
        NAPCBOL : Record "ARC NAPC BOL";
        NAPCBOL2 : Record "ARC NAPC BOL";
    begin
        TempNAPCBOLSummaryLine.DeleteAll();
        NAPCBOLHeader.Get(DocNo);
        NAPCBOLLine.SetRange("Document No.",NAPCBOLHeader."No.");
        if NAPCBOLLine.FindSet(false,false) then repeat
          NAPCBOL.Get(NAPCBOLLine."NAPC BOL Code");
          if not TempNAPCBOLSummaryLine.Get(NAPCBOLHeader."No.",NAPCBOLLine."NAPC BOL Code") then begin
            TempNAPCBOLSummaryLine.Init();
            TempNAPCBOLSummaryLine."NAPC BOL Document No." := NAPCBOLHeader."No.";
            TempNAPCBOLSummaryLine."NAPC BOL Code" := NAPCBOLLine."NAPC BOL Code";
            TempNAPCBOLSummaryLine.Description := NAPCBOL.Description;
            TempNAPCBOLSummaryLine."Unit of Measure Code" := NAPCBOLLine."Unit of Measure Code";
            TempNAPCBOLSummaryLine."Line Quantity" := NAPCBOLLine.Quantity;
            TempNAPCBOLSummaryLine."Line Weight" := NAPCBOLLine."Line Weight";
            TempNAPCBOLSummaryLine."Line Volume" := NAPCBOLLine."Line Volume";
            if NAPCBOL."Placard Code" <> '' then
              TempNAPCBOLSummaryLine.HazMat := 'X';
            TempNAPCBOLSummaryLine.Insert();
          end else begin
            TempNAPCBOLSummaryLine."Line Quantity" := TempNAPCBOLSummaryLine."Line Quantity" + NAPCBOLLine.Quantity;
            TempNAPCBOLSummaryLine."Line Weight" := TempNAPCBOLSummaryLine."Line Weight" + NAPCBOLLine."Line Weight";
            TempNAPCBOLSummaryLine."Line Volume" := TempNAPCBOLSummaryLine."Line Volume" + NAPCBOLLine."Line Volume";
            if NAPCBOL."Placard Code" <> '' then
              TempNAPCBOLSummaryLine.HazMat := 'X';
            TempNAPCBOLSummaryLine.Modify();
          end;
        until NAPCBOLLine.Next = 0;
    end;

    procedure SetAlternateBOLCodes(var TempNAPCBOLSummaryLine : Record "ARC NAPC BOL Summary Line" temporary;HazMatOnly : Boolean);
    var
        NAPCBOL : Record "ARC NAPC BOL";
        TempNAPCBOLSummaryLine2 : Record "ARC NAPC BOL Summary Line" temporary;
        NewBOLCode : Code[10];
    begin
        TempNAPCBOLSummaryLine2.DeleteAll();
        if TempNAPCBOLSummaryLine.FindSet() then repeat
          NAPCBOL.Get(TempNAPCBOLSummaryLine."NAPC BOL Code");
          NewBOLCode := TempNAPCBOLSummaryLine."NAPC BOL Code";
          case NAPCBOL."BOL Limit Unit" of
            NAPCBOL."BOL Limit Unit"::Quantity:
              if TempNAPCBOLSummaryLine."Line Quantity" > NAPCBOL."BOL Limit" then begin
                NewBOLCode := NAPCBOL."Alt. BOL Code";
              end;
            NAPCBOL."BOL Limit Unit"::Weight:
              if TempNAPCBOLSummaryLine."Line Weight" > NAPCBOL."BOL Limit" then begin
                NewBOLCode := NAPCBOL."Alt. BOL Code";
              end;
          end;
          if not TempNAPCBOLSummaryLine2.Get(TempNAPCBOLSummaryLine."NAPC BOL Document No.",
                                             NewBOLCode) then begin
            TempNAPCBOLSummaryLine2.Init();
            TempNAPCBOLSummaryLine2 := TempNAPCBOLSummaryLine;
            TempNAPCBOLSummaryLine2."NAPC BOL Code" := NewBOLCode;
            NAPCBOL.Get(TempNAPCBOLSummaryLine2."NAPC BOL Code");
            if NAPCBOL."Placard Code" <> '' then
              TempNAPCBOLSummaryLine2.HazMat := 'X';
            TempNAPCBOLSummaryLine2.Insert();
          end else begin
            TempNAPCBOLSummaryLine2."Line Quantity" := TempNAPCBOLSummaryLine2."Line Quantity" + TempNAPCBOLSummaryLine."Line Quantity";
            TempNAPCBOLSummaryLine2."Line Weight" := TempNAPCBOLSummaryLine2."Line Weight" + TempNAPCBOLSummaryLine."Line Weight";
            TempNAPCBOLSummaryLine2."Line Volume" := TempNAPCBOLSummaryLine2."Line Volume" + TempNAPCBOLSummaryLine."Line Volume";
            NAPCBOL.Get(TempNAPCBOLSummaryLine2."NAPC BOL Code");
            if NAPCBOL."Placard Code" <> '' then
              TempNAPCBOLSummaryLine2.HazMat := 'X';
            TempNAPCBOLSummaryLine2.Modify();
          end;
        until TempNAPCBOLSummaryLine.Next = 0;
        TempNAPCBOLSummaryLine.DeleteAll();
        if TempNAPCBOLSummaryLine2.FindSet() then repeat
          TempNAPCBOLSummaryLine.Init();
          TempNAPCBOLSummaryLine := TempNAPCBOLSummaryLine2;
          NAPCBOL.Get(TempNAPCBOLSummaryLine."NAPC BOL Code");
          TempNAPCBOLSummaryLine.Description := NAPCBOL.Description;
          case NAPCBOL."Placard Limit Unit" of
            NAPCBOL."Placard Limit Unit"::Volume:
              if TempNAPCBOLSummaryLine."Line Volume" > NAPCBOL."Placard Limit" then begin
                TempNAPCBOLSummaryLine."Placard Code" := NAPCBOL."Placard Code";
              end;
            NAPCBOL."Placard Limit Unit"::Weight:
              if TempNAPCBOLSummaryLine."Line Weight" > NAPCBOL."Placard Limit" then begin
                TempNAPCBOLSummaryLine."Placard Code" := NAPCBOL."Placard Code";
              end;
          end;
          //if HazMatOnly then begin
          //  if TempNAPCBOLSummaryLine2.HazMat = 'X' then
          TempNAPCBOLSummaryLine.Insert();
          //end else
          //  TempNAPCBOLSummaryLine.Insert();
        until TempNAPCBOLSummaryLine2.Next = 0;
    end;

    procedure GetNAPCBOL(ItemNo : Code[20];ShippingAgentCode : Code[10];EShipAgentSvcCode : Code[30];WorldWideSvc : Boolean) NAPCBOLCode : Code[10];
    var
        TargetSetup : Record "ARC Target Setup";
        Item : Record Item;
        EShipAgentService : Record "E-Ship Agent Service";
    begin
        TargetSetup.Get();
        TargetSetup.TestField("Unregulated Product BOL Code");
        NAPCBOLCode := TargetSetup."Unregulated Product BOL Code";
        if ItemNo = '' then
          exit;

        if not EShipAgentService.Get(ShippingAgentCode,EShipAgentSvcCode,WorldWideSvc) then
          Clear(EShipAgentService);

        Item.Get(ItemNo);
        if Item."ARC SDS Product Code" <> '' then begin
          Item.CalcFields("ARC BOL/UN/Air Code","ARC BOL/UN/Ground Code","ARC BOL/UN/Water Code");
          case EShipAgentService."Transport Method Type" of
            EShipAgentService."Transport Method Type"::Air:
              NAPCBOLCode := Item."ARC BOL/UN/Air Code";
            EShipAgentService."Transport Method Type"::Ground:
              NAPCBOLCode := Item."ARC BOL/UN/Ground Code";
            EShipAgentService."Transport Method Type"::Water:
              NAPCBOLCode := Item."ARC BOL/UN/Water Code";
          end;
        end;
    end;

    procedure GetHazMatText(NAPCBOLCode : Code[10];var HazMat : Code[2];var HazMatText : Text[100];var HazMatDesc : array [10] of Text[80]);
    var
        NAPCBOL : Record "ARC NAPC BOL";
        NAPCBOL2 : Record "ARC NAPC BOL";
        LText001 : Label 'Warning HazMat Shipping Options';
        NAPCBOLCommentLine : Record "ARC NAPC BOL Comment Line";
        LineCnt : Integer;
    begin
        HazMat := '';
        HazMatText := '';
        Clear(HazMatDesc);
        if NAPCBOLCode <> '' then begin
          NAPCBOL.Get(NAPCBOLCode);
          if NAPCBOL."Placard Code" <> '' then
            HazMat := 'X';
          if (NAPCBOL."Placard Limit Unit" <> NAPCBOL."Placard Limit Unit"::" ") then begin
            HazMatText := LText001;
            HazMatDesc[1] := NAPCBOL.Description;
            NAPCBOLCommentLine.SetRange(Code,NAPCBOL.Code);
            LineCnt := 0;
            if NAPCBOLCommentLine.FindSet(false,false) then repeat
              LineCnt += 1;
              HazMatDesc[LineCnt] := NAPCBOLCommentLine.Comment;
            until (NAPCBOLCommentLine.Next = 0) or (LineCnt = 10);
          end;
          if (NAPCBOL."Alt. BOL Code" <> '') and NAPCBOL2.Get(NAPCBOL."Alt. BOL Code") then begin
            if (HazMat = '') AND (NAPCBOL2."Placard Code" <> '') then
              HazMat := 'X';
            if (HazMatText = '') and (NAPCBOL2."Placard Limit Unit" <> NAPCBOL2."Placard Limit Unit"::" ") then begin
              HazMatText := LText001;
              HazMatDesc[1] := NAPCBOL2.Description;
              NAPCBOLCommentLine.SetRange(Code,NAPCBOL2.Code);
              LineCnt := 0;
              if NAPCBOLCommentLine.FindSet(false,false) then repeat
                LineCnt += 1;
                HazMatDesc[LineCnt] := NAPCBOLCommentLine.Comment;
              until (NAPCBOLCommentLine.Next = 0) or (LineCnt = 10);
            end;
          end;
        end;
    end;
}


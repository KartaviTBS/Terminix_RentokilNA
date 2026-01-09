table 50038 "ARC NAPC BOL Line"
{
    //DataClassification = ToBeClassified;
    
    Caption = 'NAPC BOL Line';
    //DrillDownPageID = 50607;
    //LookupPageID = 50607;

    fields
    {
        field(1;"Document No.";Code[20])
        {
            NotBlank = true;
        }
        field(2;"Line No.";Integer)
        {
        }
        field(10;"Manifest Code";Code[20])
        {
            TableRelation = "ARC NAPC Manifest"."No.";
        }
        field(21;"Source Doc. Type";Option)
        {
            OptionCaption = '" ,,,,,Sales Shipment,,,Transfer Shipment"';
            OptionMembers = " ","Sales Order","Sales Return Order","Transfer Order","Purchase Return Order","Sales Shipment","Return Shipment","Return Receipt","Transfer Shipment";
        }
        field(22;"Source Doc. No.";Code[20])
        {

            trigger OnLookup();
            var 
                SalesLine: Record "Sales Line";
                SalesLines: Page "Sales Lines";       
                PostedSalesShipmentLines: Page "Posted Sales Shipment Lines";      
                PostedTransferShipmentLines: Page "Posted Transfer Shipment Lines";
            begin
               GetBOLHeader;
                case "Source Doc. Type" of
                  "Source Doc. Type"::"Sales Order":
                    begin
                      SalesLine.SetRange("Document Type",SalesLine."Document Type"::Order);
                      SalesLine.SetRange("Document No.","Source Doc. No.");
                      SalesLine.SetFilter(Type,'%1|%2',SalesLine.Type::Item,SalesLine.Type::Resource);
                      SalesLine.SetRange("Shipping Agent Code",NAPCBOLHeader."Shipping Agent Code");
                      SalesLine.SetRange("E-Ship Agent Service",NAPCBOLHeader."E-Ship Agent Service");
                      Clear(SalesLines);
                      SalesLines.LookupMode := true;
                      SalesLines.SetTableView(SalesLine);
                      if SalesLines.RunModal = Action::LookupOK then begin
                        SalesLines.GetRecord(SalesLine);
                        "Source Doc. Line No." := SalesLine."Line No.";
                        case SalesLine.Type of
                          SalesLine.Type::Item: Type := Type::Item;
                          SalesLine.Type::Resource: Type := Type::Resource;
                        end;
                        "No." := SalesLine."No.";
                        "Variant Code" := SalesLine."Variant Code";
                        Description := SalesLine.Description;
                        "Unit of Measure Code" := SalesLine."Unit of Measure Code";
                        Quantity := SalesLine."Qty. to Ship";
                        "Line Weight" := SalesLine."Gross Weight" * Quantity;
                        "Line Volume" := SalesLine."Unit Volume" * Quantity;
                        SalesHeader.Get(SalesLine."Document Type",SalesLine."Document No.");
                        EShipAgentService.Get(NAPCBOLHeader."Shipping Agent Code",NAPCBOLHeader."E-Ship Agent Service",
                                              SalesHeader."World Wide Service");
                        if Type = Type::Item then
                          AssignBOLCode;
                      end;
                    end;

                  "Source Doc. Type"::"Sales Shipment":
                    begin
                      SalesShipmentHeader.Get(NAPCBOLHeader."Source Doc. No.");
                      SalesShipmentHeader.TestField("Shipping Agent Code",NAPCBOLHeader."Shipping Agent Code");
                      SalesShipmentHeader.TestField("E-Ship Agent Service",NAPCBOLHeader."E-Ship Agent Service");
                      SalesShipmentLine.SetRange("Document No.","Source Doc. No.");
                      SalesShipmentLine.SetRange(Type,SalesShipmentLine.Type::Item);
                      Clear(PostedSalesShipmentLines);
                      PostedSalesShipmentLines.LookupMode := true;
                      PostedSalesShipmentLines.SetTableView(SalesShipmentLine);
                      if PostedSalesShipmentLines.RunModal = Action::LookupOK then begin
                        PostedSalesShipmentLines.GetRecord(SalesShipmentLine);
                        "Source Doc. No." := NAPCBOLHeader."Source Doc. No.";
                        "Source Doc. Line No." := SalesShipmentLine."Line No.";
                        Type := Type::Item;
                        "No." := SalesShipmentLine."No.";
                        "Variant Code" := SalesShipmentLine."Variant Code";
                        Description := SalesShipmentLine.Description;
                        "Unit of Measure Code" := SalesShipmentLine."Unit of Measure Code";
                        Quantity := SalesShipmentLine.Quantity;
                        "Line Weight" := SalesShipmentLine."Gross Weight" * Quantity;
                        "Line Volume" := SalesShipmentLine."Unit Volume" * Quantity;
                        EShipAgentService.Get(NAPCBOLHeader."Shipping Agent Code",NAPCBOLHeader."E-Ship Agent Service",
                                              SalesShipmentHeader."World Wide Service");
                        if Type = Type::Item then
                          AssignBOLCode;
                      end;
                    end;

                  "Source Doc. Type"::"Transfer Shipment":
                    begin
                      TransferShipmentHeader.Get(NAPCBOLHeader."Source Doc. No.");
                      TransferShipmentHeader.TestField("Shipping Agent Code",NAPCBOLHeader."Shipping Agent Code");
                      TransferShipmentHeader.TestField("E-Ship Agent Service",NAPCBOLHeader."E-Ship Agent Service");
                      TransferShipmentLine.SetRange("Document No.","Source Doc. No.");
                      Clear(PostedTransferShipmentLines);
                      PostedTransferShipmentLines.LookupMode := true;
                      PostedTransferShipmentLines.SetTableView(TransferShipmentLine);
                      if PostedTransferShipmentLines.RunModal = Action::LookupOK then begin
                        PostedTransferShipmentLines.GetRecord(TransferShipmentLine);
                        "Source Doc. No." := NAPCBOLHeader."Source Doc. No.";
                        "Source Doc. Line No." := TransferShipmentLine."Line No.";
                        Type := Type::Item;
                        "No." := TransferShipmentLine."Item No.";
                        "Variant Code" := TransferShipmentLine."Variant Code";
                        Description := TransferShipmentLine.Description;
                        "Unit of Measure Code" := TransferShipmentLine."Unit of Measure Code";
                        Quantity := TransferShipmentLine.Quantity;
                        "Line Weight" := TransferShipmentLine."Gross Weight" * Quantity;
                        "Line Volume" := TransferShipmentLine."Unit Volume" * Quantity;
                        EShipAgentService.Get(NAPCBOLHeader."Shipping Agent Code",NAPCBOLHeader."E-Ship Agent Service",
                                              TransferShipmentHeader."World Wide Service");
                        if Type = Type::Item then
                          AssignBOLCode;
                      end;
                    end;

                end;
            end;
        }
        field(23;"Source Doc. Line No.";Integer)
        {
        }
        field(30;Type;Option)
        {
            OptionCaption = 'Item,Resource';
            OptionMembers = Item,Resource;
        }
        field(31;"No.";Code[20])
        {
            TableRelation = if (Type=const(Item)) Item."No." else if (Type=const(Resource)) Resource."No.";

            trigger OnValidate();
            begin
                case Type of
                  Type::Item: AssignBOLCode;
                  Type::Resource: GetResource;
                end;
            end;
        }
        field(32;"Variant Code";Code[10])
        {
            TableRelation = if (Type=const(Item)) "Item Variant".Code where ("Item No."=field("No."));
        }
        field(33;Description;Text[50])
        {
            Editable = false;
        }
        field(34;"NAPC BOL Code";Code[20])
        {
            TableRelation = "ARC NAPC BOL".Code;
        }
        field(35;"Unit of Measure Code";Code[10])
        {
            TableRelation = if (Type=const(Item)) "Item Unit of Measure".Code where ("Item No."=field("No.")) 
            else if (Type=const(Resource)) "Resource Unit of Measure".Code where ("Resource No."=field("No."));

            trigger OnValidate();
            begin
                UpdateUOM;
            end;
        }
        field(36;Quantity;Decimal)
        {
            DecimalPlaces = 0:5;

            trigger OnValidate();
            begin
                UpdateUOM;
            end;
        }
        field(37;"Line Weight";Decimal)
        {
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(38;"Line Volume";Decimal)
        {
            DecimalPlaces = 0:5;
            Editable = false;
        }
    }

    keys
    {
        key(Key1;"Document No.","Line No.")
        {
        }
        key(Key2;"Source Doc. Type","Source Doc. No.","Source Doc. Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        SalesLine : Record "Sales Line";
        SalesShipmentLine : Record "Sales Shipment Line";
        TransferLine : Record "Transfer Line";
        PurchaseLine : Record "Purchase Line";
        ReturnShipmentLine : Record "Return Shipment Line";
        ReturnReceiptLine : Record "Return Receipt Line";
        TransferShipmentLine : Record "Transfer Shipment Line";
        NAPCBOLHeader : Record "ARC NAPC BOL Header";
        Item : Record Item;
        ItemUOM : Record "Item Unit of Measure";
        Resource : Record Resource;
        ResourceUOM : Record "Resource Unit of Measure";
        EShipAgentService : Record  "E-Ship Agent Service";
        SalesHeader : Record "Sales Header";
        SalesShipmentHeader : Record "Sales Shipment Header";
        TransferShipmentHeader : Record "Transfer Shipment Header";
        TargetSetup: Record "ARC Target Setup";
        UOMMgt : Codeunit "Unit of Measure Management";

        DocNo : Code[20];
        QtyPerUOM : Decimal;

    trigger OnInsert()
    begin
      GetBOLHeader;
      "Source Doc. Type" := NAPCBOLHeader."Source Doc. Type";
      "Source Doc. No." := NAPCBOLHeader."Source Doc. No.";
    end;
    procedure GetBOLHeader();
    begin
        if NAPCBOLHeader."No." <> "Document No." then
          NAPCBOLHeader.Get("Document No.");
    end;

    local procedure GetItem();
    begin
        TestField("No.");
        if Type = Type::Item then begin
          if "No." <> Item."No." then begin
            Item.Get("No.");
            Description := Item.Description;
            "Unit of Measure Code" := Item."Base Unit of Measure";
            QtyPerUOM := UOMMgt.GetQtyPerUnitOfMeasure(Item,"Unit of Measure Code");
            if "Line Weight" = 0 then
              "Line Weight" := Item."Gross Weight" * QtyPerUOM * Quantity;
            if "Line Volume" = 0 then
              "Line Volume" := Item."Unit Volume" * QtyPerUOM * Quantity;
          end;
        end;
    end;

    procedure GetResource();
    begin
        TestField("No.");
        if Type = Type::Resource then begin
          if "No." <> Resource."No." then begin
            Resource.Get("No.");
            Description := Resource.Name;
            "Unit of Measure Code" := Resource."Base Unit of Measure";
            QtyPerUOM := UOMMgt.GetResQtyPerUnitOfMeasure(Resource,"Unit of Measure Code");
            if "Line Weight" = 0 then
              "Line Weight" := Resource."Gross Weight" * QtyPerUOM * Quantity;
            if "Line Volume" = 0 then
              "Line Volume" := Resource."Unit Volume" * QtyPerUOM * Quantity;
          end;
        end;
    end;

    procedure UpdateUOM();
    begin
        case Type of
          Type::Item:
            begin
              GetItem;
              QtyPerUOM := UOMMgt.GetQtyPerUnitOfMeasure(Item,"Unit of Measure Code");
              "Line Weight" := Item."Gross Weight" * QtyPerUOM * Quantity;
              "Line Volume" := Item."Unit Volume" * QtyPerUOM * Quantity;
            end;
          Type::Resource:
            begin
              GetResource;
              QtyPerUOM := UOMMgt.GetResQtyPerUnitOfMeasure(Resource,"Unit of Measure Code");
              "Line Weight" := Resource."Gross Weight" * QtyPerUOM * Quantity;
              "Line Volume" := Resource."Unit Volume" * QtyPerUOM * Quantity;
            end;
        end;
    end;

    procedure AssignBOLCode();
    begin
        GetItem;
        if Item."ARC SDS Product Code" <> '' then begin
          Item.CalcFields("ARC BOL/UN/Air Code","ARC BOL/UN/Ground Code","ARC BOL/UN/Water Code");
          if "Source Doc. Type" = "Source Doc. Type"::" " then begin
            GetBOLHeader;
            if EShipAgentService.Get(NAPCBOLHeader."Shipping Agent Code",NAPCBOLHeader."E-Ship Agent Service",
                                      TransferShipmentHeader."World Wide Service") then begin
              case EShipAgentService."Transport Method Type" of
                EShipAgentService."Transport Method Type"::Air:
                  "NAPC BOL Code" := Item."ARC BOL/UN/Air Code";
                EShipAgentService."Transport Method Type"::Ground:
                  "NAPC BOL Code" := Item."ARC BOL/UN/Ground Code";
                EShipAgentService."Transport Method Type"::Water:
                  "NAPC BOL Code" := Item."ARC BOL/UN/Water Code";
                else
                  "NAPC BOL Code" := Item."ARC BOL/UN/Ground Code";
              end;
            end else begin
              Clear(EShipAgentService);
              "NAPC BOL Code" := Item."ARC BOL/UN/Ground Code";
            end;
          end else begin
            case EShipAgentService."Transport Method Type" of
              EShipAgentService."Transport Method Type"::Air:
                "NAPC BOL Code" := Item."ARC BOL/UN/Air Code";
              EShipAgentService."Transport Method Type"::Ground:
                "NAPC BOL Code" := Item."ARC BOL/UN/Ground Code";
              EShipAgentService."Transport Method Type"::Water:
                "NAPC BOL Code" := Item."ARC BOL/UN/Water Code";
              else
                "NAPC BOL Code" := Item."ARC BOL/UN/Ground Code";
            end;
          end;
        end else begin
          TargetSetup.Get();
          "NAPC BOL Code" := TargetSetup."Unregulated Product BOL Code";
        end;
    end;
}
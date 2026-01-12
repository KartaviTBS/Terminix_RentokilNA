table 50037 "ARC NAPC BOL Header"
{
    Caption = 'NAPC BOL Header';
    DrillDownPageID = 50048;
    LookupPageID = 50048;

    fields
    {
        field(1;"No.";Code[20])
        {

            trigger OnValidate();
            begin
                if "No." <> xRec."No." then begin
                  GetTargetSetup;
                  NoSeriesMgt.TestManual(TargetSetUp."NAPC BOL Nos.");
                  "No. Series" := '';
                end;
            end;
        }
        field(5;"Source Doc. Type";Option)
        {
            OptionCaption = '" ,Sales Order,,,,Sales Shipment,,,Transfer Shipment"';
            OptionMembers = " ","Sales Order","Sales Return Order","Transfer Order","Purchase Return Order","Sales Shipment","Return Shipment","Return Receipt","Transfer Shipment";
        }
        field(6;"Source Doc. No.";Code[20])
        {

            trigger OnLookup();
            var
                SalesHeader : Record "Sales Header";
                SalesShipmentHeader : Record "Sales Shipment Header";
                TransferShipmentHeader : Record "Transfer Shipment Header";
                PostedSalesShipments: Page "Posted Sales Shipments";
                PostedTransferShipments: Page "Posted Transfer Shipments";

            begin
                TestField("Source Doc. Type");
                case "Source Doc. Type" of
                  "Source Doc. Type"::"Sales Shipment":
                    begin
                      SalesShipmentHeader.SetRange("ARC NAPC Bill of Lading No.",'');
                      Clear(PostedSalesShipments);
                      PostedSalesShipments.LookupMode := true;
                      PostedSalesShipments.SetTableView(SalesShipmentHeader);
                      if PostedSalesShipments.RunModal = Action::LookupOK then begin
                        PostedSalesShipments.GetRecord(SalesShipmentHeader);
                        "Source Doc. No." := SalesShipmentHeader."No.";
                        "Posting Date" := SalesShipmentHeader."Posting Date";
                        "Shipping Agent Code" := SalesShipmentHeader."Shipping Agent Code";
                        "E-Ship Agent Service" := SalesShipmentHeader."E-Ship Agent Service";
                        "Ship-to Type" := "Ship-to Type"::Customer;
                        "Ship-to Source No." := SalesShipmentHeader."Sell-to Customer No.";
                        "Ship-to Code" := SalesShipmentHeader."Ship-to Code";
                        
                        "Ship-to Name" := SalesShipmentHeader."Ship-to Name";
                        "Ship-to Name 2" := SalesShipmentHeader."Ship-to Name 2";
                        "Ship-to Address" := SalesShipmentHeader."Ship-to Address";
                        "Ship-to Address 2" := SalesShipmentHeader."Ship-to Address 2";
                        "Ship-to City" := SalesShipmentHeader."Ship-to City";
                        "Ship-to County" := SalesShipmentHeader."Ship-to County";
                        "Ship-to Post Code" := SalesShipmentHeader."Ship-to Post Code";
                        "Ship-to Country/Region Code" := SalesShipmentHeader."Ship-to Country/Region Code";
                        "Ship-to Contact" := SalesShipmentHeader."Ship-to Contact";
                        "Ship-to Phone No." := SalesShipmentHeader."Ship-to Phone No. -CL-";
                      end;
                    end;

                  "Source Doc. Type"::"Transfer Shipment":
                    begin
                      TransferShipmentHeader.SetRange("ARC NAPC Bill of Lading No.",'');
                      Clear(PostedTransferShipments);
                      PostedTransferShipments.LookupMode := true;
                      PostedTransferShipments.SetTableView(TransferShipmentHeader);
                      if PostedTransferShipments.RunModal = Action::LookupOK then begin
                        PostedTransferShipments.GetRecord(TransferShipmentHeader);
                        "Source Doc. No." := TransferShipmentHeader."No.";
                        "Posting Date" := TransferShipmentHeader."Posting Date";
                        "Shipping Agent Code" := TransferShipmentHeader."Shipping Agent Code";
                        "E-Ship Agent Service" := TransferShipmentHeader."E-Ship Agent Service";
                        "Ship-to Type" := "Ship-to Type"::Location;
                        "Ship-to Source No." := TransferShipmentHeader."Transfer-to Code";
                        "Ship-to Code" := TransferShipmentHeader."Transfer-to Code";
                        "Ship-to Name" := TransferShipmentHeader."Transfer-to Name";
                        "Ship-to Name 2" := TransferShipmentHeader."Transfer-to Name 2";
                        "Ship-to Address" := TransferShipmentHeader."Transfer-to Address";
                        "Ship-to Address 2" := TransferShipmentHeader."Transfer-to Address 2";
                        "Ship-to City" := TransferShipmentHeader."Transfer-to City";
                        "Ship-to County" := TransferShipmentHeader."Transfer-to County";
                        "Ship-to Post Code" := TransferShipmentHeader."Transfer-to Post Code";
                        "Ship-to Country/Region Code" := TransferShipmentHeader."Trsf.-to Country/Region Code";
                        "Ship-to Contact" := TransferShipmentHeader."Transfer-to Contact";
                        //"Ship-to Phone No." := TransferShipmentHeader."Transfer-to Phone No.";
                      end;
                    end;
                end;
            end;
        }
        field(10;"Posting Date";Date)
        {
        }
        field(11;"Shipping Agent Code";Code[10])
        {
            TableRelation = "Shipping Agent".Code;
        }
        field(12;"E-Ship Agent Service";Code[30])
        {
            TableRelation = "E-Ship Agent Service".code where ("Shipping Agent Code" = field("Shipping Agent Code"));
            
        }
        field(13;"Manifest No.";Code[20])
        {

            trigger OnLookup();
            var
             NAPCManifest: Record "ARC NAPC Manifest";
             NAPCManifestList: Page "ARC NAPC Manifest List";             
            begin
                NAPCManifest.Reset();
                NAPCManifest.SetRange("Shipping Agent Code","Shipping Agent Code");
                NAPCManifest.SetRange("E-Ship Agent Service","E-Ship Agent Service");
                Clear(NAPCManifestList);
                NAPCManifestList.Editable(false);
                NAPCManifestList.LookupMode(true);
                NAPCManifestList.SetTableView(NAPCManifest);
                if NAPCManifestList.RunModal = Action::LookupOK then begin
                  NAPCManifestList.GetRecord(NAPCManifest);
                  Validate("Manifest No.",NAPCManifest."No.");
                end;
            end;
        }
        field(20;"Ship-to Type";Option)
        {
            OptionCaption = '" ,Customer,Location,Vendor"';
            OptionMembers = " ",Customer,Location,Vendor;

            trigger OnValidate();
            begin
                if "Ship-to Type" <> xRec."Ship-to Type" then
                  Validate("Ship-to Source No.",'');
            end;
        }
        field(21;"Ship-to Source No.";Code[20])
        {
            TableRelation = if ("Ship-to Type" =const(Customer)) Customer."No." else if ("Ship-to Type"=const(Location)) 
            Location.Code where ("Use As in-Transit"= const(false)) else if ("Ship-to Type"=const(Vendor)) Vendor."No.";

            trigger OnValidate();
            begin
                if "Ship-to Source No." = '' then begin
                  "Ship-to Name" := '';
                  "Ship-to Name 2" := '';
                  "Ship-to Address" := '';
                  "Ship-to Address 2" := '';
                  "Ship-to City" := '';
                  "Ship-to Post Code" := '';
                  "Ship-to County" := '';
                  "Ship-to Country/Region Code" := '';
                  "Ship-to Phone No." := '';
                  "Ship-to Contact" := '';
                end;

                case "Ship-to Type" of
                  "Ship-to Type"::Customer:
                    begin
                      GetCust("Ship-to Source No.");
                      "Ship-to Name" := Cust.Name;
                      "Ship-to Name 2" := Cust."Name 2";
                      "Ship-to Address" := Cust.Address;
                      "Ship-to Address 2" := Cust."Address 2";
                      "Ship-to City" := Cust.City;
                      "Ship-to Post Code" := Cust."Post Code";
                      "Ship-to County" := Cust.County;
                      "Ship-to Country/Region Code" := Cust."Country/Region Code";
                      "Ship-to Phone No." := Cust."Phone No.";
                      "Ship-to Contact" := Cust.Contact;
                    end;
                  "Ship-to Type"::Location:
                    begin
                      GetLocation("Ship-to Source No.");
                      "Ship-to Name" := Location.Name;
                      "Ship-to Name 2" := Location."Name 2";
                      "Ship-to Address" := Location.Address;
                      "Ship-to Address 2" := Location."Address 2";
                      "Ship-to City" := Location.City;
                      "Ship-to Post Code" := Location."Post Code";
                      "Ship-to County" := Location.County;
                      "Ship-to Country/Region Code" := Location."Country/Region Code";
                      "Ship-to Phone No." := Location."Phone No.";
                      "Ship-to Contact" := Location.Contact;
                    end;
                  "Ship-to Type"::Vendor:
                    begin
                      GetVendor("Ship-to Source No.");
                      "Ship-to Name" := Vendor.Name;
                      "Ship-to Name 2" := Vendor."Name 2";
                      "Ship-to Address" := Vendor.Address;
                      "Ship-to Address 2" := Vendor."Address 2";
                      "Ship-to City" := Vendor.City;
                      "Ship-to Post Code" := Vendor."Post Code";
                      "Ship-to County" := Vendor.County;
                      "Ship-to Country/Region Code" := Vendor."Country/Region Code";
                      "Ship-to Phone No." := Vendor."Phone No.";
                      "Ship-to Contact" := Vendor.Contact;
                    end;
                end;
            end;
        }
        field(22;"Ship-to Code";Code[10])
        {
            TableRelation = if ("Ship-to Type"=const(Customer)) "Ship-to Address".Code where ("Customer No."=field("Ship-to Source No.")) 
            else if ("Ship-to Type"=const(Vendor)) "Order Address".Code where ("Vendor No."=field("Ship-to Source No."));

            trigger OnValidate();
            begin
                if "Ship-to Source No." = '' then
                  exit;

                case "Ship-to Type" of
                  "Ship-to Type"::Customer:
                    begin
                      GetShipTo("Ship-to Code","Ship-to Source No.");
                      "Ship-to Name" := ShipTo.Name;
                      "Ship-to Name 2" := ShipTo."Name 2";
                      "Ship-to Address" := ShipTo.Address;
                      "Ship-to Address 2" := ShipTo."Address 2";
                      "Ship-to City" := ShipTo.City;
                      "Ship-to Post Code" := ShipTo."Post Code";
                      "Ship-to County" := ShipTo.County;
                      "Ship-to Country/Region Code" := ShipTo."Country/Region Code";
                      "Ship-to Phone No." := ShipTo."Phone No.";
                      "Ship-to Contact" := ShipTo.Contact;
                    end;
                  "Ship-to Type"::Vendor:
                    begin
                      GetOrderAddress("Ship-to Code","Ship-to Source No.");
                      "Ship-to Name" := OrderAddress.Name;
                      "Ship-to Name 2" := OrderAddress."Name 2";
                      "Ship-to Address" := OrderAddress.Address;
                      "Ship-to Address 2" := OrderAddress."Address 2";
                      "Ship-to City" := OrderAddress.City;
                      "Ship-to Post Code" := OrderAddress."Post Code";
                      "Ship-to County" := OrderAddress.County;
                      "Ship-to Country/Region Code" := OrderAddress."Country/Region Code";
                      "Ship-to Phone No." := OrderAddress."Phone No.";
                      "Ship-to Contact" := OrderAddress.Contact;
                    end;
                end;
            end;
        }
        field(23;"Ship-to Name";Text[50])
        {
            CaptionML = ENU='Ship-to Name',
                        ESM='Envío a-Nombre',
                        FRC='Nom du destinataire',
                        ENC='Ship-to Name';
        }
        field(24;"Ship-to Name 2";Text[50])
        {
            CaptionML = ENU='Ship-to Name 2',
                        ESM='Envío a-Nombre 2',
                        FRC='Nom du destinataire 2',
                        ENC='Ship-to Name 2';
        }
        field(25;"Ship-to Address";Text[50])
        {
            CaptionML = ENU='Ship-to Address',
                        ESM='Envío a-Dirección',
                        FRC='Adresse (destinataire)',
                        ENC='Ship-to Address';
        }
        field(26;"Ship-to Address 2";Text[50])
        {
            CaptionML = ENU='Ship-to Address 2',
                        ESM='Envío a-Colonia',
                        FRC='Adresse  2 (destinataire)',
                        ENC='Ship-to Address 2';
        }
        field(27;"Ship-to City";Text[30])
        {
            CaptionML = ENU='Ship-to City',
                        ESM='Envío a-Municipio/Ciudad',
                        FRC='Ville (destinataire)',
                        ENC='Ship-to City';

            trigger OnLookup();
            begin
                PostCode.LookupPostCode("Ship-to City","Ship-to Post Code",
                                   "Ship-to County","Ship-to Country/Region Code");
            end;

            trigger OnValidate();
            begin
                PostCode.ValidateCity("Ship-to City","Ship-to Post Code",
                                     "Ship-to County","Ship-to Country/Region Code",(CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(28;"Ship-to County";Text[30])
        {
            CaptionML = ENU='Ship-to State',
                        ESM='Envío a-Provincia',
                        FRC='Comté destinataire',
                        ENC='Ship-to Province/State';
            TableRelation = "ARC County".Code where ("Country/Region Code" = field("Ship-from Country/Region Code"));
        }
        field(29;"Ship-to Post Code";Code[20])
        {
            CaptionML = ENU='Ship-to ZIP Code',
                        ESM='Envío a-C.P.',
                        FRC='Code postal destinataire',
                        ENC='Ship-to Postal/ZIP Code';
            TableRelation = "Post Code";
            ValidateTableRelation = false;

            trigger OnLookup();
            begin
                 PostCode.LookUpPostCode("Ship-to City","Ship-to Post Code",
                                         "Ship-to County","Ship-to Country/Region Code");
            end;

            trigger OnValidate();
            begin
                 PostCode.ValidatePostCode("Ship-to City","Ship-to Post Code",
                                           "Ship-to County","Ship-to Country/Region Code",(CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(30;"Ship-to Country/Region Code";Code[10])
        {
            CaptionML = ENU='Ship-to Country/Region Code',
                        ESM='Envío a-Cód. país/región',
                        FRC='Code pays/région (destinataire)',
                        ENC='Ship-to Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(31;"Ship-to Contact";Text[50])
        {
            CaptionML = ENU='Ship-to Contact',
                        ESM='Envío a-Atención',
                        FRC='Contact destinataire',
                        ENC='Ship-to Contact';
        }
        field(32;"Ship-to Phone No.";Text[30])
        {
        }
        field(40;"Ship-from Type";Option)
        {
            OptionCaption = '" ,Customer,Location,Vendor"';
            OptionMembers = " ",Customer,Location,Vendor;

            trigger OnValidate();
            begin
                if "Ship-from Type" <> xRec."Ship-from Type" then
                  Validate("Ship-from Source No.",'');
            end;
        }
        field(41;"Ship-from Source No.";Code[20])
        {
            TableRelation = if ("Ship-from Type"=const(Customer)) Customer."No." else if ("Ship-from Type"=const(Location)) 
            Location.Code where ("Use As in-Transit"=const(false)) else if ("Ship-from Type"=const(Vendor)) Vendor."No.";

            trigger OnValidate();
            begin
                if "Ship-from Source No." = '' then begin
                  "Ship-from Name" := '';
                  "Ship-from Name 2" := '';
                  "Ship-from Address" := '';
                  "Ship-from Address 2" := '';
                  "Ship-from City" := '';
                  "Ship-from Post Code" := '';
                  "Ship-from County" := '';
                  "Ship-from Country/Region Code" := '';
                  "Ship-from Phone No." := '';
                  "Ship-from Contact" := '';
                end;

                case "Ship-from Type" of
                  "Ship-from Type"::Customer:
                    begin
                      GetCust("Ship-from Source No.");
                      "Ship-from Name" := Cust.Name;
                      "Ship-from Name 2" := Cust."Name 2";
                      "Ship-from Address" := Cust.Address;
                      "Ship-from Address 2" := Cust."Address 2";
                      "Ship-from City" := Cust.City;
                      "Ship-from Post Code" := Cust."Post Code";
                      "Ship-from County" := Cust.County;
                      "Ship-from Country/Region Code" := Cust."Country/Region Code";
                      "Ship-from Phone No." := Cust."Phone No.";
                      "Ship-from Contact" := Cust.Contact;
                    end;
                  "Ship-from Type"::Location:
                    begin
                      GetLocation("Ship-from Source No.");
                      "Ship-from Name" := Location.Name;
                      "Ship-from Name 2" := Location."Name 2";
                      "Ship-from Address" := Location.Address;
                      "Ship-from Address 2" := Location."Address 2";
                      "Ship-from City" := Location.City;
                      "Ship-from Post Code" := Location."Post Code";
                      "Ship-from County" := Location.County;
                      "Ship-from Country/Region Code" := Location."Country/Region Code";
                      "Ship-from Phone No." := Location."Phone No.";
                      "Ship-from Contact" := Location.Contact;
                    end;
                  "Ship-from Type"::Vendor:
                    begin
                      GetVendor("Ship-from Source No.");
                      "Ship-from Name" := Vendor.Name;
                      "Ship-from Name 2" := Vendor."Name 2";
                      "Ship-from Address" := Vendor.Address;
                      "Ship-from Address 2" := Vendor."Address 2";
                      "Ship-from City" := Vendor.City;
                      "Ship-from Post Code" := Vendor."Post Code";
                      "Ship-from County" := Vendor.County;
                      "Ship-from Country/Region Code" := Vendor."Country/Region Code";
                      "Ship-from Phone No." := Vendor."Phone No.";
                      "Ship-from Contact" := Vendor.Contact;
                    end;
                end;
            end;
        }
        field(42;"Ship-from Code";Code[10])
        {
            TableRelation = if ("Ship-from Type"=const(Customer)) "Ship-to Address".Code where ("Customer No."= field("Ship-from Source No.")) 
            else if ("Ship-from Type"=const(Vendor)) "Order Address".Code where ("Vendor No."=field("Ship-from Source No."));

            trigger OnValidate();
            begin
                if "Ship-from Source No." = '' then
                  exit;

                case "Ship-from Type" of
                  "Ship-from Type"::Customer:
                    begin
                      GetShipTo("Ship-from Code","Ship-from Source No.");
                      "Ship-from Name" := ShipTo.Name;
                      "Ship-from Name 2" := ShipTo."Name 2";
                      "Ship-from Address" := ShipTo.Address;
                      "Ship-from Address 2" := ShipTo."Address 2";
                      "Ship-from City" := ShipTo.City;
                      "Ship-from Post Code" := ShipTo."Post Code";
                      "Ship-from County" := ShipTo.County;
                      "Ship-from Country/Region Code" := ShipTo."Country/Region Code";
                      "Ship-from Phone No." := ShipTo."Phone No.";
                      "Ship-from Contact" := ShipTo.Contact;
                    end;
                  "Ship-from Type"::Vendor:
                    begin
                      GetOrderAddress("Ship-from Code","Ship-from Source No.");
                      "Ship-from Name" := OrderAddress.Name;
                      "Ship-from Name 2" := OrderAddress."Name 2";
                      "Ship-from Address" := OrderAddress.Address;
                      "Ship-from Address 2" := OrderAddress."Address 2";
                      "Ship-from City" := OrderAddress.City;
                      "Ship-from Post Code" := OrderAddress."Post Code";
                      "Ship-from County" := OrderAddress.County;
                      "Ship-from Country/Region Code" := OrderAddress."Country/Region Code";
                      "Ship-from Phone No." := OrderAddress."Phone No.";
                      "Ship-from Contact" := OrderAddress.Contact;
                    end;
                end;
            end;
        }
        field(43;"Ship-from Name";Text[50])
        {
        }
        field(44;"Ship-from Name 2";Text[50])
        {
        }
        field(45;"Ship-from Address";Text[50])
        {
        }
        field(46;"Ship-from Address 2";Text[50])
        {
        }
        field(47;"Ship-from City";Text[30])
        {

            trigger OnLookup();
            begin
                PostCode.LookUpPostCode("Ship-from City","Ship-from Post Code",
                                     "Ship-from County","Ship-from Country/Region Code");
            end;

            trigger OnValidate();
            begin
                PostCode.ValidateCity("Ship-from City","Ship-from Post Code",
                                      "Ship-from County","Ship-from Country/Region Code",(CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(48;"Ship-from County";Text[30])
        {
            Caption = 'Ship-from State';
            TableRelation = "ARC County".Code where ("Country/Region Code" = field("Ship-from Country/Region Code"));
        }
        
        field(49; "Ship-from Post Code"; Code[20])
        {
            Caption = 'Ship-from ZIP Code';
            TableRelation = "Post Code";
            ValidateTableRelation = false;

            trigger OnLookup();
            begin
                
                PostCode.LookUpPostCode("Ship-from City","Ship-from Post Code",
                                        "Ship-from County","Ship-from Country/Region Code");
            end;

            trigger OnValidate();
            begin
                PostCode.ValidatePostCode("Ship-from City","Ship-from Post Code",
                                           "Ship-from County","Ship-from Country/Region Code",(CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(50;"Ship-from Country/Region Code";Code[10])
        {
            TableRelation = "Country/Region";
        }
        field(51;"Ship-from Contact";Text[50])
        {
        }
        field(52;"Ship-from Phone No.";Text[30])
        {
        }
        field(60;"No. Series";Code[10])
        {
            CaptionML = ENU='No. Series',
                        ESM='Nos. serie',
                        FRC='Séries de n°',
                        ENC='No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        NAPCBOLLine.SetRange("Document No.","No.");
        NAPCBOLLine.DeleteAll();
        NAPCBOLSummaryLine.SetRange("NAPC BOL Document No.","No.");
        NAPCBOLSummaryLine.DeleteAll();
    end;

    trigger OnInsert();
    begin
        if "No." = '' then begin
          GetTargetSetup;
          TargetSetUp.TestField("NAPC BOL Nos.");
          NoSeriesMgt.InitSeries(TargetSetup."NAPC BOL Nos.",xRec."No. Series",0D,"No.","No. Series");
        end;
    end;

    trigger OnRename();
    begin
        NAPCBOLLine.SetRange("Document No.","No.");
        if not NAPCBOLLine.IsEmpty() then
          Error(Text001);
        NAPCBOLSummaryLine.SetRange("NAPC BOL Document No.","No.");
        if not NAPCBOLSummaryLine.IsEmpty() then
          Error(Text001);
    end;

    var
        NoSeriesMgt : Codeunit NoSeriesManagement;
        PostCode : Record "Post Code";
        Cust : Record Customer;
        Vendor : Record Vendor;
        Location : Record Location;
        ShipTo : Record "Ship-to Address";
        OrderAddress : Record "Order Address";
        NAPCManifest : Record "ARC NAPC Manifest";
        TargetSetUp: Record "ARC Target Setup";
        NAPCBOLLine : Record "ARC NAPC BOL Line";
        NAPCBOLSummaryLine : Record "ARC NAPC BOL Summary Line";
        Text001 : Label 'Rename not allowed';

    procedure GetTargetSetup();
    begin
        TargetSetUp.Get;
    end;

    local procedure GetCust(CustNo : Code[20]);
    begin
        if CustNo <> '' then begin
          if CustNo <> Cust."No." then
            Cust.Get(CustNo);
        end else
          Clear(Cust);
    end;

    local procedure GetLocation(LocationCode : Code[10]);
    begin
        if LocationCode <> '' then begin
          if LocationCode <> Location.Code then
            Location.Get(LocationCode);
        end else
          Clear(Location);
    end;

    local procedure GetVendor(VendorNo : Code[20]);
    begin
        if VendorNo <> '' then begin
          if VendorNo <> Vendor."No." then
            Vendor.Get(VendorNo);
        end else
          Clear(Vendor);
    end;

    local procedure GetShipTo(ShipToCode : Code[10];SourceNo : Code[20]);
    begin
        if ShipToCode <> '' then begin
          if (ShipToCode <> ShipTo.Code) and (ShipTo."Customer No." <> SourceNo) then
            ShipTo.Get(SourceNo,ShipToCode);
        end else
          Clear(ShipTo);
    end;

    local procedure GetOrderAddress(OrderAddressCode : Code[10];SourceNo : Code[20]);
    begin
        if OrderAddressCode <> '' then begin
          if (OrderAddressCode <> OrderAddress.Code) and (OrderAddress."Vendor No." <> SourceNo) then
            OrderAddress.Get(SourceNo,OrderAddressCode);
        end else
          Clear(OrderAddress);
    end;


}
report 50014 "ARC NAPC BOL Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/NAPCBOL.Report.rdl';
    Caption = 'BOL Sales Report';
    UsageCategory = Administration;

    dataset
    {
        dataitem("Sales Shipment Header"; "Sales Shipment Header")
        {
            RequestFilterFields = "No.";

            column(No_ShipmentHeader; "No.") { }
            column(ShipToAddress1; ShipToAddress[1]) { }
            column(ShipToAddress2; ShipToAddress[2]) { }
            column(ShipToAddress3; ShipToAddress[3]) { }
            column(ShipToAddress4; ShipToAddress[4]) { }
            column(ShipToAddress5; ShipToAddress[5]) { }
            column(ShipToAddress6; ShipToAddress[6]) { }
            column(ShipToAddress7; ShipToAddress[7]) { }
            column(ShipToAddress8; ShipToAddress[8]) { }
            column(ShipFromAddress1; ShipFromAddress[1]) { }
            column(ShipFromAddress2; ShipFromAddress[2]) { }
            column(ShipFromAddress3; ShipFromAddress[3]) { }
            column(ShipFromAddress4; ShipFromAddress[4]) { }
            column(ShipFromAddress5; ShipFromAddress[5]) { }
            column(ShipFromAddress6; ShipFromAddress[6]) { }
            column(ShipFromAddress7; ShipFromAddress[7]) { }
            column(ShipFromAddress8; ShipFromAddress[8]) { }
            column(Order_No_; "Order No.") { }
            column(Location_Code; "Location Code") { }
            column(ShippingNote; ShippingNote) { }




            dataitem("ARC NAPC BOL Header"; "ARC NAPC BOL Header")
            {
                DataItemLinkReference = "Sales Shipment Header";
                DataItemTableView = sorting("No.");

                column(BOLHeaderNo_; "No.") { }
                column(Manifest_No_; "Manifest No.") { }
                column(Customer_No_; "Ship-to Source No.") { }
                column(Ship_to_Code; "Ship-to Code") { }




                dataitem("ARC NAPC BOL Summary Line"; "ARC NAPC BOL Summary Line")
                {

                    DataItemLink = "NAPC BOL Document No." = field("No.");
                    DataItemLinkReference = "ARC NAPC BOL Header";
                    DataItemTableView = sorting("NAPC BOL Document No.", "NAPC BOL Code");


                    column(LineQty; "Line Quantity") { }
                    column(Unit_of_Measure_Code; "Unit of Measure Code") { }
                    column(HazMat; HazMat) { }
                    column(FirstDesc; FirstDesc) { }
                    column(Line_Weight; Round("Line Weight")) { }
                    column(NAPC_BOL_Code; "NAPC BOL Code") { }
                    column(TotalWt; TotalWt) { }



                    dataitem("ARC NAPC BOL Comment Line"; "ARC NAPC BOL Comment Line")
                    {

                        DataItemLinkReference = "ARC NAPC BOL Summary Line";
                        DataItemLink = Code = FIELD("NAPC BOL Code");
                        DataItemTableView = sorting(Code, "Line No.");

                        column(Comment; Comment) { }
                        column(BOLCommentCode; Code) { }
                        column(Cmt_Line_No_; "Line No.") { }

                        trigger OnAfterGetRecord()
                        begin
                            if FirstRec then begin
                                FirstRec := false;
                                CurrReport.Skip();
                            end;
                            LineCnt += 1;
                        end;
                    }

                    dataitem(Integer; Integer)
                    {
                        DataItemLinkReference = "ARC NAPC BOL Header";

                        column(PlacardText; PlacardText) { }


                        trigger OnPreDataItem()
                        begin

                            PlacardCnt := TempPlacard.Count();
                            if PlacardCnt = 0 then begin
                                PlacardCnt := 1;
                                TempPlacard.Init();
                                TempPlacard.Code := 'NONE';
                                TempPlacard."Class Description" := 'NONE';
                                TempPlacard.Insert();
                            end;
                            if PlacardCnt = 1 then
                                SetRange(Number, 1)
                            else
                                SetRange(Number, 1, PlacardCnt);

                            PlacardCnt := 1;
                            Clear(PlacardArray);
                            if TempPlacard.FindSet() then
                                repeat
                                    PlacardArray[PlacardCnt] := TempPlacard."Class Description";
                                    PlacardCnt += 1;
                                until TempPlacard.Next = 0;

                        end;

                        trigger OnAfterGetRecord()
                        begin
                            IF "ARC NAPC BOL Summary Line".Count = 0 THEN
                                CurrReport.Skip;
                            PlacardText := PlacardArray[Number];
                        end;

                    }


                    trigger OnPostDataItem();
                    begin
                        NAPCBOLHeader.Get("ARC NAPC BOL Header"."No.");
                        LineCnt := 0;
                    end;

                    trigger OnAfterGetRecord();
                    var
                        NAPCBOLCommRec: Record "ARC NAPC BOL Comment Line";
                    begin
                        TotalWt += "Line Weight";
                        NAPCBOLCommentLine.Reset();
                        NAPCBOLCommentLine.SetRange(Code, "NAPC BOL Code");
                        ComCnt := NAPCBOLCommentLine.Count();
                        if ComCnt > 1 then
                            LineCnt += 1;
                        if (LineCnt + ComCnt) > 40 then begin
                            //CurrReport.NewPage;
                            LineCnt := 0;
                        end;

                        if "Placard Code" <> '' then begin
                            Placard.Get("Placard Code");
                            TempPlacard := Placard;
                            if not TempPlacard.Insert() then;
                        end;

                        NAPCBOLCommRec.SetFilter(Code, "NAPC BOL Code");
                        if NAPCBOLCommRec.FindFirst() then
                            FirstDesc := NAPCBOLCommRec.Comment
                        else
                            FirstDesc := Description;

                        FirstRec := true;
                        LineCnt += 1;

                    end;

                }


                trigger OnPreDataItem();
                begin
                    "Sales Shipment Header".CalcFields("ARC NAPC Bill of Lading No.");
                    SetRange("No.", "Sales Shipment Header"."ARC NAPC Bill of Lading No.");
                end;

                trigger OnAfterGetRecord();
                begin
                    TempPlacard.DeleteAll();
                end;


            }

            trigger OnAfterGetRecord()
            var
                myInt: Integer;
            begin
                CreateNAPCBOLHeader;

            end;
        }
    }

    labels
    {
        PackagesNoCaption = 'Packages No.';
        UOMCaption = 'UOM';
        HMCaption = 'HM';
        DescriptionCaption = 'Description';
        TotalLBSCaption = 'Total LBS';
        BOLCaption = 'BOL';
        BillOfLadingHeader = 'BILL OF LADING';
        CertifyText = 'This is to certify that the above named materials are properly classified, described, packaged, marked, and labeled and are in proper condition for transportation according to the applicable regulations of the Department of Transportation.';
        RecommendText = 'NO RECOMMENDATION HAS BEEN MADE CONCERNING THE USE OF THE PRODUCTS ON THIS INVOICE.  PLEASE OBTAIN AUTHORIZATION PRIOR TO RETURNING GOODS.  ALL RETURNED GOODS SUBJECT TO A RESTOCKING CHARGE.  A SERVICE CHARGE OF 1.5% PER MONTH WILL BE APPLIED TO ALL PAST DUE ACCOUNTS.';
        InstructionText = 'KEEP PESTICIDES LOCKED UP, READ AND FOLLOW LABEL INSTRUCTIONS';
        DomesticEmerText = 'For domestic emergency assistance involving hazardous chemicals CALL CHEMTREC at 800-424-9300. For international assistance call 800-262-8200 (Option 1).';


    }

    local procedure CreateNAPCBOLHeader();
    begin
        with "Sales Shipment Header" do begin
            CalcFields("ARC NAPC Bill of Lading No.");
            if "ARC NAPC Bill of Lading No." = '' then begin
                NAPCBOLHeader.Init();
                NAPCBOLHeader."No." := '';
                NAPCBOLHeader.Insert(true);
                NAPCBOLHeader."Source Doc. Type" := NAPCBOLHeader."Source Doc. Type"::"Sales Shipment";
                NAPCBOLHeader."Source Doc. No." := "No.";
                NAPCBOLHeader."Posting Date" := "Posting Date";
                NAPCBOLHeader."Shipping Agent Code" := "Shipping Agent Code";
                NAPCBOLHeader."E-Ship Agent Service" := "E-Ship Agent Service";
                NAPCBOLHeader."Ship-to Type" := NAPCBOLHeader."Ship-to Type"::Customer;
                NAPCBOLHeader."Ship-to Source No." := "Sell-to Customer No.";
                NAPCBOLHeader."Ship-to Code" := "Ship-to Code";
                NAPCBOLHeader."Ship-to Name" := "Ship-to Name";
                NAPCBOLHeader."Ship-to Name 2" := "Ship-to Name 2";
                NAPCBOLHeader."Ship-to Address" := "Ship-to Address";
                NAPCBOLHeader."Ship-to Address 2" := "Ship-to Address 2";
                NAPCBOLHeader."Ship-to City" := "Ship-to City";
                NAPCBOLHeader."Ship-to County" := "Ship-to County";
                NAPCBOLHeader."Ship-to Post Code" := "Ship-to Post Code";
                NAPCBOLHeader."Ship-to Country/Region Code" := "Ship-to Country/Region Code";
                NAPCBOLHeader."Ship-to Contact" := "Ship-to Contact";
                NAPCBOLHeader."Ship-to Phone No." := "Ship-to Phone No. -CL-";
                NAPCBOLHeader."Ship-from Type" := NAPCBOLHeader."Ship-from Type"::Location;
                NAPCBOLHeader.Validate("Ship-from Source No.", "Location Code");
                NAPCBOLHeader.Modify();
                HazMatOnly := NAPCBOLHeader."Shipping Agent Code" in ['UPS', 'DELIVERY', 'PICKUP'];
                NAPCBOLManagement.GetSourceLines(NAPCBOLHeader."Source Doc. Type", NAPCBOLHeader."Source Doc. No.", NAPCBOLHeader);
                NAPCBOLManagement.BuildBOLSummaryLines(NAPCBOLHeader."No.", TempNAPCBOLSummaryLine);
                NAPCBOLManagement.SetAlternateBOLCodes(TempNAPCBOLSummaryLine, HazMatOnly);
                if TempNAPCBOLSummaryLine.FindSet() then begin
                    NAPCBOLSummaryLine.SetRange("NAPC BOL Document No.", NAPCBOLHeader."No.");
                    if not NAPCBOLSummaryLine.IsEmpty() then begin
                        NAPCBOLSummaryLine.DeleteAll();
                        Commit();
                    end;
                    repeat
                        NAPCBOLSummaryLine.Init();
                        NAPCBOLSummaryLine := TempNAPCBOLSummaryLine;
                        NAPCBOLSummaryLine.Insert();
                    until TempNAPCBOLSummaryLine.Next = 0;
                    Commit();
                end;
            end else begin
                NAPCBOLHeader.Get("ARC NAPC Bill of Lading No.");
                HazMatOnly := NAPCBOLHeader."Shipping Agent Code" in ['UPS', 'DELIVERY', 'PICKUP'];
                NAPCBOLManagement.BuildBOLSummaryLines(NAPCBOLHeader."No.", TempNAPCBOLSummaryLine);
                NAPCBOLManagement.SetAlternateBOLCodes(TempNAPCBOLSummaryLine, HazMatOnly);
                if TempNAPCBOLSummaryLine.FindSet() then begin
                    NAPCBOLSummaryLine.SetRange("NAPC BOL Document No.", NAPCBOLHeader."No.");
                    if not NAPCBOLSummaryLine.IsEmpty() then begin
                        NAPCBOLSummaryLine.DeleteAll();
                        Commit();
                    end;
                    repeat
                        NAPCBOLSummaryLine.Init();
                        NAPCBOLSummaryLine := TempNAPCBOLSummaryLine;
                        NAPCBOLSummaryLine.Insert();
                    until TempNAPCBOLSummaryLine.Next = 0;
                    Commit();
                end;
            end;
            CalcFields("ARC NAPC Bill of Lading No.");
            Clear(ShipToAddress);
            Clear(ShipFromAddress);
            FormatAddress.SalesShptShipTo(ShipToAddress, "Sales Shipment Header");
            if Location.Get("Location Code") then
                FormatAddress.Location(ShipFromAddress, Location);
            if ShipToAddr.Get("Sales Shipment Header"."Sell-to Customer No.", "Sales Shipment Header"."Ship-to Code") then
                ShippingNote := ShipToAddr."ARC Shipping Note";

        end;
    end;



    var
        NAPCBOLHeader: Record "ARC NAPC BOL Header";
        NAPCBOLSummaryLine: Record "ARC NAPC BOL Summary Line";
        TempNAPCBOLSummaryLine: Record "ARC NAPC BOL Summary Line" temporary;
        NAPCBOLCommentLine: Record "ARC NAPC BOL Comment Line";
        Placard: Record "ARC Placard";
        TempPlacard: Record "ARC Placard" temporary;
        Location: Record Location;
        ShipToAddr: Record "Ship-to Address";
        NAPCBOLManagement: Codeunit "ARC NAPC BOL Management";
        FormatAddress: Codeunit "ARC RNA Format Address";
        HazMatOnly: Boolean;
        ShipToAddress: array[8] of Text[50];
        ShipFromAddress: array[8] of Text[50];
        PlacardText: Text;
        ShippingNote: Text;
        PlacardArray: array[100] of Text[50];
        FirstDesc: Text;
        FirstRec: Boolean;
        LineCnt: Integer;
        ComCnt: Integer;
        PlacardCnt: Integer;
        TotalWt: Decimal;

}
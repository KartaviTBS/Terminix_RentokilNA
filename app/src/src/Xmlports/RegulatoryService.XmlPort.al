xmlport 50004 "ARC Regulatory Service"
{
    Caption = 'Regulatory Service';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/regulatoryservice';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(RootNodeName)
        {
            tableelement(OrderHeader; "Sales Header")
            {
                UseTemporary = true;
                AutoSave = false;
                fieldelement(OrderNo; OrderHeader."No.")
                {
                }

                fieldelement(CustomerNo; OrderHeader."Sell-to Customer No.")
                {
                }
                fieldelement(ShipToCode; OrderHeader."Ship-to Code")
                {

                }
                fieldelement(ShipToCountry; OrderHeader."Ship-to Country/Region Code")
                {

                }
                fieldelement(ShipToCounty; OrderHeader."Ship-to County")
                {

                }
                fieldelement(ShipToPostCode; OrderHeader."Ship-to Post Code")
                {

                }
                fieldelement(LocalityCode; OrderHeader."ARC Locality Code")
                {

                }
                fieldelement(BusTypeCode; OrderHeader."ARC Business Type Code")
                {

                }

                textelement(OrderLines)
                {
                    tableelement(OrderLine; "Sales Line")
                    {
                        LinkFields = "Document No." = FIELD ("No.");
                        LinkTable = OrderHeader;
                        UseTemporary = true;
                        AutoSave = false;

                        fieldelement(LineType; OrderLine.Type)
                        {

                        }
                        fieldelement(ItemNo; OrderLine."No.")
                        {

                        }
                        fieldelement(Qty; OrderLine."Quantity")
                        {

                        }
                        fieldelement(LocationCode; OrderLine."Location Code")
                        {

                        }
                        fieldelement(StatusCode; OrderLine."Dimension Set ID")
                        {


                        }
                        textelement(StatusMsg)
                        {
                            trigger OnBeforePassVariable();
                            begin
                                if OrderLine."Dimension Set ID" = 0 then
                                    StatusMsg := 'OK'
                                else
                                    StatusMsg := LText011;    
                            end;
                        }

                        trigger OnBeforeInsertRecord()
                        begin
                            InsertLine;
                            currXMLport.Skip;
                        end;
                        

                    }
                }
                trigger OnBeforeInsertRecord()
                begin
                    InsertHeader;
                    currXMLport.Skip;
                end;


            }
        }
    }

    local procedure InsertHeader();
    begin
        OrderHeader."Document Type" := OrderHeader."Document Type"::Order;
        OrderHeader.Insert;
    end;

    local procedure InsertLine();
    var
        RegulatoryMgt: Codeunit "ARC Regulatory Management";
        StatusMsg: Text;
    begin
        LineNo += 10000;
        OrderLine."Document Type" := OrderHeader."Document Type";
        OrderLine."Document No." := OrderHeader."No.";
        OrderLine."Line No." := LineNo;
        StatusMsg := RegulatoryMgt.PortalTest(1,OrderHeader."Sell-to Customer No.",OrderHeader."Ship-to Code",OrderHeader."Ship-to Country/Region Code",
                OrderHeader."Ship-to County",OrderHeader."Ship-to Post Code",OrderHeader."ARC Locality Code",
                OrderHeader."ARC Business Type Code",OrderLine."No.",OrderLine."Unit of Measure Code",OrderLine."Location Code",0);
        
        If StatusMsg = 'OK' then
            OrderLine."Dimension Set ID" := 0
        else
            OrderLine."Dimension Set ID" := 1;    
               
        OrderLine.Insert;

    end;

    var
        LineNo: Integer;
        LText011: Label 'NO LICENSE ON FILE and/or RESTRICTED ITEM ON orDER.  PLEASE CONTACT YOUR LOCAL TARGET SERVICE CENTER TO PROVIDE YOUR APPLICATor''S LICENSE TO PROCESS.';
   
}
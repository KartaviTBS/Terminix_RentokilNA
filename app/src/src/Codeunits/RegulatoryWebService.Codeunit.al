codeunit 50020 "ARC Regulatory WebService Mgt."
{
    
    procedure TestRegulaotry(CustNo: Code[20]; ShipToCode: Code[10]; ShipToCountry: Code[10]; ShipToCounty: Text[30]; ShipToPostCode: Code[20]; LocalityCode: Code[20]; BusTypeCode: Code[10]; ItemNo: Code[20]; UOM: Code[10]; LocationCode: Code[10]): Text[1000];
    var
        RegulatoryMgt: Codeunit "ARC Regulatory Management";
    begin
        exit(RegulatoryMgt.PortalTest(1,CustNo,ShipToCode,ShipToCountry,ShipToCounty,ShipToPostCode,LocalityCode,BusTypeCode,ItemNo,UOM,LocationCode,0));
    end;

    procedure TestRegulaotryOrder(var RegulatoryService: XmlPort "ARC Regulatory Service");
    begin
        RegulatoryService.Import;
    end;

}
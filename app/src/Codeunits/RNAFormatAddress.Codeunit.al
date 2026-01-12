codeunit 50030 "ARC RNA Format Address"
{
    procedure Location(var AddrArray: array[8] of Text[100]; var Location: Record Location);
    var
        myInt: Integer;
    begin
        with Location do
            FormatAddress.FormatAddr(AddrArray, Name, "Name 2", Contact, Address, "Address 2",
            City, "Post Code", County, "Country/Region Code");
        AddrArray[7] := StrSubstNo(PhoneLabel, Location."Phone No.");
        AddrArray[8] := StrSubstNo(FaxLabel, Location."Fax No.");
        CompressArray(AddrArray);

    end;

    procedure NAPCBOLShipTo(var AddrArray: array[8] of Text[100]; var NAPCBOLHeader: Record "ARC NAPC BOL Header");
    begin
        with NAPCBOLHeader do
            FormatAddress.FormatAddr(
                AddrArray, "Ship-to Name", "Ship-to Name 2", "Ship-to Contact", "Ship-to Address", "Ship-to Address 2",
                "Ship-to City", "Ship-to Post Code", "Ship-to County", "Ship-to Country/Region Code");
    end;

    procedure NAPCBOLShipFrom(var AddrArray: array[8] of Text[100]; var NAPCBOLHeader: Record "ARC NAPC BOL Header");
    begin
        with NAPCBOLHeader do
            FormatAddress.FormatAddr(
                AddrArray, "Ship-from Name", "Ship-from Name 2", "Ship-from Contact", "Ship-from Address",
                "Ship-from Address 2",
                "Ship-from City", "Ship-from Post Code", "Ship-from County", "Ship-from Country/Region Code");
    end;



    procedure SalesOrderShipTo(var AddrArray: array[8] of Text[100]; var SalesHeader: Record "Sales Header");
    var
        Customer: Record Customer;
    begin
        with SalesHeader do
            FormatAddress.FormatAddr(AddrArray, "Ship-to Name", "Ship-to Name 2", "Ship-to Contact", "Ship-to Address", "Ship-to Address 2",
            "Ship-to City", "Ship-to Post Code", "Ship-to County", "Ship-to Country/Region Code");

        if SalesHeader."Ship-to Phone No. -CL-" <> '' then
            AddrArray[8] := SalesHeader."Ship-to Phone No. -CL-"
        else if SalesHeader."Bill-to Phone No. -CL-" <> '' then
                AddrArray[8] := SalesHeader."Bill-to Phone No. -CL-"
            else if SalesHeader."Sell-to Phone No. -CL-" <> '' then
                    AddrArray[8] := SalesHeader."Sell-to Phone No. -CL-"
                else if Customer.Get(SalesHeader."Sell-to Customer No.") then
                        AddrArray[8] := Customer."Phone No.";

        CompressArray(AddrArray);
        
    end;
    procedure SalesShptShipTo(var AddrArray: array[8] of Text[100]; var SalesShptHeader: Record "Sales Shipment Header");
    var
        Customer: Record Customer;
    begin
        with SalesShptHeader do
            FormatAddress.FormatAddr(AddrArray, "Ship-to Name", "Ship-to Name 2", "Ship-to Contact", "Ship-to Address", "Ship-to Address 2",
            "Ship-to City", "Ship-to Post Code", "Ship-to County", "Ship-to Country/Region Code");

        if SalesShptHeader."Ship-to Phone No. -CL-" <> '' then
            AddrArray[8] := SalesShptHeader."Ship-to Phone No. -CL-"
        else if SalesShptHeader."Bill-to Phone No. -CL-" <> '' then
                AddrArray[8] := SalesShptHeader."Bill-to Phone No. -CL-"
            else if SalesShptHeader."Sell-to Phone No. -CL-" <> '' then
                    AddrArray[8] := SalesShptHeader."Sell-to Phone No. -CL-"
                else if Customer.Get(SalesShptHeader."Sell-to Customer No.") then
                        AddrArray[8] := Customer."Phone No.";

        CompressArray(AddrArray);

    end;

    procedure TransferShptTransferTo(var AddrArray: array[8] of Text[100]; var TransShptHeader: Record "Transfer Shipment Header");
    var
        Customer: Record Customer;
    begin
        with TransShptHeader do
            FormatAddress.FormatAddr(
                AddrArray, "Transfer-to Name", "Transfer-to Name 2", "Transfer-to Contact", "Transfer-to Address", "Transfer-to Address 2",
                "Transfer-to City", "Transfer-to Post Code", "Transfer-to County", "Trsf.-to Country/Region Code");
    end;


    procedure TransferShptTransferFrom(var AddrArray: array[8] of Text[100]; var TransShptHeader: Record "Transfer Shipment Header");
    var
        Customer: Record Customer;
    begin
        with TransShptHeader do
            FormatAddress.FormatAddr(
                AddrArray, "Transfer-from Name", "Transfer-from Name 2", "Transfer-from Contact", "Transfer-from Address",
            "Transfer-from Address 2", "Transfer-from City", "Transfer-from Post Code", "Transfer-from County", "Trsf.-from Country/Region Code");
            //"Transfer-from Address 2", "Transfer-to City", "Transfer-to Post Code", "Transfer-to County", "Trsf.-to Country/Region Code");

    end;


    var
        FormatAddress: Codeunit "Format Address";
        PhoneLabel: Label 'Phone: %1';
        FaxLabel: Label 'Fax: %1';
}
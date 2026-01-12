report 50004 "ARC Test Regulatory Internal"
{
    Caption = 'Internal WS Regulatory Test';
    UsageCategory = Lists;
    ProcessingOnly = true;

    dataset
    {
        dataitem(RegulatoryWS; Integer)
        {
            DataItemTableView = SORTING (Number) WHERE (Number = CONST (1));

            trigger OnAfterGetRecord()
            var
                RegulatoryMgt: Codeunit "ARC Regulatory Management";
            begin
                If ErrorTest then
                    Error('Test');
                Message(RegulatoryMgt.PortalTest(1,CustNo,ShipToCode,ShipToCountry,ShipToCounty,ShipToPostCode,LocalityCode,BusTypeCode,ItemNo,UOM,LocationCode,0));
               
            end;

            trigger OnPostDataItem()
            var
            begin
              
            end;
        }
    }
    
    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    field(CustNo;CustNo)
                    {
                        Caption = 'Customer No.';
                    }
                    field(ShipToCode;ShipToCode)
                    {   
                        Caption = 'Ship To Code';
                    }
                    field(ShipToCountry;ShipToCountry)
                    {
                        Caption = 'Ship To Country';
                    }
                    field(ShipToCounty;ShipToCounty)
                    {
                        Caption = 'Ship To County';
                    }
                    field(ShipToPostCode;ShipToPostCode)
                    {
                        Caption = 'Ship To Post Code';
                    }
                    field(LocalityCode;LocalityCode)
                    {
                        Caption = 'Locality Code';
                    }
                    field(BusTypeCode;BusTypeCode)
                    {
                        Caption = 'Bus. Type Code';
                    }
                    field(ItemNo;ItemNo)
                    {
                        Caption = 'Item No.';
                    }
                    field(UOM;UOM)
                    {
                        Caption = 'UOM';
                    }
                    field(LocationCode;LocationCode)
                    {
                        Caption = 'Location Code';
                    }
                    field(ErrorTest;ErrorTest)
                    {

                    }

                    
                }
            }
        }
    
        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                }
            }
        }
    }
    
    var
        CustNo : Text;
        ShipToCode: Text;
        ShipToCountry: Text;
        ShipToCounty: Text;
        ShipToPostCode: Text;
        LocalityCode: Text;
        BusTypeCode: Text;
        ItemNo: Code[20];
        UOM: Code[20];
        LocationCode: Code[20];
        ErrorTest: Boolean;



        
}
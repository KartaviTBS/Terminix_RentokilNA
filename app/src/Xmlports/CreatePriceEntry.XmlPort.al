xmlport 50005 "ARC Create Price Entry"
{
    Caption = 'Create Price Entry';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/CreatePriceEntry';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(RootNodeName)
        {
            tableelement(ARCPriceEntry; "ARC Price Entry")
            {
                UseTemporary = true;

                fieldelement(EntryNo; ARCPriceEntry."Entry No.")
                {
                }

                fieldelement(EntityType; ARCPriceEntry."Entity Type")
                {
                }
                fieldelement(EntityNo; ARCPriceEntry."Entity No.")
                {

                }
                fieldelement(EntityName; ARCPriceEntry."Entity Name")
                {
                }
                fieldelement(Type; ARCPriceEntry.Type)
                {
                }
                fieldelement(No; ARCPriceEntry."No.")
                {
                }
                fieldelement(Description; ARCPriceEntry.Description)
                {
                }
                fieldelement(MinimumQuantity; ARCPriceEntry."Minimum Quantity")
                {
                }
                fieldelement(UnitofMeasureCode; ARCPriceEntry."Unit of Measure Code")
                {
                }
                fieldelement(VariantCode; ARCPriceEntry."Variant Code")
                {
                }

                fieldelement(Method; ARCPriceEntry.Method)
                {
                }

                fieldelement(EffectiveDate; ARCPriceEntry."Effective Date")
                {
                }
                fieldelement(ExpirationDate; ARCPriceEntry."Expiration Date")
                {
                }

                fieldelement(Comment; ARCPriceEntry.Comment)
                {
                }
                fieldelement(CurrencyCode; ARCPriceEntry."Currency Code")
                {
                }
                fieldelement(NetUnitPrice; ARCPriceEntry."Net Unit Price")
                {
                }
                fieldelement(MethodValue; ARCPriceEntry."Method Value")
                {
                }
                fieldelement(Status; ARCPriceEntry.Status)
                {
                }
                fieldelement(MinimumPrice; ARCPriceEntry."Minimum Price")
                {
                }

                trigger OnBeforeInsertRecord()
                begin
                    InsertRecords();
                    currXMLport.Skip;

                end;
            }
        }
    }

    procedure InsertRecords()
    var
        PriceEntry: Record "ARC Price Entry";
        PriceEntry2: Record "ARC Price Entry";
    begin
        Case RequestType of
            'MODIFY' :
                    begin
                        
                        PriceEntry2.Get(ARCPriceEntry."Entry No.");
                        PriceEntry.SetSalesPersonCode(SalesPersonCode);
                        PriceEntry.TransferFields(ARCPriceEntry);
                        PriceEntry."Created By" := PriceEntry2."Created By";
                        PriceEntry."Created On" := PriceEntry2."Created On";
                        PriceEntry.Validate("Entity No.");
                        PriceEntry.Validate("No.");
                        PriceEntry.Validate("Method Value");
                        PriceEntry.Modify(true);
                        ARCPriceEntry := PriceEntry;
                        ARCPriceEntry.SetSalesPersonCode(SalesPersonCode);
                        ARCPriceEntry.Insert(true);
                    end;
            'INSERT' :
                    begin
                        PriceEntry.SetSalesPersonCode(SalesPersonCode);
                        PriceEntry.TransferFields(ARCPriceEntry);
                        PriceEntry.Validate("Entity No.");
                        PriceEntry.Validate("No.");
                        PriceEntry.Validate("Method Value");
                        PriceEntry.Insert(true);
                        ARCPriceEntry := PriceEntry;
                        ARCPriceEntry.SetSalesPersonCode(SalesPersonCode);
                        ARCPriceEntry.Insert(true);
                    end;
        end;
    end;


    procedure SetRequestType(NewRequestType: Text[30])
    begin
        RequestType := NewRequestType;
    end;

    procedure SetSalesPersonCode(NewSalesPersonCode: Code[20])
    begin
        SalesPersonCode := NewSalesPersonCode;        
    end;


    var
        RequestType: Text[30];
        SalesPersonCode: Code[20];
        LblSalesPerson: Label 'The selected sales person is %1';

}

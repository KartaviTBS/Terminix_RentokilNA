xmlport 50003 "ARC Promotion Entry Import"
{
    Caption = 'Promotion Entry Import';
    Direction = Import;
    FieldDelimiter = '<None>';
    FieldSeparator = '<TAB>';
    Format = VariableText;
    Permissions = tabledata 50034 = ri;
    UseRequestPage = false;


    schema
    {
        textelement(Root)
        {
             tableelement(Table2000000026;Integer)
            {
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                XmlName = 'Integer';                           

                textelement(EntityType)
                {
                }
                textelement(EntityNo)
                {
                }
                textelement(Type)
                {
                }
                textelement(ItemNo)
                {
                }
                textelement(MinimumQuantity)
                {
                }
                textelement(UnitofMeasureCode)
                {
                }
                textelement(VariantCode)
                {
                }
                textelement(LocationCode)
                {
                }

                textelement(PromotionCode)
                {
                }
                textelement(Discount)
                {
                }
                textelement(DiscountAmount)
                {
                }
                textelement(Promotion1ItemNo)
                {
                }
                textelement(Promotion1UOMCode)
                {
                }
                textelement(Promotion1VariantCode)
                {
                }
                textelement(Promotion1TaxGroupCode)
                {
                }
                textelement(Promotion1Quantity)
                {
                }
               
                textelement(Promotion1Discount)
                {
                }
                textelement(Promotion1DiscountAmount)
                {
                }
                textelement(Promotion1QtyMultiplier)
                {
                }                
                textelement(SupplierNo)
                {
                }
                textelement(SupplierFunded)
                {
                }
                textelement(CountryRegionCode)
                {
                }
                textelement(County)
                {
                }
                textelement(CurrencyCode)
                {
                }
                textelement(EffectiveDate)
                {
                }
                textelement(ExpirationDate)
                {
                }

               trigger OnBeforeInsertRecord()
                begin
                    ImportEntries();
                    ClearAll;
                    i+=1;
                    currXMLport.Skip;                   
                end;            

            }
        }
    }
    local procedure ImportEntries();
    var
       PromoEntry: Record "ARC Promotion Entry";
    begin
        if i =0 then begin;
           i+=1;
           currXMLport.Skip;
        end;    
        if (ItemNo = '') OR (EffectiveDate = '') then
            currXMLport.Skip;
        PromoEntry.Init;
        PromoEntry."Entry No." := 0;
        Evaluate(PromoEntry."Entity Type",EntityType);
        PromoEntry.Validate("Entity No.",EntityNo);
        Evaluate(PromoEntry.Type,Type);
        PromoEntry.Validate("No." , ItemNo);
        Evaluate(PromoEntry."Minimum Quantity",MinimumQuantity);
        PromoEntry.Validate("Unit of Measure Code",UnitofMeasureCode);
        PromoEntry.Validate("Variant Code",VariantCode);
        PromoEntry.Validate("Location Code",LocationCode);
        PromoEntry.Validate("Promotion Code",PromotionCode);
        PromoEntry."Promotion Inclusion" := PromoEntry."Promotion Inclusion"::Automatic; 
        if Evaluate(PromoEntry."Discount %",Discount) then;
        if Evaluate(PromoEntry."Discount Amount",DiscountAmount) then;
        PromoEntry.Validate("Discount %");
        PromoEntry.Validate("Discount Amount");
        PromoEntry.Validate("Promotion 1 Item No.",Promotion1ItemNo);
        PromoEntry.Validate("Promotion 1 UOM Code",Promotion1UOMCode);
        PromoEntry.Validate("Promotion 1 Variant Code",Promotion1VariantCode);
        PromoEntry.Validate("Promotion 2 Tax Group Code",Promotion1TaxGroupCode);
        if Evaluate(PromoEntry."Promotion 1 Quantity",Promotion1Quantity) then;
        PromoEntry.Validate("Promotion 1 Quantity");
        if Evaluate(PromoEntry."Discount %",Promotion1Discount) then;
        if Evaluate(PromoEntry."Discount Amount",Promotion1DiscountAmount) then;
        PromoEntry.Validate("Promotion 1 Discount %");
        PromoEntry.Validate("Promotion 1 Discount Amount");
        if Evaluate(PromoEntry."Promotion 2 Qty. Multiplier",Promotion1QtyMultiplier) then;
        PromoEntry.Validate("Supplier No.",SupplierNo);        
        if Evaluate(PromoEntry."Supplier Funded",SupplierFunded) then;
        PromoEntry.Validate("Country/Region Code",CountryRegionCode);
        PromoEntry.Validate(County,County);        
        if Evaluate(PromoEntry."Effective Date",EffectiveDate) then;
        if Evaluate(PromoEntry."Expiration Date",ExpirationDate) then;
        PromoEntry.Validate("Expiration Date");
        PromoEntry."Currency Code" := CurrencyCode;
        PromoEntry.Insert(true);

    end;
    var
       i: Integer;
  
}

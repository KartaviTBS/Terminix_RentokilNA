xmlport 50002 "ARC Price Entry Import"
{
    Caption = 'Price Entry Import';
    Direction = Import;
    FieldDelimiter = '<None>';
    FieldSeparator = '<TAB>';
    Format = VariableText;
    Permissions = tabledata 50033=ri;
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
                textelement(Method)
                {
                }
                textelement(MethodValue)
                {
                }
                textelement(EffectiveDate)
                {
                }
                textelement(ExpirationDate)
                {
                }
                textelement(Comment)
                {
                }
                textelement(CurrencyCode)
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
       PriceEntry: Record "ARC Price Entry";
    begin
        if i =0 then begin;
           i+=1;
           currXMLport.Skip;
        end;    
        if (ItemNo = '') OR (MethodValue = '') OR (EffectiveDate = '') then
            currXMLport.Skip;
        PriceEntry.Init;
        PriceEntry."Entry No." := 0;
        Evaluate(PriceEntry."Entity Type",EntityType);
        PriceEntry.Validate("Entity No.",EntityNo);
        Evaluate(PriceEntry.Type,Type);
        PriceEntry.Validate("No." , ItemNo);
        Evaluate(PriceEntry."Minimum Quantity",MinimumQuantity);
        PriceEntry.Validate("Unit of Measure Code",UnitofMeasureCode);
        PriceEntry.Validate("Variant Code",VariantCode);
        Evaluate(PriceEntry.Method,Method);
        Evaluate(PriceEntry."Method Value",MethodValue);
        PriceEntry.Validate("Method Value");
        Evaluate(PriceEntry."Effective Date",EffectiveDate);
        Evaluate(PriceEntry."Expiration Date",ExpirationDate);
        PriceEntry.Validate("Expiration Date");
        PriceEntry.Comment := Comment;
        PriceEntry."Currency Code" := CurrencyCode;
        PriceEntry.Insert(true);

    end;
    var
       i: Integer;

    }



   
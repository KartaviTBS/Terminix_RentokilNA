xmlport 50008 "ARC Item Attributes Import"
{
    Caption = 'Item Attributes Import';
    Direction = Import;
    FieldDelimiter = '<None>';
    FieldSeparator = '<TAB>';
    Format = VariableText;
    Permissions = tabledata 27=ri;
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
               
                textelement(ItemNo)
                {
                    
                }
                textelement(Attr1)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr1Value)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr2)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr2Value)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr3)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr3Value)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr4)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr4Value)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr5)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr5Value)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr6)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr6Value)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr7)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr7Value)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr8)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr8Value)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr9)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr9Value)
                {
                    MinOccurs = Zero;
                }
                textelement(Attr10)
                {
                    MinOccurs = Zero;                    
                }
                textelement(Attr10Value)
                {
                    MinOccurs = Zero;
                }
               
                
               

                trigger OnBeforeInsertRecord()
                begin
                    ImportAttributes();
                    i+=1;
                    currXMLport.Skip;                   
                end;            

                              
            }
        }
    }
    local procedure ImportAttributes();
    var
        ItemAttribute: Record "Item Attribute";
        Item: Record Item;
    begin
        if i =0 then begin;
           i+=1;
           currXMLport.Skip;
        end;    
        if (ItemNo = '') then
            currXMLport.Skip;
        Item.Get(ItemNo);    
        TempItemAttributeValueToInsert.Reset;
        TempItemAttributeValueToInsert.DeleteAll;
        If (Attr1 <> '') and (Attr1Value <> '') then begin 
            FindItemAttributeValue(Attr1,Attr1Value);
        end;    
        If (Attr2 <> '') and (Attr2Value <> '') then begin 
            FindItemAttributeValue(Attr2,Attr2Value);
        end; 
        If (Attr3 <> '') and (Attr3Value <> '') then begin 
            FindItemAttributeValue(Attr3,Attr3Value);
        end; 
        If (Attr4 <> '') and (Attr4Value <> '') then begin 
            FindItemAttributeValue(Attr4,Attr4Value);
        end; 
        If (Attr5 <> '') and (Attr5Value <> '') then begin 
            FindItemAttributeValue(Attr5,Attr5Value);
        end; 
        If (Attr6 <> '') and (Attr6Value <> '') then begin 
            FindItemAttributeValue(Attr6,Attr6Value);
        end; 
        If (Attr7 <> '') and (Attr7Value <> '') then begin 
            FindItemAttributeValue(Attr7,Attr7Value);
        end; 
        If (Attr8 <> '') and (Attr8Value <> '') then begin 
            FindItemAttributeValue(Attr8,Attr8Value);
        end; 
        If (Attr9 <> '') and (Attr9Value <> '') then begin 
            FindItemAttributeValue(Attr9,Attr9Value);
        end; 
        If (Attr10 <> '') and (Attr10Value <> '') then begin 
            FindItemAttributeValue(Attr10,Attr10Value);
        end; 
        
        InsertItemAttributeValueMapping(Item);
    end;


    local procedure FindItemAttributeValue(ItemAttr: Text[250]; ItemAttrVal: Text[250]);
    var
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValue: Record "Item Attribute Value";
        ValDecimal: Decimal;
    begin
        ItemAttribute.Reset;
        ItemAttribute.SetRange(Name,ItemAttr);
        If ItemAttribute.FindFirst then begin 
            ItemAttributeValue.Reset;
            ItemAttributeValue.SetRange("Attribute ID",ItemAttribute.ID);
            ItemAttributeValue.SetRange(Value,ItemAttrVal);
            If ItemAttributeValue.FindFirst then begin 
                TempItemAttributeValueToInsert := ItemAttributeValue;
                TempItemAttributeValueToInsert.Insert;
            end else begin 
                ItemAttributeValue.Init;
                ItemAttributeValue."Attribute ID" := ItemAttribute.ID;
                case ItemAttribute.Type of
                    ItemAttribute.Type::Option,ItemAttribute.Type::Text:
                        ItemAttributeValue.Value := ItemAttrVal;
                    ItemAttribute.Type::Integer:
                        ItemAttributeValue.Validate(Value,ItemAttrVal);
                    ItemAttribute.Type::Decimal: begin 
                        Evaluate(ValDecimal,ItemAttrVal);
                        ItemAttributeValue.Validate(Value,Format(ValDecimal));
                    end;
                end;
                ItemAttributeValue.Insert;
                TempItemAttributeValueToInsert := ItemAttributeValue;
                TempItemAttributeValueToInsert.Insert;
            end;   
        end;
        
    end;


    local procedure InsertItemAttributeValueMapping(Item: Record Item)
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    begin
        if TempItemAttributeValueToInsert.FindFirst then
            repeat
                ItemAttributeValueMapping."Table ID" := DATABASE::Item;
                ItemAttributeValueMapping."No." := Item."No.";
                ItemAttributeValueMapping."Item Attribute ID" := TempItemAttributeValueToInsert."Attribute ID";
                ItemAttributeValueMapping."Item Attribute Value ID" := TempItemAttributeValueToInsert.ID;
                if ItemAttributeValueMapping.Insert(true) then;
            until TempItemAttributeValueToInsert.Next = 0;
    end;


    var
       i: Integer;
       TempItemAttributeValueToInsert: Record "Item Attribute Value" temporary;
    }



   
page 50054 "ARC Posted Sales Invoice Lines"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'ARC Posted Sales Invoice Lines';
    Editable = true;
    SourceTable = "Sales Invoice Line";
    Permissions =  tabledata 113 = rm;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Document No.";"Document No.")
                {                    
                    Editable = false;
                }
                field("Line No.";"Line No.")
                {                    
                    Editable = false;
                }
                field("Sell-to Customer No.";"Sell-to Customer No.")
                {                    
                    Editable = false;
                }
                field(Type;Type)
                {                    
                    Editable = false;
                }
                field("No.";"No.")
                {                    
                    Editable = false;
                }
                field("Location Code";"Location Code")
                {                    
                    Editable = false;
                }
                field(Quantity;Quantity)
                {                    
                    Editable = false;
                }
                field("Quantity (Base)";"Quantity (Base)")
                {                    
                    Editable = false;
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {                    
                    Editable = false;
                }
                field("Unit Price";"Unit Price")
                {                    
                    Editable = false;
                }
                field(Amount;Amount)
                {                    
                }
                field("Amount Including VAT";"Amount Including VAT")
                {                    
                }
            }
        }
    }
}
tableextension 50024 "ARC Transfer Shipment Header" extends "Transfer Shipment Header"
{
    fields
    {
        field(50500;"ARC NAPC Bill of Lading No.";Code[20])
        {
           CalcFormula = lookup("ARC NAPC BOL Header"."No." where ("Source Doc. Type" = const("Transfer Shipment"), "Source Doc. No." = field("No.")));
           FieldClass = FlowField;
           Editable = false;         

        }
    }
    
   
}
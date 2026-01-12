tableextension 50025 "ARC Transfer Shipment Line" extends "Transfer Shipment Line"
{
    fields
    {
         field(50500;"ARC NAPC Bill of Lading No.";Code[20])
        {
           CalcFormula = lookup("ARC NAPC BOL Line"."No." where ("Source Doc. Type" = const("Transfer Shipment"), "Source Doc. No." = field("Document No."), "Source Doc. Line No." = field("Line No.")));
           FieldClass = FlowField;
           Editable = false;         

        }
    }
  
}
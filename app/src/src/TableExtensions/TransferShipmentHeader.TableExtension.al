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
        field(50003; "2Ship Label Link"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;  
            Caption = '2Ship Label Link';        
        }
        field(50004; "2Ship BOL Link"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;          
            Caption = '2Ship BOL Link';
        }
        field(50005; "2Ship Tracking No."; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;          
            Caption = '2Ship Tracking No.';
        }
    }
    
   
}
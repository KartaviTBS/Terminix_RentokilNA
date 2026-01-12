tableextension 50023 "ARC Sales Shipment Header" extends "Sales Shipment Header"
{
    fields
    {
        field(50012;"Sell-to Territory Code";Code[10])
        {
            Caption = 'Territory Code';
            Description = 'RENT.SK.01';
            TableRelation = Territory;
            Editable = false;        
        }
        field(50013;"Bill-to Territory Code";Code[10])
        {
            Caption = 'Territory Code';
            Description = 'RENT.SK.01';
            TableRelation = Territory;
            Editable = false;
        }
        field(50014;"Ship-to Territory Code";Code[10])
        {
            Caption = 'Territory Code';
            Description = 'RENT.SK.01';
            TableRelation = Territory;
            Editable = false;
        }
        field(50053; "ARC Order Source Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Order Source Code';
        }
        field(50065;"ARC Workwave Order";Boolean)
        {
            Caption = 'WorkWave Order';
            Editable = false;
        }
        field(50072;"ARC ACH Order";Boolean)
        {
            Caption = 'ACH Order';
            Editable = false;
        }
        field(50500;"ARC NAPC Bill of Lading No.";Code[20])
        {
           CalcFormula = lookup("ARC NAPC BOL Header"."No." where ("Source Doc. Type" = const("Sales Shipment"), "Source Doc. No." = field("No.")));
           FieldClass = FlowField;
           Editable = false;         
        }
    }
}
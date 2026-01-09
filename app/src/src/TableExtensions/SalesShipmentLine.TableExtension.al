tableextension 50018 "ARC Sales Shipment Line" extends "Sales Shipment Line"
{
    fields
    {

        field(50001; "ARC Business Type Code"; Code[20])
        {
            Caption = 'Business Type Code';
            TableRelation = "ARC Customer Business Type"."Business Type Code" where ("Customer No." = FIELD ("Sell-to Customer No."));

        }
        field(50002;"ARC Price Entry No.";Integer)
        {
            Caption = 'Price Entry No.';
        }
        
        field(50003;"ARC Promotion Entry No.";Integer)
        {
            Caption = 'Promotion Entry No.';
            TableRelation = "ARC Promotion Entry";
        }
        field(50004;"ARC Promotion Code";Code[20])
        {
            Caption = 'Promotion Code';
            TableRelation = "ARC Promotion";
        }
        field(50008;"ARC Target LOB";Code[20])
        {
            Caption = 'Target LOB';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(3));
        }
        field(50009;"ARC Original Price";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Original Price';
        }
        field(50010;"ARC Markup Value";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Markup Value';
        }
        
        field(50500;"ARC NAPC Bill of Lading No.";Code[20])
        {
           CalcFormula = lookup("ARC NAPC BOL Line"."No." where ("Source Doc. Type" = const("Sales Shipment"), "Source Doc. No." = field("Document No."), "Source Doc. Line No." = field("Line No.")));
           FieldClass = FlowField;
           Editable = false;         

        }
        field(50005;"ARC Margin %";Decimal)
        {
            Caption = 'Margin %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;

        }
        field(50006;"ARC Sales Cost";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Sales Cost';
            Editable = false;
        }
         field(50062; "ARC Supplemental Charge Code"; Code[10]) 
        { 
            Caption = 'Supplemental Charge Code';
            TableRelation = "ARC Item Supplemental Charge".Code WHERE("Item No." = FIELD("No."));
           
        }
        field(50063; "ARC Supplemental Charge Rate"; Decimal) 
        { 
            Caption = 'Supplemental Charge Rate';            
        }
        field(50064; "ARC Supplemental Fixed Amount"; Decimal) 
        { 
            Caption = 'Supplemental Fixed Amount';            
        }        

    }
}
tableextension 50032 "ARC Sales Line Archive" extends "Sales Line Archive"
{
    fields
    {
        field(50001; "ARC Business Type Code"; Code[20])
        {
            Caption = 'Business Type Code';
            TableRelation = "ARC Customer Business Type"."Business Type Code" where ("Customer No." = FIELD ("Sell-to Customer No."));
            Editable = false;
        }
        field(50002;"ARC Price Entry No.";Integer)
        {
            Caption = 'Price Entry No.';
            TableRelation = "ARC Price Entry";
            Editable = false;
        }
        field(50003;"ARC Promotion Entry No.";Integer)
        {
            Caption = 'Promotion Entry No.';
            TableRelation = "ARC Promotion Entry";
            Editable = false;
        }
        field(50004;"ARC Promotion Code";Code[20])
        {
            Caption = 'Promotion Code';
            TableRelation = "ARC Promotion";
            Editable = false;
        }
        field(50005;"ARC Margin %";Decimal)
        {
            Caption = 'Margin %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
            Editable = false;
        }
        field(50006;"ARC Sales Cost";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Sales Cost';
            Editable = false;
        }
        field(50007; "ARC Price Review Exist"; Boolean)
        {
            CalcFormula = Exist ("ARC Price Review Entry" WHERE("Document No." = FIELD("Document No."),
                                                                "Document Line No." = FIELD("Line No."),
                                                                Status = const(Review)
                                                                ));
            Caption = 'Price Review Exist';
            FieldClass = FlowField;
            Editable = false;
        }
        field(50008;"ARC Target LOB";Code[20])
        {
            Caption = 'Target LOB';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(3));
            Editable = false;
        }
        field(50009;"ARC Original Price";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Original Price';
            Editable = false;
        }
        field(50010;"ARC Markup Value";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Markup Value';
            Editable = false;
        }
        field(50062; "ARC Supplemental Charge Code"; Code[10]) 
        { 
            Caption = 'Supplemental Charge Code';
            TableRelation = "ARC Item Supplemental Charge".Code WHERE("Item No." = FIELD("No."));
            Editable = false;
        }
        field(50063; "ARC Supplemental Charge Rate"; Decimal) 
        { 
            Caption = 'Supplemental Charge Rate';
            Editable = false;
        }
        field(50064; "ARC Supplemental Fixed Amount"; Decimal) 
        { 
            Caption = 'Supplemental Fixed Amount';
            Editable = false;
        }        
        field(50065;"ARC NAPC Bill of Lading No.";Code[20])
        {
           CalcFormula = lookup("ARC NAPC BOL Header"."No." where ("Source Doc. Type" = const("Sales Order"), "Source Doc. No." = field("No.")));
           FieldClass = FlowField;
           Editable = false;         
        }
    }
}
tableextension 50017 "ARC Sales Cr.Memo Line" extends "Sales Cr.Memo Line"
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
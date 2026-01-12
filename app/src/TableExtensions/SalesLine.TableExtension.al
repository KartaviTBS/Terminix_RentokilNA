tableextension 50007 "ARC SalesLine" extends "Sales Line"
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

            trigger OnValidate()
            begin
                SalesMgt.UpdateMarginPercent(Rec,xRec,CurrFieldNo);                
            end;
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
            Editable = false;
            FieldClass = FlowField;
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

        field(50062; "ARC Supplemental Charge Code"; Code[10]) 
        { 
            Caption = 'Supplemental Charge Code';
            TableRelation = "ARC Item Supplemental Charge".Code WHERE("Item No." = FIELD("No."));

            trigger OnValidate()
            begin
                if Type = Type::Item then
                    if ItemSupplCharge.GET("No.","ARC Supplemental Charge Code") then begin
                        "ARC Supplemental Charge Rate" := ItemSupplCharge."Rate %"; 
                        "ARC Supplemental Fixed Amount" := ItemSupplCharge."Fixed amount";
                    end;                 
            end;
        }
        field(50063; "ARC Supplemental Charge Rate"; Decimal) 
        { 
            Caption = 'Supplemental Charge Rate';
            //Editable = false;
        }
        field(50064; "ARC Supplemental Fixed Amount"; Decimal) 
        { 
            Caption = 'Supplemental Fixed Amount';
            //Editable = false;
        }        

        field(50065;"ARC NAPC Bill of Lading No.";Code[20])
        {
           CalcFormula = lookup("ARC NAPC BOL Header"."No." where ("Source Doc. Type" = const("Sales Order"), "Source Doc. No." = field("No.")));
           FieldClass = FlowField;
           Editable = false;         
        }
        // 50500 used on Sales Shipment Line "ARC NAPC Bill of Lading No." created from Sales Shipment
        // do not use 50510
        field(50071; "ARC Payment Terms Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Payment Terms";
            ValidateTableRelation = false;
            Caption = 'Payment Terms Code';
        }
        field(50072; "ARC eCommerce Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'eCommerce Entry No.';
        }
    }
    /*
    procedure InsertFreightLineResource(FreightAmount:Decimal);
    var
        ToShipIntSetup: Record "2Ship Integration Setup";
        SalesLine:Record "Sales Line";

        FreightAmountQuantity:Decimal;
    begin

        if  FreightAmount = 0 then           
            EXIT;
    

        FreightAmountQuantity := 1;

        ToShipIntSetup.GET;
        ToShipIntSetup.TESTFIELD("Freight Resource No.");

        Rec.TESTFIELD("Document Type");
        Rec.TESTFIELD("Document No.");

        SalesLine.SETRANGE("Document Type","Document Type");
        SalesLine.SETRANGE("Document No.","Document No.");
        
        SalesLine.SETRANGE(Type,SalesLine.Type::Resource);
        SalesLine.SETRANGE("No.",ToShipIntSetup."Freight Resource No.");
        // "Quantity Shipped" will be equal to 0 until FreightAmount line successfully shipped
        SalesLine.SETRANGE("Quantity Shipped",0);
        SalesLine.SetRange("Line No.",0);
        IF SalesLine.FINDFIRST THEN BEGIN
            SalesLine.SuspendStatusCheck(true);
            SalesLine.VALIDATE(Quantity,FreightAmountQuantity);
            SalesLine.VALIDATE("Unit Price",SalesLine."Unit Price" + FreightAmount);
            SalesLine.MODIFY;
            SalesLine.SuspendStatusCheck(false);
        END ELSE BEGIN
            SalesLine.SETRANGE(Type);
            SalesLine.SETRANGE("No.");
            SalesLine.SETRANGE("Quantity Shipped");
            SalesLine.SetRange("Line No.");
            SalesLine.FindLast();
            SalesLine."Line No." += 10000;
            SalesLine.INIT;
            SalesLine.SuspendStatusCheck(true);
            SalesLine.VALIDATE(Type,SalesLine.Type::Resource);
            SalesLine.VALIDATE("No.",ToShipIntSetup."Freight Resource No.");
            SalesLine.VALIDATE(Quantity,FreightAmountQuantity);
            SalesLine.VALIDATE("Unit Price",FreightAmount);
            SalesLine.INSERT;
            SalesLine.SuspendStatusCheck(false);
        end;
    end;
    */
    var 
        SalesMgt: Codeunit ARCSalesMgt;
        ItemSupplCharge: Record "ARC Item Supplemental Charge";
}
table 50029 "ARC Regulatory Hold Buffer"
{
    Caption = 'Regulatory Hold Buffer';


    fields
    {
        field(1;"Document Type";Option)
        {
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Shipment';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",Shipment;
        }
        field(2;"Document No.";Code[20])
        {
            NotBlank = true;
        }
        field(3;"Doc. Line No.";Integer)
        {
            NotBlank = true;
        }
        field(4;"Line No.";Integer)
        {
            NotBlank = true;
        }
        field(20;"Item No.";Code[20])
        {
        }
        field(21;"CAS Code";Code[30])
        {
        }
        field(22;"SDS Product Code";Code[20])
        {
        }
        field(23;"Customer No.";Code[20])
        {
        }
        field(24;"Ship-to Code";Code[10])
        {
        }
        field(25;"License Type Code";Code[20])
        {
        }
        field(26;"Business Type Code";Code[10])
        {
            TableRelation = "ARC Business Type";
        }
        field(27;"Product Type Restriction Code";Code[20])
        {
        }
        field(28;"Product Use";Option)
        {
            Caption = 'Product Use';
            InitValue = TO_AG;
            //MinValue = TO_AG;
            OptionCaption = '" ,TO_AG,Structural,Dual,Other"';
            OptionMembers = " ",TO_AG,Structural,Dual,Other;
        }
        field(30;"Sales Order Approval Code";Code[20])
        {
            CalcFormula = Lookup("ARC Product Type Restriction"."Sales Order Approval Code" WHERE (Code=FIELD("Product Type Restriction Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(100;Comment;Text[100])
        {
        }
        field(120;Indentation;Integer)
        {
            CaptionML = ENU='Indentation',
                        ESM='Indentar',
                        FRC='Indentation',
                        ENC='Indentation';
            MinValue = 0;
        }
        field(121;Override;Boolean)
        {
            /*
            CalcFormula = Exist("Sales Line Override" WHERE ("Document Type"=FIELD("Document Type"),
                                                             "Document No."=FIELD("Document No."),
                                                             "Doc. Line No."=FIELD("Doc. Line No."),
                                                             "CAS Code"=FIELD("CAS Code"),
                                                             "License Type Code"=FIELD("License Type Code"),
                                                             "Business Type Code"=FIELD("Business Type Code"),
                                                           "Product Type Restriction Code"=FIELD("Product Type Restriction Code")));
            */                                                
            Editable = false;
            FieldClass = Normal;
        }
        field(130;"Chemical Name";Text[100])
        {
            CalcFormula = Lookup("ARC CAS"."Chemical Name" WHERE (Code=FIELD("CAS Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(140;Restricted;Boolean)
        {
        }
    }

    keys
    {
        key(Key1;"License Type Code","Business Type Code","Product Type Restriction Code","Product Use","Doc. Line No.","Line No.")
        {
        }
        key(Key2;"Document Type","Document No.","Doc. Line No.","Line No.")
        {
        }
        key(Key3;Restricted)
        {
        }
    }

    fieldgroups
    {
    }
}


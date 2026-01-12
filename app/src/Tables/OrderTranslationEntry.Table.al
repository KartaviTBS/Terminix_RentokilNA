table 50078 "ARC Order Translation Entry"
{
    DataClassification = CustomerContent;
    Caption = 'Order Translation Entry';
    
    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(11;"Document Area";Option)
        {
            DataClassification = CustomerContent;
            OptionCaption = 'Sales,Purchases,Transfers';
            OptionMembers = Sales,Purchases,Transfers;
        }
        field(12;"Document Type";Option)
        {
            DataClassification = CustomerContent;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(13;"Document No.";Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(14;"Document Line No.";Integer)
        {
            DataClassification = CustomerContent;
        }
        field(21; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(31; Type; Option)
        {
            DataClassification = CustomerContent;
            OptionCaption = ' ,G/L Account,Item,Resource,Fixed Asset,Charge (Item)';
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
        }
        field(32; "No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(36; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 0:5;
        }
        field(41; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(46; "Qty. per Unit of Measure"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 0:5;
        }
        field(56; "Quantity (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 0:5;
        }
        field(71; "Payment Terms Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Payment Terms";
            ValidateTableRelation = false;
        }
        field(201; "Sell-to Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(301; "External Document No."; Code[35])
        {
            DataClassification = CustomerContent;
        }
        field(503; "Updated Document No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(504; "Updated Document Line No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(519; "Updated Document Exists"; Boolean)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = exist("Sales Header" where("Document Type" = field("Document Type"), "No." = field("Updated Document No.")));
        }
        field(520; "Updated Status"; Option)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup("Sales Header".Status where ("Document Type" = const(Order), "No." = field("Updated Document No.")));
            OptionMembers = Open,Released,"Pending Approval","Pending Prepayment";
            OptionCaption = 'Open,Released,Pending Approval,Pending Prepayment';
        }
        field(521; "Updated Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(4032; "Item Description"; Text[100])
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Item.Description where ("No." = field("No.")));
        }
        field(4033; "Item Description 2"; Text[50])
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Item."Description 2" where ("No." = field("No.")));
        }
        field(4201; "Customer Name"; Text[100])
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Customer.Name where ("No." = field("Sell-to Customer No.")));
        }
        field(4911; "Created by"; Code[50])
        {
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(4912; "Created at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4913; "Created at Date"; Date)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4914; "Created at Time"; Time)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4950; Analyze; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4951; Analyzed; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4952; "Analyzed at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4953; "Analyzed No. of Attempts"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4954; "Analyzed Duration"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4955; "Analyzed Error Text"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4956; "Analyzed Data Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4960; Release; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4961; Released; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4962; "Released at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4963; "Released No. of Attempts"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4964; "Released Duration"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Pending;
            ObsoleteReason = 'Incorrect field type';
        }
        field(4965; "Released Error Text"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4966; "Released Duration (new)"; Duration)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50043;"ARC Ranking Code";Code[20])
        {
            Caption = 'Ranking Code';
            TableRelation = "ARC Ranking Code";
        }
    }

    keys
    {
        key(Primary; "Entry No.")
        {
            Clustered = true;
        }
        key(Analyze; Analyze, Analyzed) { }
        key(Release; Release, Released) { }
        key(Docs; "Document Area","Document Type","Document No.","Document Line No.") { }
        key(Updated; "Updated Document No.", "Updated Document Line No.") { }
        key(CustNo; "Sell-to Customer No.") { }
        key(ExtDocNo; "External Document No.") { }
        key(CreatedAtDateTime; "Created at DateTime") { }
    }

    trigger OnInsert();
    begin
    end;

    trigger OnModify();
    begin
    end;

    trigger OnDelete();
    begin
    end;

    trigger OnRename();
    begin
    end;
}
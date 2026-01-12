table 50000 "ARC RNA Setup"
{
    DataClassification = CustomerContent;
    Caption = 'RNA Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Regulatory User Group"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "User Group";
        }
        field(3; "Disable Custom Price Logic"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(4; "Quote Expiration Calculation"; DateFormula)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Send Approval/Reject Email"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(6; "LOB Lift Field Calculation"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "Unit Cost","Sales Cost","Unit Price";
            OptionCaption = 'Unit Cost,Sales Cost,Unit Price';
        }
        field(7; "Release On Price Approval"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(8; "COI Journal Template Name"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Template";
        }
        field(9; "COI Journal Batch Name"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FIELD("COI Journal Template Name"));
        }
        field(10; "Journal Template Name"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Template";
        }
        field(11; "Journal Batch Name"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(12; "Regulatory Workflow Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Workflow;
        }
        field(13; "Default Fin. Charge Funct Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            Caption = 'Default Fin. Charge Function Code';
            CaptionClass = '1,2,2';
        }
        field(14; "Reserve On Posting"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(15; "AR Workflow Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Workflow;
        }
        field(101; "Order Management Active"; Boolean)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                _OrderMgt: Codeunit "ARC OrderManagement";
            begin
                _OrderMgt.OnValidateOrderMgtActive(Rec);
            end;
        }
        field(102; "Order Translation No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            var
                _OrderMgt: Codeunit "ARC OrderManagement";
            begin
                _OrderMgt.OnValidateOrderTranslationNoSeries(Rec);
            end;
        }
        field(103; "Order Mgt. Log Level"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = None,Error,Warning,Normal,Verbose;

            trigger OnValidate()
            var
                _OrderMgt: Codeunit "ARC OrderManagement";
            begin
                _OrderMgt.OnValidateOrderMgtLogLevel(Rec);
            end;
        }
        field(104; "Order Mgt. Handle EFT Txs."; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(201; "eCommerce Order Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(211; "eCommerce Process No. Entries"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(212; "eCommerce Max. No. of Attempts"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(213; "eCommerce Auto-Release"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(214; "eCommerce Bypass Price/Promotion"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(221; "eCommerce Strip Leading Chars."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(50050; "AR Summary Export File"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(50051; "AR Summary Export Day of Month"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(50052; "AR Aging Summary Versions"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(50053; "AR Aging Summary Measures"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(50054; "AR Aging Summary LOB"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3));
        }
        field(50055; "AR Aging Summary Function"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(50056; "AR Aging Summary Currency"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(50061; "Sales Terms and Conditions"; Blob)
        {
            DataClassification = CustomerContent;
        }
        field(50062; "AR Aging Summary 0D Account"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Debit Account 0D';
        }
        field(50063; "AR Aging Summary 30D Account"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Debit Account 30D';
        }
        field(50064; "AR Aging Summary 60D Account"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Debit Account 60D';
        }
        field(50065; "AR Aging Summary 90D Account"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Debit Account 90D';
        }
        field(50066; "AR Aging Summary 120D Account"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Debit Account 120D';
        }
        field(50067; "AR Aging Summary 180D Account"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Debit Account 180D';
        }
        field(50068; "AR Aging Summary 365D Account"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Debit Account 365D';
        }
        field(50069; "AR Aging Summary Billing Account"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Billing Account 0D';
        }
        field(50071; "SalesPerson Dimension 1"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Dimension;
        }
        field(50072; "SalesPerson Dimension 2"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Dimension;
        }

        field(50073; "SalesPerson Dimension 3"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Dimension;
        }

        field(50074; "SalesPerson Dimension 4"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Dimension;
        }

        field(50075; "SalesPerson Dimension 5"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Dimension;
        }
        field(50076; "SalesPerson Dimension 6"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Dimension;
        }
        field(50077; "SalesPerson Dimension 7"; Code[20])
        {
            TableRelation = Dimension;
            DataClassification = CustomerContent;
        }
        field(50078; "AR Aging Summary 0D Credit Account"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Credit Account 0D';
        }
        field(50079; "AR Aging Summary 30D Credit Account"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Credit Account 30D';
        }
        field(50080; "AR Aging Summary 60D Credit Account"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Credit Account 60D';
        }
        field(50081; "AR Aging Summary 90D Credit Account"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Credit Account 90D';
        }
        field(50082; "AR Aging Summary 120D Credit Account"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Credit Account 120D';
        }
        field(50083; "AR Aging Summary 180D Credit Account"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Credit Account 180D';
        }
        field(50084; "AR Aging Summary 365D Credit Account"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Credit Account 365D';
        }
        field(50085; "Cr. Limit Threshold Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50090; "DDC Invoice File Path"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(50091; "OnGuard Invoice File Path"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(50092; "No. of Invoice Per Batch"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(50093; "Test Posting Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(50100; "Internal Customer Order Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(50101; "Contract Price Expiry"; DateFormula)
        {
            DataClassification = CustomerContent;
        }
        field(50102; "DDC CrMemo File Path"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(50103; "DDC CrMemo File Path - All"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(50104; "Price Admin User Group"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "User Group";
        }
        field(50200; "Invoice Report ID"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(50201; "Invoice Report File Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
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

    procedure GetTermsandConditions(): Text
    var
        TempBlob: Record TempBlob;
        CR: Text[1];
    begin
        CALCFIELDS("Sales Terms and Conditions");
        IF NOT "Sales Terms and Conditions".HASVALUE THEN
            EXIT('');
        CR[1] := 10;
        TempBlob.Blob := "Sales Terms and Conditions";
        EXIT(TempBlob.ReadAsText(CR, TEXTENCODING::Windows));
    end;

    procedure SetTermsandConditions(NewTerms: Text);
    var
        TempBlob: Record TempBlob;
    begin
        CLEAR("Sales Terms and Conditions");
        IF NewTerms = '' THEN
            EXIT;
        TempBlob.Blob := "Sales Terms and Conditions";
        TempBlob.WriteAsText(NewTerms, TEXTENCODING::Windows);
        "Sales Terms and Conditions" := TempBlob.Blob;
        MODIFY;
    end;
}
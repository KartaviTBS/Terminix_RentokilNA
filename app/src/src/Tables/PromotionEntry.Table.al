table 50034 "ARC Promotion Entry"
{
    Caption = 'Promotion Entry';
    DataClassification = CustomerContent;
    DataCaptionFields = "Entity Name","No.";
    DrillDownPageId = "ARC Promotion Entry List";
    LookupPageId = "ARC Promotion Entry List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Location Code"; Code[20])
        {
            TableRelation = Location;
        }
        field(4; "Entity Type"; Option)
        {
            OptionMembers = Customer, "Customer Price Group", "Customer Posting Group";
            OptionCaption = 'Customer,Customer Price Group,Customer Posting Group';
        }
        field(5; "Entity No."; Code[20])
        {
            TableRelation = if("Entity Type" = const ("Customer Price Group")) "Customer Price Group"
            else if("Entity Type" = const (Customer)) Customer
            else if("Entity Type" = const ("Customer Posting Group")) "Customer Posting Group";

            trigger OnValidate()
            var
                Customer: Record Customer;
                CustomerPostingGroup: Record "Customer Posting Group";
                CustomerPriceGroup: Record "Customer Price Group";
            begin
                case "Entity Type" of
                    "Entity Type"::Customer :
                        if Customer.Get("Entity No.") then
                    "Entity Name" := Customer.Name;
                "Entity Type"::"Customer Posting Group" :
                        if CustomerPostingGroup.Get("Entity No.") then
                    "Entity Name" := CustomerPostingGroup.Description;
                "Entity Type"::"Customer Price Group" :
                        if CustomerPriceGroup.Get("Entity No.") then
                    "Entity Name" := CustomerPriceGroup.Description;
                end;
            end;
        }
        field(6; "Entity Name"; Text[50])
        {
            Editable = false;
        }
        field(7; Type; Option)
        {
            OptionMembers = " ", Item, Resource, "Item Discount Group", "Resource Group";
            OptionCaption = ' ,Item,Resource,Item Discount Group,Resource Group';
        }
        field(8; "No."; code[20])
        {
            TableRelation = IF(Type = CONST (" ")) "Standard Text"
            ELSE IF(Type = CONST (Resource)) Resource
            ELSE IF(Type = CONST ("Item Discount Group")) "Item Discount Group"
            ELSE IF(Type = CONST ("Resource Group")) "Resource Group"
            ELSE IF(Type = CONST (Item)) Item WHERE (Blocked = CONST (false));

            ValidateTableRelation = false;

            trigger OnValidate()
            var
                Item: Record Item;
                Resource: Record Resource;
                ItemDiscountGroup: Record "Item Discount Group";
                ResourceGroup: Record "Resource Group";
            begin
                case Type of
                    Type::Item :
                        if Item.Get("No.") then begin
                    "No. 2" := Item."No. 2";
                    Description := Item.Description;
                    "Agency Include" := Item."ARC Agency Item";
                    "MCP Include" := Item."ARC MCP";
                    "Manufacturer Code" := Item."Manufacturer Code";
                    "Item Category Code" := Item."Item Category Code";
                end;
                Type::"Item Discount Group" :
                        if ItemDiscountGroup.Get("No.") then
                    Description := ItemDiscountGroup.Description;
                Type::"Resource Group" :
                        if ResourceGroup.Get("No.") then
                    Description := ResourceGroup.Name;

                end;
            end;
        }
        field(9; "No. 2"; code[20])
        {
            Editable = false;
        }
        field(10; Description; code[50])
        {
            Editable = false;
        }
        field(11; "Agency Include"; Boolean)
        {
            Editable = false;
            Caption = 'Agency Item';
        }
        field(12; "MCP Include"; Boolean)
        {
            Editable = false;
            Caption = 'MCP Item';
        }
        field(13; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(14; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE ("Item No." = FIELD ("No."));            
        }
        field(15; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No." = FIELD ("Entity No."));
        }
        field(16; "Manufacturer Code"; Code[10])
        {
            Caption = 'Manufacturer Code';
            Editable = false;
            TableRelation = Manufacturer.Code;
        }
        field(17; "Item Category Code"; Code[10])
        {
            Caption = 'Item Category Code';
            Editable = false;
            TableRelation = "Item Category".Code;
        }
        field(18; "Promotion Code"; Code[20])
        {
            TableRelation = "ARC Promotion";
        }
        field(19; "Promotion Description"; Text[100]) /// Absolute name includes . so removed it
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup ("ARC Promotion".Description Where ("Code" = field ("Promotion Code")));
        }
        field(20; "Promotion Inclusion"; Option)
        {
            OptionMembers = Automatic, "Optional", "Mandatory";
            OptionCaption = 'Automatic,Optional,Mandatory';
        }
        field(21; "Promotion 1 Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(22; "Promotion 1 UOM Code"; Code[10])
        {

            TableRelation = "Item Unit of Measure".Code WHERE ("Item No." = FIELD ("Promotion 1 Item No."));
        }
        field(23; "Promotion 1 Variant Code"; Code[10])
        {

            TableRelation = "Item Variant".Code WHERE ("Item No." = FIELD ("Promotion 1 Item No."));
        }

        field(24; "Promotion 1 Tax Group Code"; Code[10])
        {
            TableRelation = "Tax Group";
        }
        field(25; "Promotion 1 Quantity"; Decimal)
        {

        }
        field(26; "Promotion 1 Amount"; Decimal)
        {

        }
        field(27; "Promotion 1 Discount %"; Decimal)
        {
            trigger OnValidate();
            begin
                if "Promotion 1 Discount %" <> 0 then
                    Clear("Promotion 1 Discount Amount");
            end;
        }
        field(28; "Promotion 1 Discount Amount"; Decimal)
        {
            trigger OnValidate();
            begin
                If "Promotion 1 Discount Amount" <> 0 then
                    Clear("Promotion 1 Discount %");
            end;
        }
        field(29; "Promotion 1 Qty. Multiplier"; Boolean)
        {

        }
        field(30; "Promotion 1 Max Value"; Decimal)
        {

        }
        field(31; "Promotion 2 Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(32; "Promotion 2 UOM Code"; Code[10])
        {
            TableRelation = "Item Unit of Measure".Code WHERE ("Item No." = FIELD ("Promotion 2 Item No."));
        }
        field(33; "Promotion 2 Variant Code"; Code[10])
        {
            TableRelation = "Item Variant".Code WHERE ("Item No." = FIELD ("Promotion 2 Item No."));
        }
        field(34; "Promotion 2 Tax Group Code"; Code[10])
        {
            TableRelation = "Tax Group";
        }
        field(35; "Promotion 2 Quantity"; Decimal)
        {

        }
        field(36; "Promotion 2 Amount"; Decimal)
        {

        }
        field(37; "Promotion 2 Discount %"; Decimal)
        {
            trigger OnValidate();
            begin
                if "Promotion 2 Discount %" <> 0 then
                    Clear("Promotion 2 Discount Amount");
            end;
        }
        field(38; "Promotion 2 Discount Amount"; Decimal)
        {
            trigger OnValidate();
            begin
                If "Promotion 2 Discount Amount" <> 0 then
                    Clear("Promotion 2 Discount %");
            end;
        }
        field(39; "Promotion 2 Qty. Multiplier"; Boolean)
        {

        }
        field(40; "Promotion 2 Max Value"; Decimal)
        {

        }
        field(41; "Supplier No."; Code[20])
        {
            TableRelation = Vendor;
        }
        field(42; "Supplier Funded"; Boolean)
        {

        }
        field(43; "Country/Region Code"; Code[20])
        {
            TableRelation = "Country/Region";
        }
        field(45; County; Text[30])
        {
           Caption = 'State';
        }
        field(51; "Effective Date"; Date)
        {
            Caption = 'Effective Date';

            trigger OnValidate()
            begin
                if("Effective Date" > "Expiration Date") and("Expiration Date" <> 0D) then
                    Error(Text000, FieldCaption("Effective Date"), FieldCaption("Expiration Date"));

                if CurrFieldNo = 0 then
                    exit;
            end;
        }
        field(62; "Discount %"; Decimal)
        {
            trigger OnValidate();
            begin
                if "Discount %" <> 0 then
                    Clear("Discount Amount");
            end;
        }
        field(63; "Discount Amount"; Decimal)
        {
            trigger OnValidate();
            begin
                if "Discount Amount" <> 0 then
                    Clear("Discount %");
            end;
        }
        field(52; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';

            trigger OnValidate()
            begin
                if CurrFieldNo = 0 then
                    exit;

                Validate("Effective Date");
            end;
        }
        field(54; "Created By"; Code[50])
        {
            Editable = false;
        }
        field(55; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(56; "Currency Code"; Code[20])
        {
            TableRelation = Currency;
        }
        field(57; "Modified By"; Code[50])
        {
            Editable = false;
        }
        field(58; "Modified On"; DateTime)
        {
            Editable = false;
        }
        field(59; "Approved By"; Code[50])
        {
            TableRelation = User."User Name";
            Editable = false;
        }
        field(60; "Approved On"; DateTime)
        {
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        Text000: Label '%1 cannot be after %2';
        Text001: Label '%1 must be blank.';
        Text002: Label 'You cannot create price entry, becuase you are not associated with Salesperson code';
        Text003: Label 'User setup does not exist for the user %1';
        RecRef: RecordRef;
        xRecRef: RecordRef;
        DVPSynchTriggerPublisher: Codeunit "NTN Synch Trigger Publisher";
        PostCode: Record "Post Code";

    trigger OnInsert();
    begin
        CanUserCreateEntry();
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        "Modified By" := UserId;
        "Modified On" := CurrentDateTime;
        RecRef.GetTable(Rec);
        DVPSynchTriggerPublisher.OnInsertSynchTrigger(RecRef);
    end;

    trigger OnModify();
    begin
        "Modified By" := UserId;
        "Modified On" := CurrentDateTime;
        RecRef.GetTable(Rec);
        DVPSynchTriggerPublisher.OnModifySynchTrigger(RecRef);
    end;

    trigger OnDelete();
    begin
        RecRef.GetTable(Rec);
        DVPSynchTriggerPublisher.OnDeleteSynchTrigger(RecRef);
    end;

    trigger OnRename();
    begin
        RecRef.GetTable(Rec);
        xRecRef.GetTable(xRec);
        DVPSynchTriggerPublisher.OnRenameSynchTrigger(RecRef, xRecRef);
    end;

    local procedure CanUserCreateEntry();
    var
        UserSetup: Record "User Setup";
        SalesPerson: Record "Salesperson/Purchaser";
    begin
        if not UserSetup.Get(UserId) then
            Error(Text003,UserId);
        if UserSetup."Salespers./Purch. Code" = '' then
            Error(Text002);
        SalesPerson.Get(UserSetup."Salespers./Purch. Code");
        SalesPerson.TestField("ARC Manager");
        SalesPerson.TestField("ARC Agency User Group");
        SalesPerson.TestField("ARC MCP User Group");
    end;
}
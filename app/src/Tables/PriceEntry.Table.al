table 50033 "ARC Price Entry"
{
    Caption = 'Price Entry';
    DataClassification = CustomerContent;
    DrillDownPageId = "ARC Price Entry List";
    LookupPageId = "ARC Price Entry List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Shorcut Dimension 1 Code"; Code[20])
        {

        }
        field(3; "Shorcut Dimension 2 Code"; Code[20])
        {

        }
        field(4; "Entity Type"; Option)
        {
            OptionMembers = Customer, "Customer Price Group", "Customer Posting Group","All Customers";
            OptionCaption = 'Customer,Customer Price Group,Customer Posting Group,All Customers';

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
            OptionMembers = " ", Item, Resource, "Item Discount Group", "Resource Group","All Items";
            OptionCaption = ' ,Item,Resource,Item Discount Group,Resource Group,All Items';
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
                CanUserCreateEntry();
                If  not ("Entity Type" in ["Entity Type"::"All Customers"]) then
                    Testfield("Entity No.");

                case Type of
                    Type::Item :
                        if Item.Get("No.") then begin
                    "No. 2" := Item."No. 2";
                    Description := Item.Description;
                    "Agency Include" := Item."ARC Agency Item";
                    "MCP Include" := Item."ARC MCP";
                    "Manufacturer Code" := Item."Manufacturer Code";
                    "Item Category Code" := Item."Item Category Code";
                    "Minimum Price" := Item."ARC Minimum Price";
                end;
                Type::"Item Discount Group" :
                        if ItemDiscountGroup.Get("No.") then
                    Description := ItemDiscountGroup.Description;
                Type::"Resource Group" :
                        if ResourceGroup.Get("No.") then
                    Description := ResourceGroup.Name;
                Type:: "All Items":
                    Description := 'All Items';    

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
            TableRelation = "Item Variant".Code WHERE ("Item No." = FIELD ("No."));
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
        field(18; Method; Option)
        {
            OptionMembers = MarkUp, Discount, "Fixed";
            OptionCaption = 'Margin,Discount,Fixed';

            trigger OnValidate()
            begin
                If Method <> xRec.Method then
                    Validate("Method Value",0);
                CalculateNetPrice;
            end;
        }
        field(19; "Method Value."; Decimal) /// Absolute name includes . so removed it
        {
            Caption = 'Method Value Old';
            AutoFormatType = 2;
            MinValue = 0;
            ObsoleteState = Pending;
        }
        field(20; "Effective Date"; Date)
        {
            Caption = 'Effective Date';

            trigger OnValidate()
            begin
                if("Effective Date" > "Expiration Date") and ("Expiration Date" <> 0D) then
                    Error(Text000, FieldCaption("Effective Date"), FieldCaption("Expiration Date"));

                if CurrFieldNo = 0 then
                    exit;

            end;
        }
        field(21; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';

            trigger OnValidate()
            begin
                if CurrFieldNo = 0 then
                    exit;

                Validate("Effective Date");
            end;
        }

        field(22; "Always Use"; Boolean)
        {

        }
        field(23; Comment; Text[250])
        {

        }
        field(24; "Created By"; Code[50])
        {
            Editable = false;
        }
        field(25; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(30; "Currency Code"; Code[20])
        {
            TableRelation = Currency;
        }
        field(31; "Modified By"; Code[50])
        {
            Editable = false;
        }
        field(32; "Modified On"; DateTime)
        {
            Editable = false;
        }
        field(33; "Net Unit Price"; Decimal)
        {
            trigger OnValidate();
            var
                Item: Record Item;
                ItemUOM: Record "Item Unit of Measure";
                MinPrice: Decimal;
            begin
                CanUserCreateEntry();
                If Item.Get("No.") then begin
                    MinPrice := Item."ARC Minimum Price";
                    If "Unit of Measure Code" <> '' then begin
                        ItemUOM.Get(Item."No.","Unit of Measure Code");
                        MinPrice := ItemUOM."Qty. per Unit of Measure" * MinPrice;
                    end;        

                    If "Net Unit Price" < MinPrice then begin
                        Status := Status::Review;
                        If Item."ARC MCP" then
                            "Approver User Group" := SalesPerson."ARC MCP User Group"
                        else
                            "Approver User Group" := Salesperson."ARC Agency User Group";
                    end else begin 
                        Status := Status::" ";
                        "Approver User Group" := '';
                    end;
                end;
            end;

        }
        field(34; "Method Value"; Decimal)
        {
            AutoFormatType = 2;
            MinValue = 0;

            trigger OnValidate()
            begin
                CalculateNetPrice;
            end;
        }
        field(35; Status; Option)
        {
            OptionMembers = " ", Review, Approved, Rejected;
            OptionCaption = ' ,Review,Approved,Rejected';
            Editable = false;
        }


        field(38; "Approved By"; Code[50])
        {
            TableRelation = User."User Name";
            Editable = false;
        }
        field(39; "Approved On"; DateTime)
        {
            Editable = false;
        }
        field(40; "Approver User Group"; Code[50])
        {
            Editable = false;
        }
        field(41; "Minimum Price"; Decimal)
        {
            Editable = false;
        }
        field(42;"Vendor No.";Code[20])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup (Item."Vendor No." WHERE("No." = FIELD("No.")));
        }
        field(43; "Markup Value"; Decimal)
        {
            
        }
        field(44;"Delete Entry";Boolean)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                PriceMgt: Codeunit "ARC Price Management";    
            begin 
                if CurrFieldNo <> 0 then
                    PriceMgt.VerifyPermissions(Rec);
            end;
        }

    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        Key(Key1; "Expiration Date")
        {

        }
        Key(Key2; "Delete Entry")
        {

        }
    }

    var

        RecRef: RecordRef;
        xRecRef: RecordRef;
        SalesPerson: Record "Salesperson/Purchaser";
        UserSetup: Record "User Setup";
        DVPSynchTriggerPublisher: Codeunit "NTN Synch Trigger Publisher";
        SalesPersonCode: Code[20];        
        Text000: Label '%1 cannot be after %2';
        Text001: Label '%1 must be blank.';
        Text002: Label 'You cannot create price entry, becuase you are not associated with Salesperson code';
        Text003: Label 'User setup does not exist for the user %1';
        LblSalesperson: Label 'The salesperson is %1';


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
    begin
        if not UserSetup.Get(UserId) then
            Error(Text003,UserId);
        if not callFromWebService then begin    
            if UserSetup."Salespers./Purch. Code" = '' then
                Error(Text002);
            SalesPerson.Get(UserSetup."Salespers./Purch. Code");
        end else
            Salesperson.Get(SalesPersonCode);    
              
        SalesPerson.TestField("ARC Manager");
        SalesPerson.TestField("ARC Agency User Group");
        SalesPerson.TestField("ARC MCP User Group");

    end;

    local procedure CalculateNetPrice();
    var
        Item: Record Item;
    begin
        If Type = Type::Item then begin
            Item.Get("No.");
            Item.TestField("ARC Sales Cost");
            Item.TestField("ARC Minimum Price");
            if (Item."ARC Agency Item") and ("Method Value" <> 0) then 
                TestField(Method,Method::"Fixed")
        end;    
        If "Method Value" = 0 then
            Validate("Net Unit Price",0);    
        case "Method" of
            Method::Discount :
                Validate("Net Unit Price", Item."Unit Price" - (("Method Value" / 100) * Item."Unit Price"));
            Method::Fixed :
                Validate("Net Unit Price", "Method Value");
            Method::MarkUp :
                begin
                    If "Method Value" = 0 then
                        Validate("Net Unit Price", 0)
                    else
                        Validate("Net Unit Price", ROUND(Item."ARC Sales Cost" / (1 - ("Method Value" / 100))));
                end;

        end

    end;

    local procedure callFromWebService() :Boolean 
    var
        ClientTypeManagement:Codeunit ClientTypeManagement;
    begin 
        if ClientTypeManagement.GetCurrentClientType in [CLIENTTYPE::SOAP, CLIENTTYPE::OData, CLIENTTYPE::ODataV4] then
            exit(true)
    end;

    procedure SetSalesPersonCode(newSalesPersonCode: Code[20])
    begin 
        SalesPersonCode := newSalesPersonCode;
    end;

}
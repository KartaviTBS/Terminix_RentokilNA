page 50039 "ARC Promotion Entry Card"
{
    PageType = Card;
    SourceTable = "ARC Promotion Entry";
    Caption = 'ARC Promotion Entry Card';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Entity Type"; "Entity Type")
                {
                    ApplicationArea = All;
                }
                field("Entity No."; "Entity No.")
                {
                    ApplicationArea = All;
                }
                field("Entity Name"; "Entity Name")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("No. 2"; "No. 2")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Agency Include"; "Agency Include")
                {
                    ApplicationArea = All;
                }
                field("MCP Include"; "MCP Include")
                {
                    ApplicationArea = All;
                }
                field("Minimum Quantity"; "Minimum Quantity")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Manufacturer Code"; "Manufacturer Code")
                {
                    ApplicationArea = All;
                }
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = All;
                }
                field("Promotion Code"; "Promotion Code")
                {
                    ApplicationArea = All;
                }
                field("Promotion Description"; "Promotion Description")
                {
                    ApplicationArea = All;
                }
                field("Promotion Inclusion"; "Promotion Inclusion")
                {
                    ApplicationArea = All;
                }
                field("Supplier No."; "Supplier No.")
                {
                    ApplicationArea = All;
                }
                field("Supplier Funded"; "Supplier Funded")
                {
                    ApplicationArea = All;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(County; County)
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Discount %"; "Discount %")
                {
                    ApplicationArea = All;
                }
                field("Discount Amount"; "Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Effective Date"; "Effective Date")
                {
                    ApplicationArea = All;
                }
                field("Expiration Date"; "Expiration Date")
                {
                    ApplicationArea = All;
                }
            }
            group("Buy X Get Y")
            {
                field("Promotion 1 Item No."; "Promotion 1 Item No.")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 Quantity"; "Promotion 1 Quantity")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 UOM Code"; "Promotion 1 UOM Code")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 Variant Code"; "Promotion 1 Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 Tax Group Code"; "Promotion 1 Tax Group Code")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 Amount"; "Promotion 1 Amount")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 Discount %"; "Promotion 1 Discount %")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 Discount Amount"; "Promotion 1 Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 Qty. Multiplier"; "Promotion 1 Qty. Multiplier")
                {
                    ApplicationArea = All;
                }
            }
            group(Customer)
            {
                field(customerNo; Customer."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Read-only for web service retrieval';
                }
                field(customerName; Customer.Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Read-only for web service retrieval';
                }
                field(eCommerceEnabled; eCommerceEnabled)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Read-only for web service retrieval';
                }
            }
            group(RecordMetadata)
            {
                Caption = 'Metadata';

                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies Created By';
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies Created On';
                }
                field("Modified By"; Rec."Modified By")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies Modified By';
                }
                field("Modified On"; Rec."Modified On")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies Modified On';
                }
            }
        }
    }

    var
        Customer: Record Customer;
        eCommerceEnabled: Boolean;

    trigger OnAfterGetRecord()
    begin
        if not Customer.Get(Rec."Entity No.") then begin
            Customer.Init();
            eCommerceEnabled := true;
        end else
            eCommerceEnabled := Customer."ARC eCommerce Enabled";
    end;
}
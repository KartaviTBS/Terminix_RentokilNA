page 50038 "ARC Promotion Entry List"
{
    
    PageType = List;
    SourceTable = "ARC Promotion Entry";
    Caption = 'Promotion Entry List';
    CardPageId = "ARC Promotion Entry Card";
    ApplicationArea = All;
    UsageCategory = Lists;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Entity Type"; Rec."Entity Type")
                {
                    ApplicationArea = All;
                }
                field("Entity No."; Rec."Entity No.")
                {
                    ApplicationArea = All;
                }
                field("Entity Name"; Rec."Entity Name")
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("No. 2"; Rec."No. 2")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Agency Include"; Rec."Agency Include")
                {
                    ApplicationArea = All;
                }
                field("MCP Include"; Rec."MCP Include")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Manufacturer Code"; Rec."Manufacturer Code")
                {
                    ApplicationArea = All;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                }
                field("Promotion Code"; Rec."Promotion Code")
                {
                    ApplicationArea = All;
                    
                    trigger OnValidate()                   
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Promotion Description"; Rec."Promotion Description")
                {
                    ApplicationArea = All;
                }
                field("Promotion Inclusion"; Rec."Promotion Inclusion")
                {
                    ApplicationArea = All;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(County; Rec.County)
                {
                    ApplicationArea = All;
                }
                field("Discount %"; Rec."Discount %")
                {
                   ApplicationArea = All;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                }                
                field("Promotion 1 Item No."; Rec."Promotion 1 Item No.")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 UOM Code"; Rec."Promotion 1 UOM Code")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 Variant Code"; Rec."Promotion 1 Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 Tax Group Code"; Rec."Promotion 1 Tax Group Code")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 Quantity"; Rec."Promotion 1 Quantity")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 Amount"; Rec."Promotion 1 Amount")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 Discount %"; Rec."Promotion 1 Discount %")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 Discount Amount"; Rec."Promotion 1 Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 Qty. Multiplier"; Rec."Promotion 1 Qty. Multiplier")
                {
                    ApplicationArea = All;
                }
                field("Promotion 1 Max Value"; Rec."Promotion 1 Max Value")
                {
                    ApplicationArea = All;
                }
                field("Promotion 2 Item No."; Rec."Promotion 2 Item No.")
                {
                    ApplicationArea = All;
                }
                field("Promotion 2 UOM Code"; Rec."Promotion 2 UOM Code")
                {
                    ApplicationArea = All;
                }
                field("Promotion 2 Variant Code"; Rec."Promotion 2 Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Promotion 2 Tax Group Code"; Rec."Promotion 2 Tax Group Code")
                {
                    ApplicationArea = All;
                }
                field("Promotion 2 Quantity"; Rec."Promotion 2 Quantity")
                {
                    ApplicationArea = All;
                }
                field("Promotion 2 Amount"; Rec."Promotion 2 Amount")
                {
                    ApplicationArea = All;
                }
                field("Promotion 2 Discount %"; Rec."Promotion 2 Discount %")
                {
                    ApplicationArea = All;
                }
                field("Promotion 2 Discount Amount"; Rec."Promotion 2 Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Promotion 2 Qty. Multiplier"; Rec."Promotion 2 Qty. Multiplier")
                {
                    ApplicationArea = All;
                }
                field("Promotion 2 Max Value"; Rec."Promotion 2 Max Value")
                {
                    ApplicationArea = All;
                }
                field("Supplier No."; Rec."Supplier No.")
                {
                    ApplicationArea = All;
                }
                field("Supplier Funded"; Rec."Supplier Funded")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Effective Date"; Rec."Effective Date")
                {
                    ApplicationArea = All;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = All;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = All;
                }
                field("Modified By"; Rec."Modified By")
                {
                    ApplicationArea = All;
                }
                field("Modified On"; Rec."Modified On")
                {
                    ApplicationArea = All;
                }
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
        }
    }
    actions
    {
        area(processing)
        {
            action(ImportPriceEntries)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Import Promotion Entries';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = false;
                PromotedOnly = true;
                ToolTip = 'Import a Promotion Entry File.';

                trigger OnAction()
                begin
                    XMLPORT.Run(XMLPORT::"ARC Promotion Entry Import", false, true);                        
                end;
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
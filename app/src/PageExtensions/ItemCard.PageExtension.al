pageextension 50001 "ARC Item Card" extends "Item Card"
{
    layout
    {
        addafter(Description)
        {
            field("Description 2"; Rec."Description 2")
            {
                ApplicationArea = All;
            }
            field("ARC Web Enabled"; Rec."ARC Web Enabled")
            {
                ApplicationArea = All;
                Importance = Additional;
                ToolTip = 'Enables the item for Adobe Commerce';
            }
            field("Updated In 2Ship";"Updated In 2Ship")
            {
                ApplicationArea = all;
            }
        }
        addafter("Item Category Code")
        {
            field("ARC Ranking Code"; Rec."ARC Ranking Code")
            {
                ApplicationArea = All;
            }
        }
        addafter(Blocked)
        {
            field("ARC Block Regulatory"; Rec."ARC Block Regulatory")
            {
                Importance = Promoted;
                ApplicationArea = Basic,Suite;
                ToolTip = 'Specifies that the related record is blocked for regulatory, for example a customer that is declared insolvent or an item that is placed in quarantine.';
            }
            field("ARC Purchase Block"; Rec."ARC Purchase Block")
            {
                ApplicationArea = Basic,Suite;
                ToolTip = 'To block purchasing Items';
            }

            field("ARC Quick Item"; Rec."ARC Quick Item")
            {
                Importance = Promoted;
                ApplicationArea = Basic, Suite;
            }
        }
        addafter("Item Category Code")
        {
            field("Manufacture Code"; "Manufacturer Code")
            {
                Importance = Promoted;
                ApplicationArea = Basic,Suite;
            }
            field("ARC SDS Product Code"; Rec."ARC SDS Product Code")
            {
                Importance = Promoted;
                ApplicationArea = Basic,Suite;
            }
            field("ARC BOL/UN/Ground Code"; Rec."ARC BOL/UN/Ground Code")
            {
                Importance = Promoted;
                ApplicationArea = Basic,Suite;
            }
            field("ARC BOL/UN/Air Code"; Rec."ARC BOL/UN/Air Code")
            {
                Importance = Promoted;
                ApplicationArea = Basic,Suite;
            }
            field("ARC BOL/UN/Water Code"; Rec."ARC BOL/UN/Water Code")
            {
                Importance = Promoted;
                ApplicationArea = Basic,Suite;
            }
            field("ARC SDS Revision Date"; Rec."ARC SDS Revision Date")
            {
                Importance = Promoted;
                ApplicationArea = Basic,Suite;
            }
            field("ARC Agency Payment Terms"; Rec."ARC Agency Payment Terms")
            {
                Importance = Promoted;
                ApplicationArea = Basic,Suite;
            }
            field("ARC Agency Code"; Rec."ARC Agency Code")
            {
                Importance = Promoted;
                ApplicationArea = Basic,Suite;
            }
            field("ARC Commission Ranking"; Rec."ARC Commission Ranking")
            {
                ApplicationArea = Basic,Suite;
            }
        }
        addafter("Unit Cost")
        {
            field("ARC Sales Cost"; Rec."ARC Sales Cost")
            {
                ApplicationArea = Basic,Suite;
            }
        }
        addafter("Unit Price")
        {
            field("ARC Minimum Price"; Rec."ARC Minimum Price")
            {
                ApplicationArea = Basic,Suite;
            }
           
            field("ARC MCP"; Rec."ARC MCP")
            {
                ApplicationArea = Basic,Suite;
            }
            field("ARC Agency Item"; "ARC Agency Item")
            {
                Importance = Promoted;
                ApplicationArea = Basic,Suite;
                ToolTip = 'Identifies if an item is agency item or not';
            }
            field("ARC Free Item"; Rec."ARC Free Item")
            {
                Importance = Promoted;
                ApplicationArea = Basic,Suite;
            }
        }
        addafter("Tax Group Code")
        {
            field("ARC Target LOB"; Rec."ARC Target LOB")
            {
                ApplicationArea = All;
            }
        }
        addlast(Item)
        {
            field("ARC APL"; Rec."ARC APL")
            {
                ApplicationArea = All;
            }
            field("Last DateTime Modified"; Rec."Last DateTime Modified")
            {
                ApplicationArea = All;
                Editable = false;
                Importance = Additional;
            }
            field("NAV Modified Date"; Rec."NAV Modified Date")
            {
                ApplicationArea = All;
                Editable = false;
                Importance = Additional;
            }
        }
    }
    actions
    {
        addlast(Action190)
        {
            action(APL)
            {
                Caption = 'APL Entries';
                Image = Approvals;

                trigger OnAction();
                var
                    _APLMgt: Codeunit "ARC APL Management";
                begin
                    _APLMgt.ShowRecordsRelatedToItem(Rec);
                end;
            }
            action(VFM)
            {
                Caption = 'VFM Entries';
                Image = CoupledCurrency;

                trigger OnAction();
                var
                    _VFMMgt: Codeunit "ARC VFM Management";
                begin
                    _VFMMgt.ShowRecordsRelatedToItem(Rec);
                end;
            }
            action(PriceEntries)
            {
                Caption = 'Price Entries';
                Image = SuggestSalesPrice;
                RunObject = Page "ARC Price Entry List";
                RunPageLink = "Entity No." = FIELD("No.");
            }
            action(SupplementalCharges)
            {
                Caption = 'Supplemental Charges';
                Image = Price;
                RunObject = Page "ARC Item Supplemental Charges";
                RunPageLink = "Item No." = FIELD("No.");
            }
        }
    }
}
page 50184 "ARC Inventory Balance Entries"
{
    // SOW13 Adobe eCommerce to CSM to NAV 2018

    ApplicationArea = All;
    UsageCategory = Lists;
    PageType = List;
    SourceTable = "ARC Inventory Balance Entry";
    Caption = 'Inventory Balance Entries';
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Entries)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                    begin
                        Rec.TestField("Item No.");
                        Item.Get(Rec."Item No.");
                        Page.Run(Page::"Item Card",Item);
                    end;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        Location: Record Location;
                    begin
                        Rec.TestField("Location Code");
                        Location.Get(Rec."Location Code");
                        Page.Run(Page::"Location Card",Location);
                    end;
                }
                field("Location Name"; Rec."Location Name")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Item Ledger Entry No."; Rec."Item Ledger Entry No.")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        ItemLedgEntry: Record "Item Ledger Entry";
                    begin
                        Rec.TestField("Item Ledger Entry No.");
                        ItemLedgEntry.Get(Rec."Item Ledger Entry No.");
                        Page.Run(Page::"Item Ledger Entries",ItemLedgEntry);
                    end;
                }
                field("Created by"; Rec."Created by")
                {
                    ApplicationArea = All;
                }
                field("Created at Date"; Rec."Created at Date")
                {
                    ApplicationArea = All;
                }
                field("Created at DateTime"; Rec."Created at DateTime")
                {
                    ApplicationArea = All;
                }
                field("Created at Time"; Rec."Created at Time")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes) { }
    }

    actions
    {
        area(processing) { }
    }

    trigger OnOpenPage()
    begin
        if Rec.FindLast() then;
        Rec.Ascending(false);
    end;
}
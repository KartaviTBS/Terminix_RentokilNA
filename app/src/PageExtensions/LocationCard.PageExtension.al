pageextension 50006 "ARC Location Card" extends "Location Card"
{
    layout
    {
        addlast(General)
        {
            field("ARC Location IC Code"; Rec."ARC Location IC Code")
            {
                ApplicationArea = Location;
                ToolTip = 'Location IC Code for AGData';
            }
            field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
            {
                ApplicationArea = Dimensions;
                ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                Visible = true;
            }
            field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
            {
                ApplicationArea = Dimensions;
                ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                Visible = true;
            }
            field("ARC Regulaotry Workflow Group Code"; Rec."ARC Regulaotry Workflow Group Code")
            {
                ApplicationArea = All;
            }
            field("ARC COI Location Code"; Rec."ARC COI Location Code")
            {
                ApplicationArea = All;
            }
            field("ARC Enable Korber WMS";Rec."ARC Enable Korber WMS")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether Korber WMS functionality is enabled for this location';
            }
            field("ARC Korber Location Code"; Rec."ARC Korber Location Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the location code to transmit to Korber WMS';
            }
            field("ARC Korber Order Hdr. Code"; Rec."ARC Korber Order Hdr. Code")
            {
                ApplicationArea = All;
                ToolTip = 'If sales order header has Korber WMS Location Code specified, use this value instead during order split';
            }
        }
    }
    actions
    {
        addlast("&Location")
        {
            action(LocationPriorities)
            {
                Image = ItemAvailbyLoc;
                ApplicationArea = All;
                ToolTip = 'Opens a page showing Location Priority records for the location';
                Caption = 'Location Priorities';

                trigger OnAction()
                var
                    _LocationPriorityMgt: Codeunit "ARC LocationPriorityMgt";
                begin
                    _LocationPriorityMgt.OpenPageFromLocationCard(Rec);
                end;
            }
        }
    }
}
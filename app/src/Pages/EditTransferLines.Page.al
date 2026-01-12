page 50079 "Edit Transfer Lines"
{
    ApplicationArea = All;
    Caption = 'Edit Transfer Lines';
    PageType = List;
    SourceTable = "Transfer Line";
    UsageCategory = History;
    Permissions = tabledata "Transfer Line" = rm;
    DeleteAllowed = false;
    InsertAllowed = false;
    Description = 'RENT.SK.1.0';
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field.', Comment = '%';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field("Appl.-to Item Entry"; Rec."Appl.-to Item Entry")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Appl.-to Item Entry field.', Comment = '%';
                }
                field("Completely Received"; Rec."Completely Received")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Completely Received field.', Comment = '%';
                }
                field("Completely Shipped"; Rec."Completely Shipped")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Completely Shipped field.', Comment = '%';
                }
                field("Derived From Line No."; Rec."Derived From Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Derived From Line No. field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 2 field.', Comment = '%';
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension Set ID field.', Comment = '%';
                }
                field("Direct Transfer"; Rec."Direct Transfer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Transfer field.', Comment = '%';
                }
                field("E-Ship Invt. Outst. Qty (Base)"; Rec."E-Ship Invt. Outst. Qty (Base)")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the E-Ship Invt. Outst. Qty (Base) field.', Comment = '%';
                }
                field("E-Ship Invt. Outstanding Qty."; Rec."E-Ship Invt. Outstanding Qty.")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the E-Ship Invt. Outstanding Qty. field.', Comment = '%';
                }
                field("E-Ship Whse. Outst. Qty (Base)"; Rec."E-Ship Whse. Outst. Qty (Base)")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the E-Ship Whse. Outst. Qty (Base) field.', Comment = '%';
                }
                field("E-Ship Whse. Outstanding Qty."; Rec."E-Ship Whse. Outstanding Qty.")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the E-Ship Whse. Outstanding Qty. field.', Comment = '%';
                }
                field("E-Ship Whse. Ship. Qty (Base)"; Rec."E-Ship Whse. Ship. Qty (Base)")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the E-Ship Whse. Ship. Qty (Base) field.', Comment = '%';
                }
                field("E-Ship Whse. Shipment Qty."; Rec."E-Ship Whse. Shipment Qty.")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the E-Ship Whse. Shipment Qty. field.', Comment = '%';
                }
                field("EDI Segment Group"; Rec."EDI Segment Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the EDI Segment Group field.', Comment = '%';
                }
                field("Exclude From Usage"; Rec."Exclude From Usage")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Exclude From Usage field.', Comment = '%';
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field.', Comment = '%';
                }
                field("Gross Weight"; Rec."Gross Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gross Weight field.', Comment = '%';
                }
                field("In-Transit Code"; Rec."In-Transit Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the In-Transit Code field.', Comment = '%';
                }
                field("Inbound Whse. Handling Time"; Rec."Inbound Whse. Handling Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inbound Whse. Handling Time field.', Comment = '%';
                }
                field("Inventory Posting Group"; Rec."Inventory Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inventory Posting Group field.', Comment = '%';
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Category Code field.', Comment = '%';
                }
                field("NAV Created Date"; Rec."NAV Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NAV Created Date field.', Comment = '%';
                }
                field("NAV Modified Date"; Rec."NAV Modified Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NAV Modified Date field.', Comment = '%';
                }
                field("NAV Modified by"; Rec."NAV Modified by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NAV Modified by field.', Comment = '%';
                }
                field("NAV Previously Modified Date"; Rec."NAV Previously Modified Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NAV Previously Modified Date field.', Comment = '%';
                }
                field("Net Weight"; Rec."Net Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Net Weight field.', Comment = '%';
                }
                field("Outbound Whse. Handling Time"; Rec."Outbound Whse. Handling Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Outbound Whse. Handling Time field.', Comment = '%';
                }
                field("Outstanding Qty. (Base)"; Rec."Outstanding Qty. (Base)")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Outstanding Qty. (Base) field.', Comment = '%';
                }
                field("Outstanding Quantity"; Rec."Outstanding Quantity")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Outstanding Quantity field.', Comment = '%';
                }
                field("Planning Flexibility"; Rec."Planning Flexibility")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Planning Flexibility field.', Comment = '%';
                }
                field("Qty. Received (Base)"; Rec."Qty. Received (Base)")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Qty. Received (Base) field.', Comment = '%';
                }
                field("Qty. Shipped (Base)"; Rec."Qty. Shipped (Base)")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Qty. Shipped (Base) field.', Comment = '%';
                }
                field("Qty. in Transit"; Rec."Qty. in Transit")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Qty. in Transit field.', Comment = '%';
                }
                field("Qty. in Transit (Base)"; Rec."Qty. in Transit (Base)")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Qty. in Transit (Base) field.', Comment = '%';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Qty. per Unit of Measure field.', Comment = '%';
                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Qty. to Receive field.', Comment = '%';
                }
                field("Qty. to Receive (Base)"; Rec."Qty. to Receive (Base)")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Qty. to Receive (Base) field.', Comment = '%';
                }
                field("Qty. to Ship"; Rec."Qty. to Ship")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Qty. to Ship field.', Comment = '%';
                }
                field("Qty. to Ship (Base)"; Rec."Qty. to Ship (Base)")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Qty. to Ship (Base) field.', Comment = '%';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Quantity field.', Comment = '%';
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Quantity (Base) field.', Comment = '%';
                }
                field("Quantity Received"; Rec."Quantity Received")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Quantity Received field.', Comment = '%';
                }
                field("Quantity Shipped"; Rec."Quantity Shipped")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Quantity Shipped field.', Comment = '%';
                }
                field("Receipt Date"; Rec."Receipt Date")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Receipt Date field.', Comment = '%';
                }
                field("Reserved Qty. Inbnd. (Base)"; Rec."Reserved Qty. Inbnd. (Base)")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Reserved Qty. Inbnd. (Base) field.', Comment = '%';
                }
                field("Reserved Qty. Outbnd. (Base)"; Rec."Reserved Qty. Outbnd. (Base)")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Reserved Qty. Outbnd. (Base) field.', Comment = '%';
                }
                field("Reserved Qty. Shipped (Base)"; Rec."Reserved Qty. Shipped (Base)")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Reserved Qty. Shipped (Base) field.', Comment = '%';
                }
                field("Reserved Quantity Inbnd."; Rec."Reserved Quantity Inbnd.")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Reserved Quantity Inbnd. field.', Comment = '%';
                }
                field("Reserved Quantity Outbnd."; Rec."Reserved Quantity Outbnd.")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Reserved Quantity Outbnd. field.', Comment = '%';
                }
                field("Reserved Quantity Shipped"; Rec."Reserved Quantity Shipped")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Reserved Quantity Shipped field.', Comment = '%';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Date field.', Comment = '%';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Agent Code field.', Comment = '%';
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field.', Comment = '%';
                }
                field("Shipping Time"; Rec."Shipping Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Time field.', Comment = '%';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field.', Comment = '%';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field.', Comment = '%';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }
                field("Suggested Order Line No."; Rec."Suggested Order Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Suggested Order Line No. field.', Comment = '%';
                }
                field("Suggested Order No."; Rec."Suggested Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Suggested Order No. field.', Comment = '%';
                }             
                field("Transfer-To Bin Code"; Rec."Transfer-To Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transfer-To Bin Code field.', Comment = '%';
                }
                field("Transfer-from Bin Code"; Rec."Transfer-from Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transfer-from Bin Code field.', Comment = '%';
                }
                field("Transfer-from Code"; Rec."Transfer-from Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transfer-from Code field.', Comment = '%';
                }
                field("Transfer-to Code"; Rec."Transfer-to Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transfer-to Code field.', Comment = '%';
                }
                field("Unit Volume"; Rec."Unit Volume")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Volume field.', Comment = '%';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure field.', Comment = '%';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field.', Comment = '%';
                }
                field("Units per Parcel"; Rec."Units per Parcel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Units per Parcel field.', Comment = '%';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field.', Comment = '%';
                }
                field("Whse Outbnd. Otsdg. Qty (Base)"; Rec."Whse Outbnd. Otsdg. Qty (Base)")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Whse Outbnd. Otsdg. Qty (Base) field.', Comment = '%';
                }
                field("Whse. Inbnd. Otsdg. Qty (Base)"; Rec."Whse. Inbnd. Otsdg. Qty (Base)")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the value of the Whse. Inbnd. Otsdg. Qty (Base) field.', Comment = '%';
                }
            }
        }
    }
    trigger OnOpenPage();
    var
        PermissionErr : Label 'Access Denied';
    begin
        if not (UserId in ['RI-NA\SAKETH.KARROLA','RI-NA\SKARROLA-SDM','RI-NA\JENNIFER.GUNTER','RI-NA\SDM-JENNIFER.GUNTER','RI-NA\ERIK.HOLMBERG','RI-NA\SDM-ERIK.HOLMBERG','RI-NA\SHAUN.JETER','RI-NA\SDM-SHAUN.JETER']) then
            Error(PermissionErr);

    end;
}

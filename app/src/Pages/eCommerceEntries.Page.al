page 50183 "ARC eCommerce Entries"
{
    // SOW13 Adobe eCommerce to CSM to NAV 2018

    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    ModifyAllowed = false;
    DeleteAllowed = false;
    SourceTable = "ARC eCommerce Entry";
    Caption = 'eCommerce Entries';

    layout
    {
        area(content)
        {
            repeater(Entries)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Entry No.';
                }
                field("Order ID"; Rec."eCom Order ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Order ID';
                }
                field("Customer No."; Rec."eCom Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Customer No.';

                    trigger OnDrillDown()
                    begin
                        eCommerceMgt.ShowCustomer(Rec);
                    end;
                }
                field("eCom Your Reference"; Rec."eCom Your Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Your Reference';
                }
                field("eCom Customer PO No."; Rec."eCom Customer PO No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Customer PO No.';
                }
                field("eCom Payment Method Code"; Rec."eCom Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Payment Method Code';
                }
                field("eCom Shipment Method Code"; Rec."eCom Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Shipment Method Code';
                }
                field("eCom Shipping Agent Code"; Rec."eCom Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Shipping Agent Code';
                }
                field("eCom Ship-to Code"; Rec."eCom Ship-to Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Ship-to Code';
                }
                field("eCom Ship-to Name"; Rec."eCom Ship-to Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Ship-to Name';
                }
                field("eCom Ship-to Name 2"; Rec."eCom Ship-to Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Ship-to Name 2';
                }
                field("eCom Ship-to Address"; Rec."eCom Ship-to Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Ship-to Address';
                }
                field("eCom Ship-to Address 2"; Rec."eCom Ship-to Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Ship-to Address 2';
                }
                field("eCom Ship-to City"; Rec."eCom Ship-to City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Ship-to City';
                }
                field("eCom Ship-to County"; Rec."eCom Ship-to County")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Ship-to County';
                }
                field("eCom Ship-to Post Code"; Rec."eCom Ship-to Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Ship-to Post Code';
                }
                field("eCom Ship-to Country"; Rec."eCom Ship-to Country")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Ship-to Country';
                }
                field("eCom Type"; Rec."eCom Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Type';
                }
                field("eCom No."; Rec."eCom No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom No.';

                    trigger OnDrillDown()
                    begin
                        eCommerceMgt.ShowNo(Rec);
                    end;
                }
                field("eCom Quantity"; Rec."eCom Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Quantity';
                }
                field("eCom Unit of Measure Code"; Rec."eCom Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Unit of Measure Code';
                }
                field("eCom Unit Price"; Rec."eCom Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Unit Price';
                }
                field("eCom Line Discount Amount"; Rec."eCom Line Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Line Discount Amount';
                }
                field("eCom Amount"; Rec."eCom Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Amount';
                }
                field("eCom Amount Including VAT"; Rec."eCom Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Amount Including VAT';
                }
                field("eCom Amount Mismatch"; Rec."eCom Amount Mismatch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether a mismatch exists between eCommerce Amount and legacy ERP Amount';
                }
                field("eCom Bypass Price/Promo"; Rec."eCom Bypass Price/Promo")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether custom price/promotion logic should be bypassed (system default in RNA Setup)';
                }
                field("eCom Group Count"; Rec."eCom Group Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies eCom Group Count';
                }
                field("eCom. eBiz Cust. Token";"eCom. eBiz Cust. Token")
                {
                    ApplicationArea = All;
                }
                field("eCom. eBiz Pmt. Token";"eCom. eBiz Pmt. Token")
                {
                    ApplicationArea = All;
                }
                field("eCom. eBiz Last4";"eCom. eBiz Last4")
                {
                    ApplicationArea = All;
                }
                field("Created by"; Rec."Created by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Created by';
                }
                field("Created at Date"; Rec."Created at Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Created at Date';
                }
                field("Created at DateTime"; Rec."Created at DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Created at DateTime';
                }
                field("Created at Time"; Rec."Created at Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Created at Time';
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Processed';
                }
                field("Processed at Date"; Rec."Processed at Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Processed at Date';
                }
                field("Processed at DateTime"; Rec."Processed at DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Processed at DateTime';
                }
                field("Processed at Time"; Rec."Processed at Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Processed at Time';
                }
                field("Processed Duration"; Rec."Processed Duration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Processed Duration';
                }
                field("Processed No. of Attempts"; Rec."Processed No. of Attempts")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Processed No. of Attempts';
                }
                field("Processed Data Entry No."; Rec."Processed Data Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Processed Data Entry No.';

                    trigger OnDrillDown()
                    begin
                        Rec.TestField("Processed Data Entry No.");
                        DataMgt.ShowValueFromEntryNo(Rec."Processed Data Entry No.");
                    end;
                }
                field("Processed Error Text"; Rec."Processed Error Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Processed Error Text';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Document No.';

                    trigger OnDrillDown()
                    begin
                        eCommerceMgt.ShowDocument(Rec);
                    end;
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Document Line No.';
                }
            }
        }
        area(factboxes) { }
    }

    actions
    {
        area(Navigation)
        {
            action(JobQueue)
            {
                ApplicationArea = All;
                Image = Job;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Job Queue';

                trigger OnAction()
                begin
                    eCommerceMgt.ShowJobQueue();
                end;
            }
            action(OrdTranslEntries)
            {
                ApplicationArea = All;
                Image = CoupledOrderList;
                Caption = 'Order Transl.';
                ToolTip = 'Show the Order Translation Entries';

                trigger OnAction()
                begin
                    eCommerceMgt.ShowOrdTranslEntriesFreCommerceEntries(Rec);
                end;
            }
            action(WebService)
            {
                ApplicationArea = All;
                Image = Web;
                Caption = 'Web Service';

                trigger OnAction()
                begin
                    eCommerceMgt.ShowWebService();
                end;
            }
        }
        area(Processing)
        {
            action(Reset)
            {
                ApplicationArea = All;
                Image = ResetStatus;
                ToolTip = 'Reset one or more records for re-processing';
                Caption = 'Reset';

                trigger OnAction()
                var
                    eCommerceEntry: Record "ARC eCommerce Entry";
                    entryNo: BigInteger;
                begin
                    entryNo := Rec."Entry No.";
                    CurrPage.SetSelectionFilter(eCommerceEntry);
                    eCommerceMgt.ResetEntry(eCommerceEntry);
                    CurrPage.Update(false);
                    if Rec.Get(entryNo) then;
                end;
            }
            action(MarkAsFailed)
            {
                ApplicationArea = All;
                Image = FaultDefault;
                ToolTip = 'Mark one or more records as failed';
                Caption = 'Mark as Failed';

                trigger OnAction()
                var
                    eCommerceEntry: Record "ARC eCommerce Entry";
                    entryNo: BigInteger;
                begin
                    entryNo := Rec."Entry No.";
                    CurrPage.SetSelectionFilter(eCommerceEntry);
                    eCommerceMgt.MarkAsFailed(eCommerceEntry);
                    CurrPage.Update(false);
                    if Rec.Get(entryNo) then;
                end;
            }
            action(TogglePricePromotion)
            {
                ApplicationArea = All;
                Image = ReverseLines;
                ToolTip = 'Toggle the Bypass Price/Promotion flag on selected records';
                Caption = 'Toggle Bypass Price/Promotion';

                trigger OnAction()
                var
                    eCommerceEntry: Record "ARC eCommerce Entry";
                    entryNo: BigInteger;
                begin
                    entryNo := Rec."Entry No.";
                    CurrPage.SetSelectionFilter(eCommerceEntry);
                    eCommerceMgt.ToggleBypassPricePromotion(eCommerceEntry);
                    CurrPage.Update(false);
                    if Rec.Get(entryNo) then;
                end;
            }
        }
    }

    var
        DataMgt: Codeunit "ARC DataMgt";
        eCommerceMgt: Codeunit "ARC eCommerceMgt";

    trigger OnOpenPage()
    begin
        if Rec.FindLast() then;
        Rec.Ascending(false);
        CurrPage.Editable(not GuiAllowed());
    end;
}
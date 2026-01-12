pageextension 50007 "ARC Sales Order" extends "Sales Order"
{
    layout
    {

        addafter(General)
        {

            group("Workwave")
            {
                field("ARC WW Amount Authorized"; Rec."ARC WW Amount Authorized")
                {
                    ApplicationArea = All;
                }
                field("ARC WW Amount Charged"; Rec."ARC WW Amount Charged")
                {
                    ApplicationArea = All;
                }
                field("ARC WW Amount Charged Settled"; Rec."ARC WW Amount Charge Settled")
                {
                    ApplicationArea = All;
                }
                field("ARC WW Amount Charged Open"; Rec."ARC WW Amount Charged Open")
                {
                    ApplicationArea = All;
                }
                
            }            
        }
        addlast(General)
        {
            field(Priority_Korber;Priority_Korber)
            {
                ApplicationArea = all;
            }
            field("Pending Deletion";"Pending Deletion")
            {
                ApplicationArea = all;
            }
        }        

        addafter("Sell-to Customer Name")
        {
            field("Customer Name 2"; Rec."Sell-to Customer Name 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Bill-to Name")
        {
            field("Bill-to Name 2"; Rec."Bill-to Name 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Ship-to Name")
        {
            field("Ship-to Name 2"; Rec."Ship-to Name 2")
            {
                ApplicationArea = All;
            }
        }

        addafter("Ship-to County")
        {
            field("ARC Locality Code"; Rec."ARC Locality Code")
            {
                Importance = Promoted;
                ApplicationArea = Basic, Suite;
            }
            field("ARC Business Type Code"; Rec."ARC Business Type Code")
            {
                Importance = Promoted;
                ApplicationArea = Basic, Suite;
            }
        }
        addafter("Assigned User ID")
        {
            field("ARC Created By"; Rec."ARC Created By")
            {
                ApplicationArea = All;
            }

        }
        addbefore(Status)
        {
            field("ARC COI Order"; Rec."ARC COI Order")
            {
                ApplicationArea = All;
            }

            field("ARC Regulatory Hold"; Rec."ARC Regulatory Hold")
            {
                ApplicationArea = All;
            }
            field("ARC AR Hold"; Rec."ARC AR Hold")
            {
                ApplicationArea = All;
            }
            field("ARC Workwave Order"; Rec."ARC Workwave Order")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("ARC Allow Ship & Invoice"; Rec."ARC Allow Ship & Invoice")
            {
                ApplicationArea = All;
            }
            field("ARC Order Source Code"; Rec."ARC Order Source Code")
            {
                ApplicationArea = All;
            }
            field("ARC Order Mgt. Status"; Rec."ARC Order Mgt. Status")
            {
                ApplicationArea = All;
            }
        }
        addafter("Location Code")
        {
            field("ARC COI Location Code"; Rec."ARC COI Location Code")
            {
                ApplicationArea = All;
            }
        }

        addafter(ShippingOptions)
        {
            field("ARC Use Locaton Address"; Rec."ARC Use Location Address")
            {
                Importance = Promoted;
                ApplicationArea = All;
                ToolTip = 'Select to use Location Card Address as Ship-to Address';
            }
        }

        addlast(FactBoxes)
        {
            part(ItemPriceEntry; "ARC Item Price Entry FactBox")
            {
                Caption = 'Item Price Entry Details';
                Provider = SalesLines;
                SubPageLink = "Document Type" = FIELD ("Document Type"),
                              "Document No." = FIELD ("Document No."),
                              "Line No." = FIELD ("Line No.");
                Visible = true;
            }
            part(APL; "ARC APL FactBox")
            {
                Caption = 'APL Entries';
                Provider = SalesLines;
                SubPageLink = "Item No." = FIELD ("No.");
            }
            part(VFM; "ARC VFM FactBox")
            {
                Caption = 'VFM Entries';
                Provider = SalesLines;
                SubPageLink = "Item No." = FIELD ("No.");
            }
            part(APLReview; "ARC APL Review FactBox")
            {
                Caption = 'APL Review Entries';
                SubPageView = sorting ("Document Area");
                SubPageLink = "Document Type" = field ("Document Type"), "Document No." = field ("No.");
            }
        }
        modify("Due Date")
        {
            Enabled = false;
        }
        modify("Document Date")
        {
            Enabled = false;
        }
        modify("Tax Liable")
        {
            Enabled = false;
        }
    }

    actions
    {
        addlast("O&rder")
        {
            action("CheckRegulatory")
            {
                Caption = 'Check Regulatory';
                Image = CheckRulesSyntax;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction();
                var
                    RegulatoryManagement: Codeunit "ARC Regulatory Management";
                begin
                    RegulatoryManagement.TestRestriction(Rec, true);
                end;
            }

            action("ARHoldEntries")
            {
                Caption = 'AR Hold Entries';
                Image = Entries;
                Promoted = true;
                RunObject = page "ARC AR Hold Log Entries";
                RunPageLink = "Sales Order No." = field ("No.");
            }
            action("WorkWaveEntries")
            {
                Caption = 'WorkWave Entries';
                Image = CreditCardLog;
                Promoted = true;
                RunObject = page "ARC Workwave Entries";
                RunPageLink = "Sales Order No." = field ("No.");
            }
            action(KorberEdgeShipments)
            {
                Image = Warehouse;
                ApplicationArea = All;
                Caption = 'Korber WMS Shpt. Entries';
                ToolTip = 'Show the Korber Edge WMS Shipment Entries for this sales order';

                trigger OnAction()
                var
                    _KorberShptMgt: Codeunit "ARC KorberShptMgt";
                begin
                    _KorberShptMgt.ShowShptEntriesFromSales(Rec);
                end;
            }
        }
        addlast("Documents")
        {
            action("Create BOL")
            {
                Caption = 'Create BOL';
                Image = CreateForm;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction();
                var
                    SalesHeader: Record "Sales Header";
                begin
                    SalesHeader.SETRANGE("No.", "No.");
                    REPORT.RUNMODAL(50027, true, false, SalesHeader)
                end;
            }
        }        
        addafter(Documents)
        {
            group("2Ship")
            {
                Caption = '2 Ship';               
                action("2Ship Get Edit URL")
                {
                    ApplicationArea = All;
                    Caption = '2Ship Get Edit URL';
                    Image = Link;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    
                    trigger OnAction();
                    var
                        ShipIntMgt:Codeunit "2Ship Integration Mgmt.";
                    begin
                        ShipIntMgt.Submit2ShipRateShopRequest(Rec,false);
                        //Rec.Testfield("2Ship Get Edit URL");
                        CurrPage.Update;
                        Hyperlink(Rec."2Ship Get Edit URL");
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.Editable("ARC Order Mgt. Status" <> "ARC Order Mgt. Status"::Queued);
    end;

    trigger OnAfterGetRecord()
    begin
        CurrPage.Editable("ARC Order Mgt. Status" <> "ARC Order Mgt. Status"::Queued);
    end;
}
pageextension 50031 "ARC Sales Order Archive" extends "Sales Order Archive"
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
        addbefore(Status)
        {
            field("ARC Created By"; Rec."ARC Created By")
            {
                ApplicationArea = All;
            }
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
                Provider = SalesLinesArchive;
                SubPageLink = "Document Type" = FIELD ("Document Type"),
                              "Document No." = FIELD ("Document No."),
                              "Line No." = FIELD ("Line No.");
                Visible = true;
            }
            part(APL; "ARC APL FactBox")
            {
                Caption = 'APL Entries';
                Provider = SalesLinesArchive;
                SubPageLink = "Item No." = FIELD ("No.");
            }
            part(VFM; "ARC VFM FactBox")
            {
                Caption = 'VFM Entries';
                Provider = SalesLinesArchive;
                SubPageLink = "Item No." = FIELD ("No.");
            }
            part(APLReview; "ARC APL Review FactBox")
            {
                Caption = 'APL Review Entries';
                SubPageView = sorting("Document Area");
                SubPageLink = "Document Type" = field ("Document Type"), "Document No." = field ("No.");
            }
        }
    }

    actions
    {
    }
}
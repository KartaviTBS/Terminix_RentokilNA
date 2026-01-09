pageextension 50024 "ARC Sales List" extends "Sales List"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("Sell-to Customer Name 2"; "Sell-to Customer Name 2")
            {
                ApplicationArea = All;
            }
            field("Sell-to Address"; "Sell-to Address")
            {
                ApplicationArea = All;
            }
        }

        addafter("Bill-to Name")
        {
            field("Bill-to Name 2"; "Bill-to Name 2")
            {
                ApplicationArea = All;
            }
        }

        addafter("Ship-to Name")
        {
            field("Ship-to Name 2"; "Ship-to Name 2")
            {
                ApplicationArea = All;
            }
        }

    }
    actions
    {
        addlast(Navigation)
        {

            action("RegulatoryReopen")
            {
                Caption = 'Admin ReOpen Only';
                Image = Reconcile;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction();
                var
                    SalesReleaseDoc: Codeunit "Release Sales Document";
                    ConfirmReeopn: Label 'If you are not an IT Administrator don''t use this action.\ Please use this action only when regulatory is approved and status is pending approval.\Do you want to continue?';
                begin
                    if not confirm(ConfirmReeopn, true) then
                        exit;
                    SalesReleaseDoc.Reopen(Rec);
                end;
            }
            action("WorkWaveEntries")
            {
                Caption = 'WorkWave Entries';
                Image = CreditCardLog;
                Promoted = true;
                PromotedCategory = Category4;
                RunObject = page "ARC Workwave Entries";
                RunPageLink = "Sales Order No." = field("No.");
            }
        }
    }

}
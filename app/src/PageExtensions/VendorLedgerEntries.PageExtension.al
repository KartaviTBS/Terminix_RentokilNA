pageextension 50062 "ARC Vendor Ledger Entries" extends "Vendor Ledger Entries"
{

    layout
    {
        addbefore("Entry No.")
        {
            field("ARC Exported for Financials"; "ARC Exported for Financials")
            {
                Importance = Promoted;
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        addlast("F&unctions")
        {
            action("ARCExportedToggle")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Exported Enable/Disable';
                Image = Check;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    VendorLedgerEntry: Record "Vendor Ledger Entry";
                    ExportAPSweepDate: Codeunit "ARC Export AP Sweep Data";
                begin
                    Currpage.SetSelectionFilter(VendorLedgerEntry);
                    if VendorLedgerEntry.FindSet then
                        repeat
                            ExportAPSweepDate.VendorLedgEntryExportToggle(VendorLedgerEntry);
                        until VendorLedgerEntry.Next = 0;
                    CurrPage.Update;
                end;
            }

        }
    }
}
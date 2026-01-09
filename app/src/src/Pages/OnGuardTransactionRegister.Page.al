page 50029 "ARC OnGuard Trans. Register"
{
    PageType = List;
    SourceTable = "ARC OnGuard Trans. Register";
    Caption = 'OnGuard Transaction Register';
    ApplicationArea = All;
    UsageCategory = Lists;
    InsertAllowed = false;
    Editable =false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Export Date"; "Export Date")
                {
                    ApplicationArea = All;
                }
                field("Export Time"; "Export Time")
                {
                    ApplicationArea = All;
                }
                field("No. of Transactions"; "No. of Transactions")
                {
                    ApplicationArea = All;
                }
                field("From Entry No."; "From Entry No.")
                {
                    ApplicationArea = All;
                }
                field("To Entry No."; "To Entry No.")
                {
                    ApplicationArea = All;
                }

            }
        }

    }

    actions
    {
        area(processing)
        {
            action(Export)
            {
                ApplicationArea = All;
                Caption = 'Export';
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Clear(ExptOnGuardData);
                    ExptOnGuardData.RunManual;
                end;
            }

            action(ReExport)
            {
                ApplicationArea = All;
                Caption = 'Re-Export';
                Image = ExportElectronicDocument;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Clear(ExptOnGuardData);
                    ExptOnGuardData.SetParams(Rec);
                    ExptOnGuardData.RunManual;
                end;
            }

            action(ResetRegister)
            {
                ApplicationArea = All;
                Caption = 'Reset Register';
                Image = Restore;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = codeunit "ARC Set up OnGuard Register";

                trigger OnAction()
                begin
                    
                end;
            }
        }
    }
    var
        ExptOnGuardData: Codeunit "ARC Export OnGuard Data";

}
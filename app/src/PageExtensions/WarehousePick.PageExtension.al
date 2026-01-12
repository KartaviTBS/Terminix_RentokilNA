pageextension 50067 "ARC Warehouse Pick" extends "Warehouse Pick"
{

    actions
    {
        addafter("&Print")
        {
            action("ARCPickSingle")
                {
                    ApplicationArea = Advanced;
                    Caption = 'Pick Single';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction();
                    var
                        WarehouseActivityHeader: Record "Warehouse Activity Header";
                        PickReportSingle: Report "Pick Report (Single)";
                    begin
                        CLEAR(PickReportSingle);
                        WarehouseActivityHeader.Reset;
                        WarehouseActivityHeader.SetRange(Type, "Type");
                        WarehouseActivityHeader.SetRange("No.", "No.");
                        PickReportSingle.SetTableView(WarehouseActivityHeader);
                        PickReportSingle.RunModal;
                    end;
                }
            action("ARCPickMulti")
                {
                    ApplicationArea = Advanced;
                    Caption = 'Pick Multi';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction();
                    var
                        WarehouseActivityHeader: Record "Warehouse Activity Header";
                        PickReportMulti: Report "Pick Report (Multiple)";
                    begin
                        CLEAR(PickReportMulti);
                        WarehouseActivityHeader.Reset;
                        WarehouseActivityHeader.SetRange(Type, "Type");
                        WarehouseActivityHeader.SetRange("No.", "No.");
                        PickReportMulti.SetTableView(WarehouseActivityHeader);
                        PickReportMulti.RunModal;
                    end;
                }
        }
    }

}
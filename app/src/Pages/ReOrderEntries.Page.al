page 50041 "ARC ReOrder Entries"
{
    ApplicationArea = All;
    UsageCategory = Lists;
    PageType = List;
    Caption = 'ReOrder Entries';
    SourceTable = "ARC ReOrder Entry";
    ModifyAllowed = false;
    DeleteAllowed = false;
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("ReOrder ID"; "ReOrder ID")
                {
                    ApplicationArea = All;
                }
                field("ReOrder ID Line Count";"ReOrder ID Line Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'The ReOrder ID Line Count must match the total no. of records for that ReOrder ID or the Job Queue will continue skipping that ReOrder ID.';
                }
                field(SellToCustNo; SellToCustNo)
                {
                    ApplicationArea = All;
                }
                field(BillToCustNo; BillToCustNo)
                {
                    ApplicationArea = All;
                }
                field(ShipToLocation; ShipToCode)
                {
                    ApplicationArea = All;
                }
                field(LocationCode; LocationCode)
                {
                    ApplicationArea = All;
                }
                field(ItemNo; ItemNo)
                {
                    ApplicationArea = All;
                }
                field(ItemVariant; ItemVariant)
                {
                    ApplicationArea = All;
                }
                field(ItemUnitOfMeasure; ItemUnitOfMeasure)
                {
                    ApplicationArea = All;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Shipment Method Code";"Shipment Method Code")
                {
                    ApplicationArea = All;
                }
                               
                field(RequestedDeliveryDate; RequestedDeliveryDate)
                {
                    ApplicationArea = All;
                }
                field("Created at DateTime"; "Created at DateTime")
                {
                    ApplicationArea = All;
                }
                field("Created by User ID"; "Created by User ID")
                {
                    ApplicationArea = All;
                }
                field("NAV No. of Attempts";"NAV No. of Attempts")
                {
                    ApplicationArea = All;
                }
                field("NAV Processed"; "NAV Processed")
                {
                    ApplicationArea = All;
                }
                field("NAV Processed at DateTime"; "NAV Processed at DateTime")
                {
                    ApplicationArea = All;
                }
                field("NAV Processed Duration"; "NAV Processed Duration")
                {
                    ApplicationArea = All;
                }
                field("NAV Processed Error Text"; "NAV Processed Error Text")
                {
                    ApplicationArea = All;
                }
                field("NAV Sales Order No."; "NAV Sales Order No.")
                {
                    ApplicationArea = All;
                }
                field("NAV Sales Order Line No."; "NAV Sales Order Line No.")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {
        }
    }

    actions
    {
        area(Processing)
        {
            action(Order)
            {
                ApplicationArea = All;
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Order';

                trigger OnAction()
                var
                    ReOrderMgt: Codeunit "ARC ReOrderMgt";
                begin
                    ReOrderMgt.ShowSalesOrder(Rec);
                end;
            }
            action(TestReOrderAppln)
            {
                ApplicationArea = All;
                Image = TestDatabase;
                Caption = 'Test';

                trigger OnAction();
                var
                    _ReOrderMgt: Codeunit "ARC ReOrderMgt";
                    _ReOrderID: Text[50];
                    _Text000Qst: Label 'Submit test ReOrder record(s)?';
                    _Text001Msg: Label 'ReOrder ID %1 created.';
                begin
                    if not Confirm(_Text000Qst, false) then 
                        exit;
                    _ReOrderID := CopyStr(_ReOrderMgt.TestReOrderAppln(),1,MaxStrLen(_ReOrderID));
                    Rec.Reset();
                    Rec.SetCurrentKey("ReOrder ID");
                    Rec.SetFilter("ReOrder ID",'*' + _ReOrderID + '*');
                    CurrPage.Update(false);
                    Message(_Text001Msg,_ReOrderID);
                end;
            }
            action(JobQueueEntry)
            {
                ApplicationArea = All;
                Image = Action;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Job Queue';

                trigger OnAction()
                var
                    _ReOrderMgt: Codeunit "ARC ReOrderMgt";
                begin
                    _ReOrderMgt.ShowJobQueueEntry();
                end;
            }
            action(Process)
            {
                ApplicationArea = All;
                Image = Process;
                Caption = 'Process';
                Visible = false;

                trigger OnAction();
                var
                    _ReOrderMgt: Codeunit "ARC ReOrderMgt";
                    _ReOrderWs: Codeunit "ARC ReOrder WebServices";
                    _Text000Qst: Label 'Run Process?';
                begin
                    if not Confirm(_Text000Qst,false) then
                        exit;
                    _ReOrderWs.ProcessReOrder(Rec."ReOrder ID");
                    CurrPage.Update(false);
                end;
            }
            action(Refresh)
            {
                ApplicationArea = All;
                Image = Refresh;
                Visible = false;
                Caption = 'Refresh';

                trigger OnAction();
                begin
                    CurrPage.Update(false);
                end;
            }
            action(Delete)
            {
                ApplicationArea = All;
                Image = Delete;
                Visible = false;
                Caption = 'Delete';

                trigger OnAction();
                var
                    _ReOrderMgt: Codeunit "ARC ReOrderMgt";
                begin
                    _ReOrderMgt.DeleteEntry(Rec."Entry No.");
                    CurrPage.Update(false);
                end;
            }
        }
    }

    procedure GetNavSalesOrderByEntryNo(EntryNo: Integer; var NavSalesOrderNo: text[20]; var NavSalesOrderLineNo: Integer)
    var
        ReOrderMgt: Codeunit "ARC ReOrderMgt";
    begin
        ReOrderMgt.GetNavSalesOrderByEntryNo(EntryNo, NavSalesOrderNo, NavSalesOrderLineNo);
    end;

    procedure GetNavSalesOrderByReOrderID(ReOrderID: text[50]; var NavSalesOrderNo: text[20])
    var
        ReOrderMgt: Codeunit "ARC ReOrderMgt";
    begin
        ReOrderMgt.GetNavSalesOrderByReOrderID(ReOrderID, NavSalesOrderNo);
    end;

    procedure GetResultByEntryNo(EntryNo: Integer; var Result: Integer; var ProcessedDateTime: DateTime; var ProcessedDuration: Duration; var ErrorText: Text[250])
    var
        ReOrderMgt: Codeunit "ARC ReOrderMgt";
    begin
        ReOrderMgt.GetResultByEntryNo(EntryNo, Result, ProcessedDateTime, ErrorText);
    end;

    procedure GetResultByReOrderID(ReOrderID: Text[50]; var Result: Integer; var ProcessedDateTime: DateTime; var ProcessedDuration: Duration; var ErrorText: Text[250])
    var
        ReOrderMgt: Codeunit "ARC ReOrderMgt";
    begin
        ReOrderMgt.GetResultByReOrderID(ReOrderID, Result, ProcessedDateTime, ErrorText);
    end;

    trigger OnOpenPage()
    begin
        CurrPage.Editable := not GuiAllowed;
    end;
}
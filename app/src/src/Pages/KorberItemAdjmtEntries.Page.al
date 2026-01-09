page 50106 "ARC Korber Item Adjmt. Entries"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ARC Korber Item Adjmt. Entry";
    //SourceTableView = sorting("Entry No.") order(descending);
    Caption = 'Korber Edge WMS Item Adjmt. Entries';
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Entries)
            {
                field("Entry No.";Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Entry No. (PK)';
                }
                field("Entry Type";Rec."Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Entry Type (positive or negative adjmt.)';
                }
                field("Item No.";Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Item No.';

                    trigger OnDrillDown()
                    begin
                        ItemAdjmtMgt.ShowItem(Rec);
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Location Code';

                    trigger OnDrillDown()
                    begin
                        ItemAdjmtMgt.ShowLocation(Rec);
                    end;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Quantity';
                }
                field("Item Unit of Measure Code"; Rec."Item Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the Item Unit of Measure';

                    trigger OnDrillDown()
                    begin
                        ItemAdjmtMgt.ShowItemUom(Rec);
                    end;
                }
                field("Qty. per Unit of Measure";"Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the Quantity per Unit of Measure';
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the Quantity in the Base Unit of Measure';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Reason Code';
                }
                field("Item Ledger Entry No."; Rec."Item Ledger Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the related Item Ledger Entry No.';
                }
                field("WMS Product Code"; Rec."WMS Product Code")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                }
                field("WMS Warehouse"; Rec."WMS Warehouse")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                }
                field("WMS Zone Code"; Rec."WMS Zone Code")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                }
                field("WMS Bin Location"; Rec."WMS Bin Location")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                }
                field("WMS Operator Name"; Rec."WMS Operator Name")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                }
                field("WMS OrderNum"; Rec."WMS OrderNum")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                }
                field("WMS Reason Code"; Rec."WMS Reason Code")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                }
                field("WMS Transaction Code"; Rec."WMS Transaction Code")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                }
                field("WMS Adjustment Date"; Rec."WMS Adjustment Date")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                }
                field("WMS Quantity"; Rec."WMS Quantity")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                }
                field("WMS RowId"; Rec."WMS RowId")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                }
                field("Import Data Entry No."; Rec."Import Data Entry No.")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        _DataMgt: Codeunit "ARC DataMgt";
                    begin
                        Rec.TestField("Import Data Entry No.");
                        _DataMgt.ShowValueFromEntryNo("Import Data Entry No.");
                    end;
                }
                field("Created by"; Rec."Created by")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Style = Favorable;
                    ToolTip = 'Specifies the credential that created the entry';
                }
                field("Created at Date"; Rec."Created at Date")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the date the entry was created';
                }
                field("Created at DateTime"; Rec."Created at DateTime")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the date and time the entry was created';
                }
                field("Created at Time"; Rec."Created at Time")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the time the entry was created';
                }
                field(Analyze; Rec.Analyze)
                {
                    ApplicationArea = All;
                    Visible = false;
                    Style = StrongAccent;
                    ToolTip = 'Originally specified whether the entry should be analyzed, but adjmt. interface is unidirectional, so Edge to NAV only; however, when adjmts. are posted in NAV, entries are recorded here with Analyze=Yes';
                }
                field(Analyzed; Rec.Analyzed)
                {
                    ApplicationArea = All;
                    Visible = false;
                    Style = StrongAccent;
                    ToolTip = 'Specifies whether the entry was analyzed';
                }
                field("Analyzed at DateTime"; Rec."Analyzed at DateTime")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Style = StrongAccent;
                    ToolTip = 'Specifies the date and time the entry was analyzed';
                }
                field("Analyzed No. of Attempts"; Rec."Analyzed No. of Attempts")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Style = StrongAccent;
                    ToolTip = 'Specifies the no. of attempts made to analyze';
                }
                field("Analyzed Duration"; Rec."Analyzed Duration")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Style = StrongAccent;
                    ToolTip = 'Specifies the duration of the analysis';
                }
                field("Analyzed Error Text"; Rec."Analyzed Error Text")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Style = StrongAccent;
                    ToolTip = 'Specifies any error text associated with the analysis';
                }
                field("Send to WMS"; Rec."Send to WMS")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Style = Strong;
                    ToolTip = 'Specifies whether this record / transaction should be sent to Korber Edge WMS';
                }
                field("Sent to WMS Data Entry No."; Rec."Sent to WMS Data Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Style = Strong;
                    ToolTip = 'Reveals the content of the XML sent to Korber Edge WMS';

                    trigger OnDrillDown()
                    var
                        _DataMgt: Codeunit "ARC DataMgt";
                    begin
                        Rec.TestField("Sent to WMS Data Entry No.");
                        _DataMgt.ShowValueFromEntryNo("Sent to WMS Data Entry No.");
                    end;
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    ToolTip = 'Specifies the result for the process attempt (1 = success, -1 = ultimate failure after repeated attempts, 0 = unprocessed)';
                }
                field("Processed at DateTime"; Rec."Processed at DateTime")
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    ToolTip = 'Specifies the datetime stamp for the latest process attempt';
                }
                field("Processed Duration"; Rec."Processed Duration")
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    ToolTip = 'Specifies the duration for the latest process attempt';
                }
                field("Processed No. of Attempts"; Rec."Processed No. of Attempts")
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    ToolTip = 'Specifies the total number of attempts made to process';
                }
                field("Processed Error Text"; Rec."Processed Error Text")
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    ToolTip = 'Specifies the error text for the latest process attempt';

                    trigger OnDrillDown()
                    begin
                        Message(Rec."Processed Error Text");
                    end;
                }
            }
        }
        area(factboxes)
        {
        }
    }

    actions
    {
        area(Navigation)
        {
            action(JobQueue)
            {
                Image = Job;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Job Queue';
                ToolTip = 'Shows the Job Queue';

                trigger OnAction()
                var
                    _KorberMgt: Codeunit "ARC KorberMgt";
                begin
                    _KorberMgt.ShowJobQueue();
                end;
            }
            action(ErrorLog)
            {
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Error Log';
                ToolTip = 'Shows the Error Log';

                trigger OnAction()
                var
                    _KorberMgt: Codeunit "ARC KorberMgt";
                begin
                    _KorberMgt.ShowErrorLog();
                end;
            }
            action(Ledger)
            {
                Image = Ledger;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Show Item Ledger';
                ToolTip = 'Shows the item ledger';

                trigger OnAction()
                var
                begin
                    ItemAdjmtMgt.ShowItemLedgEntry(Rec);
                end;
            }
        }
        area(Processing)
        {
            action(Reset)
            {
                Image = Process;
                Caption = 'Reset';
                ToolTip = 'Reprocess highlighted entries';

                trigger OnAction()
                var
                    _KorberItemAdjmtMgt: Codeunit "ARC KorberItemAdjmtMgt";
                    _entryNo: BigInteger;
                begin
                    _entryNo := Rec."Entry No.";
                    CurrPage.SetSelectionFilter(Rec);
                    _KorberItemAdjmtMgt.ResetEntry(Rec);
                    if Rec.Get(_entryNo) then;
                    Rec.Ascending(false);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        ItemAdjmtMgt: Codeunit "ARC KorberItemAdjmtMgt";
    
    trigger OnOpenPage()
    begin
        if Rec.FindLast() then;
        Rec.Ascending(false);
    end;
}
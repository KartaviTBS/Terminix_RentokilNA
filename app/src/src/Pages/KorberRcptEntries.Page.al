page 50104 "ARC Korber Rcpt. Entries"
{
    // SOW11 Körber Edge WMS Integration

    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ARC Korber Rcpt. Entry";
    Editable = false;
    //SourceTableView = sorting("Entry No.") order(descending);
    Caption = 'Korber Edge WMS Receipt Entries';

    layout
    {
        area(content)
        {
            repeater(Receipts)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Entry No.';
                }
                field("Document Area"; Rec."Document Area")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Document Area';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Document Type';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Document No.';

                    trigger OnDrillDown();
                    begin
                        KorberRcptMgt.ShowDocument(Rec);
                    end;
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Document Line No.';
                }
                field("Sell-to/Buy-from Entity No."; Rec."Sell-to/Buy-from Entity No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Sell-to/Buy-from Entity No.';

                    trigger OnDrillDown()
                    begin
                        KorberRcptMgt.ShowEntity(Rec);
                    end;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Item No.';

                    trigger OnDrillDown()
                    begin
                        KorberRcptMgt.ShowItem(Rec);
                    end;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Unit of Measure Code';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    DecimalPlaces = 0:5;
                    ToolTip = 'Specifies the Quantity';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    DecimalPlaces = 0:5;
                    ToolTip = 'Specifies the Qty. per Unit of Measure';
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    DecimalPlaces = 0:5;
                    ToolTip = 'Specifies the Quantity (Base)';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Location Code for the transaction';

                    trigger OnDrillDown()
                    begin
                        KorberRcptMgt.ShowLocation(Rec);
                    end;
                }
                field("Created by"; Rec."Created by")
                {
                    ApplicationArea = All;
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
                    Style = StrongAccent;
                    ToolTip = 'Specifies whether the entry should be analyzed';
                }
                field(Analyzed; Rec.Analyzed)
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    ToolTip = 'Specifies whether the entry was analyzed';
                }
                field("Analyzed at DateTime"; Rec."Analyzed at DateTime")
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    ToolTip = 'Specifies the date and time the entry was analyzed';
                }
                field("Analyzed No. of Attempts"; Rec."Analyzed No. of Attempts")
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    ToolTip = 'Specifies the no. of attempts made to analyze';
                }
                field("Analyzed Duration"; Rec."Analyzed Duration")
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    ToolTip = 'Specifies the duration of the analysis';
                }
                field("Analyzed Error Text"; Rec."Analyzed Error Text")
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    ToolTip = 'Specifies any error text associated with the analysis';

                    trigger OnDrillDown()
                    begin
                        Message(Rec."Analyzed Error Text");
                    end;
                }
                field("Send to WMS"; Rec."Send to WMS")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies whether this record / transaction should be sent to Korber Edge WMS';
                }
                field("Sent to WMS"; Rec."Sent to WMS")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies whether the transaction was sent to Korber Edge WMS; 0 = unprocessed, -1 = error, 1 = success';
                }
                field("Sent to WMS at DateTime"; Rec."Sent to WMS at DateTime")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the date and time the transaction was sent to Korber Edge WMS';
                }
                field("Sent to WMS No. of Attempts"; Rec."Sent to WMS No. of Attempts")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the No. of Attempts made to send the transaction to Korber Edge WMS';
                }
                field("Sent to WMS Duration"; Rec."Sent to WMS Duration")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the duration required to send the transaction to Korber Edge WMS';
                }
                field("Sent to WMS Error Text"; Rec."Sent to WMS Error Text")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies any error text that occurred when the attempt was made to send the transaction to Korber Edge WMS';

                    trigger OnDrillDown()
                    begin
                        Message(Rec."Sent to WMS Error Text");
                    end;
                }
                field("Sent to WMS Data Entry No."; Rec."Sent to WMS Data Entry No.")
                {
                    ApplicationArea = All;
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
                field(Process; Rec.Process)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies whether the entry should be processed';
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the result of processing; 0 = unprocessed, -1 = error, 1 = success';
                }
                field("Processed at DateTime"; Rec."Processed at DateTime")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the date and time when the entry was processed';
                }
                field("Processed Duration"; Rec."Processed Duration")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the duration of processing';
                }
                field("Processed No. of Attempts"; Rec."Processed No. of Attempts")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the no. of attempts made to process';
                }
                field("Processed Data Entry No."; Rec."Processed Data Entry No.")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Shows diagnostic messages added during process attempt';
                }
                field("Processed Error Text"; Rec."Processed Error Text")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the most recent error text when an error occurred';

                    trigger OnDrillDown()
                    begin
                        Message(Rec."Processed Error Text");
                    end;
                }
                field("Import Entry No."; Rec."Import Entry No.")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the Import Entry to which this record relates';

                    trigger OnDrillDown()
                    begin
                        KorberRcptMgt.ShowImportEntry(Rec);
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
        }
        area(Processing)
        {
            action(Reset)
            {
                Image = Process;
                Caption = 'Reset';
                ToolTip = 'Re-process one or more entries';

                trigger OnAction()
                var
                    _KorberRcptMgt: Codeunit "ARC KorberRcptMgt";
                    _entryNo: BigInteger;
                begin
                    _entryNo := Rec."Entry No.";
                    CurrPage.SetSelectionFilter(Rec);
                    _KorberRcptMgt.ResetEntry(Rec);
                    CurrPage.Update(false);
                    if Rec.Get(_entryNo) then;
                    Rec.Ascending(false);
                end;
            }
        }
    }

    var
        KorberRcptMgt: Codeunit "ARC KorberRcptMgt";
    
    trigger OnOpenPage()
    begin
        if Rec.FindLast() then;
        Rec.Ascending(false);
    end;
}
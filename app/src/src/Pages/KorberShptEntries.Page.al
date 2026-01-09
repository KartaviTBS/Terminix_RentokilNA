page 50103 "ARC Korber Shpt. Entries"
{
    // SOW11 Körber Edge WMS Integration

    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ARC Korber Shpt. Entry";
    Editable = false;
    //SourceTableView = sorting("Entry No.") order(descending);
    Caption = 'Korber Edge WMS Shipment Entries';

    layout
    {
        area(content)
        {
            repeater(Shipments)
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

                    trigger OnDrillDown()
                    begin
                        KorberShptMgt.ShowDocument(Rec);
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
                        KorberShptMgt.ShowEntity(Rec);
                    end;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Item No.';

                    trigger OnDrillDown()
                    begin
                        KorberShptMgt.ShowItem(Rec);
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
                        KorberShptMgt.ShowLocation(Rec);
                    end;
                }
                field("Picker ID"; Rec."Picker ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Picker ID';
                }
                field("Track Trace Number"; Rec."Track Trace Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Track Trace Number';
                }
                field("Ship Via"; Rec."Ship Via")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Ship Via';
                }
                field("Shipment Carrier"; Rec."Shipment Carrier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Shipment Carrier';
                }
                field("Shipment Service"; Rec."Shipment Service")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Shipment Service';
                }
                field("Shipment ID"; Rec."Shipment ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Shipment ID';
                }
                field("Total Shipment Charge"; Rec."Total Shipment Charge")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Total Shipment Charge';
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
                field("Analyzed Data Entry No."; Rec."Analyzed Data Entry No.")
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    ToolTip = 'Shows diagnostic messages added during attempt to analyze';

                    trigger OnDrillDown()
                    var
                        _DataMgt: Codeunit "ARC DataMgt";
                    begin
                        Rec.TestField("Analyzed Data Entry No.");
                        _DataMgt.ShowValueFromEntryNo("Analyzed Data Entry No.");
                    end;
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
                field("Processed Data Entry No."; Rec."Processed Data Entry No.")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Shows diagnostic messages added during process attempt';

                    trigger OnDrillDown()
                    var
                        _DataMgt: Codeunit "ARC DataMgt";
                    begin
                        Rec.TestField("Processed Data Entry No.");
                        _DataMgt.ShowValueFromEntryNo(Rec."Processed Data Entry No.");
                    end;
                }
                field("Processed No. of Attempts"; Rec."Processed No. of Attempts")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the no. of attempts made to process';
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
                        KorberShptMgt.ShowImportEntry(Rec);
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
            action(EnqueueManually)
            {
                Image = NewWarehouseShipment;
                Caption = 'Enqueue';
                ToolTip = 'Manually enqueue a document';

                trigger OnAction()
                var
                    _EntryNo: BigInteger;
                begin
                    _EntryNo := KorberShptMgt.EnqueueManualEntry();
                    if _EntryNo <> 0 then begin
                        Rec.Reset();
                        if Rec.Get(_EntryNo) then;
                        Rec.Ascending(false);
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(Reset)
            {
                Image = Process;
                Caption = 'Reset';
                ToolTip = 'Re-process one or more entries';

                trigger OnAction()
                var
                    _KorberShptMgt: Codeunit "ARC KorberShptMgt";
                    _entryNo: BigInteger;
                begin
                    _entryNo := Rec."Entry No.";
                    CurrPage.SetSelectionFilter(Rec);
                    _KorberShptMgt.ResetEntry(Rec);
                    CurrPage.Update(false);
                    if Rec.Get(_entryNo) then;
                    Rec.Ascending(false);
                end;
            }
        }
    }

    var
        KorberShptMgt: Codeunit "ARC KorberShptMgt";
    
    trigger OnOpenPage()
    begin
        if Rec.FindLast() then;
        Rec.Ascending(false);
    end;
}
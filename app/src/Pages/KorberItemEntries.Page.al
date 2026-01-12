page 50105 "ARC Korber Item Entries"
{
    // SOW11 Körber Edge WMS Integration

    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ARC Korber Item Entry";
    Editable = false;
    //SourceTableView = sorting("Entry No.") order(descending);
    Caption = 'Korber Edge WMS Item Entries';

    layout
    {
        area(content)
        {
            repeater(Items)
            {
                field("Entry No.";"Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Entry No.';
                }
                field("Item No.";"Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Item No.';

                    trigger OnDrillDown()
                    begin
                        KorberItemMgt.ShowItem(Rec);
                    end;
                }
                field("Record Action";"Record Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Record Action';
                }
                field("Created by";"Created by")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the credential that created the entry';
                }
                field("Created at Date";"Created at Date")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the date the entry was created';
                }
                field("Created at DateTime";"Created at DateTime")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the date and time the entry was created';
                }
                field("Created at Time";"Created at Time")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the time the entry was created';
                }
                field("Sent to WMS";"Sent to WMS")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies whether the transaction was sent to Korber Edge WMS; 0 = unprocessed, -1 = error, 1 = success';
                }
                field("Sent to WMS at DateTime";"Sent to WMS at DateTime")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the date and time the transaction was sent to Korber Edge WMS';
                }
                field("Sent to WMS No. of Attempts";"Sent to WMS No. of Attempts")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the No. of Attempts made to send the transaction to Korber Edge WMS';
                }
                field("Sent to WMS Duration";"Sent to WMS Duration")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the duration required to send the transaction to Korber Edge WMS';
                }
                field("Sent to WMS Error Text";"Sent to WMS Error Text")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies any error text that occurred when the attempt was made to send the transaction to Korber Edge WMS';
                }
                field("Sent to WMS Data Entry No.";"Sent to WMS Data Entry No.")
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
                    _KorberItemMgt: Codeunit "ARC KorberItemMgt";
                    _entryNo: BigInteger;
                begin
                    _entryNo := Rec."Entry No.";
                    CurrPage.SetSelectionFilter(Rec);
                    _KorberItemMgt.ResetEntry(Rec);
                    CurrPage.Update(false);
                    if Rec.Get(_entryNo) then;
                    Rec.Ascending(false);
                end;
            }
        }
    }

    var
        KorberItemMgt: Codeunit "ARC KorberItemMgt";
    
    trigger OnOpenPage()
    begin
        if Rec.FindLast() then;
        Rec.Ascending(false);
    end;
}
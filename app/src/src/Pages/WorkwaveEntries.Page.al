page 50060 "ARC Workwave Entries"
{
    Caption = 'Workwave Entries';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "ARC Workwave Entry";
    InsertAllowed = false;
    DeleteAllowed = false;
    CardPageId = "ARC WorkWave Entry Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Transaction ID"; "Transaction ID")
                {
                    ApplicationArea = All;
                }
                field("Transaction Status"; "Transaction Status")
                {
                    ApplicationArea = All;
                }
                field("Transaction Type"; "Transaction Type")
                {
                    ApplicationArea = All;
                }
                field("Payment Acct Type"; "Payment Acct Type")
                {
                    ApplicationArea = All;
                }
                field("Card Type"; "Card Type")
                {
                    ApplicationArea = All;
                }
                field("Masked Card No."; "Masked Card No.")
                {
                    ApplicationArea = All;
                }
                field("Masked Account No.";"Masked Account No.")
                {
                    ApplicationArea = All;
                }
                field("Masked Routing No.";"Masked Routing No.")
                {
                    ApplicationArea = All;
                }
                
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Captured"; "Amount Captured")
                {
                    ApplicationArea = All;
                }
                field("Approval No."; "Approval No.")
                {
                    ApplicationArea = All;
                }
                field("Payment Acct Token"; "Payment Acct Token")
                {
                    ApplicationArea = All;
                }
                field("Employee ID"; "Employee ID")
                {
                    ApplicationArea = All;
                }
                field("Billing Address"; "Billing Address")
                {
                    ApplicationArea = All;
                }
                field("Billing City";"Billing City")
                {
                    ApplicationArea = All;
                }
                field("Billing State"; "Billing State")
                {
                    ApplicationArea = All;
                }
                field(Reference; Reference)
                {
                    ApplicationArea = All;
                }
                field("Payment Acct Reference"; "Payment Acct Reference")
                {
                    ApplicationArea = All;
                }
                field("Web Order No."; "Web Order No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Order No."; "Sales Order No.")
                {
                    ApplicationArea = All;
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field(Status;Status)
                {
                    ApplicationArea = All;
                }
                field("Related Entry No.";"Related Entry No.")
                {
                    ApplicationArea = All;
                }
                
                field("Created On"; "Created On")
                {
                    ApplicationArea = All;
                }
                field("Updated On"; "Updated On")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Process;Rec.Process)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Processed;Processed)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Processed at DateTime";"Processed at DateTime")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Processed No. of Attempts";"Processed No. of Attempts")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Processed Error Text";"Processed Error Text")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Transmit Data Entry No."; "Transmit Data Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        _DataMgt: Codeunit "ARC DataMgt";
                    begin
                        TestField("Transmit Data Entry No.");
                        _DataMgt.ShowValueFromEntryNo("Transmit Data Entry No.");
                    end;
                }
                field("Receipt Data Entry No."; "Receipt Data Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        _DataMgt: Codeunit "ARC DataMgt";
                    begin
                        TestField("Receipt Data Entry No.");
                        _DataMgt.ShowValueFromEntryNo("Receipt Data Entry No.");
                    end;
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
            action(ProcessRec)
            {
                ApplicationArea = All;
                Caption = 'Process';
                Image = Process;

                trigger OnAction()
                var
                    _WorkwaveACHMgt: Codeunit "ARC Workwave ACH Management";
                    _Text000Err: Label 'At present, the action "Process" is for ACH transactions only.  Payment Acct Type is %1';
                begin
                    if StrPos(LowerCase(Rec."Payment Acct Type"),'ach') = 0 then
                        Error(_Text000Err,Rec."Payment Acct Type");
                    _WorkwaveACHMgt.SetEntryNoToProcess(Rec."Entry No.");
                    _WorkwaveACHMgt.Run();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action("RelatedEntries")
            {
                ApplicationArea = All;
                Caption = 'Related Entries';
                Image = PostingEntries;
                PromotedCategory = Process;
                Promoted = true;
                RunObject = page "ARC Workwave Entries";
                RunPageLink = "Entry No." = field("Related Entry No.");
            }
            action(EventLogEntries)
            {
                ApplicationArea = All;
                Caption = 'Event Log Entries';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    _EventLogEntry: Record "ARC Event Log Entry";
                begin
                    _EventLogEntry.SetRange("Object Type",_EventLogEntry."Object Type"::Codeunit);
                    _EventLogEntry.SetRange("Object ID",Codeunit::"ARC Workwave ACH Management");
                    _EventLogEntry.SetRange("Related Entry No.",Rec."Entry No.");
                    Page.Run(Page::"ARC Event Log Entries",_EventLogEntry);
                end;
            }
            action(JobQueue)
            {
                ApplicationArea = All;
                Caption = 'Job Queue';
                Image = Job;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    _JobQueueEntry: Record "Job Queue Entry";
                begin
                    _JobQueueEntry.SetRange("Object ID to Run",Codeunit::"ARC Workwave ACH Management");
                    Page.Run(Page::"Job Queue Entries",_JobQueueEntry);
                end;
            }
        }
    }
}
page 50075 "ARC Event Log Entries"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ARC Event Log Entry";
    //SourceTableView = sorting("Entry No.") order(descending);
    Caption = 'Event Log Entries';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater("Event Log Entries")
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                }
                field("Object ID"; "Object ID")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Related Entry No.";"Related Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Message Text"; "Message Text")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        if "Message Text" <> '' then
                            Message("Message Text");
                    end;
                }
                field("Error Text"; "Error Text")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        if "Error Text" <> '' then
                            Message("Error Text");
                    end;
                }
                field("Created by"; "Created by")
                {
                    ApplicationArea = All;
                }
                field("Created at DateTime"; "Created at DateTime")
                {
                    ApplicationArea = All;
                }
                field("Notification to be Sent"; "Notification to be Sent")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Notification Sent"; "Notification Sent")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Notification E-Mail Addresses"; "Notification E-Mail Addresses")
                {
                    ApplicationArea = All;
                    Visible = false;
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
            action("DeleteEntriesOlderThan")
            {
                ApplicationArea = All;
                Image = DeleteQtyToHandle;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Delete Entries Older Than';

                trigger OnAction();
                var
                    _EventLogEntry: Record "ARC Event Log Entry";
                begin
                    _EventLogEntry.DeleteEntriesOlderThan(0DT);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec.FindLast() then;
        Rec.Ascending(false);
    end;
}
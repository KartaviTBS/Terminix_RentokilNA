page 50102 "ARC Korber Setup"
{
    // SOW11 Körber Edge WMS Integration

    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "ARC Korber Setup";
    Caption = 'Korber Edge WMS Setup';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Log Level"; Rec."Log Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the level of logging';
                }
                field("Process Queue Enabled"; Rec."Process Queue Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the master enable/disable switch for Korber Edge WMS Integration';
                }
                field("Process Queue No. Entries"; Rec."Process Queue No. Entries")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of entries to process in each staging table for each iteration of the Job Queue';
                }
                field("Maximum No. of Attempts"; Rec."Maximum No. of Attempts")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the maximum number of attempts made to process a confirmation';
                }
                field("Data Retention DateFormula"; Rec."Data Retention DateFormula")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the timeframe for which data entries should be retained';
                }
                field("Outb. Base File Path"; Rec."Outb. Base File Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the folder (in UNC notation) for files outbound to Korber Edge - example \\server\path';
                }
                field("Inb. Base File Path"; Rec."Inb. Base File Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the folder (in UNC notation) for files inbound from Korber Edge - Archive and Error folders are expected underneath - example \\server\path';
                }
                field("Location Priority Active"; Rec."Location Priority Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the Location Priority table is utilized when item is entered on sales order';
                }
                field("Remove Special Characters"; Rec."Remove Special Characters")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether special characters should be removed from text sent to Korber Edge WMS';
                }
                field("Special Characters"; Rec."Special Characters")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the special characters that should be removed from text sent to Korber Edge WMS';
                }
            }
            group(Shipments)
            {
                field("Send Shipments"; Rec."Send Shipments")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether shipment instructions are sent to Korber Edge WMS';
                }
                field("Post Shipment"; Rec."Post Shipment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether shipment confirmations from WMS are automatically posted (sales orders, transfer orders, purchase returns)';
                }
                field("Post Invoice for Outb. Shpts."; Rec."Post Invoice for Outb. Shpts.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether shipment confirmations are automatically invoiced (affects sales orders only)';
                }
                field("Shipment - Incl. Drop Ship"; Rec."Shipment - Incl. Drop Ship")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether sales lines marked as Drop Ship should be retained';
                }
                field("Freight Charges Active"; Rec."Freight Charges Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Evaluate "Freight Charges from Korber Edge" (addendum dated Wed 26 Oct 2022)';
                }
            }
            group(Receipts)
            {
                field("Send Receipts"; Rec."Send Receipts")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether receipt instructions are sent to Korber Edge WMS';
                }
                field("Post Receipt"; Rec."Post Receipt")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether receipt confirmations from WMS are automatically posted (purchase orders, transfer receipts, sales returns)';
                }
                field("Post Invoice for Inb. Rcpts."; Rec."Post Invoice for Inb. Rcpts.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether receipt confirmations are automatically invoiced (purchase orders, sales returns)';
                }
            }
            group(Inventory)
            {
                field("Send Items"; Rec."Send Items")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether changes made to Item records are sent to WMS automatically (create, update, delete)';
                }
                field("Activate Item Subscribers"; Rec."Activate Item Subscribers")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether a Korber WMS Item record is created when an Item record is inserted or modified';
                }
                field("Send Item Adjmts."; Rec."Send Item Adjmts.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies whether a qualified item journal adjustment will be sent to WMS';
                }
                field("Send Inventory Snapshot"; Rec."Send Inventory Snapshot")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies whether an item quantity on hand balance will be sent to WMS if a new Item Ledger Entry record is created or modified';
                }
                field("Item Journal Template"; Rec."Item Journal Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Item Journal Template to use for item adjustments';
                }
                field("Item Journal Batch"; Rec."Item Journal Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Item Journal Batch to use for item adjustments';
                }
                field("Hazmat Shpt. Method Code"; Rec."Hazmat Shpt. Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a Shipment Method Code for an order when an item is classified as hazardous';
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
            action(EventLog)
            {
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Event Log';

                trigger OnAction()
                begin
                    KorberMgt.ShowErrorLog();
                end;
            }
            action(JobQueue)
            {
                Image = Job;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Job Queue';

                trigger OnAction()
                begin
                    KorberMgt.ShowJobQueue();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.FindFirst() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    var
    KorberMgt: Codeunit "ARC KorberMgt";
}
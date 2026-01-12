page 50118 "ARC Korber Import Entries"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    SourceTable = "ARC Korber Import Entry";
    //SourceTableView = sorting("Entry No.") order(descending);
    Caption = 'Korber Edge WMS Import Entries';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Entry No.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    ToolTip = 'Specifies the Document Type from Korber Edge WMS';
                }
                field("Action Text"; Rec."Action Text")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    Visible = ShowAllFields;
                    ToolTip = 'Specifies the Action Text from Korber Edge WMS';
                }
                field("Container Batch Reference"; Rec."Container Batch Reference")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    Visible = ShowAllFields;
                    ToolTip = 'Specifies the Container Batch Reference from Korber Edge WMS';
                }
                field("Date Text"; Rec."Date Text")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    Visible = ShowAllFields;
                    ToolTip = 'Specifies the Date Text from Korber Edge WMS';
                }
                field("Order Number"; Rec."Order Number")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    Visible = ShowAllFields;
                    ToolTip = 'Specifies the Order Number from Korber Edge WMS';
                }
                field("Order Type"; Rec."Order Type")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    Visible = ShowAllFields;
                    ToolTip = 'Specifies the Order Type from Korber Edge WMS';
                }
                field("Purchase Order Number"; Rec."Purchase Order Number")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    Visible = ShowAllFields;
                    ToolTip = 'Specifies the Purchase Order Number from Korber Edge WMS';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Style = Attention;
                    Visible = ShowAllFields;
                    ToolTip = 'Specifies the Status from Korber Edge WMS';
                }
                field("Time Text"; Rec."Time Text")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    Visible = ShowAllFields;
                    ToolTip = 'Specifies the Time Text from Korber Edge WMS';
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    Style = StandardAccent;
                    ToolTip = 'Specifies the name of the file to be imported';
                }
                field("File Path"; Rec."File Path")
                {
                    ApplicationArea = All;
                    Style = StandardAccent;
                    ToolTip = 'Specifies the path of the file to be imported';
                }
                field("File Date"; Rec."File Date")
                {
                    ApplicationArea = All;
                    Style = StandardAccent;
                    ToolTip = 'Specifies the datestamp of the file to be imported';
                }
                field("File Time"; Rec."File Time")
                {
                    ApplicationArea = All;
                    Style = StandardAccent;
                    ToolTip = 'Specifies the timestamp of the file to be imported';
                }
                field("File Size"; Rec."File Size")
                {
                    ApplicationArea = All;
                    Style = StandardAccent;
                    ToolTip = 'Specifies the size of the file to be imported';
                }
                field("Total Shipment Charge"; Rec."Total Shipment Charge")
                {
                    ApplicationArea = All;
                    Style = StandardAccent;
                    Visible = ShowAllFields;
                    ToolTip = 'Specifies the total shipment charge';
                }
                field("Created at Date"; Rec."Created at Date")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                    ToolTip = 'Specifies the date stamp for this record';
                }
                field("Created at DateTime"; Rec."Created at DateTime")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                    ToolTip = 'Specifies the datetime stamp for this record';
                }
                field("Created at Time"; Rec."Created at Time")
                {
                    ApplicationArea = All;
                    Style = Subordinate;
                    ToolTip = 'Specifies the timestamp for this record';
                }
                field(Import; Rec.Import)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies whether the system should attempt to import the record';
                }
                field(Imported; Rec.Imported)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the result for the import attempt (1 = success, -1 = ultimate failure after repeated attempts, 0 = unprocessed)';
                }
                field("Imported at DateTime"; Rec."Imported at DateTime")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the datetime stamp for the latest import attempt';
                }
                field("Imported No. of Attempts"; Rec."Imported No. of Attempts")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the number of import attempts';
                }
                field("Imported Duration"; Rec."Imported Duration")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the duration for the latest import attempt';
                }
                field("Imported Data Entry No."; Rec."Imported Data Entry No.")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the file contents';

                    trigger OnDrillDown()
                    begin
                        Rec.TestField("Imported Data Entry No.");
                        DataMgt.ShowValueFromEntryNo(Rec."Imported Data Entry No.");
                    end;
                }
                field("Imported Error Text"; Rec."Imported Error Text")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the error text for the latest failed attempt';

                    trigger OnDrillDown()
                    begin
                        Message(Rec."Imported Error Text");
                    end;
                }
                field(Process; Rec.Process)
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    ToolTip = 'Specifies whether the system should attempt to process the record';
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
                field("Processed Data Entry No."; Rec."Processed Data Entry No." )
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    ToolTip = 'Specifies XML contents in formatted text';

                    trigger OnDrillDown()
                    begin
                        Rec.TestField("Processed Data Entry No.");
                        DataMgt.ShowValueFromEntryNo(Rec."Processed Data Entry No.");
                    end;
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
                    _entryNo: BigInteger;
                begin
                    _entryNo := Rec."Entry No.";
                    CurrPage.SetSelectionFilter(Rec);
                    KorberMgt.ResetEntry(Rec);
                    CurrPage.Update(false);
                    if Rec.Get(_entryNo) then;
                    Rec.Ascending(false);
                end;
            }
            action(ToggleShowAllFields)
            {
                Image = ToggleBreakpoint;
                Caption = 'Show/Hide Fields';
                ToolTip = 'Show/Hide Fields';

                trigger OnAction()
                begin
                    ShowAllFields := not ShowAllFields;
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        DataMgt: Codeunit "ARC DataMgt";
        KorberMgt: Codeunit "ARC KorberMgt";
        [InDataSet]
        ShowAllFields: Boolean;
    
    trigger OnOpenPage()
    begin
        if Rec.FindLast() then;
        Rec.Ascending(false);
    end;
}
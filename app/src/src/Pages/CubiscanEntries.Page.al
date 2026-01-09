page 50117 "ARC Cubiscan Entries"
{
    // SOW11 Körber Edge WMS Integration - CO2 Cubiscan Integration

    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ARC Cubiscan Entry";
    SourceTableView = sorting("Entry No.") order(descending);
    Caption = 'Cubiscan Entries';

    layout
    {
        area(content)
        {
            repeater(Entries)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Entry No.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Item No.';

                    trigger OnDrillDown()
                    begin
                        CubiscanMgt.ShowItem(Rec);
                    end;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Unit of Measure Code';
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Base Unit of Measure';
                }
                field("Selling Unit of Measure"; Rec."Selling Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Selling Unit of Measure';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Description';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Description 2';
                }
                field(Length; Rec.Length)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Length';
                }
                field(Width; Rec.Width)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Width';
                }
                field(Height; Rec.Height)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Height';
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Weight';
                }
                field(Volume; Rec.Volume)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Volume';
                }
                field("Dim. Weight"; Rec."Dim. Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Dim. Weight';
                }
                field("Dim. Unit"; Rec."Dim. Unit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Dim. Unit';
                }
                field("Wgt. Unit"; Rec."Wgt. Unit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Wgt. Unit';
                }
                field("Vol. Unit"; Rec."Vol. Unit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Vol. Unit';
                }
                field(Cubage; Rec.Cubage)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Cubage';
                }
                field("Site Id"; Rec."Site Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Site Id';
                }
                field("Date/Time"; Rec."Date/Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Date/Time';
                }
                field("Optional Info. 5"; Rec."Optional Info. 5")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Optional Info. 5';
                }
                field("Optional Info. 6"; Rec."Optional Info. 6")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Optional Info. 6';
                }
                field("Optional Info. 7"; Rec."Optional Info. 7")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Optional Info. 7';
                }
                field("Optional Info. 8"; Rec."Optional Info. 8")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Optional Info. 8';
                }
                field("Image File"; Rec."Image File")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Image File';
                }
                field(Updated; Rec.Updated)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field Updated';
                }
                field("Created at Date"; Rec."Created at Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the date when the entry was created';
                }
                field("Created at DateTime"; Rec."Created at DateTime")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the DateTime when the entry was created';
                }
                field("Created at Time"; Rec."Created at Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the time when the entry was created';
                }
                field(Import; Rec.Import)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies whether data should be imported';
                }
                field(Imported; Rec.Imported)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies whether import failed (-1), was successful (1), or not yet attempted (0)';
                }
                field("Imported at DateTime"; Rec."Imported at DateTime")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the DateTime when the data was imported';
                }
                field("Imported No. of Attempts"; Rec."Imported No. of Attempts")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the no. of attempts required to import the data';
                }
                field("Imported Duration"; Rec."Imported Duration")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the time required to import data';
                }
                field("Imported Error Text"; Rec."Imported Error Text")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies any error text associated with import of data';
                }
                field("Imported Data Entry No."; Rec."Imported Data Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the Data Entry record containing the import data';

                    trigger OnDrillDown()
                    begin
                        Rec.TestField("Imported Data Entry No.");
                        DataMgt.ShowValueFromEntryNo("Imported Data Entry No.");
                    end;
                }
                field("Import Filename";"Import Filename")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the filename to import';
                }
                field(Process; Rec.Process)
                {
                    ApplicationArea = All;
                    //Editable = false;
                    ToolTip = 'Specifies whether the entry should be processed';
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies whether the entry failed (-1) or was processed successfully (1)';
                }
                field("Processed at DateTime"; Rec."Processed at DateTime")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the DateTime the entry was processed';
                }
                field("Processed No. of Attempts"; Rec."Processed No. of Attempts")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the no. of attempts required to process the record';
                }
                field("Processed Duration"; Rec."Processed Duration")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the processing duration';
                }
                field("Processed Error Text"; Rec."Processed Error Text")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies any error text associated with record processing';
                }
            }
        }
        area(factboxes)
        {
        }
    }

    actions
    {
        area(processing)
        {
            action(Reset)
            {
                ApplicationArea = All;
                Image = ResetStatus;
                Caption = 'Reset Entries';

                trigger OnAction()
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    CubiscanMgt.Reset(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(JobQueue)
            {
                ApplicationArea = All;
                Image = Job;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Job Queue';

                trigger OnAction()
                begin
                    CubiscanMgt.ShowJobQueue();
                end;
            }
            action(EventLogEntry)
            {
                ApplicationArea = All;
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Event Log';

                trigger OnAction()
                begin
                    CubiscanMgt.ShowEventLog();
                end;
            }
        }
    }

    var
        CubiscanMgt: Codeunit "ARC CubiscanMgt";
        DataMgt: Codeunit "ARC DataMgt";

    trigger OnOpenPage()
    begin
        CurrPage.Editable(not GuiAllowed());
    end;
}
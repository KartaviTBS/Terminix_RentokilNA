page 50001 "ARC RNA Setup"
{
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "ARC RNA Setup";
    Caption = 'RNA Setup';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Regulatory User Group"; Rec."Regulatory User Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Regulatory User Group to Control Security';
                }
                field("Regulatory Workflow Code"; Rec."Regulatory Workflow Code")
                {
                    ApplicationArea = All;
                }
                field("AR Workflow Code"; Rec."AR Workflow Code")
                {
                    ApplicationArea = All;
                }
                field("COI Journal Template Name"; Rec."COI Journal Template Name")
                {
                    ApplicationArea = All;
                }
                field("COI Journal Batch Name"; Rec."COI Journal Batch Name")
                {
                    ApplicationArea = All;
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ApplicationArea = All;
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                }
                field("Default Fin. Charge Funct Code"; Rec."Default Fin. Charge Funct Code")
                {
                    ApplicationArea = All;
                }
                field("Reserve On Posting"; Rec."Reserve On Posting")
                {
                    ApplicationArea = All;
                }
                field("Cr. Limit Threshold Amount"; Rec."Cr. Limit Threshold Amount")
                {
                    ApplicationArea = All;
                }
                field("Internal Customer Order Date"; Rec."Internal Customer Order Date")
                {
                    ApplicationArea = All;
                }
                field("Contract Price Expiry"; Rec."Contract Price Expiry")
                {
                    ApplicationArea = All;
                }

                field("Price Admin User Group"; Rec."Price Admin User Group")
                {
                    ApplicationArea = All;
                }
                field("Order Management Active"; Rec."Order Management Active")
                {
                    ApplicationArea = All;
                }
                field("Order Mgt. Log Level"; Rec."Order Mgt. Log Level")
                {
                    ApplicationArea = All;
                }
                field("Order Translation No. Series"; Rec."Order Translation No. Series")
                {
                    ApplicationArea = All;
                }
                field("Order Mgt. Handle EFT Txs."; Rec."Order Mgt. Handle EFT Txs.")
                {
                    ApplicationArea = All;
                }
                field("JDE AP Export File Path";"JDE AP Export File Path")
                {
                    ApplicationArea = all;
                }
                field("JDE AP Last Export File Name";"JDE AP Last Export File Name")
                {
                    ApplicationArea = all;
                }
                field("JDE GL Export File Path";"JDE GL Export File Path")
                {
                    ApplicationArea = all;
                }
                field("JDE Last Export File Name";"JDE Last Export File Name")
                {
                    ApplicationArea = all;
                }
                field("Disable Batch Deletion_OrdMgt"; Rec."Disable Batch Deletion_OrdMgt")
                {
                    ApplicationArea = All;
                }
                
            }
            group("Sales & Pricing")
            {
                Caption = 'Sales & Pricing';
                field("Quote Expiration Calculation"; Rec."Quote Expiration Calculation")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("LOB Lift Field Calculation"; Rec."LOB Lift Field Calculation")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(SalesTerms; SalesTerms)
                {
                    Caption = 'Sales Terms and Conditions';
                    ApplicationArea = Basic, Suite;
                    MultiLine = true;

                    trigger OnValidate();

                    begin
                        SetTermsandConditions(SalesTerms);
                    end;
                }
                field("Disable Custom Price Logic"; Rec."Disable Custom Price Logic")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Send Approval/Reject Email"; Rec."Send Approval/Reject Email")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Release On Price Approval"; Rec."Release On Price Approval")
                {
                    ApplicationArea = All;
                }

            }



            group(Dimensions)
            {
                Caption = 'Salesperson Dimensions';
                field("Salesperson Dimension 1"; Rec."Salesperson Dimension 1")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salesperson Dimension 2"; Rec."Salesperson Dimension 2")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salesperson Dimension 3"; Rec."Salesperson Dimension 3")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salesperson Dimension 4"; Rec."Salesperson Dimension 4")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salesperson Dimension 5"; Rec."Salesperson Dimension 5")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salesperson Dimension 6"; Rec."Salesperson Dimension 6")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salesperson Dimension 7"; Rec."Salesperson Dimension 7")
                {
                    ApplicationArea = Basic, Suite;
                }
            }

            group(ARAging)
            {
                Caption = 'AR Aging';
                field("AR Summary Export File"; Rec."AR Summary Export File")
                {
                    ApplicationArea = All;
                    ToolTip = 'Export File for Anaplan upload';
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    begin
                        ClientFileName := FileManagement.SaveFileDialog(ExportFileTxt, ClientFileName, FileManagement.GetToFilterText('', '.txt'));
                        "AR Summary Export File" := ClientFileName;
                    end;
                }
                field("AR Summary Export Day of Month"; Rec."AR Summary Export Day of Month")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Day of Month (number) to run AR Summary Export in Job Queue';
                }
                field("AR Aging Summary Versions"; Rec."AR Aging Summary Versions")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan version for AR aging summary export';
                }
                field("AR Aging Summary Measures"; Rec."AR Aging Summary Measures")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan measures for AR aging summary export';
                }
                field("AR Aging Summary LOB"; Rec."AR Aging Summary LOB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan LOB dimension for AR aging summary export';
                }
                field("AR Aging Summary Function"; Rec."AR Aging Summary Function")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan function dimension for AR aging summary export';
                }
                field("AR Aging Summary Currency"; Rec."AR Aging Summary Currency")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan currency for AR aging summary export';
                }
                field("AR Aging Summary Billing Account"; Rec."AR Aging Summary Billing Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan Billing Account Code for 0D AR aging summary export';
                }
                field("AR Aging Summary 0D Account"; Rec."AR Aging Summary 0D Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan Debit Account Code for 0D AR aging summary export';
                }
                field("AR Aging Summary 30D Account"; Rec."AR Aging Summary 30D Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan Debit Account Code for 30D AR aging summary export';
                }
                field("AR Aging Summary 60D Account"; Rec."AR Aging Summary 60D Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan Debit Account Code for 60D AR aging summary export';
                }
                field("AR Aging Summary 90D Account"; Rec."AR Aging Summary 90D Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan Debit Account Code for 90D AR aging summary export';
                }

                field("AR Aging Summary 120D Account"; Rec."AR Aging Summary 120D Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan Debit Account Code for 120D AR aging summary export';
                }
                field("AR Aging Summary 180D Account"; Rec."AR Aging Summary 180D Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan Debit Account Code for 180D AR aging summary export';
                }
                field("AR Aging Summary 365D Account"; Rec."AR Aging Summary 365D Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan Debit Account Code for 365D AR aging summary export';
                }
                field("AR Aging Summary 0D Credit Account"; Rec."AR Aging Summary 0D Credit Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan Credit Account Code for 0D AR aging summary export';
                }
                field("AR Aging Summary 30D Credit Account"; Rec."AR Aging Summary 30D Credit Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan Credit Account Code for 30D AR aging summary export';
                }
                field("AR Aging Summary 60D Credit Account"; Rec."AR Aging Summary 60D Credit Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan Credit Account Code for 60D AR aging summary export';
                }
                field("AR Aging Summary 90D Credit Account"; Rec."AR Aging Summary 90D Credit Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan Credit Account Code for 90D AR aging summary export';
                }

                field("AR Aging Summary 120D Credit Account"; Rec."AR Aging Summary 120D Credit Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan Credit Account Code for 120D AR aging summary export';
                }
                field("AR Aging Summary 180D Credit Account"; Rec."AR Aging Summary 180D Credit Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan Credit Account Code for 180D AR aging summary export';
                }
                field("AR Aging Summary 365D Credit Account"; Rec."AR Aging Summary 365D Credit Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anaplan Credit Account Code for 365D AR aging summary export';
                }
            }
            group("Invoice Print")
            {
                field("DDC Invoice File Path"; Rec."DDC Invoice File Path")
                {
                    AssistEdit = true;

                    trigger OnValidate()
                    begin
                        CheckAndAppendPath("DDC Invoice File Path");
                    end;

                    trigger OnAssistEdit()
                    var
                        FileManagement: Codeunit "File Management";
                    begin
                        "DDC Invoice File Path" := FileManagement.BrowseForFolderDialog(ExportFilePathTxt, '', false);
                        CheckAndAppendPath("DDC Invoice File Path");
                    end;

                }
                field("OnGuard Invoice File Path"; Rec."OnGuard Invoice File Path")
                {
                    ApplicationArea = Basic, Suite;
                    AssistEdit = true;

                    trigger OnValidate()
                    begin
                        CheckAndAppendPath("OnGuard Invoice File Path");
                    end;

                    trigger OnAssistEdit()
                    var
                        FileManagement: Codeunit "File Management";
                    begin
                        "OnGuard Invoice File Path" := FileManagement.BrowseForFolderDialog(ExportFilePathTxt, '', false);
                        CheckAndAppendPath("OnGuard Invoice File Path");
                    end;
                }
                field("No. of Invoice Per Batch"; Rec."No. of Invoice Per Batch")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Test Posting Date"; Rec."Test Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Set this value only for testing purpose';
                }

                field("DDC CrMemo File Path"; Rec."DDC CrMemo File Path")
                {
                    AssistEdit = true;

                    trigger OnValidate()
                    begin
                        CheckAndAppendPath("DDC CrMemo File Path");
                    end;

                    trigger OnAssistEdit()
                    var
                        FileManagement: Codeunit "File Management";
                    begin
                        "DDC CrMemo File Path" := FileManagement.BrowseForFolderDialog(ExportFilePathTxt, '', false);
                        CheckAndAppendPath("DDC CrMemo File Path");
                    end;

                }
                field("DDC CrMemo File Path - All"; Rec."DDC CrMemo File Path - All")
                {
                    AssistEdit = true;

                    trigger OnValidate()
                    begin
                        CheckAndAppendPath("DDC CrMemo File Path - All");
                    end;

                    trigger OnAssistEdit()
                    var
                        FileManagement: Codeunit "File Management";
                    begin
                        "DDC CrMemo File Path - All" := FileManagement.BrowseForFolderDialog(ExportFilePathTxt, '', false);
                        CheckAndAppendPath("DDC CrMemo File Path - All");
                    end;

                }
                field("Invoice Report ID"; rec."Invoice Report ID")
                {
                    Caption = 'Invoice Report ID';
                    ToolTip = 'Enter Report ID of Invoicing Report.  If 0, Report 50060 will be used.';
                }
                field("Invoice Report File Name"; rec."Invoice Report File Name")
                {
                    Caption = 'Invoice Report Export File Name';
                    ToolTip = 'Enter File Name for exported Invoice PDF file';
                }
            }
            group(eCommerce)
            {
                field("eCommerce Order Nos."; Rec."eCommerce Order Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Order Nos. to use for new orders sourced by D365BC SaaS';
                }
                field("eCommerce Process No. Entries"; Rec."eCommerce Process No. Entries")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the no. of entries to process for a given iteration of the job queue';
                }
                field("eCommerce Max. No. of Attempts"; Rec."eCommerce Max. No. of Attempts")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the maximum number of attempts to process an entry';
                }
                field("eCommerce Auto-Release"; Rec."eCommerce Auto-Release")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether an attempt should be made to release the sales order once it is successfully created';
                }
                field("eCommerce Bypass Price/Promotion"; Rec."eCommerce Bypass Price/Promotion")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether custom price/promotion logic should be bypassed when eCommerce Entry records are converted to sales lines (system default)';
                }
                field("eCommerce Strip Leading Chars."; Rec."eCommerce Strip Leading Chars.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many leading characters of the eCommerce Order ID should be stripped';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ExportJDEAP)
            {
                ApplicationArea = All;
                Image = ExportAttachment;
                RunObject = codeunit "Export AP Details to JDE TEST";               
            }
             action(ExportJDEGL)
            {
                ApplicationArea = All;
                Image = ExportAttachment;            
                RunObject = codeunit "Export GL Details to JDE TEST";               
            }
        }
    }

    local procedure CheckAndAppendPath(var value: Text)
    begin
        if value <> '' then
            if CopyStr(value, StrLen(value), 1) <> '\' then
                value += '\'
    end;

    trigger OnOpenPage();
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;

    trigger OnAfterGetRecord();
    begin
        SalesTerms := GetTermsandConditions;
    end;

    var
        FileManagement: Codeunit "File Management";
        ExportFileTxt: Label 'Export to Text File';
        ExportFilePathTxt: Label 'Select File Export Path';
        ClientFileName: Text[250];
        SalesTerms: Text;

}
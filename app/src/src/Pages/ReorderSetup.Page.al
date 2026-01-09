page 50119 "ARC Reorder Setup"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    PageType = Card;
    SourceTable = "ARC Reorder Setup";
    Caption = 'ReOrder Setup';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Order Nos.";Rec."Order Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order no. series for ReOrder';
                }
                field("Order Source"; Rec."Order Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies value to be used for Order Source on new sales orders originating from ReOrder portal';
                }
                field("Max Entries to Process";Rec."Max Entries to Process")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the maximum number of entries to process when the ReOrder codeunit runs on the job queue';
                }
                field("SMTP Errors Notif. Email From";Rec."SMTP Errors Notif. Email From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify a valid return email address from which errors are emailed; SMTP Mail Setup is required';
                }
                field("SMTP Errors Notif. Email To"; Rec."SMTP Errors Notif. Email To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify one valid email address to which errors should be emailed; SMTP Mail Setup is required; use an email distribution list if multiple addresses are required';
                }
                field("SMTP Errors Notif. Email Subj.";Rec."SMTP Errors Notif. Email Subj.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the email subject to be used for error notifications';
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
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.FindFirst() then begin
            Rec.Init();
            Rec.Insert(false);
        end;
    end;
}
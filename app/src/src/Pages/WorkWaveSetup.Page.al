page 50072 "ARC WorkWave Setup"
{
    ApplicationArea = Basic, Suite;
    Caption = 'WorkWave Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Customer Groups,Payments';
    SourceTable = "ARC Workwave Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Api Key";"Api Key")
                {
                    ApplicationArea = All;
                }
                field("User Name";"User Name")
                {
                    ApplicationArea = All;
                }
                field(Password;Password)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                }
                field("Transactions Url";"Transactions Url")
                {
                    ApplicationArea = All;
                }
                field("Authorize Url";"Authorize Url")
                {
                    ApplicationArea = All;
                }
                field("Credit Url";"Credit Url")
                {
                    ApplicationArea = All;
                }
                field("Void Url";"Void Url")
                {
                    ApplicationArea = All;
                }
                field("Refund Url";"Refund Url")
                {
                    ApplicationArea = All;
                }
                field("Capture Url";"Capture Url")
                {
                    ApplicationArea = All;
                }
                field("Reauth. On Partial Inv.";"Reauth. On Partial Inv.")
                {
                    ApplicationArea = All;
                }
                field("Auth/Charge Diff Amount";"Auth/Charge Diff Amount")
                {
                    ApplicationArea = All;
                }
                field("ACH Transfer Url";"ACH Transfer Url")
                {
                    ApplicationArea = All;
                }
                
                field("Retry Count";"Retry Count")
                {
                    ApplicationArea = All;
                }
                
                field("Enable Debugging";"Enable Debugging")
                {
                    ApplicationArea = All;
                }
                
                
            }
           
            
            
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Account Types")
            {
                Caption = 'Account Types';
                Image = RelatedInformation;
                Promoted = true;
                RunObject = page "ARC Acct. Type Gen. Batches";
                
            }
        }
    }

    trigger OnOpenPage()
    
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
        
    end;

}
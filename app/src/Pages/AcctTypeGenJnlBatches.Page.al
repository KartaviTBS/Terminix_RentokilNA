page 50073 "ARC Acct. Type Gen. Batches"
{
    
    ApplicationArea = All;
    Caption = 'Acct. Type Gen. Batches';
    PageType = List;
    SourceTable = "ARC WW Acct. Type GenJnl Batch";
    UsageCategory = Lists;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Account Type";"Account Type")
                {
                    ApplicationArea = All;
                }
                field("Populate Cash Receipt Jnl.";"Populate Cash Receipt Jnl.")
                {
                    ApplicationArea = All;
                }
                field("Gen. Journal Template";"Gen. Journal Template")
                {
                    ApplicationArea = All;
                }
                field("Gen. Journal Batch";"Gen. Journal Batch")
                {
                    ApplicationArea = All;
                }
                field("Temp Gen. Journal Batch";"Temp Gen. Journal Batch")
                {
                    Caption = 'Temp WW Batch Name';
                    ApplicationArea = All;
                }
                
                field("Populate External Doc. No.";"Populate External Doc. No.")
                {
                    ApplicationArea = All;
                }
                field("External Doc. No. Base";"External Doc. No. Base")
                {
                    ApplicationArea = All;
                }
                
                field("Bal. Account Type";"Bal. Account Type")
                {
                    ApplicationArea = All;
                }
                field("Bal. Account No.";"Bal. Account No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
}

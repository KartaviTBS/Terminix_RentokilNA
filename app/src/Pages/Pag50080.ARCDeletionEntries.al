page 50080 "ARC Deletion Entries"
{
    ApplicationArea = All;
    Caption = 'Deletion Entries';
    PageType = List;
    SourceTable = "ARC Deletion Entry";
    UsageCategory = Lists;
    InsertAllowed = false;
    ModifyAllowed = false;    
    
    layout
    {
        area(Content)
        {
            repeater(Entries)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field.', Comment = '%';
                }
                field("Created at DateTime"; Rec."Created at DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created at DateTime field.', Comment = '%';
                }
                field(Deleted; Rec.Deleted)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deleted field.', Comment = '%';
                }
            }
        }
    }
}

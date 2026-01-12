page 50065 "ARC AP Journal Errors List"
{

    PageType = List;
    SourceTable = "ARC AP Journal Errors";
    Caption = 'AP Journal Errors List';
    ApplicationArea = All;
    Editable = false;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Terms code"; "Terms code")
                {
                    ApplicationArea = All;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Remaining Amount"; "Remaining Amount")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor 1099 Code"; "Vendor 1099 Code")
                {
                    ApplicationArea = All;
                }
                field("GL Bal. Account"; "GL Bal. Account")
                {
                    ApplicationArea = All;
                }
                field("Dim Code1"; "Dim Code1")
                {
                    ApplicationArea = All;
                }
                field("Dim Code2"; "Dim Code2")
                {
                    ApplicationArea = All;
                }
                field("Dim Code3"; "Dim Code3")
                {
                    ApplicationArea = All;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}

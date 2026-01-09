page 50064 "ARC Inv Journal Errors List"
{

    PageType = List;
    SourceTable = "ARC Inventory Journal Errors";
    Caption = 'Inventory Journal Errors List';
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
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
                 field("Document Line No."; "Document Line No.")
                {
                    ApplicationArea = All;
                }
                field("Purchase Order No."; "Purchase Order No.")
                {
                    ApplicationArea = All;
                }  
                field("Transfer Order No."; "Transfer Order No.")
                {
                    ApplicationArea = All;
                }                

                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Agency Item"; "Agency Item")
                {
                    ApplicationArea = All;
                }               
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Rem. Quantity"; "Rem. Quantity")
                {
                    ApplicationArea = All;
                }
                field("Inv. Quantity"; "Inv. Quantity")
                {
                    ApplicationArea = All;
                }                
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Standard Cost"; "Standard Cost")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Bin Code"; "Bin Code")
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
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor Name"; "Vendor Name")
                {
                    ApplicationArea = All;
                }
                 field("Old Item No."; "Old Item No.")
                {
                    ApplicationArea = All;
                }
                field("Old Item Description"; "Old Item Description")
                {
                    ApplicationArea = All;
                }

                field("Zero Cost"; "Zero cost")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}

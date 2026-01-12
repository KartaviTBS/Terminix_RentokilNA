page 50033 "ARC Price Entry List"
{
    
    PageType = List;
    SourceTable = "ARC Price Entry";
    Caption = 'Contract Price List';
    ApplicationArea = All;
    DeleteAllowed = false;
    UsageCategory = Lists;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                
                field("Entity Type"; Rec."Entity Type")
                {
                    ApplicationArea = All;
                }
                field("Entity No."; Rec."Entity No.")
                {
                    ApplicationArea = All;
                }
                field("Entity Name"; Rec."Entity Name")
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("No. 2"; Rec."No. 2")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Agency Include"; Rec."Agency Include")
                {
                    ApplicationArea = All;
                }
                field("MCP Include"; Rec."MCP Include")
                {
                    ApplicationArea = All;
                }
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Manufacturer Code"; Rec."Manufacturer Code")
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                }
                field(Method; Rec.Method)
                {
                    ApplicationArea = All;
                }
                field("MethodValue"; Rec."Method Value")
                {
                    ApplicationArea = All;
                }
                field("Net Unit Price"; Rec."Net Unit Price")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Effective Date"; Rec."Effective Date")
                {
                    ApplicationArea = All;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = All;
                }                
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = All;
                }
                field("Modified By"; Rec."Modified By")
                {
                    ApplicationArea = All;
                }
                field("Modified On"; Rec."Modified On")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = All;
                }
                field("Approved On"; Rec."Approved On")
                {
                    ApplicationArea = All;
                }
                field("Delete Entry"; Rec."Delete Entry")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Minimum Price"; Rec."Minimum Price")
                {
                    ApplicationArea = All;
                }
                field("Markup Value"; Rec."Markup Value")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
           action(ImportPriceEntries)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import Price Entries';
                    Image = Import;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = false;
                    PromotedOnly = true;
                    ToolTip = 'Import a Price Entry File.';

                    trigger OnAction()
                    begin
                        XMLPORT.Run(XMLPORT::"ARC Price Entry Import", false, true);                        
                    end;
                }
               
        }
    }
   
    
}

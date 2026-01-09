page 50035 "ARC Price Entry Review List"
{
    
    PageType = List;
    SourceTable = "ARC Price Entry";    
    Caption = 'Contract Price Review List';
    ApplicationArea = All;
    PromotedActionCategories = 'New,Process,Report,Approve';
    UsageCategory = Lists;
    ModifyAllowed = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTableView = where("Status" = filter(Review));

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No.";"Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }                
                field("Entity Type";"Entity Type")
                {
                    ApplicationArea = All;
                }
                field("Entity No.";"Entity No.")
                {
                    ApplicationArea = All;
                }
                field("Entity Name";"Entity Name")
                {
                    ApplicationArea = All;
                }
                field(Type;Type)
                {
                    ApplicationArea = All;
                }
                field("No.";"No.")
                {
                    ApplicationArea = All;
                }
                field("No. 2";"No. 2")
                {
                    ApplicationArea = All;
                }
                field(Description;Description)
                {
                    ApplicationArea = All;
                }
                field("Agency Include";"Agency Include")
                {
                    ApplicationArea = All;
                }
                field("MCP Include";"MCP Include")
                {
                    ApplicationArea = All;
                }
                field("Minimum Quantity";"Minimum Quantity")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Variant Code";"Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Vendor No.";"Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Manufacturer Code";"Manufacturer Code")
                {
                    ApplicationArea = All;
                }
                field("Item Category Code";"Item Category Code")
                {
                    ApplicationArea = All;
                }
                field(Method;Method)
                {
                    ApplicationArea = All;
                }
                field("Method Value.";"Method Value")
                {
                    ApplicationArea = All;
                }
                field("Net Unit Price";"Net Unit Price")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Minimum Price";"Minimum Price")
                {
                    ApplicationArea = All;
                }
                field("Effective Date";"Effective Date")
                {
                    ApplicationArea = All;
                }
                field("Expiration Date";"Expiration Date")
                {
                    ApplicationArea = All;
                }
                field(Comment;Comment)
                {
                    ApplicationArea = All;
                }
                field(Status;Status)
                {
                    ApplicationArea = All;
                }
                field("Approver User Group";"Approver User Group")
                {
                    
                }
                field("Created By";"Created By")
                {
                    ApplicationArea = All;
                }
                field("Created On";"Created On")
                {
                    ApplicationArea = All;
                }
                field("Modified By";"Modified By")
                {
                    ApplicationArea = All;
                }
                field("Modified On";"Modified On")
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
           
            group(Approval)
            {
                Caption = 'Approval';
                
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Approve the requested changes.';
                    

                    trigger OnAction()
                    var
                        PriceMgt: Codeunit "ARC Price Management";
                    begin
                        PriceMgt.ApprovePriceEntry(Rec);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Reject the approval request.';

                    trigger OnAction()
                    var
                        PriceMgt: Codeunit "ARC Price Management";
                    begin
                       PriceMgt.RejectPriceEntry(Rec);                       
                    end;
                }
            }
        }
    }
   
   
    
}

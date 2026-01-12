page 50034 "ARC Price Review Entry List"
{
    
    PageType = List;
    SourceTable = "ARC Price Review Entry";
    Caption = 'Sales Price Review List';
    PromotedActionCategories = 'New,Process,Report,Approve';
    ApplicationArea = All;
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
                }
                field("Document Area";"Document Area")
                {
                    ApplicationArea = All;
                }
                field("Document Type";"Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No.";"Document No.")
                {
                    ApplicationArea = All;
                }
                field("Document Line No.";"Document Line No.")
                {
                    ApplicationArea = All;
                }
                field("Entity Type";"Entity Type")
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
                field("Unit Price";"Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Minimum Price";"Minimum Price")
                {
                    ApplicationArea = All;
                }                
                field("Unit Cost";"Unit Cost")
                {
                    ApplicationArea = All;
                }
                field("Line Discount Amount";"Line Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Line Amount Excl. Tax";"Line Amount Excl. Tax")
                {
                    ApplicationArea = All;
                }
                field("Net Unit Price";"Net Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Margin %";"Margin %")
                {
                    ApplicationArea = All;
                }
                field("Price Entry No.";"Price Entry No.")
                {
                    ApplicationArea = All;
                }
                
                field(Status;Status)
                {
                    ApplicationArea = All;
                }
                field("Last Entry";"Last Entry")
                {
                    ApplicationArea = All;
                }
                field("Entry Text";"Entry Text")
                {
                    ApplicationArea = All;
                }
                field("Created By";"Created By")
                {
                    ApplicationArea = All;
                }
                field("Created On";"Created On")
                {
                    ApplicationArea = All;
                }
               
                field("Approved By";"Approved By")
                {
                    ApplicationArea = All;
                }
                field("Approved On";"Approved On")
                {
                    ApplicationArea = All;
                }
                field(Approver;Approver)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            group("Navigate")
            {
                Caption = 'Navigate';
                Image = Navigate;
                action("Show Document")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Document';
                    Image = Document;
                    Promoted = true;

                    trigger OnAction()
                    var
                        PriceMgt: Codeunit "ARC Price Management";                      
                      begin
                        PriceMgt.ShowDocument(Rec);
                    end;
                }
            }
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
                        PriceMgt.ApprovePriceReviewEntry(Rec);
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
                       PriceMgt.RejectPriceReviewEntry(Rec);                       
                    end;
                }
            }
            action(DocLineNo)
            {
                Image = AutoReserve;
                ApplicationArea = All;
                ToolTip = 'Correct the Document Line No.';
                Caption = 'Doc. Line No.';

                trigger OnAction()
                var
                    _PriceMgt: Codeunit "ARC Price Management";
                begin
                    _PriceMgt.FixPriceEntryDocLineNo(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}

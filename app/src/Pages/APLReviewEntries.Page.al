page 50043 "ARC APL Review Entries"
{
    PageType = List;
    SourceTable = "ARC APL Review Entry";
    Caption = 'APL Review Entries';
    UsageCategory = Lists;
    ApplicationArea = All;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field("Document Area";"Document Area")
                {
                }
                field("Document Type";"Document Type")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("Document Line No.";"Document Line No.")
                {
                }
                field("Sell-to Customer No.";"Sell-to Customer No.")
                {
                }
                field("Sell-to Customer Name";"Sell-to Customer Name")
                {
                }
                field("Sell-to Customer Name 2";"Sell-to Customer Name 2")
                {
                }
                field("Sell-to Address";"Sell-to Address")
                {
                }
                field("Sell-to Address 2";"Sell-to Address 2")
                {
                }
                field("Sell-to City";"Sell-to City")
                {
                }
                field("Sell-to County";"Sell-to County")
                {
                }
                field("Sell-to Post Code";"Sell-to Post Code")
                {
                }
                field("Bill-to Customer No.";"Bill-to Customer No.")
                {
                }
                field("Bill-to Customer Name";"Bill-to Customer Name")
                {
                }
                field("Bill-to Customer Name 2";"Bill-to Customer Name 2")
                {
                }
                field("Bill-to Address";"Bill-to Address")
                {
                }
                field("Bill-to Address 2";"Bill-to Address 2")
                {
                }
                field("Bill-to City";"Bill-to City")
                {
                }
                field("Bill-to County";"Bill-to County")
                {
                }
                field("Bill-to Post Code";"Bill-to Post Code")
                {
                }
                field("Ship-to Code";"Ship-to Code")
                {
                }
                field("Ship-to Name";"Ship-to Name")
                {
                }
                field("Ship-to Address";"Ship-to Address")
                {
                }
                field("Ship-to Address 2";"Ship-to Address 2")
                {
                }
                field("Ship-to City";"Ship-to City")
                {
                }
                field("Ship-to County";"Ship-to County")
                {
                }
                field("Ship-to Post Code";"Ship-to Post Code")
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Unit Price";"Unit Price")
                {
                }
                field("Line Amount";"Line Amount")
                {
                }
                field("Created by";"Created by")
                {
                }
                field("Created at DateTime";"Created at DateTime")
                {
                }
                field(Reviewed;Reviewed)
                {
                }
                field("Reviewed by";"Reviewed by")
                {
                }
                field("Reviewed at DateTime";"Reviewed at DateTime")
                {
                }
                field("Reviewed Error Text";"Reviewed Error Text")
                {
                }
                field(Notified;Notified)
                {
                    Visible = false;
                }
                field("Notified at DateTime";"Notified at DateTime")
                {
                    Visible = false;
                }
                field("Notified Error Text";"Notified Error Text")
                {
                    Visible = false;
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
            action(ShowDocument)
            {
                Image = Document;
                Caption = 'Show Document';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                var
                    _APLMgt: Codeunit "ARC APL Management";
                begin
                    _APLMgt.ShowDocument(Rec);
                end;
            }
            action(ApproveEntry)
            {
                Image = Approve;
                Caption = 'Approve Entry';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                var
                    _APLMgt: Codeunit "ARC APL Management";
                begin
                    _APLMgt.ApproveRejectReviewEntry(Rec, true, false);
                end;
            }
            action(ApproveDoc)
            {
                Image = Approve;
                Caption = 'Approve Document';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                var
                    _APLMgt: Codeunit "ARC APL Management";
                begin
                    _APLMgt.ApproveRejectReviewEntry(Rec, true, true);
                end;
            }
            action(RejectEntry)
            {
                Image = Reject;
                Caption = 'Reject Entry';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                var
                    _APLMgt: Codeunit "ARC APL Management";
                begin
                    _APLMgt.ApproveRejectReviewEntry(Rec, false, false);
                end;
            }
            action(RejectDoc)
            {
                Image = Reject;
                Caption = 'Reject Document';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                var
                    _APLMgt: Codeunit "ARC APL Management";
                begin
                    _APLMgt.ApproveRejectReviewEntry(Rec, false, true);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrPage.Editable := not GuiAllowed;
        if GuiAllowed then
            if GetFilter("Document Line No.") = '' then
                SetRange(Reviewed,0);
    end;

    trigger OnInsertRecord(BelowxRec : Boolean) : Boolean;
    var
        _Text000Err: TextConst ENU='Not allowed.';
    begin
        if GuiAllowed then
            Error(_Text000Err);
    end;

    trigger OnModifyRecord() : Boolean;
    var
        _Text000Err: TextConst ENU='Not allowed.';
    begin
        if GuiAllowed then
            Error(_Text000Err);
    end;

    trigger OnDeleteRecord() : Boolean;
    var
        _Text000Err: TextConst ENU='Not allowed.';
    begin
        if GuiAllowed then
            Error(_Text000Err);
    end;
}
page 50044 "ARC VFM Entries"
{
    PageType = List;
    SourceTable = "ARC VFM Entry";
    Caption = 'VFM Entries';
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
                field("Item No.";"Item No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Substitution No.";"Substitution No.")
                {
                }
                field("Subst. Description";"Subst. Description")
                {
                }
                field(Ranking;Ranking)
                {
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                }
                field("Cost per Application";"Cost per Application")
                {
                }
                field("Applications per UOM";"Applications per UOM")
                {
                }
                field("Created by";"Created by")
                {
                }
                field("Created at DateTime";"Created at DateTime")
                {
                }
                field("NAV Processed";"NAV Processed")
                {
                    Visible = false;
                }
                field("NAV Processed at DateTime";"NAV Processed at DateTime")
                {
                    Visible = false;
                }
                field("NAV Processed Duration";"NAV Processed Duration")
                {
                    Visible = false;
                }
                field("NAV Processed Error Text";"NAV Processed Error Text")
                {
                    Visible = false;
                }
                field("NAV Notified";"NAV Notified")
                {
                    Visible = false;
                }
                field("NAV Notified at DateTime";"NAV Notified at DateTime")
                {
                    Visible = false;
                }
                field("NAV Notified Error Text";"NAV Notified Error Text")
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
            action(Import)
            {
                Caption = 'Import Data';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                begin
                    Xmlport.Run(Xmlport::"ARC VFM Import");
                    CurrPage.Update(false);
                end;
            }
            action(ShowItem)
            {
                Caption = 'Show Item';
                Image = Item;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    _VFMMgt: Codeunit "ARC VFM Management";
                begin
                    _VFMMgt.ShowItemRec(Rec);
                end;
            }
            action(ShowSubstItem)
            {
                Caption = 'Show Subst. Item';
                Image = Item;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    _VFMMgt: Codeunit "ARC VFM Management";
                begin
                    _VFMMgt.ShowSubstItemRec(Rec);
                end;
            }
            action(Test)
            {
                Caption = 'Test';
                Image = TestFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    _VFMMgt: Codeunit "ARC VFM Management";
                begin
                    _VFMMgt.TestVFM();
                    CurrPage.Update(false);
                end;
            }
            action(Delete)
            {
                Caption = 'Delete';
                Image = Delete;

                trigger OnAction()
                var
                    _VFMMgt: Codeunit "ARC VFM Management";
                begin
                    _VFMMgt.DeleteEntry(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(DeleteAll)
            {
                Caption = 'Delete All';
                Image = Delete;

                trigger OnAction()
                var
                    _VFMMgt: Codeunit "ARC VFM Management";
                begin
                    _VFMMgt.DeleteAllEntries(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

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

    trigger OnOpenPage()
    begin
        CurrPage.Editable := NOT GuiAllowed;
    end;
}
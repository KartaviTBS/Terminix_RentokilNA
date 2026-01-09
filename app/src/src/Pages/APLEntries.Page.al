page 50042 "ARC APL Entries"
{
    PageType = List;
    SourceTable = "ARC APL Entry";
    Caption = 'APL Entries';
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
                }
                field("NAV Processed at DateTime";"NAV Processed at DateTime")
                {
                }
                field("NAV Processed Duration";"NAV Processed Duration")
                {
                }
                field("NAV Processed Error Text";"NAV Processed Error Text")
                {
                }
                field("NAV Notified";"NAV Notified")
                {
                }
                field("NAV Notified at DateTime";"NAV Notified at DateTime")
                {
                }
                field("NAV Notified Error Text";"NAV Notified Error Text")
                {
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
                    Xmlport.Run(Xmlport::"ARC APL Import");
                    CurrPage.Update(false);
                end;
            }
            action(Process)
            {
                Caption = 'Process one record';
                Image = Process;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    _APLMgt: Codeunit "ARC APL Management";
                begin
                    _APLMgt.SetMaxEntriesToProcess(1);
                    _APLMgt.Run;
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
                    _APLMgt: Codeunit "ARC APL Management";
                begin
                    _APLMgt.ShowItemRec(Rec);
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
                    _APLMgt: Codeunit "ARC APL Management";
                begin
                    _APLMgt.ShowSubstItemRec(Rec);
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
                    _APLMgt: Codeunit "ARC APL Management";
                begin
                    _APLMgt.TestAPL();
                    CurrPage.Update(false);
                end;
            }
            action(Delete)
            {
                Caption = 'Delete';
                Image = Delete;

                trigger OnAction()
                var
                    _APLMgt: Codeunit "ARC APL Management";
                begin
                    _APLMgt.DeleteEntry(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(DeleteAll)
            {
                Caption = 'Delete All';
                Image = Delete;

                trigger OnAction()
                var
                    _APLMgt: Codeunit "ARC APL Management";
                begin
                    _APLMgt.DeleteAllEntries(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ClearAPL)
            {
                Caption = 'Clear APL';
                Image = DefaultFault;

                trigger OnAction()
                var
                    _APLMgt: Codeunit "ARC APL Management";
                begin
                    _APLMgt.ClearAPL();
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
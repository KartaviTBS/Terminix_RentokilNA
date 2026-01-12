page 50045 "ARC System Mappings"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ARC System Mapping";
    Caption = 'System Mappings';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Mappings)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field("Source System";"Source System")
                {
                }
                field("Source Type";"Source Type")
                {
                }
                field("Source No.";"Source No.")
                {
                }
                field("Destination No.";"Destination No.")
                {
                }
                field("Created by";"Created by")
                {
                }
                field("Created at DateTime";"Created at DateTime")
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
            action(Card)
            {
                Image = Card;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    _SysMapMgt: Codeunit "ARC SystemMappingMgt";
                begin
                    _SysMapMgt.ShowCard(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Import)
            {
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    _SysMapImp: XmlPort "ARC System Mapping Import";
                begin
                    _SysMapImp.Run;
                    CurrPage.Update(false);
                end;
            }
            action(Delete)
            {
                Image = Delete;

                trigger OnAction()
                var
                    _SysMapMgt: Codeunit "ARC SystemMappingMgt";
                    SysMapping: Record "ARC System Mapping";
                    TextErrMsg: TextConst ENU='Do you want to delete selected records?';
                begin
                     if not Confirm(TextErrMsg,true) then
                        exit;
                     CurrPage.SetSelectionFilter(SysMapping);
                     if SysMapping.FindSet then  
                     repeat
                        _SysMapMgt.DeleteSystemMapping(SysMapping);
                     until SysMapping.Next = 0;
                    CurrPage.Update(false);
                end;
            }
            action(Purge)
            {
                Image = Delete;

                trigger OnAction();
                var
                    _SysMapMgt: Codeunit "ARC SystemMappingMgt";
                begin
                    _SysMapMgt.PurgeSystemMappings();
                    CurrPage.Update(false);
                end;
            }
            action(Test)
            {
                Image = TestFile;

                trigger OnAction()
                var
                    _SysMapMgt: Codeunit "ARC SystemMappingMgt";
                begin
                    _SysMapMgt.Test();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrPage.Editable := not GuiAllowed;
    end;
}
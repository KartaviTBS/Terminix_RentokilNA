page 50007 "ARC CAS List"
{
    PageType = List;
    SourceTable = "ARC CAS";
    Caption = 'CAS List';
    RefreshOnActivate = true;
    ApplicationArea = All;
    PromotedActionCategories = 'New,Process,Report,Navigate';
    UsageCategory = Administration;

     layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Code;Code)
                {
                    ApplicationArea = All;
                }
                field("Chemical Name";"Chemical Name")
                {
                    ApplicationArea = All;
                }
                field("CA Prop 65";"CA Prop 65")
                {
                    ApplicationArea = All;
                }
                field(Clopyralid;Clopyralid)
                {
                    ApplicationArea = All;
                }
                field("Ground Water";"Ground Water")
                {
                    ApplicationArea = All;
                }
                field(Restricted;Restricted)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            group("&CAS")
            {
                Caption = '&SDS Products';
                Image = ProductDesign;
                action("SDS Products")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'SDS Products';
                    Image = ItemLines;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        SDSProductCAS: Record "ARC SDS Product CAS";    
                        SDSProductCASList: Page "ARC SDS Product CAS List";                    
                    begin
                        clear(SDSProductCAS);
                        SDSProductCAS.SetRange("CAS Code",Code);
                        SDSProductCASList.SetTableView(SDSProductCAS);
                        SDSProductCASList.SetFields(Database::"ARC CAS");
                        SDSProductCASList.RunModal;
                    end;

                }

                action("CAS Restrictions")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'CAS Restrictions';
                    Image = ResourcePlanning;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "ARC CAS Restrictions List";
                    RunPageLink = "CAS Code" = FIELD(Code);                   

                }
                
            }
        }
    }
}
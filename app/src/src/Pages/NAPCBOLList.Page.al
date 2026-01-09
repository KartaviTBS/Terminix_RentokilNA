page 50026 "ARC NAPC BOL Code List"
{
    PageType = List;
    SourceTable = "ARC NAPC BOL";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'NAPC BOL Code List';
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Matter State"; "Matter State")
                {
                    ApplicationArea = All;
                }
                field("BOL Limit Unit"; "BOL Limit Unit")
                {
                    ApplicationArea = All;
                }
                field("BOL Limit"; "BOL Limit")
                {
                    ApplicationArea = All;
                }
                field("Placard Limit Unit"; "Placard Limit Unit")
                {
                    ApplicationArea = All;
                }
                field("Placard Limit"; "Placard Limit")
                {
                    ApplicationArea = All;
                }
                field("Placard Code"; "Placard Code")
                {
                    ApplicationArea = All;
                }
                field("Alt. BOL Code"; "Alt. BOL Code")
                {
                    ApplicationArea = All;
                }
                field(Comments; Comments)
                {
                    ApplicationArea = All;
                }

            }
        }
    }

   actions
    {
        area(Navigation)
        {
            action("&Comments")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Comments';
                Image = ViewComments;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;
                RunObject = Page "ARC NAPC BOL Comment Line List";
                RunPageLink = Code = FIELD(Code);

            }
        }
    }
}
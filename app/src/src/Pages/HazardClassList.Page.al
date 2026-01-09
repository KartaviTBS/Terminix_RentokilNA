page 50013 "ARC Hazard Class List"
{
    PageType = List;
    SourceTable = "ARC Hazard Class";
    Caption = 'Hazard Class List';
    ApplicationArea = All;
    UsageCategory = Lists;
    RefreshOnActivate = true;
    CardPageId = "ARC Hazard Class Card";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Code)
                {

                }
                field(Description; Description)
                {

                }
                field("Warehouse Storage Code"; "Warehouse Storage Code")
                {

                }
            }
        }

    }

    actions
    {
        area(Navigation)
        {
            action("Comments")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Comments';
                Image = ViewComments;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;
                RunObject = Page "ARC Hazard Class Comment Sheet";
                RunPageLink = "Hazard Class Code" = FIELD (Code);

            }
        }
    }
}
page 50058 "ARC APL FactBox"
{
    Caption = 'APL FactBox';
    PageType = ListPart;
    SourceTable = "ARC APL Entry";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(APL)
            {
                field("Item No.";"Item No.")
                {
                    Visible = false;                    
                }
                field(Ranking;Ranking)
                {
                }
                field("Cost per Application";"Cost per Application")
                {
                }
                field("Applications per UOM";"Applications per UOM")
                {
                }
                field("Substitution No.";"Substitution No.")
                {
                }
                field("Subst. Description";"Subst. Description")
                {
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Show)
            {
                Image = List;

                trigger OnAction();
                var
                    _APLEntry: Record "ARC APL Entry";
                begin
                    _APLEntry.CopyFilters(Rec);
                    Page.Run(Page::"ARC APL Entries",_APLEntry);
                end;
            }
        }
    }
    
    var
        myInt : Integer;
}
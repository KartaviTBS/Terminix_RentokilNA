page 50059 "ARC VFM FactBox"
{
    Caption = 'VFM FactBox';
    PageType = ListPart;
    SourceTable = "ARC VFM Entry";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(VFM)
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
                    _VFMEntry: Record "ARC VFM Entry";
                begin
                    _VFMEntry.CopyFilters(Rec);
                    Page.Run(Page::"ARC VFM Entries",_VFMEntry);
                end;
            }
        }
    }
    
    var
        myInt : Integer;
}
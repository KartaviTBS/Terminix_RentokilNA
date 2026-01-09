pageextension 50061 "ARC Manufacturers" extends Manufacturers
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(Processing)
        {
            action("Notes")
            {
                Caption = 'Notes';
                ToolTip = 'View or add notes for the manufacturer';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = ViewComments;
                RunObject = Page "ARC Manufacturer Notes";
                RunPageLink = Code = FIELD (Code);
                
                trigger OnAction();
                begin
                end;
            } 
        }
    }
}
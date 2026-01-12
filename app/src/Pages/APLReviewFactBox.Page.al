page 50056 "ARC APL Review FactBox"
{
    Caption = 'APL Review FactBox';
    PageType = ListPart;
    SourceTable = "ARC APL Review Entry";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(APLReview)
            {
                field("Document Line No.";"Document Line No.")
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field("Reviewed Error Text";"Reviewed Error Text")
                {
                }
                field("Reviewed by";"Reviewed by")
                {
                }
                field("Reviewed at DateTime";"Reviewed at DateTime")
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
                    _APLReviewEntry: Record "ARC APL Review Entry";
                begin
                    _APLReviewEntry.CopyFilters(Rec);
                    _APLReviewEntry.SetFilter("Document Line No.",'<>0');
                    Page.Run(Page::"ARC APL Review Entries",_APLReviewEntry);
                end;
            }
        }
    }
    
    var
        myInt : Integer;
}
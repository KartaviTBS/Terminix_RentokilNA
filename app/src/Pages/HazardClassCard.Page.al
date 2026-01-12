page 50012 "ARC Hazard Class Card"
{
    PageType = ListPlus;
    SourceTable = "ARC Hazard Class";
    Caption = 'Hazard Class Card';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
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
            part(CommentLines; "ARC Hazard Class Comment Sheet")
            {
                Caption = 'Comment Lines';
                SubPageLink = "Hazard Class Code" = FIELD (Code);
            }
        }
    }
}
page 50020  "ARC Cust. Lic. Comments Part"
{
    PageType = ListPart;
    SourceTable = "ARC Customer Lic. Comment Line";
    Caption = 'Customer License Comments';
    Autosplitkey = true;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Comment;Comment)
                {
                    ApplicationArea = All;
                }
            }
        }
      
    }
  
}
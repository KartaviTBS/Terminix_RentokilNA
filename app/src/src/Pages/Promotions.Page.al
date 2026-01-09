page 50036 "ARC Promotions"
{
    PageType = List;
    SourceTable = "ARC Promotion";
    Caption = 'Promotions List';
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code;Code)
                {
                    ApplicationArea = All;
                }
                
                field(Description;Description)
                {
                    ApplicationArea = All;
                }
            }
        }
       
    }

  
}
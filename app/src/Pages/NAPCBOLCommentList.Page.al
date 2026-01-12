page 50047 "ARC NAPC BOL Comment Line List"
{
    AutoSplitKey = true;
    PageType = List;
    SourceTable = "ARC NAPC BOL Comment Line";
    Caption = 'ARC NAPC BOL Comment Line List';
    ApplicationArea = All;
    UsageCategory = Lists;
        
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
}

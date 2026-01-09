page 50009 "ARC Localities"
{
    PageType = List;
    SourceTable = "ARC Locality";
    Caption = 'Localities';
    RefreshOnActivate = true;
    UsageCategory = Lists;   
    DelayedInsert = true;
    ApplicationArea = Basic, Suite, Service;   
    
   

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(County; County)
                {
                    ApplicationArea = All;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                }
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
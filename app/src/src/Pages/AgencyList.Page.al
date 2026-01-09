page 50061 "ARC Agencies"
{

    PageType = List;
    SourceTable = "ARC Agency";
    Caption = 'Agencies';
    ApplicationArea = All;
    UsageCategory = Lists;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Payment Terms Code"; "Payment Terms Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}

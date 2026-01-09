page 50008 "ARC CAS Restrictions List"
{
    PageType = List;
    SourceTable = "ARC CAS Restriction";
    Caption = 'CAS Restrictions List';
    DelayedInsert = true;
    RefreshOnActivate = true;
    
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("CAS Code";"CAS Code")
                {
                    ApplicationArea = All;
                }
                field("Country/Region Code";"Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(County;County)
                {
                    ApplicationArea = All;
                }
                field("Locality Code";"Locality Code")
                {
                    ApplicationArea = All;
                }
                field("Product Type Restriction Code";"Product Type Restriction Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
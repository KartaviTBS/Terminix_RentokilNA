page 50024 "ARC Target Setup"
{
    ApplicationArea = Basic,Suite;
    Caption = 'Target Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "ARC Target Setup";
    UsageCategory = Administration;


    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("CA Prop 65 Statement";"CA Prop 65 Statement")
                {
                    ApplicationArea = All;                    
                }
                field("Unregulated Product BOL Code";"Unregulated Product BOL Code")
                {
                    ApplicationArea = All;                    
                }
            }
            group(NoSeries)
            {
                Caption = 'No. Series';
                field("NAPC BOL Nos.";"NAPC BOL Nos.")
                {
                    ApplicationArea = All;                    
                }
                field("NAPC Manifest Nos.";"NAPC Manifest Nos.")
                {
                    ApplicationArea = All;                    
                }
            }
        }
    }

    trigger OnOpenPage();
    begin
        Reset;
        if not Get then begin
          Init;
          Insert;
        end;
    end;
}
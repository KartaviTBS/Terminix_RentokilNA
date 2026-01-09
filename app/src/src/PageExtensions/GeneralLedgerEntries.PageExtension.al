pageextension 50019 "ARC General Ledger Entries" extends "General Ledger Entries"
{
    layout
    {
        addafter("Global Dimension 2 Code")
        {
            field("Global Dimension 3 Code";"Global Dimension 3 Code")
            {
                ApplicationArea = All;
            }
            field("ARC WorkWave Entry No.";"ARC WorkWave Entry No.")
            {
                ApplicationArea = All;
            }
            
        }
    }

    actions
    {
        addafter(Dimensions)
        {
            action(WorkWaveEntry)
            {
              ApplicationArea=Basic,Suite;
              Caption = 'WorkWave Entry';
              RunObject=Page 50074;
              RunPageLink= "Entry No." =field("ARC WorkWave Entry No.");
              Image = CreditCardLog;
            }
        }
    }
    
    var
        myInt : Integer;
}
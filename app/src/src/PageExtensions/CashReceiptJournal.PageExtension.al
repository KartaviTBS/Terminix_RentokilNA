pageextension 50025 "ARC Cash Receipt Journal" extends "Cash Receipt Journal"
{
    layout
    {
        addafter("Document No.")
        {
            field("Line No.";"Line No.")
            {
                ApplicationArea = All;
            }
        }
        addafter("Applies-to ID")
        {
            field("ARC WorkWave Entry No.";"ARC WorkWave Entry No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }

    actions
    {
        addafter(IncomingDoc)
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
pageextension 50054 "ARC Customer Ledger Entries" extends "Customer Ledger Entries"
{
    layout
    {
        addafter("Global Dimension 2 Code")
        {            
            field("ARC WorkWave Entry No.";"ARC WorkWave Entry No.")
            {
                ApplicationArea = All;
            }
            
        }
        addlast(Control1)
        {
            field(ARCExtDocNo;"External Document No.")
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
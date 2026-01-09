pageextension 50043 "ARC Cust. Posting Group Card" extends "Customer Posting Group Card"
{
    layout
    {
        addlast(General)
        {
            field("ARC LOB Lift %";"ARC LOB Lift %")
            {
            }
            field("ARC Internal Customer";"ARC Internal Customer")
            {
            }
            field("ARC Material Expense Account";"ARC Material Expense Account")
            {
                ApplicationArea = All;
            }
            
        }
    }

    actions
    {
    }    
   
}
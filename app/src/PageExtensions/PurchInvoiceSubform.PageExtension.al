pageextension 50078 "ARC Purch. Invoice Subform" extends "Purch. Invoice Subform"
{
    layout
    {
       addafter(Description)
       {
           field("Description 2";"Description 2")
           {
               ApplicationArea = All;
           }
       }

        modify("Unit of Measure")
        {
            Visible = false;
            Enabled = false;
        }

    }

  
}
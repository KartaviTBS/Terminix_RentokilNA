pageextension 50079 "ARC Purch. Cr. Memo Subform" extends "Purch. Cr. Memo Subform"
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
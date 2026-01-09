pageextension 50015 "ARC Purchase Order Subform" extends "Purchase Order Subform"
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

  
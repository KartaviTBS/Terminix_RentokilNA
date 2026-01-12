pageextension 50071 "ARC Purchase Invoice" extends "Purchase Invoice"
{
    layout
    {
       addafter("Buy-from Vendor Name")
       {
           field("Vendor Name 2";"Buy-from Vendor Name 2")
           {
               ApplicationArea = All;
           }
       }      
    }

    actions
    {
        // Add changes to page actions here
    }

}
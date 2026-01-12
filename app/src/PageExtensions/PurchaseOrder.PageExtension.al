pageextension 50018 "ARC Purchase Order" extends "Purchase Order"
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
       addafter("Order Date")
       {
           field("Reason Code";"Reason Code")
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
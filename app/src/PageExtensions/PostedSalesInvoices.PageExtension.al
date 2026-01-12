pageextension 50028 "ARC Posted Sales Invoces" extends "Posted Sales Invoices"
{
    layout
    {
        addafter("Ship-to Contact")
        {
            field("Order No.";"Order No.")
            {
                ApplicationArea = All;
            }
            
            field("ARC Workwave Order";"ARC Workwave Order")
            {
                ApplicationArea = All;
            }
            
        }
    }

   
    
    actions
    {
        
       addafter(IncomingDoc)
        { 
            action(UpdateInvs)
            {
                ApplicationArea = All;
                Caption = 'Import/Export';
                Image = ImportExport;
            
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    XMLPORT.Run(XMLPORT::"Update Invoice Due Dates");
                end;
            }
         }
         addafter(Dimensions)
         {
            action("WorkWaveEntries")
            {
                Caption = 'WorkWave Entries';
                Image = CreditCardLog;
                PromotedCategory=Category4;
                Promoted = true;
                RunObject = page "ARC Workwave Entries";
                RunPageLink = "Sales Order No." = field("Order No.");
            }
         }
    }
    var
        myInt : Integer;
}
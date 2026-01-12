pageextension 50053 "ARC Posted Sales Invoice" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Order No.")
        {
            field("ARC Workwave Order";"ARC Workwave Order")
            {
                ApplicationArea = All;
            }
            
        }
    }

       actions
    {
        
       addafter(Statistics)
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
         addafter("Co&mments")
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
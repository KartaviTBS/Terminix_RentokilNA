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
            group("2Ship Integration")
            {
                Caption = '2Ship';
                Editable = false;
                field("2Ship Label Link"; Rec."2Ship Label Link")
                {
                    ApplicationArea = All;
                }
                field("2Ship BOL Link"; Rec."2Ship BOL Link")
                {
                    ApplicationArea = All;
                }
                field("2Ship Tracking No."; Rec."2Ship Tracking No.")
                {
                    ApplicationArea = All;
                }                            
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
pageextension 50027 "ARC Subcontracting Worksheet" extends "Subcontracting Worksheet"
{
    layout
    {
        addbefore(Type)
        {
            field("ARC Selected";"ARC Selected")
            {
                ApplicationArea = All;
            }
            
        }
    }

    actions
    {
        addlast(Processing)
        {
         action("SelectAll")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Select All';
                    Image = SelectEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction();
                    var
                        ReqLine: Record "Requisition Line";
                    begin 
                        ReqLine.Reset;
                        ReqLine.SetRange("Worksheet Template Name","Worksheet Template Name");
                        ReqLine.SetRange("Journal Batch Name","Journal Batch Name");
                        ReqLine.ModifyAll("ARC Selected",true);

                    end;
                 

                }
        }
    }
    
    var
        myInt : Integer;
}
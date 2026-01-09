pageextension 50064 "ARC Company Information" extends "Company Information"
{
    layout
    {
        addafter("Federal ID No.")
        {
            field("ARC Company Code";"ARC Company Code")
            {
                ApplicationArea = All;
            }
            field("ARC Company Identifier";"ARC Company Identifier")
            {
                ApplicationArea = All;
            }
            
        }
        addlast(Payments)
        {
            field("ARC Remit to Name";"ARC Remit to Name")
            {
            }
            field("ARC Remit to Address";"ARC Remit to Address")
            {
            }
            field("ARC Remit to City";"ARC Remit to City")
            {
            }
            field("ARC Remit to County";"ARC Remit to County")
            {
            }
            field("ARC Remit to Post Code";"ARC Remit to Post code")
            {
            }   
            field("ARC Remit to Phone No.";"ARC Remit to Phone No.")
            {
            }                                               
        }
    }
     actions
    {
        addafter(Currencies)
        {
            action("TestCharge")
            {
                Caption = 'Test Charge';
                Image = TestDatabase;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var 
                    WorkWaveMgt: Codeunit "ARC Workwave Management";
                begin 
                    WorkWaveMgt.ChargeTransaction('101005',"ARC Remit to Address",15.77,0);
                end;
               
            }

            action("Transactions")
            {
                Caption = 'Transactions';
                Image = ExecuteBatch;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var 
                    WorkWaveMgt: Codeunit "ARC Workwave Management";
                begin 
                    WorkWaveMgt.GetTransaction('Kz5NdR7EZB9pVM0qABXAy6AJXx4brWloDYjL');
                end;
               
            }
        }
    }
 }
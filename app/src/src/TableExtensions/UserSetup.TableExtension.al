tableextension 50026 "ARC User Setup" extends "User Setup"
{
    fields
    {
        field(50001;"ARC Sales Price Approval Mgr.";Boolean)
        {
            Caption = 'Sales Price Approval Mgr.';            
        }
        field(50002;"ARC Purchasing Manager";Boolean)
        {
            Caption = 'Purchasing Mgr.';
        }
        field(50003;"ARC Administrator";Boolean)
        {
            Caption = 'Administrator';
        }
        field(50004;"ARC Workwave Administrator";Boolean)
        {
            Caption = 'Workwave Administrator';
        }
    }
    
    var
        myInt : Integer;
}
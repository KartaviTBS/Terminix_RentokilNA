pageextension 50041 "ARC General Ledger Setup" extends "General Ledger Setup"
{
    layout
    {
        addlast(General)
        {
            field("ARC LOB Lift G/L Account"; Rec."ARC LOB Lift G/L Account")
            {
                ApplicationArea= All;
            }
        }
        addlast(Dimensions)
        {
            field("ARC Default Target LOB Code"; Rec."ARC Default Target LOB Code")
            {
                ApplicationArea = All;
            }
            field("ARC Default Pest LOB Code"; Rec."ARC Default Pest LOB Code")
            {
                ApplicationArea = All;
            }
            field("ARC Default Tax LOB Code"; Rec."ARC Default Tax LOB Code")
            {
                ApplicationArea = All;
            }
        }
        addlast(Application)
        {
            field("ARC Job Queue Credential"; Rec."ARC Job Queue Credential")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }
}
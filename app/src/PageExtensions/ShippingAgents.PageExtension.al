pageextension 50066 "ARC Shipping Agents" extends "Shipping Agents"
{
    layout
    {
        addlast(Control1)        
        {
            field("ARC Use Location Ship-to"; Rec."ARC Use Location Ship-to") { }
            field("ARC Bypass E-Ship"; Rec."ARC Bypass E-Ship")
            {
                ToolTip = 'Bypasses E-Ship functionality during posting (leveraged in C/AL codeunits 14000243 EShip CU & Rpt Subscr. Funcs and 14000245 EShip Posting Sub functions)';
            }
            field("Freight Class ID"; Rec."Freight Class ID")
            {
                ApplicationArea = All;
            }
            
        }
    }
}
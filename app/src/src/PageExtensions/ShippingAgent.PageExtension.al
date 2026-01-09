pageextension 50065 "ARC Shipping Agent" extends "Shipping Agent"
{
    layout
    {
        addlast(General)
        {
            field("ARC Use Location Ship-to"; Rec."ARC Use Location Ship-to") { }
            field("ARC Bypass E-Ship"; Rec."ARC Bypass E-Ship")
            {
                ToolTip = 'Bypasses E-Ship functionality during posting (leveraged in C/AL codeunits 14000243 EShip CU & Rpt Subscr. Funcs and 14000245 EShip Posting Sub functions)';
            }
        }
    }
}
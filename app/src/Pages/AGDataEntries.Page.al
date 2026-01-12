page 50002 "ARC AG Data Entries"
{

    PageType = List;
    SourceTable = "ARC AG Data Entry";
    Caption = 'AG Data Entries';
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("ARC Entry No."; "ARC Entry No.") { }
                field("ARC Manufacturer IC Code "; "ARC Manufacturer IC Code ") { }
                field("ARC Distributor IC Code"; "ARC Distributor IC Code") { }
                field("ARC Location IC Code"; "ARC Location IC Code") { }
                field("ARC Location City"; "ARC Location City") { }
                field("ARC Location State"; "ARC Location State") { }
                field("ARC Customer No."; "ARC Customer No.") { }
                field("ARC Ship To Code"; "ARC Ship To Code") { }
                field("ARC Ship To Name"; "ARC Ship To Name") { }
                field("ARC Ship To Address 1"; "ARC Ship To Address 1") { }
                field("ARC Ship To Address 2"; "ARC Ship To Address 2") { }
                field("ARC Ship To City"; "ARC Ship To City") { }
                field("ACR Ship To State"; "ARC Ship To State") { }
                field("ARC Ship To ZipCode"; "ARC Ship To ZipCode") { }
                field("ARC Invoice Date"; "ARC Invoice Date") { }
                field("ARC Created Date"; "ARC Created Date") { }
                field("ARC Created Time"; "ARC Created Time")
                { Visible = false; }
                field("ARC Created By"; "ARC Created By")
                { Visible = false; }
                field("ARC Invoice No."; "ARC Invoice No.") { }
                field("ARC Item No."; "ARC Item No.") { }
                field("ARC Item Description"; "ARC Item Description") { }
                field("ARC Quantity"; "ARC Quantity") { }
                field("ARC Unit of Measure Code"; "ARC Unit of Measure Code") { }
                field("ARC Unit UOM"; "ARC Unit UOM") { }
                field("ARC Unit Price"; "ARC Unit Price") { }
                field("ARC Agency"; "ARC Agency") { }
                field("ARC Sales Type"; "ARC Sales Type") { }
                field("ARC Return Reason Code"; "ARC Return Reason Code") { }
                field("ARC Bill To"; "ARC Bill To") { }
                field("ARC Bill To Name"; "ARC Bill To Name") { }
                field("ARC Bill To Address 1"; "ARC Bill To Address 1") { }
                field("ARC Bill To Address 2"; "ARC Bill To Address 2") { }
                field("ARC Bill To City"; "ARC Bill To City") { }
                field("ACR Bill To State"; "ARC Bill To State") { }
                field("ARC Bill To ZipCode"; "ARC Bill To ZipCode") { }
                field("ARC Bill To Unit Unit of Measure"; "ARC Bill To Unit of Measure") { }
                field("ARC SalesPerson Code"; "ARC SalesPerson Code") { }
                field("ARC SalesPerson Name"; "ARC SalesPerson Name") { }
                field("ARC Customer Name"; "ARC Customer Name")
                { Visible = false; }
                field("ARC Customer Address 1"; "ARC Customer Address 1")
                { Visible = false; }
                field("ARC Customer Address 2"; "ARC Customer Address 2")
                { Visible = false; }
                field("ARC Customer City"; "ARC Customer City")
                { Visible = false; }
                field("ARC Customer State"; "ARC Customer State")
                { Visible = false; }
                field("ARC Customer ZipCode"; "ARC Customer Address")
                { Visible = false; }
            }
        }
    }

}

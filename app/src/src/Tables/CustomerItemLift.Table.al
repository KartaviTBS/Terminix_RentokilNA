table 50036 "ARC Customer Item Lift"
{
    Caption = 'Customer Item Lift %';
    DrillDownPageId = "ARC Customer Item Lift List";
    LookupPageId = "ARC Customer Item Lift List";
    
    fields
    {
        field(1;"Customer No.";Code[20])
        {
            TableRelation = Customer;
        }
        field(2; "Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(3;"Lift %";Decimal)
        {
           
        }
    }

    keys
    {
        key(Key1;"Customer No.","Item No.")
        {
            Clustered = true;
        }
    }     

}
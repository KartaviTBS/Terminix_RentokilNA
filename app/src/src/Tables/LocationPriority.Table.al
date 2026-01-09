table 50077 "ARC Location Priority"
{
    // SOW11 Körber Edge WMS Integration / RDCs (Regional Distribution Centers) located in Charlotte, NC and Salt Lake City, UT
    //   agreement between ArcherPoint and Rentokil-NA executed 29 Mar 2022
    //   reference:
    //     Case 109188 Sales Order Item Routing
    //     CO1 Sales Order Item Routing - Reqmnt 1 Loc Priority
    //     CO4 Order Management
    // table 50077 "ARC Location Priority" marked obsolete b/c of fields/PK/destructiveSchemaChange - Tue 11 Oct 2022
    // table 50079 "ARC Location Pri. Ver.20221011" will be leveraged going forward - Tue 11 Oct 2022

    DataClassification = CustomerContent;
    Caption = 'Location Priority';
    ObsoleteState = Pending;
    ObsoleteReason = 'Rentokil-NA requested refactoring of SOW11 Körber Edge, CO4 Order Mgt / Location Priority - Mon 10 Oct 2022';
    
    fields
    {
        field(1; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(2; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(3; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(4; Priority; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(101; "Customer Name"; Text[100])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup (Customer.Name where ("No." = field("Customer No.")));
        }
        field(102; "Item Description"; Text[100])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup (Item.Description where ("No." = field("Item No.")));
        }
        field(103; "Location Name"; Text[100])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup (Location.Name where (Code = field("Location Code")));
        }
        field(901; "Korber Edge WMS"; Boolean)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup (Location."ARC Enable Korber WMS" where (Code = field("Location Code")));
        }
    }

    keys
    {
        key(PK;"Customer No.","Item No.","Location Code",Priority)
        {
            Clustered = true;
        }
        key(Cust; "Customer No.","Location Code","Item No.") { }
        key(ItemCust; "Item No.","Customer No.","Location Code") { }
        key(LocCust; "Location Code","Customer No.","Item No.") { }
        key(Priority; "Customer No.","Item No.",Priority) { }
    }

    trigger OnInsert();
    begin
    end;

    trigger OnModify();
    begin
    end;

    trigger OnDelete();
    begin
    end;

    trigger OnRename();
    begin
    end;
}
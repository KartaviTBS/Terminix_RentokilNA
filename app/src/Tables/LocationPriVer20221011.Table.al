table 50079 "ARC Location Pri. Ver.20221011"
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

    fields
    {
        field(1; "Sales Line Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(2; Priority; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(11; "Override Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
    }

    keys
    {
        key(PK;"Sales Line Location Code",Priority)
        {
            Clustered = true;
        }
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
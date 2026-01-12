table 50049 "ARC Deletion Entry"
{
    Caption = 'Deletion Entry';
    LookupPageId = "ARC Deletion Entries";
    DrillDownPageId = "ARC Deletion Entries";
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(11; "Document No."; Code[20]) { }
        field(21; "Created at DateTime"; DateTime) { }
        field(31; Deleted; Boolean) { }
    }

    keys
    {
        key(PrimaryKey; "Entry No.") { Clustered = true; }
        key(DocNo; "Document No.") { }
        key(CreatedAtDateTime; "Created at DateTime") { }
        key(Deleted; Deleted) { }
    }
}
table 50004 "ARC SDS Ship-from Block"
{
   
    Caption = 'SDS Ship-from Block';
    DrillDownPageID = 50004;
    LookupPageID = 50004;

    fields
    {
        field(1;"SDS Code";Code[20])
        {
            TableRelation = "ARC SDS Product";
        }
        field(2;"Location Code";Code[10])
        {
            TableRelation = Location WHERE ("Use As In-Transit"=CONST(false));
        }
        field(3;"Ship-to Country/Region Code";Code[10])
        {
            TableRelation = "Country/Region";
        }
        field(4;"Ship-to County";Text[30])
        {
            Caption = 'Ship-to State';
            TableRelation = "ARC County".Code WHERE ("Country/Region Code"=FIELD("Ship-to Country/Region Code"));
        }
        field(5;"Product Use";Option)
        {
            Caption = 'Product Use';
            OptionCaption = '" ,TO_AG,Structural,Dual,Other"';
            OptionMembers = " ",TO_AG,Structural,Dual,Other;
        }
        field(6;"Product Type Restriction Code";Code[20])
        {
            TableRelation = "ARC Product Type Restriction".Code;
        }
    }

    keys
    {
        key(Key1;"SDS Code","Location Code","Ship-to Country/Region Code","Ship-to County","Product Use","Product Type Restriction Code")
        {
        }
    }

    fieldgroups
    {
    }
}


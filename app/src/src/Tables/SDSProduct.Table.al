table 50003 "ARC SDS Product"
{
   
    Caption = 'SDS Product';
    DrillDownPageID = 50014;
    LookupPageID = 50014;

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(6;"Manufacturer Code";Code[10])
        {
            Caption = 'Manufacturer Code';
            TableRelation = Manufacturer;
        }
        field(10;"Revision Date";Date)
        {
            Caption = 'Revision Date';
        }
        field(11;"Matter State";Option)
        {
            Caption = 'Matter State';
            OptionCaption = 'Solid,Liquid,Gas,Other';
            OptionMembers = Solid,Liquid,Gas,Other;
        }
        field(20;"EPA Code";Code[20])
        {
            Caption = 'EPA Code';
        }
        field(21;"Hazard Class Code";Code[10])
        {
            Caption = 'Hazard Class Code';
            TableRelation = "ARC Hazard Class".Code;
        }
        field(22;"NFPA Placard Health Code";Code[1])
        {
            Caption = 'NFPA Placard Health Code';
            Numeric = true;
            //ValuesAllowed = '0';'1';'2';'3';'4';
        }
        field(23;"NFPA Placard Flame Code";Code[1])
        {
            Caption = 'NFPA Placard Flame Code';
            Numeric = true;
            //ValuesAllowed = 0;1;2;3;4;
        }
        field(24;"NFPA Placard Reactive Code";Code[1])
        {
            Caption = 'NFPA Placard Reactive Code';
            Numeric = true;
            //ValuesAllowed = 0;1;2;3;4;
        }
        field(25;Chronic;Boolean)
        {
            Caption = 'Chronic';
        }
        field(30;"Product Use";Option)
        {
            Caption = 'Product Use';
            InitValue = TO_AG;
            OptionCaption = '" ,TO_AG,Structural,Dual,Other"';
            OptionMembers = " ",TO_AG,Structural,Dual,Other;
        }
        field(40;"BOL/UN/Ground Code";Code[10])
        {
            TableRelation = "ARC NAPC BOL".Code;
        }
        field(41;"BOL/UN/Air Code";Code[10])
        {
            TableRelation = "ARC NAPC BOL".Code;
        }
        field(42;"BOL/UN/Water Code";Code[10])
        {
            TableRelation = "ARC NAPC BOL".Code;
        }
        field(100;"CAS Ingredients";Integer)
        {
            CalcFormula = Count("ARC SDS Product CAS" WHERE ("SDS Product Code"=FIELD(Code)));
            Caption = 'CAS Ingredients';
            Description = 'Flowfield';
            Editable = false;
            FieldClass = FlowField;
        }
        field(102;"License Types";Integer)
        {
            CalcFormula = Count("ARC Product Use License Type" WHERE ("Product Use"=FIELD("Product Use")));
            Caption = 'License Types';
            Description = 'Flowfield';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
        key(Key2;"Revision Date")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        SDSShipfromBlock.SETRANGE("SDS Code",Code);
        SDSShipfromBlock.DELETEALL;
        SDSRegionBlock.SETRANGE("SDS Code",Code);
        SDSRegionBlock.DELETEALL;
        SDSProductCAS.SETRANGE("SDS Product Code",Code);
        SDSProductCAS.DELETEALL;
    end;

    
    trigger OnRename();
    begin
        SDSShipfromBlock.SETRANGE("SDS Code",Code);
        IF NOT SDSShipfromBlock.ISEMPTY THEN
          ERROR(Text001);
        SDSRegionBlock.SETRANGE("SDS Code",Code);
        IF NOT SDSRegionBlock.ISEMPTY THEN
          ERROR(Text001);
        SDSProductCAS.SETRANGE("SDS Product Code",Code);
        IF NOT SDSProductCAS.ISEMPTY THEN
          ERROR(Text001);

    end;

    var
        SDSShipfromBlock : Record "ARC SDS Ship-from Block";
        SDSRegionBlock : Record "ARC SDS Region Block";
        SDSProductCAS : Record "ARC SDS Product CAS";
        Text001 : Label 'Rename not allowed';
    
}


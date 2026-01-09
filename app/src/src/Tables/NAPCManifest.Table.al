table 50025 "ARC NAPC Manifest"
{
   
    Caption = 'NAPC Manifest';
    DrillDownPageID = "ARC NAPC Manifest List";
    LookupPageID = "ARC NAPC Manifest List";

    fields
    {
        field(1;"No.";Code[20])
        {

            trigger OnValidate();
            begin
                if "No." <> xRec."No." then begin
                  GetTargetSetup;
                  NoSeriesMgt.TestManual(TargetSetup."NAPC Manifest Nos.");
                  "No. Series" := '';
                end;
            end;
        }
        field(10;Description;Text[50])
        {
        }
        field(11;"Shipping Agent Code";Code[10])
        {
            TableRelation = "Shipping Agent".Code;
        }
        field(12;"E-Ship Agent Service";Code[30])
        {
            TableRelation = "E-Ship Agent Service".Code WHERE ("Shipping Agent Code"=FIELD("Shipping Agent Code"));
        }
        field(30;"No. of BOL";Integer)
        {
            CalcFormula = Count("ARC NAPC BOL Header" WHERE ("Manifest No."=FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(40;"No. Series";Code[10])
        {
            CaptionML = ENU='No. Series',
                        ESM='Nos. serie',
                        FRC='Séries de n°',
                        ENC='No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert();
    begin
        if "No." = '' then begin
           GetTargetSetup;
           TargetSetup.TestField("NAPC Manifest Nos.");
           NoSeriesMgt.InitSeries(TargetSetup."NAPC Manifest Nos.",xRec."No. Series",0D,"No.","No. Series");
        end;
    end;

    var
        TargetSetup : Record "ARC Target Setup";
        NoSeriesMgt : codeunit NoSeriesManagement ;   
        HasTargetSetup : Boolean;

    procedure GetTargetSetup();
    begin
        if not HasTargetSetup then begin
          TargetSetup.GET;
          HasTargetSetup := true;
        end;
    end;
}


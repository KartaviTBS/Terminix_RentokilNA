tableextension 50001 "ARC Item" extends Item
{
    fields
    {
        field(50000; "ARC Block Regulatory"; Boolean)
        {
            Caption = 'Block Regulatory';

            trigger OnValidate()
            var
                item: Record Item;
            begin
                if ("ARC Block Regulatory" <> xRec."ARC Block Regulatory") then
                    ValidateRegulatory
            end;
        }
        field(50001; "ARC Agency Item"; Boolean)
        {
            Caption = 'Agency Item';

            trigger OnValidate()
            begin
                if "ARC Agency Item" then
                  Rec.TestField("Manufacturer Code");
                if "ARC MCP" then
                   Rec.TestField("ARC MCP",false);
            end;
        }
        field(50002; "ARC SDS Product Code"; Code[20])
        {
            Caption = 'SDS Product Code';
            TableRelation = "ARC SDS Product".Code;
        }
        field(50003; "ARC SDS Revision Date"; Date)
        {
            Caption = 'SDS Revision Date';
            FieldClass = FlowField;
            CalcFormula = lookup ("ARC SDS Product"."Revision Date" where (Code = FIELD ("ARC SDS Product Code")));
            Editable = false;
        }
        field(50004; "ARC MCP"; Boolean)
        {
            Caption = 'MCP';

            trigger OnValidate()
            begin
                if "ARC MCP" then
                   Rec.TestField("ARC Agency Item",false);
            end;
        }
        field(50005; "ARC Commission Ranking"; Boolean)
        {
            Caption = 'Commission Ranking';
        }
        field(50006; "ARC Lowest Allowable Price"; Boolean)
        {
            Caption = 'Lowest Allowable Price (Not Used)';
            ObsoleteState = Pending;
        }
        field(50007; "ARC MCP Lowest Price"; Decimal)
        {
            Caption = 'MCP Lowest Price (Not Used)';
        }
        field(50008; "ARC Minimum Price"; Decimal)
        {
            Caption = 'Minimum Price';
        }
        field(50009;"ARC Sales Cost";Decimal )
        {
            Caption = 'Sales Cost';
            trigger OnValidate() 
            begin
                Rec.Validate("Price/Profit Calculation");
            end;
        }
        field(50010;"ARC Quick Item";Boolean)
        {
            Caption = 'Quick Item';
        }
        field(50011;"ARC Target LOB";Code[20])
        {
           Caption = 'Target LOB';
           TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(3));
        }

        field(50012;"ARC BOL/UN/Ground Code";Code[20])
        {
           Caption = 'BOL/UN/Ground Code';
           Editable = false;
           FieldClass = FlowField;
           CalcFormula = lookup("ARC SDS Product"."BOL/UN/Ground Code" where (code = field("ARC SDS Product Code")));
        }
        field(50013;"ARC BOL/UN/Air Code";Code[20])
        {
           Caption = 'BOL/UN/Air Code';
           Editable = false;
           FieldClass = FlowField;
           CalcFormula = lookup("ARC SDS Product"."BOL/UN/Air Code" where (code = field("ARC SDS Product Code")));
        }
        field(50014;"ARC BOL/UN/Water Code";Code[20])
        {
           Caption = 'BOL/UN/Water Code';
           Editable = false;
           FieldClass = FlowField;
           CalcFormula = lookup("ARC SDS Product"."BOL/UN/Water Code" where (code = field("ARC SDS Product Code")));
        }
        field(50020;"ARC Purchase Block";Boolean)
        {
            Caption = 'Purchase Block';            
        }

        field(50021;"ARC Free Item";Boolean)
        {
            Caption = 'Free Item';            
        }
        field(50031; "ARC Web Enabled"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Web Enabled';
        }
        field(50042; "ARC APL"; Boolean)
        {
            Caption = 'APL';
            Editable = false;
        }
        field(50043;"ARC Ranking Code";Code[20])
        {
            Caption = 'Ranking Code';
            TableRelation = "ARC Ranking Code";
        }
        field(50061; "ARC Agency Code"; code[20])
        {
            Caption = 'Agency Code';
            TableRelation = "ARC Agency";

            trigger OnValidate()
            begin
                Rec.TestField("ARC Agency Item", true);
            end;
        }
        field(50062; "ARC Agency Payment Terms"; Code[20])
        {
            Caption = 'Agency Payment Terms';
            FieldClass = FlowField;
            CalcFormula = lookup ("ARC Agency"."Payment Terms Code" where (Code = FIELD ("ARC Agency Code")));
            Editable = false;
        }
    }

    local procedure ValidateRegulatory();
    var
        RNASetup: Record "ARC RNA Setup";
        User: Record User;
        UserGroupMember: Record "User Group Member";
    begin
        if "ARC Block Regulatory" then begin;
            Blocked := true;
            exit;
         end;               
        RNASetup.Get;
        RNASetup.TestField("Regulatory User Group");
        if not User.Get(UserSecurityId) then
            exit;
        if not UserGroupMember.Get(RNASetup."Regulatory User Group", User."User Security ID", CompanyName) then
            if not UserGroupMember.Get(RNASetup."Regulatory User Group", User."User Security ID", '') then
                error(NotAllowedTxt);
    end;

    var
        NotAllowedTxt: Label 'You are not allowed to change it.\Please contact administrator';
}




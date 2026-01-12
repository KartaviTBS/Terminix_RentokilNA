tableextension 50014 "ARC Salesperson/Purchaser" extends "Salesperson/Purchaser"
{
    fields
    {
        field(50001; "ARC Manager"; Code[50])
        {
            Caption = 'Manager';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(50002; "Agency User Group"; Code[20])
        {


            TableRelation = "User Group";
            DataClassification = CustomerContent;
            ObsoleteState = Pending;

        }
        field(50003; "MCP User Group"; Code[20])
        {

            TableRelation = "User Group";
            DataClassification = CustomerContent;
            ObsoleteState = Pending;

        }
        field(50004; "ARC Agency User Group"; Code[20])
        {
            Caption = 'Agency User Group';
            TableRelation = "User Group";
            DataClassification = CustomerContent;

        }
        field(50005; "ARC MCP User Group"; Code[20])
        {
            Caption = 'MCP User Group';
            TableRelation = "User Group";
            DataClassification = CustomerContent;

        }
        field(50061; "ARC Dimension 3"; Code[20])
        {
            Caption = 'Dimension 3';
            CaptionClass = '1,2,3';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (3));

            trigger OnValidate()
            begin
                ARCValidateShortcutDimCode(3, "ARC Dimension 3");
            end;
        }
        field(50062; "ARC Dimension 4"; Code[20])
        {
            Caption = 'Dimension 4';
            CaptionClass = '1,2,4';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (4));

            trigger OnValidate()
            begin
                ARCValidateShortcutDimCode(4, "ARC Dimension 4");
            end;
        }
        field(50063; "ARC Dimension 5"; Code[20])
        {
            Caption = 'Dimension 5';
            CaptionClass = '1,2,5';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (5));

            trigger OnValidate()
            begin
                ARCValidateShortcutDimCode(5, "ARC Dimension 5");
            end;
        }
        field(50064; "ARC Dimension 6"; Code[20])
        {
            Caption = 'Dimension 6';
            CaptionClass = '1,2,6';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (6));

            trigger OnValidate()
            begin
                ARCValidateShortcutDimCode(6, "ARC Dimension 6");
            end;
        }
        field(50065; "ARC Dimension 7"; Code[20])
        {
            Caption = 'Dimension 7';
            CaptionClass = '1,2,7';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (7));

            trigger OnValidate()
            begin
                ARCValidateShortcutDimCode(7, "ARC Dimension 7");
            end;
        }
        field(50066; "ARC Dimension 8"; Code[20])
        {
            Caption = 'Dimension 8';
            CaptionClass = '1,2,8';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (8));

            trigger OnValidate()
            begin
                ARCValidateShortcutDimCode(8, "ARC Dimension 8");
            end;
        }

        field(50071; "ARC Salesperson Dimension 1"; Code[20])
        {
            Caption = 'Slsp Dim 1';
            CaptionClass = '1,5,,' + ARCGetSalespersonDimension(1);

            trigger OnValidate();
            begin
                ARCValidateSalespersonDimValue(1, "ARC Salesperson Dimension 1");
                ARCSaveSalespersonDefaultValue(Code, ARCGetSalespersonDimension(1), "ARC Salesperson Dimension 1");
            end;

            trigger OnLookup();
            begin
                "ARC Salesperson Dimension 1" := ARCLookupSalespersonDimValue(1);
                Validate("ARC Salesperson Dimension 1");
            end;
        }
        field(50072; "ARC Salesperson Dimension 2"; Code[20])
        {
            Caption = 'Slsp Dim 2';
            CaptionClass = '1,5,,' + ARCGetSalespersonDimension(2);

            trigger OnValidate();
            begin
                ARCValidateSalespersonDimValue(2, "ARC Salesperson Dimension 2");
                ARCSaveSalespersonDefaultValue(Code, ARCGetSalespersonDimension(2), "ARC Salesperson Dimension 2");
            end;

            trigger OnLookup();
            begin
                "ARC Salesperson Dimension 2" := ARCLookupSalespersonDimValue(2);
                Validate("ARC Salesperson Dimension 2");
            end;
        }

        field(50073; "ARC Salesperson Dimension 3"; Code[20])
        {
            Caption = 'Slsp Dim 3';
            CaptionClass = '1,5,,' + ARCGetSalespersonDimension(3);

            trigger OnValidate();
            begin
                ARCValidateSalespersonDimValue(3, "ARC Salesperson Dimension 3");
                ARCSaveSalespersonDefaultValue(Code, ARCGetSalespersonDimension(3), "ARC Salesperson Dimension 3");
            end;

            trigger OnLookup();
            begin
                "ARC Salesperson Dimension 3" := ARCLookupSalespersonDimValue(3);
                Validate("ARC Salesperson Dimension 3");
            end;
        }

        field(50074; "ARC Salesperson Dimension 4"; Code[20])
        {
            Caption = 'Slsp Dim 4';
            CaptionClass = '1,5,,' + ARCGetSalespersonDimension(4);

            trigger OnValidate();
            begin
                ARCValidateSalespersonDimValue(4, "ARC Salesperson Dimension 4");
                ARCSaveSalespersonDefaultValue(Code, ARCGetSalespersonDimension(4), "ARC Salesperson Dimension 4");
            end;

            trigger OnLookup();
            begin
                "ARC Salesperson Dimension 4" := ARCLookupSalespersonDimValue(4);
                Validate("ARC Salesperson Dimension 4");
            end;
        }
        field(50075; "ARC Salesperson Dimension 5"; Code[20])
        {
            Caption = 'Slsp Dim 5';
            CaptionClass = '1,5,,' + ARCGetSalespersonDimension(5);

            trigger OnValidate();
            begin
                ARCValidateSalespersonDimValue(5, "ARC Salesperson Dimension 5");
                ARCSaveSalespersonDefaultValue(Code, ARCGetSalespersonDimension(5), "ARC Salesperson Dimension 5");
            end;

            trigger OnLookup();
            begin
                "ARC Salesperson Dimension 5" := ARCLookupSalespersonDimValue(5);
                Validate("ARC Salesperson Dimension 5");
            end;
        }
        field(50076; "ARC Salesperson Dimension 6"; Code[20])
        {
            Caption = 'Slsp Dim 6';
            CaptionClass = '1,5,,' + ARCGetSalespersonDimension(6);

            trigger OnValidate();
            begin
                ARCValidateSalespersonDimValue(6, "ARC Salesperson Dimension 6");
                ARCSaveSalespersonDefaultValue(Code, ARCGetSalespersonDimension(6), "ARC Salesperson Dimension 6");
            end;

            trigger OnLookup();
            begin
                "ARC Salesperson Dimension 6" := ARCLookupSalespersonDimValue(6);
                Validate("ARC Salesperson Dimension 6");
            end;
        }
        field(50077; "ARC Salesperson Dimension 7"; Code[20])
        {
            Caption = 'Slsp Dim 7';
            CaptionClass = '1,5,,' + ARCGetSalespersonDimension(7);

            trigger OnValidate();
            begin
                ARCValidateSalespersonDimValue(7, "ARC Salesperson Dimension 7");
                ARCSaveSalespersonDefaultValue(Code, ARCGetSalespersonDimension(7), "ARC Salesperson Dimension 7");
            end;

            trigger OnLookup();
            begin
                "ARC Salesperson Dimension 7" := ARCLookupSalespersonDimValue(7);
                Validate("ARC Salesperson Dimension 7");
            end;
        }

    }

    local procedure ARCValidateShortcutDimCode(FieldNumber: Integer; ShortcutDimCode: Code[20]);
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"Salesperson/Purchaser", Code, FieldNumber, ShortcutDimCode);
    end;

    procedure ARCGetSalespersonDimension(FieldNumber: Integer): Code[20];

    begin
        RNASetup.GET;
        case FieldNumber of
1 :
            exit(RNASetup."SalesPerson Dimension 1");
2 :
            exit(RNASetup."SalesPerson Dimension 2");
3 :
            exit(RNASetup."SalesPerson Dimension 3");
4 :
            exit(RNASetup."SalesPerson Dimension 4");
5 :
            exit(RNASetup."SalesPerson Dimension 5");
6 :
            exit(RNASetup."SalesPerson Dimension 6");
7 :
            exit(RNASetup."SalesPerson Dimension 7");
        end;
    end;

    local procedure ARCLookupSalespersonDimValue(FieldNumber: Integer): Code[20];

    begin
        DimValue.reset;
        CLEAR(DimValues);
        DimValue.SetRange("Dimension Code", ARCGetSalespersonDimension(FieldNumber));
        DimValue.SetRange(Blocked, false);
        DimValues.SetTableView(DimValue);
        DimValues.LookUpMode := true;
        if DimValues.RunModal = action::LookupOK then begin
            DimValues.GETRECORD(DimValue);
            exit(DimValue.Code);
        end;
    end;

    local procedure ARCValidateSalespersonDimValue(FieldNumber: Integer; DimValueCode: Code[20]);
    var
        DimValueError: TextConst ENU = 'Invalid Dimension Value %1 for Dimension %2';
    begin
        if DimValueCode <> '' then begin
            DimValue.Reset;
            DimValue.SetRange("Dimension Code", ARCGetSalespersonDimension(FieldNumber));
            DimValue.SetRange(Code, DimValueCode);
            if NOT DimValue.FindFirst THEN
                ERROR(DimValueError, DimValueCode, ARCGetSalespersonDimension(FieldNumber));
        end;
    end;

    local procedure ARCSaveSalespersonDefaultValue(SlspCode: Code[20]; DimCode: Code[20]; DimValueCode: Code[20]);
    var
        DefaultDim: Record "Default Dimension";
    begin
        if DimValueCode = '' then begin
            DefaultDim.SetRange("Table ID", Database::"Salesperson/Purchaser");
            DefaultDim.SetRange("No.", SlspCode);
            DefaultDim.SetRange("Dimension Code", DimCode);
            if DefaultDim.FindFirst then
                DefaultDim.Delete;
        end else begin
            DefaultDim."Table ID" := Database::"Salesperson/Purchaser";
            DefaultDim."No." := SlspCode;
            DefaultDim."Dimension Code" := DimCode;
            DefaultDim."Dimension Value Code" := DimValueCode;
            if NOT DefaultDim.Insert then
                DefaultDim.Modify
        end;
    end;

    var
        RNASetup: Record "ARC RNA Setup";
        DimValue: Record "Dimension Value";
        Dimension: Record Dimension;
        DimValues: page "Dimension Values";
        DimMgt: Codeunit DimensionManagement;
}
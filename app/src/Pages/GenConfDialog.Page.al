page 50057 "General Confirmation Dialog"
{
    PageType = StandardDialog;
    DataCaptionExpression = WindowTitle;

    layout
    {
        area(content)
        {
            grid(InstructionalTextSection)
            {
                GridLayout = Rows;
                group(InstructionalTextGroup)
                {
                    Caption = 'Instructions';
                    field(InstructionalText;InstructionalText)
                    {
                        Enabled = false;
                        ShowCaption = false;
                        Visible = NOT InstructionalTextInvisible;
                    }
                }
                group(ValuesGroup)
                {
                    Caption = 'Enter value';
                    field(TextValue;TextValue)
                    {
                        CaptionClass = FieldCaptionValue;
                        Style = Strong;
                        StyleExpr = TRUE;
                        Visible = TextVisible;
                    }
                field(BigTextValue; BigTextValue)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    CaptionClass = FieldCaptionValue;
                    Visible = BigTextVisible;
                }
                    field(BooleanValue;BooleanValue)
                    {
                        CaptionClass = FieldCaptionValue;
                        Style = Strong;
                        StyleExpr = TRUE;
                        Visible = BooleanVisible;
                    }
                    field(CodeValue;CodeValue)
                    {
                        CaptionClass = FieldCaptionValue;
                        Style = Strong;
                        StyleExpr = TRUE;
                        Visible = CodeVisible;
                    }
                    field(DecimalValue;DecimalValue)
                    {
                        CaptionClass = FieldCaptionValue;
                        Style = Strong;
                        StyleExpr = TRUE;
                        Visible = DecimalVisible;
                    }
                    field(IntegerValue;IntegerValue)
                    {
                        CaptionClass = FieldCaptionValue;
                        Style = Strong;
                        StyleExpr = TRUE;
                        Visible = IntegerVisible;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ActionName)
            {
            }
        }
    }
    
    trigger OnOpenPage();
    begin
        IF InstructionalText = '' THEN
          InstructionalText := Text000;
    end;

    var
        BigTextVisible: Boolean;
        BooleanValue : Boolean;
        [InDataSet]
        BooleanVisible : Boolean;
        [InDataSet]
        CodeVisible : Boolean;
        [InDataSet]
        DecimalVisible : Boolean;
        [InDataSet]
        InstructionalTextInvisible : Boolean;
        [InDataSet]
        IntegerVisible : Boolean;
        [InDataSet]
        TextVisible : Boolean;
        CodeValue : Code[250];
        DecimalValue : Decimal;
        IntegerValue : Integer;
        BigTextValue: Text;
        [InDataSet]
        FieldCaptionValue : Text[80];
        InstructionalText : Text[250];
        TextValue : Text[250];
        [InDataSet]
        WindowTitle : Text[80];
        Text000 : Label 'Click OK or press Ctrl+Enter when complete.';

    procedure GetBooleanValue() : Boolean;
    begin
        exit(BooleanValue);
    end;

    procedure GetCodeValue() : Code[250];
    begin
        exit(CodeValue);
    end;

    procedure GetDecimalValue() : Decimal;
    begin
        exit(DecimalValue);
    end;

    procedure GetIntegerValue() : Integer;
    begin
        exit(IntegerValue);
    end;

    procedure GetTextValue() : Text[250];
    begin
        exit(TextValue);
    end;

    procedure SetBigTextValue(_BigTextValue: Text)
    begin
        BigTextValue := _BigTextValue;
    end;

    procedure SetBigTextVisible()
    begin
        BigTextVisible := true;
    end;

    procedure SetBooleanValueTrue();
    begin
        BooleanValue := true;
    end;

    procedure SetBooleanVisible();
    begin
        BooleanVisible := true;
    end;

    procedure SetCodeValue(_CodeValue : Code[250]);
    begin
        CodeValue := _CodeValue;
    end;

    procedure SetCodeVisible();
    begin
        CodeVisible := TRUE;
    end;

    procedure SetDecimalValue(_DecimalValue : Decimal);
    begin
        DecimalValue := _DecimalValue;
    end;

    procedure SetDecimalVisible();
    begin
        DecimalVisible := TRUE;
    end;

    procedure SetFieldCaptionValue(_FieldCaptionValue : Text[80]);
    begin
        FieldCaptionValue := _FieldCaptionValue;
    end;

    procedure SetInstructionalText(_InstructionalText : Text[250]);
    begin
        InstructionalText := _InstructionalText;
    end;

    procedure SetInstructionalTextInvisible();
    begin
        InstructionalTextInvisible := TRUE;
    end;

    procedure SetIntegerValue(_IntegerValue : Integer);
    begin
        IntegerValue := _IntegerValue;
    end;

    procedure SetIntegerVisible();
    begin
        IntegerVisible := TRUE;
    end;

    procedure SetTextValue(_TextValue : Text[250]);
    begin
        TextValue := _TextValue;
    end;

    procedure SetTextVisible();
    begin
        TextVisible := TRUE;
    end;

    procedure SetWindowTitle(_WindowTitle : Text[80]);
    begin
        WindowTitle := _WindowTitle;
    end;
}
page 50597 "ARC Run Fields"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ARC Buffer";
    SourceTableTemporary = true;
    Editable = false;
    Caption = 'Run Fields';

    layout
    {
        area(Content)
        {
            repeater("Fields")
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Entry No.';
                    ToolTip = 'Specifies field value';
                }
                field("Integer 01"; Rec."Integer 01")
                {
                    ApplicationArea = All;
                    Caption = 'Table No.';
                    ToolTip = 'Specifies field value';
                }
                field("Text 01"; Rec."Text 01")
                {
                    ApplicationArea = All;
                    Caption = 'Table Name';
                    ToolTip = 'Specifies field value';
                }
                field("Integer 02"; Rec."Integer 02")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                    ToolTip = 'Specifies field value';
                }
                field("Text 02"; Rec."Text 02")
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies field value';
                }
                field("Text 03"; Rec."Text 03")
                {
                    ApplicationArea = All;
                    Caption = 'Caption';
                    ToolTip = 'Specifies field value';
                }
                field("Integer 03"; Rec."Integer 03")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Caption = 'Type';
                    ToolTip = 'Specifies field value';
                }
                field("Integer 04"; Rec."Integer 04")
                {
                    ApplicationArea = All;
                    Caption = 'Len';
                    ToolTip = 'Specifies field value';
                }
                field("Integer 05"; Rec."Integer 05")
                {
                    ApplicationArea = All;
                    Caption = 'Class';
                    ToolTip = 'Specifies field value';
                }
                field("BigInteger 01"; Rec."BigInteger 01")
                {
                    ApplicationArea = All;
                    Caption = 'Relation Table No.';
                    ToolTip = 'Specifies field value';
                }
                field("Text 04"; Rec."Text 04")
                {
                    ApplicationArea = All;
                    Caption = 'Relation Table Info';
                    ToolTip = 'Specifies field value';
                }
                field("BigInteger 02"; Rec."BigInteger 02")
                {
                    ApplicationArea = All;
                    Caption = 'Relation Field No.';
                    ToolTip = 'Specifies field value';
                }
                field("Text 05"; Rec."Text 05")
                {
                    ApplicationArea = All;
                    Caption = 'Relation Field Info';
                    ToolTip = 'Specifies field value';
                }
                field("Code 01"; Rec."Code 01")
                {
                    ApplicationArea = All;
                    Caption = 'SQL Data Type';
                    ToolTip = 'Specifies field value';
                }
                field("Code 02"; Rec."Code 02")
                {
                    ApplicationArea = All;
                    Caption = 'Option String';
                    ToolTip = 'Think "enum."';
                }
            }
        }
        area(Factboxes)
        {
        }
    }

    actions
    {
        area(Processing)
        {
        }
    }

    trigger OnOpenPage()
    begin
        BuildFieldList(false);
    end;

    var
        TableNo: Integer;

    procedure BuildFieldList(_Reset: Boolean)
    var
        _Field: Record Field;
        _Field2: Record Field;
        _Obj: Record AllObjWithCaption;
        _EntryNo: BigInteger;
        _Text000Lbl: Label 'Name: "%1" Caption: "%2"', Comment = '%1 name, %2 caption';
    begin
        Rec.Reset();
        Rec.DeleteAll();
        _Obj.SetRange("Object Type", 1);  // table
        if TableNo <> 0 then
            _Field.SetRange(TableNo, TableNo);
        if _Field.FindSet(false) then
            repeat
                _EntryNo += 1;
                Rec."Entry No." := _EntryNo;
                Rec."Integer 01" := _Field.TableNo;
                Rec."Integer 02" := _Field."No.";
                Rec."Integer 03" := _Field.Type;
                Rec."Integer 04" := _Field.Len;
                Rec."Integer 05" := _Field.Class;
                Rec."Text 01" := CopyStr(_Field.TableName, 1, MaxStrLen(Rec."Text 01"));
                Rec."Text 02" := CopyStr(_Field.FieldName, 1, MaxStrLen(Rec."Text 02"));
                Rec."Text 03" := CopyStr(_Field."Field Caption", 1, MaxStrLen(Rec."Text 03"));
                Clear(Rec."Text 04");
                Clear(Rec."Text 05");
                Rec."BigInteger 01" := _Field.RelationTableNo;
                Rec."BigInteger 02" := _Field.RelationFieldNo;
                if Rec."BigInteger 01" <> 0 then begin
                    _Obj.SetRange("Object ID", Rec."BigInteger 01");
                    if _Obj.FindFirst() then
                        if _Obj."Object Name" <> _Obj."Object Caption" then
                            Rec."Text 04" := CopyStr(StrSubstNo(_Text000Lbl, _Obj."Object Name", _obj."Object Caption"), 1, MaxStrLen(Rec."Text 04"))
                        else
                            Rec."Text 04" := CopyStr(_obj."Object Name", 1, MaxStrLen(Rec."Text 04"));
                    if Rec."BigInteger 02" <> 0 then begin
                        _Field2.SetRange(TableNo, Rec."BigInteger 01");
                        _Field2.SetRange("No.", Rec."BigInteger 02");
                        if _Field2.FindFirst() then
                            if _Field2.FieldName <> _Field2."Field Caption" then
                                Rec."Text 05" := CopyStr(StrSubstNo(_Text000Lbl, _Field2.FieldName, _Field2."Field Caption"), 1, MaxStrLen(Rec."Text 05"))
                            else
                                Rec."Text 05" := CopyStr(_Field2.FieldName, 1, MaxStrLen(Rec."Text 05"));
                    end;
                end;
                Rec."Code 01" := CopyStr(Format(_Field.SQLDataType), 1, MaxStrLen(Rec."Code 01"));
                Rec."Code 02" := CopyStr(Format(_Field.OptionString), 1, MaxStrLen(Rec."Code 02"));
                Rec.Insert();
            until _Field.Next() = 0;

        if _Reset then
            CurrPage.Update(false);
    end;

    procedure SetTableNo(_TableNo: Integer)
    begin
        TableNo := _TableNo;
    end;
}
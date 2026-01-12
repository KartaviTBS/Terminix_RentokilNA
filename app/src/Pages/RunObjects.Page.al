page 50596 "ARC Run Objects"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ARC Buffer";
    SourceTableTemporary = true;
    Caption = 'Run Objects';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Objects)
            {
                field("Integer 01"; Rec."Integer 01")
                {
                    ApplicationArea = All;
                    Caption = 'Object Type';
                    ToolTip = 'Specifies the Object Type';
                }
                field("Text 01"; Rec."Text 01")
                {
                    ApplicationArea = All;
                    Caption = 'Object Type (Text)';
                    ToolTip = 'Specifies the Object Type (Text)';
                }
                field("Integer 02"; Rec."Integer 02")
                {
                    ApplicationArea = All;
                    Caption = 'Object ID';
                    ToolTip = 'Specifies the Object ID';
                }
                field("Text 02"; Rec."Text 02")
                {
                    ApplicationArea = All;
                    Caption = 'Object Name';
                    ToolTip = 'Specifies the Object Name';
                }
                field("Text 03"; Rec."Text 03")
                {
                    ApplicationArea = All;
                    Caption = 'Object Caption';
                    ToolTip = 'Specifies the Object Caption';
                }
                field("Text 04"; Rec."Text 04")
                {
                    ApplicationArea = All;
                    Caption = 'Object Subtype';
                    ToolTip = 'Specifies the Object Subtype';
                }
                field("Guid 01"; Rec."Guid 01")
                {
                    ApplicationArea = All;
                    Caption = 'App Package ID';
                    ToolTip = 'Specifies the App Package ID';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Entry No.';
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
            action("Run Object")
            {
                ApplicationArea = All;
                Image = Apply;
                Caption = 'Run Object';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Run the object';

                trigger OnAction()
                begin
                    RunObject();
                end;
            }
            action("Run Fields")
            {
                ApplicationArea = All;
                Image = List;
                Caption = 'Run Fields';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Generate a list of fields for the table';

                trigger OnAction()
                var
                    _RunFields: Page "ARC Run Fields";
                    _Text000Err: Label 'Object Type must be Table.';
                begin
                    if Rec."Integer 01" <> 1 then
                        Error(_Text000Err);
                    _RunFields.SetTableNo(Rec."Integer 02");
                    _RunFields.Run();
                end;
            }
            group(Events)
            {
                action(Publishers)
                {
                    ApplicationArea = All;
                    Image = InteractionTemplate;
                    ToolTip = 'Generate a list of publishers relevant to this object';

                    trigger OnAction()
                    var
                        _RunEvents: Page "ARC Run Events";
                        _Text000Err: Label 'Displaying publishers requires subscriber object to be a Codeunit.';
                    begin
                        if Rec."Integer 01" <> 5 then
                            Error(_Text000Err);
                        _RunEvents.SetOriginatingObject(Rec."Text 01", Rec."Integer 02", Rec."Text 02", Rec."Text 03");
                        _RunEvents.SetSubscriber(Rec."Integer 02");
                        _RunEvents.Run();
                    end;
                }
                action(Subscribers)
                {
                    ApplicationArea = All;
                    Image = InteractionTemplate;
                    ToolTip = 'Generate a list of subscribers relevant to this object';

                    trigger OnAction()
                    var
                        _RunEvents: Page "ARC Run Events";
                    begin
                        _RunEvents.SetOriginatingObject(Rec."Text 01", Rec."Integer 02", Rec."Text 02", Rec."Text 03");
                        _RunEvents.SetPublisher(Rec."Integer 01", Rec."Integer 02");
                        _RunEvents.Run();
                    end;
                }
                action(All)
                {
                    ApplicationArea = All;
                    Image = InteractionTemplate;
                    ToolTip = 'Generate a list of all events relevant to this object';

                    trigger OnAction()
                    var
                        _RunEvents: Page "ARC Run Events";
                    begin
                        _RunEvents.Run();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        BuildObjectList(false);
    end;

    procedure BuildObjectList(_Reset: Boolean)
    var
        _Obj: Record AllObjWithCaption;
        _EntryNo: BigInteger;
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if _Obj.FindSet(false) then
            repeat
                _EntryNo += 1;
                Rec."Entry No." := _EntryNo;
                Rec."Text 01" := Format(_Obj."Object Type");
                Rec."Text 02" := CopyStr(_Obj."Object Name", 1, MaxStrLen(Rec."Text 02"));
                Rec."Text 03" := CopyStr(_Obj."Object Caption", 1, MaxStrLen(Rec."Text 03"));
                Rec."Text 04" := CopyStr(_Obj."Object Subtype", 1, MaxStrLen(Rec."Text 04"));
                Rec."Integer 01" := _obj."Object Type";
                Rec."Integer 02" := _Obj."Object ID";
                Rec."Guid 01" := _Obj."App Package ID";
                Rec.Insert();
            until _Obj.Next() = 0;
        //SetFilter("Integer 01", '3');
        //SetFilter("Integer 02", '77700..77799');
        if Rec.IsEmpty then begin
            Rec.SetRange(Rec."Integer 01");
            Rec.SetRange(Rec."Integer 02");
        end;
        if _Reset then
            CurrPage.Update(false);
    end;

    procedure RunObject()
    var
        _bt: BigText;
        _is: InStream;
        _os: OutStream;
        _rr: RecordRef;
        _filename: Text;
        _output: Text;
        _var: Variant;
        _Text000Err: Label 'Not supported.';
    begin
        case Rec."Integer 01" of
            1:  // table
                begin
                    _rr.Open(Rec."Integer 02");
                    _var := _rr;
                    Page.Run(0, _var);
                end;
            3:  // report
                Report.Run(Rec."Integer 02");
            5:  // codeunit
                Codeunit.Run(Rec."Integer 02");
            6:  // XMLport
                Xmlport.Run((Rec."Integer 02"));
            8:  // page
                Page.Run(Rec."Integer 02");
            9:  // query
                begin
                    Rec."Blob 01".CreateOutStream(_os);
                    Query.SaveAsCsv(Rec."Integer 02", _output);
                    _bt.AddText(_output);
                    _bt.Write(_os);
                    Rec."Blob 01".CreateInStream(_is);
                    if Rec."Blob 01".HasValue then
                        DownloadFromStream(_is, 'Save query output', '', 'CSV Files (*.csv)|*.csv', _filename) // instream, dialog title, ToFolder, ToFilter, var ToFile
                    else
                        Message('HasValue: %1, Length: %2', Rec."Blob 01".HasValue, _bt.Length());
                end;
            else
                Message(_Text000Err);
        end;
    end;
}

page 50598 "ARC Run Events"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ARC Buffer";
    SourceTableTemporary = true;
    Editable = false;
    Caption = 'Run Events';

    layout
    {
        area(Content)
        {
            group("Originating Object")
            {
                Visible = ShowOriginatingObject;

                field(OriginatingObjectLabel; OriginatingObjectLabel)
                {
                    ApplicationArea = All;
                    Caption = 'Originating Object';
                    ToolTip = 'Specifies the originating object';
                }
            }
            repeater(Events)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Entry No.';
                }
                field("BigInteger 01"; Rec."BigInteger 01")
                {
                    ApplicationArea = All;
                    Caption = 'Subscriber Codeunit ID';
                    ToolTip = 'Specifies the Codeunit ID';
                }
                field("Text 06"; Rec."Text 06")
                {
                    ApplicationArea = All;
                    Caption = 'Subscriber Codeunit Name';
                    ToolTip = 'Specifies the Codeunit Name';
                }
                field("Text 01"; Rec."Text 01")
                {
                    ApplicationArea = All;
                    Caption = 'Subscriber Function';
                    ToolTip = 'Specifies the Subscriber Function';
                }
                field("Text 02"; Rec."Text 02")
                {
                    ApplicationArea = All;
                    Caption = 'Subscriber Instance';
                    ToolTip = 'Specifies the Subscriber Instance';
                }
                field("Integer 01"; Rec."Integer 01")
                {
                    ApplicationArea = All;
                    Caption = 'Event Type';
                    ToolTip = 'Specifies the Event Type';
                }
                field("Code 01"; Rec."Code 01")
                {
                    ApplicationArea = All;
                    Caption = 'Event Type (Text)';
                    ToolTip = 'Specifies the Event Type (Text)';
                }
                field("Integer 02"; Rec."Integer 02")
                {
                    ApplicationArea = All;
                    Caption = 'Publisher Object Type';
                    ToolTip = 'Specifies the Publisher Object Type';
                }
                field("Code 02"; Rec."Code 02")
                {
                    ApplicationArea = All;
                    Caption = 'Publisher Object Type (Text)';
                    ToolTip = 'Specifies the Publisher Object Type (Text)';
                }
                field("BigInteger 02"; Rec."BigInteger 02")
                {
                    ApplicationArea = All;
                    Caption = 'Publisher Object ID';
                    ToolTip = 'Specifies the Publisher Object ID';
                }
                field("Text 03"; Rec."Text 03")
                {
                    ApplicationArea = All;
                    Caption = 'Published Function';
                    ToolTip = 'Specifies the Published Function';
                }
                field("Boolean 01"; Rec."Boolean 01")
                {
                    ApplicationArea = All;
                    Caption = 'Active';
                    ToolTip = 'Specifies whether the Event is Active';
                }
                field("BigInteger 03"; Rec."BigInteger 03")
                {
                    ApplicationArea = All;
                    Caption = 'Number of Calls';
                    ToolTip = 'Specifies the Number of Calls';
                }
                field("Text 04"; Rec."Text 04")
                {
                    ApplicationArea = All;
                    Caption = 'Error Information';
                    ToolTip = 'Specifies Error Information';
                }
                field("Text 05"; Rec."Text 05")
                {
                    ApplicationArea = All;
                    Caption = 'Originating App Name';
                    ToolTip = 'Specifies the Originating App Name';
                }
                field("Guid 01"; Rec."Guid 01")
                {
                    ApplicationArea = All;
                    Caption = 'Originating Package ID';
                    ToolTip = 'Specifies the Originating Package ID';
                }
                field("Integer 03"; Rec."Integer 03")
                {
                    ApplicationArea = All;
                    Caption = 'Active Manual Instances';
                    ToolTip = 'Specifies Active Manual Instances';
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

    var
        [InDataSet]
        ShowOriginatingObject: Boolean;
        PublisherNo: Integer;
        PublisherType: Integer;
        SubscriberNo: Integer;
        OriginatingObjectLabel: Text;

    trigger OnOpenPage()
    begin
        BuildEventList(false);
        ShowOriginatingObject := OriginatingObjectLabel <> '';
        if PublisherNo <> 0 then begin
            Rec.SetRange("Integer 02", PublisherType);
            Rec.SetRange("BigInteger 02", PublisherNo);
        end else
            if SubscriberNo <> 0 then
                Rec.SetRange("BigInteger 01", SubscriberNo)
            else
                Rec.SetFilter("BigInteger 03", '<>0');
    end;

    local procedure BuildEventList(_Reset: Boolean)
    var
        _AllObjsWithCaption: Record AllObjWithCaption;
        _EventSubscr: Record "Event Subscription";
        _EntryNo: BigInteger;
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if _EventSubscr.FindSet(false) then
            repeat
                Clear(_AllObjsWithCaption);
                _AllObjsWithCaption.Reset();
                _AllObjsWithCaption.SetRange("Object Type", 5);
                _AllObjsWithCaption.SetRange("Object ID", _EventSubscr."Subscriber Codeunit ID");
                if not _AllObjsWithCaption.FindFirst() then
                    Clear(_AllObjsWithCaption);
                _EntryNo += 1;
                Rec.Init();
                Rec."Entry No." := _EntryNo;
                Rec."BigInteger 01" := _EventSubscr."Subscriber Codeunit ID";
                Rec."Text 06" := CopyStr(_AllObjsWithCaption."Object Name", 1, MaxStrLen(Rec."Text 06"));
                Rec."Text 01" := CopyStr(_EventSubscr."Subscriber Function", 1, MaxStrLen(Rec."Text 01"));
                Rec."Text 02" := CopyStr(_EventSubscr."Subscriber Instance", 1, MaxStrLen(Rec."Text 02"));
                Rec."Integer 01" := _EventSubscr."Event Type";
                Rec."Code 01" := CopyStr(Format(_EventSubscr."Event Type"), 1, MaxStrLen(Rec."Code 01"));
                Rec."Integer 02" := _EventSubscr."Publisher Object Type";
                Rec."Code 02" := CopyStr(Format(_EventSubscr."Publisher Object Type"), 1, MaxStrLen(Rec."Code 02"));
                Rec."BigInteger 02" := _EventSubscr."Publisher Object ID";
                Rec."Text 03" := CopyStr(_EventSubscr."Published Function", 1, MaxStrLen(Rec."Text 03"));
                Rec."Boolean 01" := _EventSubscr.Active;
                Rec."BigInteger 03" := _EventSubscr."Number of Calls";
                Rec."Text 04" := CopyStr(_EventSubscr."Error Information", 1, MaxStrLen(Rec."Text 04"));
                Rec."Text 05" := CopyStr(_EventSubscr."Originating App Name", 1, MaxStrLen(Rec."Text 05"));
                Rec."Guid 01" := _EventSubscr."Originating Package ID";
                Rec."Integer 03" := _EventSubscr."Active Manual Instances";
                Rec.Insert();
            until _EventSubscr.Next() = 0;
        if _Reset then
            CurrPage.Update(false);
    end;

    procedure SetOriginatingObject(_ObjType: Text; _ObjID: Integer; _ObjName: Text; _ObjCaption: Text)
    var
        Text000Lbl: Label '%1 %2 %3', Comment = '%1 one, %2 two, %3 three';
        Text001Lbl: Label '%1 %2 Name: "%3" Caption: "%4"', Comment = '%1 label, %2 type, %3 name, %4 caption';
    begin
        if _ObjName = _ObjCaption then
            OriginatingObjectLabel := CopyStr(StrSubstNo(Text000Lbl, _ObjType, _ObjID, _ObjName), 1, MaxStrLen(OriginatingObjectLabel))
        else
            OriginatingObjectLabel := CopyStr(StrSubstNo(Text001Lbl, _ObjType, _ObjID, _ObjName, _ObjCaption), 1, MaxStrLen(OriginatingObjectLabel));
    end;

    procedure SetPublisher(_ObjType: Integer; _ObjNo: Integer)
    begin
        PublisherType := _ObjType;
        PublisherNo := _ObjNo;
    end;

    procedure SetSubscriber(_ObjNo: Integer)
    begin
        SubscriberNo := _ObjNo;
    end;
}
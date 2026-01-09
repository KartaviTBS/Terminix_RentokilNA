codeunit 50063 "ARC DataMgt"
{
    Permissions = tabledata "ARC Data Entry" = ri;

    trigger OnRun()
    begin
    end;

    var
        DataEntryCodeLbl: Label 'DATA ENTRY';

    procedure CreateDataEntry(_Code: Code[20]; _Desc: Text; _size: Integer; var _tempBlob: Record TempBlob temporary; _show: Boolean) : BigInteger
    var
        _DataEntry: Record "ARC Data Entry";
        _is: InStream;
        _os: OutStream;
        _time: Time;
        _Text000Err: Label 'Output is empty';
    begin
        if not _tempBlob.Blob.HasValue() then
            if not _show then
                exit
            else
                Error(_Text000Err);
        _tempBlob.CalcFields(Blob);
        _tempBlob.Blob.CreateInStream(_is);
        _time := Time();
        _DataEntry.Init();
        _DataEntry."Entry No." := 0;
        _DataEntry.Code := CopyStr(_Code, 1, MaxStrLen(_DataEntry.Code));
        _DataEntry.Description := CopyStr(_Desc, 1, MaxStrLen(_DataEntry.Description));
        _DataEntry."Created by" := CopyStr(UserId(), 1, MaxStrLen(_DataEntry."Created by"));
        _DataEntry."Created at Date" := Today();
        _DataEntry."Created at Time" := _time;
        _DataEntry."Created at DateTime" := CreateDateTime(Today(),_time);
        _DataEntry.Data.CreateOutStream(_os);
        _DataEntry.Size := _size;
        CopyStream(_os,_is);
        _DataEntry.Insert();
        if _show then begin
            _DataEntry.SetRecFilter();
            Page.Run(Page::"ARC Data Entries",_DataEntry);
        end;
        exit(_DataEntry."Entry No.");
    end;

    procedure CreateSampleRecord()
    var
        _AllObjWithCaption: Record AllObjWithCaption;
        _DataEntry: Record "ARC Data Entry";
        _bt: BigText;
        _x: Integer;
        _os: OutStream;
        _text: Text;
        _sampleDescMsg: Label 'This is an example of a sample description value.';
        _sampleTextMsg: Label 'Table %1 %2, AppPkgId %3.  ', Comment = '%1 Tableno, %2 tablename, %3 appPkgId';
        _Text000Qst: Label 'Are you SURE you want to create a sample record?';
    begin
        if GuiAllowed() then
            if not Confirm(_Text000Qst, false) then
                exit;
        _AllObjWithCaption.SetRange("Object Type", _AllObjWithCaption."Object Type"::Table);
        for _x := 1 to 2500 do begin
            _AllObjWithCaption.SetRange("Object ID", _x);
            if _AllObjWithCaption.FindFirst() then
                _text := CopyStr(_text + StrSubstNo(_sampleTextMsg, _x, _AllObjWithCaption."Object Name", _AllObjWithCaption."App Package ID"), 1, MaxStrLen(_text));
        end;
        _DataEntry."Entry No." := 0;
        _DataEntry.Description := CopyStr(_sampleDescMsg, 1, MaxStrLen(_DataEntry.Description));
        _DataEntry.Code := CopyStr(DataEntryCodeLbl, 1, MaxStrLen(_DataEntry.Code));
        _bt.AddText(_text);
        _DataEntry.Data.CreateOutStream(_os);
        _bt.Write(_os);
        _DataEntry.Insert(true);
    end;

    procedure ImportFile(_code: Code[10]; _desc: Text[250]; _dialogTitle: Text): BigInteger
    var
        _DataEntry: Record "ARC Data Entry";
        _is: InStream;
        _os: OutStream;
        _filename: Text;
    begin
        _DataEntry.Init();
        _DataEntry."Entry No." := 0;
        _DataEntry.Code := CopyStr(_code, 1, MaxStrLen(_DataEntry.Code));
        _DataEntry."Created by" := CopyStr(UserId(), 1, MaxStrLen(_DataEntry."Created by"));
        _DataEntry."Created at Date" := Today();
        _DataEntry."Created at Time" := Time();
        _DataEntry."Created at DateTime" := CurrentDateTime();
        _DataEntry.Data.CreateOutStream(_os);
        UploadIntoStream(_dialogTitle, '', '', _filename, _is);
        if not CopyStream(_os, _is) then
            exit(0);
        _DataEntry.Description := CopyStr(_desc + _filename, 1, MaxStrLen(_DataEntry.Description));
        _DataEntry.Insert();
        exit(_DataEntry."Entry No.");
    end;

    procedure NewDataEntry(_code: Code[20]; _desc: Text; _bt: BigText): BigInteger
    var
        _DataEntry: Record "ARC Data Entry";
        _size: Integer;
        _os: OutStream;
    begin
        _size := _bt.Length();
        if (_code = '') and (_desc = '') and (_size = 0) then
            exit;
        _DataEntry.Init();
        _DataEntry.Data.CreateOutStream(_os);
        if _bt.Length() > 0 then
            _bt.Write(_os);
        _DataEntry.Code := CopyStr(_code,1,MaxStrLen(_DataEntry.Code));
        _DataEntry.Description := CopyStr(_desc,1,MaxStrLen(_DataEntry.Description));
        _DataEntry.Size := _size;
        _DataEntry.Insert(true);
        exit(_DataEntry."Entry No.");
    end;

    procedure NewDataEntryUsingTempBlob(_code: Code[20]; _desc: Text; var _tempBlob: Record TempBlob temporary): BigInteger
    var
        _DataEntry: Record "ARC Data Entry";
        _bt: BigText;
        _is: InStream;
        _size: Integer;
        _os: OutStream;
    begin
        if (_code = '') and (_desc = '') then
            exit;
        if not _tempBlob.Blob.HasValue() then
            exit;
        _tempBlob.CalcFields(Blob);
        _tempBlob.Blob.CreateInStream(_is);
        _bt.Read(_is);
        _size := _bt.Length();
        Clear(_is);
        _tempBlob.Blob.CreateInStream(_is);
        _DataEntry.Init();
        _DataEntry.Data.CreateOutStream(_os);
        CopyStream(_os,_is);
        _DataEntry.Code := CopyStr(_code,1,MaxStrLen(_DataEntry.Code));
        _DataEntry.Description := CopyStr(_desc,1,MaxStrLen(_DataEntry.Description));
        _DataEntry.Size := _size;
        _DataEntry.Insert(true);
        exit(_DataEntry."Entry No.");
    end;

    procedure ShowValue(_DataEntry: Record "ARC Data Entry")
    var
        _bt: BigText;
        _is: InStream;
        _GenConfDialog: Page "General Confirmation Dialog";
        _text: Text;
        _Text000Err: Label 'Field Data is empty.';
        _Text001Msg: Label '%1 %2', Comment = '%1 Data Entry tablecaption, %2 Entry No.';
    begin
        if not _DataEntry.Data.HasValue then
            Error(_Text000Err);
        _DataEntry.CalcFields(Data);
        _DataEntry.Data.CreateInStream(_is);
        _bt.Read(_is);
        _bt.GetSubText(_text, 1);
        _GenConfDialog.LookupMode := false;
        _GenConfDialog.Editable := false;
        _GenConfDialog.SetInstructionalTextInvisible();
        _GenConfDialog.SetCodeVisible();
        _GenConfDialog.SetCodeValue(_DataEntry.Code);
        _GenConfDialog.SetTextVisible();
        _GenConfDialog.SetTextValue(_DataEntry.Description);
        _GenConfDialog.SetBigTextVisible();
        _GenConfDialog.SetBigTextValue(_text);
        _GenConfDialog.SetFieldCaptionValue('Contents of Data');
        _GenConfDialog.SetWindowTitle(StrSubstNo(_Text001Msg, _DataEntry.TableCaption, _DataEntry."Entry No."));
        _GenConfDialog.RunModal();
    end;

    procedure ShowValueFromEntryNo(_EntryNo: BigInteger)
    var
        _DataEntry: Record "ARC Data Entry";
    begin
        if not _DataEntry.Get(_EntryNo) then
            exit;
        ShowValue(_DataEntry);
    end;
}
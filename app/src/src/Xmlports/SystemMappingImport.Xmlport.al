xmlport 50045 "ARC System Mapping Import"
{
    Caption = 'System Mapping Import';
    Direction = Import;
    FieldDelimiter = '<None>';
    FieldSeparator = '<TAB>';
    Format = VariableText;
    Permissions = tabledata 50045=ri;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(Table2000000026;Integer)
            {
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                XmlName = 'Integer';

                textelement(SourceSystem)
                {
                }
                textelement(SourceType)
                {
                }
                textelement(SourceNo)
                {
                }
                textelement(DestinationNo)
                {
                }

                trigger OnBeforeInsertRecord();
                begin
                    ImportRecord;
                    Clear(SourceSystem);
                    Clear(SourceType);
                    Clear(SourceNo);
                    Clear(DestinationNo);
                    currXMLport.Skip;
                end;
            }
        }
    }

    trigger OnPostXmlPort()
    var
        _EndingMessage: Text[1024];
    begin
        if GuiAllowed then begin
            _EndingMessage := StrSubstNo(Text000Msg,ImportCount,ErrCount);
            if ErrFileCreated then
                _EndingMessage := _EndingMessage + '\' + StrSubstNo(Text001Msg,ErrFilename);
            Message(_EndingMessage);
        end;
    end;

    local procedure ImportRecord()
    var
        _Customer: Record Customer;
        _Item: Record Item;
        _Vendor: Record Vendor;
        Location: Record Location;
        SalesPerson: Record "Salesperson/Purchaser";
        _SystemMapping: Record "ARC System Mapping";
        _continue: Boolean;
        _SourceSystem: Option NAV2009, GreatPlains, Sage;
        _SourceType: Option Customer, Item, Vendor,Location, SalesPerson;
        _Text000Msg: TextConst ENU='SourceSystem %1 not interpreted correctly.';
        _Text001Msg: TextConst ENU='SourceType %1 not interpreted correctly.';
        _Text002Msg: TextConst ENU='Unable to retrieve customer %1.';
        _Text003Msg: TextConst ENU='Unable to retrieve item %1.';
        _Text004Msg: TextConst ENU='Unable to retrieve vendor %1.';
        _Text005Msg: TextConst ENU='Unable to retrieve Location %1.';
        _Text006Msg: TextConst ENU='Unable to retrieve SalesPerson %1.';
    begin
        LineNo += 1;
        if ErrFilename = '' then
            ErrFilename := FileMgt.ServerTempFileName('txt');
        if LowerCase(SourceSystem) = 'sourcesystem' then
            exit;
        _continue := true;
        if not Evaluate(_SourceSystem,SourceSystem) then begin
            WriteToFile(StrSubstNo(_Text000Msg,SourceSystem));
            _continue := false;
            ErrCount += 1;
        end;
        if _continue then
            if not Evaluate(_SourceType,SourceType) then begin
                WriteToFile(StrSubstNo(_Text001Msg,SourceType));
                _continue := false;
                ErrCount += 1;
            end;
        case _SourceType of
            _SourceType::Customer:
                if not _Customer.Get(CopyStr(DestinationNo,1,MaxStrLen(_Customer."No."))) then begin
                    WriteToFile(StrSubstNo(_Text002Msg,DestinationNo));
                    _continue := false;
                    ErrCount += 1;
                end;
            _SourceType::Item:
                if not _Item.Get(CopyStr(DestinationNo,1,MaxStrLen(_Item."No."))) then begin
                    WriteToFile(StrSubstNo(_Text003Msg,DestinationNo));
                    _continue := false;
                    ErrCount += 1;
                end;
            
            _SourceType::Location:
                if not Location.Get(CopyStr(DestinationNo,1,MaxStrLen(Location.Code))) then begin
                    WriteToFile(StrSubstNo(_Text005Msg,DestinationNo));
                    _continue := false;
                    ErrCount += 1;
                end;
            _SourceType::SalesPerson:  
                if not SalesPerson.Get(CopyStr(DestinationNo,1,MaxStrLen(SalesPerson.Code))) then begin
                    WriteToFile(StrSubstNo(_Text006Msg,DestinationNo));
                    _continue := false;
                    ErrCount += 1;
                end;   

        end;
        if _continue then begin
            _SystemMapping.Init;
            _SystemMapping."Entry No." := 0;
            _SystemMapping."Source System" := _SourceSystem;
            _SystemMapping."Source Type" := _SourceType;
            _SystemMapping."Source No." := CopyStr(SourceNo,1,MaxStrLen(_SystemMapping."Source No."));
            _SystemMapping."Destination No." := CopyStr(DestinationNo,1,MaxStrLen(_SystemMapping."Destination No."));
            _SystemMapping."Created by" := UserId;
            _SystemMapping."Created at DateTime" := CurrentDateTime;
            _SystemMapping.Insert;
            ImportCount += 1;
        end;
    end;

    local procedure WriteToFile(_text: Text[1024])
    var
        _File: File;
    begin
        if ErrFilename = '' then
            exit;
        _File.TextMode(true);
        _File.WriteMode(true);
        case Exists(ErrFilename) of
            false:
                if _File.Create(ErrFilename) then
                    ErrFileCreated := true;
            true:
                if _File.Open(ErrFilename) then begin
                    ErrFileCreated := true;
                    _File.Seek(_File.Len);
                end;
        end;
        if ErrFileCreated then begin
            _File.Write(StrSubstNo('Line %1: %2',LineNo,_text));
            _File.Close;
        end;
    end;

    var
        FileMgt: Codeunit "File Management";
        ErrFileCreated: Boolean;
        ErrCount: Integer;
        ImportCount: Integer;
        LineNo: Integer;
        ErrFilename: Text[250];
        Text000Msg: TextConst ENU='Records imported: %1.  Errors: %2.';
        Text001Msg: TextConst ENU='  Errors written to file: %1';
}
codeunit 50117 "ARC CubiscanMgt"
{
    // SOW11 Körber Edge WMS Integration - CO2 Cubiscan Integration

    Permissions = tabledata "ARC Cubiscan Entry" = im,
                  tabledata "ARC Data Entry" = i,
                  tabledata "ARC Event Log Entry" = i;

    trigger OnRun();
    begin
        Initialize();
        if EntryNoToImport <> 0 then begin
            ImportFile();
            exit;
        end;
        if EntryNoToProcess <> 0 then begin
            ProcessEntry();
            exit;
        end;
        ImportFiles();
        ProcessEntries();
    end;

    var
        KorberSetup: Record "ARC Korber Setup";
        EntryNoToImport: BigInteger;
        EntryNoToProcess: BigInteger;
        Initialized: Boolean;
        PathArchive: Text;
        PathError: Text;
        PathImport: Text;

    local procedure GetPaths()
    var
        _InvSetup: Record "Inventory Setup";
        _Text000Msg: Label 'Method GetPaths(): PathImport: %1, PathArchive: %2, PathError: %3';
    begin
        _InvSetup.Get();
        _InvSetup.TestField("ARC Cubiscan Import Path");
        PathImport := CopyStr(_InvSetup."ARC Cubiscan Import Path",1,MaxStrLen(PathImport));
        if PathImport[StrLen(PathImport)] <> '\' then
            PathImport := CopyStr(PathImport + '\',1,MAXSTRLEN(PathImport));
        PathArchive := CopyStr(PathImport + 'Archive\',1,MAXSTRLEN(PathArchive));
        PathError := CopyStr(PathImport + 'Error\',1,MAXSTRLEN(PathError));
        //WriteLog(KorberSetup."Log Level"::Verbose,0,0,StrSubstNo(_Text000Msg,PathImport,PathArchive,PathError),'');
    end;

    local procedure ImportFile()
    var
        _CubiscanEntry: Record "ARC Cubiscan Entry";
        _CubiscanEntry2: Record "ARC Cubiscan Entry";
        _DataEntry: Record "ARC Data Entry";
        _tempBlob: Record TempBlob temporary;
        _DataMgt: Codeunit "ARC DataMgt";
        _importedDataEntryNo: BigInteger;
        _file: File;
        _is: InStream;
        _size: Integer;
        _os: OutStream;
        _FilepathImport: Text;
        _FilepathArchive: Text;
        _timeBegin: Time;
        _timeEnd: Time;
        _CubiscanImport: XmlPort "ARC Cubiscan Import";
        _Text000Msg: Label 'Method ImportFile(): FilepathImport: "%1"';
    begin
        _timeBegin := Time();
        _CubiscanEntry.Get(EntryNoToImport);
        _CubiscanEntry.TestField("Import Filename");
        _importedDataEntryNo := _CubiscanEntry."Imported Data Entry No.";
        IF _importedDataEntryNo = 0 then begin
            // file data not previously imported; attempt to import data from file and store in BLOB field
            _FilepathImport := CopyStr(PathImport + _CubiscanEntry."Import Filename",1,MaxStrLen(_FilepathImport));
            _FilepathArchive := CopyStr(PathArchive + _CubiscanEntry."Import Filename",1,MaxStrLen(_FilepathArchive));
            WriteLog(KorberSetup."Log Level"::Verbose,0,0,StrSubstNo(_Text000Msg,_FilepathImport),'');
            Clear(_tempBlob);
            _tempBlob.DeleteAll();
            _tempBlob.Blob.CreateOutStream(_os);
            Clear(_file);
            _file.TextMode(true);
            _file.WriteMode(false);
            _file.Open(_FilepathImport);
            _size := _file.Len();
            _file.CreateInStream(_is);
            CopyStream(_os,_is);
            _file.Close();
            _tempBlob.Insert();
            _tempBlob.CalcFields(Blob);
            _importedDataEntryNo := _DataMgt.CreateDataEntry('CUBISCAN',StrSubstNo(_Text000Msg,_CubiscanEntry."Import Filename"),_size,_tempBlob,false);
        END;
        _DataEntry.Get(_importedDataEntryNo);
        _DataEntry.CalcFields(Data);
        _DataEntry.Data.CreateInStream(_is);
        _CubiscanImport.SetEntryNoToReference(_CubiscanEntry."Entry No.");
        _CubiscanImport.SetSource(_is);
        _CubiscanImport.Import();
        Clear(_CubiscanEntry2);
        _CubiscanEntry2.Reset();
        _CubiscanEntry2.LockTable();
        _CubiscanEntry2.Get(EntryNoToImport);
        _CubiscanEntry2.Imported := 1;
        _CubiscanEntry2."Imported Data Entry No." := _importedDataEntryNo;
        _CubiscanEntry2."Imported No. of Attempts" := _CubiscanEntry2."Imported No. of Attempts" + 1;
        _timeEnd := Time();
        _CubiscanEntry2."Imported at DateTime" := CreateDateTime(Today(),_timeEnd);
        _CubiscanEntry2."Imported Duration" := _timeEnd - _timeBegin;
        _CubiscanEntry2.Modify();
        // write file contents to archive location and delete original file
        _tempBlob.CalcFields(Blob);
        _tempBlob.Blob.CreateInStream(_is);
        Clear(_file);
        _file.TextMode(true);
        _file.WriteMode(true);
        _file.Create(_FilepathArchive);
        _file.CreateOutStream(_os);
        CopyStream(_os,_is);
        _file.Close();
        Erase(_FilepathImport);
    end;

    local procedure ImportFiles()
    var
        _CubiscanEntry: Record "ARC Cubiscan Entry";
        _CubiscanEntry2: Record "ARC Cubiscan Entry";
        _fileRec: Record File;
        _CubiscanMgt: Codeunit "ARC CubiscanMgt";
        _result: Boolean;
        _entriesProcessed: Integer;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text001Err: Label 'Unable to import files; ReadPermission is missing for credential %1 and path "%2".';
        _Text002Msg: Label 'Files queued for import: %1';
        _Text003Msg: Label 'Import attempted for files: %1';
    begin
        // get list of files to import
        _fileRec.SetRange(Path,PathImport);
        _fileRec.SetRange("Is a file",TRUE);
        if not _fileRec.ReadPermission() then begin
            WriteLog(KorberSetup."Log Level"::Error,0,0,'',StrSubstNo(_Text001Err,UserId(),PathImport));
            exit;
        end;
        _timeBegin := Time();
        if _fileRec.FindSet(false) then
            repeat
                _CubiscanEntry.Init();
                _CubiscanEntry."Entry No." := 0;
                // _CubiscanEntry."Import Filename" := COPYSTR(_fileRec.Path + _fileRec.Name,1,MAXSTRLEN(_CubiscanEntry."Import Filename"));
                _CubiscanEntry."Import Filename" := CopyStr(_fileRec.Name,1,MaxStrLen(_CubiscanEntry."Import Filename"));
                _CubiscanEntry.Import := true;
                _CubiscanEntry."Created at Date" := Today();
                _CubiscanEntry."Created at DateTime" := CreateDateTime(Today(),_timeBegin);
                _CubiscanEntry."Created at Time" := _timeBegin;
                _CubiscanEntry.Insert();
                _entriesProcessed += 1;
            until (_fileRec.Next() = 0) OR (_entriesProcessed >= KorberSetup."Process Queue No. Entries");
        if _entriesProcessed > 0 then
            WriteLog(KorberSetup."Log Level"::Verbose,0,0,StrSubstNo(_Text002Msg,_entriesProcessed),'');
        // attempt to import files
        Clear(_entriesProcessed);
        Clear(_CubiscanEntry);
        _CubiscanEntry.Reset();
        _CubiscanEntry.SetCurrentKey(Import);
        _CubiscanEntry.SetRange(Import,true);
        _CubiscanEntry.SetRange(Imported,0);
        IF _CubiscanEntry.FindSet(false) then
            repeat
                _timeBegin := Time();
                Clear(_CubiscanMgt);
                _CubiscanMgt.SetEntryNoToImport(_CubiscanEntry."Entry No.");
                Commit();
                _result := _CubiscanMgt.Run();
                if not _result then begin
                    Clear(_CubiscanEntry2);
                    _CubiscanEntry2.Reset();
                    _CubiscanEntry2.LockTable();
                    if _CubiscanEntry2.Get(_CubiscanEntry."Entry No.") then begin
                        _timeEnd := Time();
                        _CubiscanEntry2."Imported at DateTime" := CreateDateTime(Today(),_timeEnd);
                        _CubiscanEntry2."Imported Duration" := _timeEnd - _timeBegin;
                        _CubiscanEntry2."Imported No. of Attempts" := _CubiscanEntry2."Imported No. of Attempts" + 1;
                        _CubiscanEntry2."Imported Error Text" := CopyStr(GetLastErrorText(),1,MaxStrLen(_CubiscanEntry2."Imported Error Text"));
                        //if _CubiscanEntry2."Imported No. of Attempts" >= 10 then 
                        if _CubiscanEntry2."Imported No. of Attempts" >= KorberSetup."Maximum No. of Attempts" then 
                            _CubiscanEntry2.Imported := -1;
                        _CubiscanEntry2.Modify();
                    end;
                end;
                _entriesProcessed += 1;
            until (_CubiscanEntry.Next() = 0) OR (_entriesProcessed >= KorberSetup."Process Queue No. Entries");
            //until (_CubiscanEntry.Next() = 0) OR (_entriesProcessed >= KorberSetup."Maximum No. of Attempts");
        if _entriesProcessed > 0 then
            WriteLog(KorberSetup."Log Level"::Verbose,0,0,StrSubstNo(_Text003Msg,_entriesProcessed),'');
    end;

    local procedure Initialize()
    begin
        KorberSetup.Get();
        GetPaths();
        Initialized := true;
    end;

    local procedure ProcessEntries()
    var
        _CubiscanEntry: Record "ARC Cubiscan Entry";
        _CubiscanEntry2: Record "ARC Cubiscan Entry";
        _CubiscanMgt: Codeunit "ARC CubiscanMgt";
        _result: Boolean;
        _entriesProcessed: Integer;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Msg: Label 'Process attempted for files: %1';
    begin
        _CubiscanEntry.SetCurrentKey(Process,Processed);
        _CubiscanEntry.SetRange(Process,true);
        _CubiscanEntry.SetRange(Processed,0);
        if _CubiscanEntry.FindSet(false) then
            repeat
                _timeBegin := Time();
                Clear(_CubiscanMgt);
                _CubiscanMgt.SetEntryNoToProcess(_CubiscanEntry."Entry No.");
                Commit();
                _result := _CubiscanMgt.Run();
                if not _result then begin
                    Clear(_CubiscanEntry2);
                    _CubiscanEntry2.Reset();
                    _CubiscanEntry2.LockTable();
                    if _CubiscanEntry2.Get(_CubiscanEntry."Entry No.") then begin
                        _CubiscanEntry2."Processed No. of Attempts" := _CubiscanEntry2."Processed No. of Attempts" + 1;
                        _CubiscanEntry2."Processed Error Text" := CopyStr(GetLastErrorText(),1,MaxStrLen(_CubiscanEntry2."Processed Error Text"));
                        _timeEnd := Time();
                        _CubiscanEntry2."Processed Duration" := _timeEnd - _timeBegin;
                        _CubiscanEntry2."Processed at DateTime" := CreateDateTime(Today(),_timeEnd);
                        if _CubiscanEntry2."Processed No. of Attempts" >= KorberSetup."Maximum No. of Attempts" then
                            _CubiscanEntry2.Processed := -1;
                        _CubiscanEntry2.Modify();
                    end;
                end;
                _entriesProcessed += 1;
            until (_CubiscanEntry.Next() = 0) or (_entriesProcessed >= KorberSetup."Process Queue No. Entries");
        if _entriesProcessed > 0 then
             WriteLog(KorberSetup."Log Level"::Verbose,0,0,StrSubstNo(_Text000Msg,_entriesProcessed),'');
    end;

    local procedure ProcessEntry()
    var
        _CubiscanEntry: Record "ARC Cubiscan Entry";
        _CubiscanEntry2: Record "ARC Cubiscan Entry";
        _CubiscanEntry3: Record "ARC Cubiscan Entry";
        _Item: Record Item;
        _ItemCrossReference: Record "Item Cross Reference";
        _ItemUom: Record "Item Unit of Measure";
        _Uom: Record "Unit of Measure";
        _KorberItemMgt: Codeunit "ARC KorberItemMgt";
        _requireUpdate: Boolean;
        _UomCode: Code[10];
        _height: Decimal;
        _length: Decimal;
        _volume: Decimal;
        _weight: Decimal;
        _width: Decimal;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Err: Label 'After trimming spaces, the Unit of Measure Code turned out to be empty.';
        _Text001Msg: Label 'ItemUom values prior to modification at %1';
    begin
        _timeBegin := Time();
        _CubiscanEntry.Get(EntryNoToProcess);
        _CubiscanEntry.TestField("Item No.");
        _UomCode := CopyStr(DelChr(_CubiscanEntry."Unit of Measure Code",'<>'),1,MaxStrLen(_UomCode));
        if _UomCode = '' then
            Error(_Text000Err);
        if Evaluate(_height,_CubiscanEntry.Height) then;
        if Evaluate(_length,_CubiscanEntry.Length) then;
        if Evaluate(_volume,_CubiscanEntry.Volume) then;
        if Evaluate(_weight,_CubiscanEntry.Weight) then;
        if Evaluate(_width,_CubiscanEntry.Width) then;
        _Item.Get(_CubiscanEntry."Item No.");
        _Uom.Get(_UomCode);
        _ItemUom.SetRange("Item No.",_CubiscanEntry."Item No.");
        _ItemUom.SetRange(Code,_UomCode);
        if _ItemUom.FindFirst() then begin
            _requireUpdate := (_height <> 0) and (_height <> _ItemUom.Height);
            _requireUpdate := _requireUpdate or ((_length <> 0) and (_length <> _ItemUom.Length));
            _requireUpdate := _requireUpdate or ((_volume <> 0) and (_volume <> _ItemUom.Cubage));
            _requireUpdate := _requireUpdate or ((_weight <> 0) and (_weight <> _ItemUom.Weight));
            _requireUpdate := _requireUpdate or ((_width <> 0) and (_width <> _ItemUom.Width));
            if _requireUpdate then begin
                // preserve settings prior to modification
                _CubiscanEntry3 := _CubiscanEntry;
                _CubiscanEntry3."Entry No." := 0;
                _CubiscanEntry3.Height := CopyStr(DelChr(Format(_ItemUom.Height),'=',','),1,MaxStrLen(_CubiscanEntry3.Height));
                _CubiscanEntry3.Length := CopyStr(DelChr(Format(_ItemUom.Length),'=',','),1,MaxStrLen(_CubiscanEntry3.Length));
                _CubiscanEntry3.Volume := CopyStr(DelChr(Format(_ItemUom.Cubage),'=',','),1,MaxStrLen(_CubiscanEntry3.Volume));
                _CubiscanEntry3.Weight := CopyStr(DelChr(Format(_ItemUom.Weight),'=',','),1,MaxStrLen(_CubiscanEntry3.Weight));
                _CubiscanEntry3.Width := CopyStr(DelChr(Format(_ItemUom.Width),'=',','),1,MaxStrLen(_CubiscanEntry3.Width));
                _CubiscanEntry3."Created at Date" := Today();
                _CubiscanEntry3."Created at DateTime" := CreateDateTime(Today,0T);
                _CubiscanEntry3."Created at Time" := 0T;
                _CubiscanEntry3.Import := false;
                _CubiscanEntry3."Import Filename" := CopyStr(StrSubstNo(_Text001Msg,Format(Time())),1,MaxStrLen(_CubiscanEntry3."Import Filename"));
                _CubiscanEntry3.Imported := 0;
                _CubiscanEntry3."Imported at DateTime" := CreateDateTime(Today,0T);
                _CubiscanEntry3."Imported Data Entry No." := 0;
                _CubiscanEntry3."Imported Duration" := 0;
                _CubiscanEntry3."Imported No. of Attempts" := 0;
                _CubiscanEntry3."Imported Error Text" := '';
                _CubiscanEntry3.Process := false;
                _CubiscanEntry3.Processed := 0;
                _CubiscanEntry3."Processed at DateTime" := CreateDateTime(Today,0T);
                _CubiscanEntry3."Processed Duration" := 0;
                _CubiscanEntry3."Processed Error Text" := '';
                _CubiscanEntry3."Processed No. of Attempts" := 0;
                _CubiscanEntry3.Insert();
                // modify the record
                _ItemUom.LockTable();
                _ItemUom.Get(_CubiscanEntry."Item No.",_UomCode);
                _ItemUom.Height := _height;
                _ItemUom.Length := _length;
                _ItemUom.Cubage := _volume;
                _ItemUom.Weight := _weight;
                _ItemUom.Width := _width;
                _ItemUom.Modify(true);
            end;
        end else begin
            Clear(_ItemUom);
            _ItemUom.Reset();
            _ItemUom."Item No." := CopyStr(_CubiscanEntry."Item No.",1,MaxStrLen(_ItemUom."Item No."));
            _ItemUom.Code := CopyStr(_UomCode,1,MaxStrLen(_ItemUom.Code));
            _ItemUom.Height := _height;
            _ItemUom.Length := _length;
            _ItemUom.Cubage := _volume;
            _ItemUom.Weight := _weight;
            _ItemUom.Width := _width;
            _ItemUom.Insert();
            _requireUpdate := true;
        end;
        // verify item cross reference using Optional 5 field
        _CubiscanEntry."Optional Info. 5" := CopyStr(DelChr(_CubiscanEntry."Optional Info. 5",'<>'),1,MaxStrLen(_CubiscanEntry."Optional Info. 5"));  // trim
        if (_CubiscanEntry."Item No." <> '') and (_UomCode <> '') and (_CubiscanEntry."Optional Info. 5" <> '') then begin
            _ItemCrossReference.SetRange("Item No.",_CubiscanEntry."Item No.");
            _ItemCrossReference.SetRange("Unit of Measure",_UomCode);
            _ItemCrossReference.SetRange("Cross-Reference Type",_ItemCrossReference."Cross-Reference Type"::"Bar Code");
            _ItemCrossReference.DeleteAll();
            _ItemCrossReference.Init();
            _ItemCrossReference."Item No." := CopyStr(_CubiscanEntry."Item No.",1,MaxStrLen(_ItemCrossReference."Item No."));
            _ItemCrossReference."Unit of Measure" := CopyStr(_UomCode,1,MaxStrLen(_ItemCrossReference."Unit of Measure"));
            _ItemCrossReference."Cross-Reference Type" := _ItemCrossReference."Cross-Reference Type"::"Bar Code";
            _ItemCrossReference."Cross-Reference Type No." := CopyStr(_CubiscanEntry."Optional Info. 5",1,MaxStrLen(_ItemCrossReference."Cross-Reference Type No."));
            _ItemCrossReference.Insert();
        end;
        // transmit item master to Korber Edge
        _KorberItemMgt.EnqueueItem(_Item,'CUBISCAN');
        // mark record as processed
        Clear(_CubiscanEntry2);
        _CubiscanEntry2.Reset();
        _CubiscanEntry2.LockTable();
        _CubiscanEntry2.Get(_CubiscanEntry."Entry No.");
        _CubiscanEntry2."Processed No. of Attempts" := _CubiscanEntry2."Processed No. of Attempts" + 1;
        if _requireUpdate then
            _CubiscanEntry2.Processed := 10
        else
            _CubiscanEntry2.Processed := 1;
        _timeEnd := Time();
        _CubiscanEntry2."Processed at DateTime" := CreateDateTime(Today(),_timeEnd);
        _CubiscanEntry2."Processed Duration" := _timeEnd - _timeBegin;
        _CubiscanEntry2.Modify();
    end;

    procedure Reset(var _CubiscanEntry: Record "ARC Cubiscan Entry")
    var
    _count: Integer;
    _Text000Qst: Label 'Entries to reset: %1.  Continue?';
    begin
        _count := _CubiscanEntry.Count();
        if GuiAllowed() then
            if not Confirm(_Text000Qst,false,_count) then
                exit;
        _CubiscanEntry.ModifyAll(Processed,0);
        if GuiAllowed() then
            Message('Done');
    end;

    procedure SetEntryNoToImport(_EntryNoToImport: BigInteger)
    begin
        EntryNoToImport := _EntryNoToImport;
    end;

    procedure SetEntryNoToProcess(_EntryNoToProcess: BigInteger)
    begin
        EntryNoToProcess := _EntryNoToProcess;
    end;

    procedure ShowEventLog()
    var
        _EventLogEntry: Record "ARC Event Log Entry";
    begin
        _EventLogEntry.SetCurrentKey(Code, "Object Type", "Object ID");
        _EventLogEntry.SetRange(Code,'CUBISCAN');
        Page.Run(Page::"ARC Event Log Entries",_EventLogEntry);
    end;

    procedure ShowItem(_CubiscanEntry: Record "ARC Cubiscan Entry")
    var
        _Item: Record Item;
    begin
        _Item.Get(_CubiscanEntry."Item No.");
        _Item.SetRecFilter();
        Page.Run(Page::"Item Card",_Item);
    end;

    procedure ShowJobQueue()
    var
        _JobQueueEntry: Record "Job Queue Entry";
    begin
        _JobQueueEntry.SetRange("Object Type to Run",_JobQueueEntry."Object Type to Run"::Codeunit);
        _JobQueueEntry.SetRange("Object ID to Run",Codeunit::"ARC CubiscanMgt");
        Page.Run(Page::"Job Queue Entries",_JobQueueEntry);
    end;

    local procedure WriteLog(_logLevel: Integer; _relatedEntryNo: BigInteger; _relatedDataEntryNo: BigInteger; _msg: Text; _err: Text)
    var
        _EventLogEntry: Record "ARC Event Log Entry";
        _status: Integer;
    begin
        if _logLevel > KorberSetup."Log Level" then
            exit;
        if _err <> '' then
            _status := _EventLogEntry.Status::Error
        else
            _status := _EventLogEntry.Status::Message;
        _EventLogEntry.NewEventLogEntry('CUBISCAN',_EventLogEntry."Object Type"::Codeunit,Codeunit::"ARC CubiscanMgt",
            _status,_relatedEntryNo,_msg,_err,false,'');
    end;
}
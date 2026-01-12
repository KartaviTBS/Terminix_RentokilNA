codeunit 50106 "ARC KorberItemAdjmtMgt"
{
    // SOW11 Körber Edge WMS Integration

    trigger OnRun();
    begin
        Initialize();
        if not KorberSetup."Process Queue Enabled" then
            exit;
        if EntryNoToProcess <> 0 then begin
            ProcessEntry();
            exit;
        end;
        ProcessEntries();
    end;

    var
        KorberSetup: Record "ARC Korber Setup";
        EntryNoToProcess: BigInteger;
        Initialized: Boolean;

    procedure CreateItemAdjmtWMS(var _tempBuf: Record "ARC Buffer" temporary)
    var
        _Item: Record Item;
        _KorberItemAdjmtEntry: Record "ARC Korber Item Adjmt. Entry";
        _Location: Record Location;
        _Reason: Record "Reason Code";
    begin
        _KorberItemAdjmtEntry.Init();
        _KorberItemAdjmtEntry."Entry No." := 0;
        if _tempBuf."Decimal 01" < 0 then
            _KorberItemAdjmtEntry."Entry Type" := _KorberItemAdjmtEntry."Entry Type"::"Negative Adjmt."
        else
            _KorberItemAdjmtEntry."Entry Type" := _KorberItemAdjmtEntry."Entry Type"::"Positive Adjmt.";
        if _tempBuf."Code 03" <> '' then
            if _Item.Get(_tempBuf."Code 03") then begin
                _KorberItemAdjmtEntry."Item No." := CopyStr(_tempBuf."Code 03",1,MaxStrLen(_KorberItemAdjmtEntry."Item No."));
                _KorberItemAdjmtEntry."Item Unit of Measure Code" := CopyStr(_Item."Base Unit of Measure",1,MaxStrLen(_KorberItemAdjmtEntry."Item Unit of Measure Code"));
            end;
        if _tempBuf."Code 06" <> '' then begin
            _Location.SetRange("ARC Korber Location Code",_tempBuf."Code 06");
            if _Location.FindFirst() then
                _KorberItemAdjmtEntry."Location Code" := CopyStr(_Location.Code,1,MaxStrLen(_KorberItemAdjmtEntry."Location Code"));
        end;
        _KorberItemAdjmtEntry."WMS RowId" := CopyStr(_tempBuf."Text 01",1,MaxStrLen(_KorberItemAdjmtEntry."WMS RowId"));
        _KorberItemAdjmtEntry."WMS Adjustment Date" := CopyStr(_tempBuf."Text 02",1,MaxStrLen(_KorberItemAdjmtEntry."WMS Adjustment Date"));
        _KorberItemAdjmtEntry."WMS Bin Location" := CopyStr(_tempBuf."Code 01",1,MaxStrLen(_KorberItemAdjmtEntry."WMS Bin Location"));
        _KorberItemAdjmtEntry."WMS Operator Name" := CopyStr(_tempBuf."Code 02",1,MaxStrLen(_KorberItemAdjmtEntry."WMS Operator Name"));
        _KorberItemAdjmtEntry."WMS OrderNum" := CopyStr(_tempBuf."Text 03",1,MaxStrLen(_KorberItemAdjmtEntry."WMS OrderNum"));
        _KorberItemAdjmtEntry."WMS Product Code" := CopyStr(_tempBuf."Code 03",1,MaxStrLen(_KorberItemAdjmtEntry."WMS Product Code"));
        _KorberItemAdjmtEntry."WMS Reason Code" := CopyStr(_tempBuf."Code 04",1,MaxStrLen(_KorberItemAdjmtEntry."WMS Reason Code"));
        _KorberItemAdjmtEntry."WMS Transaction Code" := CopyStr(_tempBuf."Code 05",1,MaxStrLen(_KorberItemAdjmtEntry."WMS Transaction Code"));
        if _tempBuf."Code 05" <> '' then begin
            _Reason.SetRange("ARC Korber Reason Code",_tempBuf."Code 05");
            if _Reason.FindFirst() then
                _KorberItemAdjmtEntry."Reason Code" := CopyStr(_Reason.Code,1,MaxStrLen(_KorberItemAdjmtEntry."Reason Code"));
        end;
        _KorberItemAdjmtEntry."WMS Warehouse" := CopyStr(_tempBuf."Code 06",1,MaxStrLen(_KorberItemAdjmtEntry."WMS Warehouse"));
        _KorberItemAdjmtEntry."WMS Zone Code" := CopyStr(_tempBuf."Code 07",1,MaxStrLen(_KorberItemAdjmtEntry."WMS Zone Code"));
        // always base unit of measure
        _KorberItemAdjmtEntry."WMS Quantity" := CopyStr(_tempBuf."Text 04",1,MaxStrLen(_KorberItemAdjmtEntry."WMS Quantity"));
        _KorberItemAdjmtEntry.Quantity := Abs(_tempBuf."Decimal 01");
        _KorberItemAdjmtEntry."Qty. per Unit of Measure" := 1;
        _KorberItemAdjmtEntry."Quantity (Base)" := _KorberItemAdjmtEntry.Quantity;
        _KorberItemAdjmtEntry."Import Data Entry No." := _tempBuf."BigInteger 01";
        _KorberItemAdjmtEntry.Insert();
    end;

    local procedure Initialize()
    begin
        if Initialized then
            exit;
        KorberSetup.Get();
        Initialized := true;
    end;

    procedure OnBeforeInsertItemAdjmtEntry(var Rec: Record "ARC Korber Item Adjmt. Entry"; RunTrigger: Boolean)
    var
        _time: Time;
    begin
        _time := Time();
        Rec."Created by" := CopyStr(UserId(),1,MaxStrLen(Rec."Created by"));
        Rec."Created at Date" := Today();
        Rec."Created at DateTime" := CreateDateTime(Today(),_time);
        Rec."Created at Time" := _time;
    end;

    local procedure ProcessEntries()
    var
        _KorberItemAdjmtEntry: Record "ARC Korber Item Adjmt. Entry";
        _KorberItemAdjmtEntry2: Record "ARC Korber Item Adjmt. Entry";
        _KorberItemAdjmtMgt: Codeunit "ARC KorberItemAdjmtMgt";
        _result: Boolean;
        _entriesProcessed: Integer;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Msg: Label 'KorberItemAdjmtMgt, entries processed: %1';
    begin
        KorberSetup.TestField("Item Journal Template");
        KorberSetup.TestField("Item Journal Batch");
        _KorberItemAdjmtEntry.SetCurrentKey(Processed);
        _KorberItemAdjmtEntry.SetRange(Processed,0);
        if _KorberItemAdjmtEntry.FindSet(false) then
            repeat
                _timeBegin := Time();
                Clear(_KorberItemAdjmtMgt);
                _KorberItemAdjmtMgt.SetEntryNoToProcess(_KorberItemAdjmtEntry."Entry No.");
                Commit();
                _result := _KorberItemAdjmtMgt.Run();
                if not _result then begin
                    Clear(_KorberItemAdjmtEntry2);
                    _KorberItemAdjmtEntry2.Reset();
                    _KorberItemAdjmtEntry2.LockTable();
                    if _KorberItemAdjmtEntry2.Get(_KorberItemAdjmtEntry."Entry No.") then begin
                        _timeEnd := Time();
                        _KorberItemAdjmtEntry2."Processed at DateTime" := CreateDateTime(Today(),_timeEnd);
                        _KorberItemAdjmtEntry2."Processed Duration" := _timeEnd - _timeBegin;
                        _KorberItemAdjmtEntry2."Processed No. of Attempts" := _KorberItemAdjmtEntry2."Processed No. of Attempts" + 1;
                        _KorberItemAdjmtEntry2."Processed Error Text" := CopyStr(GetLastErrorText(),1,MaxStrLen(_KorberItemAdjmtEntry2."Processed Error Text"));
                        if _KorberItemAdjmtEntry2."Processed No. of Attempts" >= KorberSetup."Maximum No. of Attempts" then
                            _KorberItemAdjmtEntry2.Processed := -1;
                        _KorberItemAdjmtEntry2.Modify();
                    end;
                end;
                _entriesProcessed += 1;
            until (_KorberItemAdjmtEntry.Next() = 0) or (_entriesProcessed >= KorberSetup."Process Queue No. Entries");
        if _entriesProcessed > 0 then
            WriteLog(KorberSetup."Log Level"::Verbose,0,0,StrSubstNo(_Text000Msg,_entriesProcessed),'');
    end;

    local procedure ProcessEntry()
    var
        _KorberItemAdjmtEntry: Record "ARC Korber Item Adjmt. Entry";
        _KorberItemAdjmtEntry2: Record "ARC Korber Item Adjmt. Entry";
        _ItemJournalLine: Record "Item Journal Line";
        _KorberItemAdjmtMgt: Codeunit "ARC KorberItemAdjmtMgt";
        _AdjmtDate: Date;
        _DateBegin: Date;
        _DateEnd: Date;
        _LineNo: Integer;
        _AdjmtDateText: Text;
        _timeBegin: Time;
        _timeEnd: Time;
        _Text000Err: Label 'Invalid Entry Type %1';
        _Text001Err: Label 'Too many records exist in the item journal batch.  Please clear out the batch.';
    begin
        _timeBegin := Time();
        _KorberItemAdjmtEntry.Get(EntryNoToProcess);
        _AdjmtDateText := CopyStr(_KorberItemAdjmtEntry."WMS Adjustment Date",1,MaxStrLen(_AdjmtDateText));
        if StrLen(_AdjmtDateText) > 10 then
            if Evaluate(_AdjmtDate,CopyStr(_AdjmtDateText,6,2) + '/' + CopyStr(_AdjmtDateText,9,2) + '/' + CopyStr(_AdjmtDateText,1,4)) then;
        _DateBegin := CalcDate('CM+1D-1M',Today());
        _DateEnd := CalcDate('CM',Today());
        if (_AdjmtDate < _DateBegin) or (_AdjmtDate > _DateEnd) then
            _AdjmtDate := Today();
        _KorberItemAdjmtEntry.TestField("Item No.");
        _KorberItemAdjmtEntry.TestField("Item Unit of Measure Code");
        _KorberItemAdjmtEntry.TestField(Quantity);
        _KorberItemAdjmtEntry.TestField("Location Code");
        if (not (_KorberItemAdjmtEntry."Entry Type" in [_KorberItemAdjmtEntry."Entry Type"::"Negative Adjmt.",_KorberItemAdjmtEntry."Entry Type"::"Positive Adjmt."])) then
            Error(_Text000Err,_KorberItemAdjmtEntry."Entry Type");
        _ItemJournalLine.SetRange("Journal Template Name",KorberSetup."Item Journal Template");
        _ItemJournalLine.SetRange("Journal Batch Name",KorberSetup."Item Journal Batch");
        if _ItemJournalLine.FindLast() then
            _LineNo := _ItemJournalLine."Line No.";
        if _LineNo < 2000000000 then
            _LineNo += Round(_LineNo + 100,10,'>')
        else
            Error(_Text001Err);
        _ItemJournalLine.Init();
        _ItemJournalLine."Journal Template Name" := CopyStr(KorberSetup."Item Journal Template",1,MaxStrLen(_ItemJournalLine."Journal Template Name"));
        _ItemJournalLine."Journal Batch Name" := CopyStr(KorberSetup."Item Journal Batch",1,MaxStrLen(_ItemJournalLine."Journal Batch Name"));
        _ItemJournalLine."Line No." := _LineNo;
        _ItemJournalLine.Insert();
        _ItemJournalLine.Validate("Posting Date",_AdjmtDate);
        _ItemJournalLine.Validate("Entry Type",_KorberItemAdjmtEntry."Entry Type");
        _ItemJournalLine.Validate("Document No.",CopyStr('WMS_' + Format(_KorberItemAdjmtEntry."Entry No."),1,MaxStrLen(_ItemJournalLine."Document No.")));
        _ItemJournalLine.Validate("Item No.",_KorberItemAdjmtEntry."Item No.");
        _ItemJournalLine.Validate("Unit of Measure Code",_KorberItemAdjmtEntry."Item Unit of Measure Code");
        _ItemJournalLine.Validate("Location Code",_KorberItemAdjmtEntry."Location Code");
        _ItemJournalLine.Validate(Quantity,Abs(_KorberItemAdjmtEntry.Quantity));
        _ItemJournalLine.Validate("Reason Code",_KorberItemAdjmtEntry."Reason Code");
        _ItemJournalLine.Modify();
        _timeEnd := Time();
        _KorberItemAdjmtEntry2.LockTable();
        _KorberItemAdjmtEntry2.Get(EntryNoToProcess);
        _KorberItemAdjmtEntry2.Processed := 1;
        _KorberItemAdjmtEntry2."Processed at DateTime" := CreateDateTime(Today(),_timeEnd);
        _KorberItemAdjmtEntry2."Processed Duration" := _timeEnd - _timeBegin;
        _KorberItemAdjmtEntry2."Processed No. of Attempts" := _KorberItemAdjmtEntry2."Processed No. of Attempts" + 1;
        _KorberItemAdjmtEntry2.Modify();
    end;

    procedure ResetEntry(var _KorberItemAdjmtEntry: Record "ARC Korber Item Adjmt. Entry")
    var
        _KorberItemAdjmtEntry2: Record "ARC Korber Item Adjmt. Entry";
        _count: Integer;
        _Text000Qst: Label 'Entries selected: %1.  Are you SURE you want to reset?';
        _Text001Msg: Label '*** RESET *** %1 No. %2, Item %3';
    begin
        Initialize();
        _count := _KorberItemAdjmtEntry.Count();
        if GuiAllowed() then
            if not Confirm(_Text000Qst,false,_count) then
                exit;
        if _KorberItemAdjmtEntry.FindSet(false) then
            repeat
                Clear(_KorberItemAdjmtEntry2);
                _KorberItemAdjmtEntry2.Reset();
                _KorberItemAdjmtEntry2.LockTable();
                _KorberItemAdjmtEntry2.Get(_KorberItemAdjmtEntry."Entry No.");
                _KorberItemAdjmtEntry2.Processed := 0;
                _KorberItemAdjmtEntry2."Processed at DateTime" := 0DT;
                _KorberItemAdjmtEntry2."Processed Duration" := 0;
                _KorberItemAdjmtEntry2."Processed Error Text" := CopyStr('',1,MaxStrLen(_KorberItemAdjmtEntry2."Analyzed Error Text"));
                _KorberItemAdjmtEntry2."Processed No. of Attempts" := 0;
                _KorberItemAdjmtEntry2.Modify();
                WriteLog(KorberSetup."Log Level"::Normal,_KorberItemAdjmtEntry."Entry No.",0,
                    StrSubstNo(_Text001Msg,_KorberItemAdjmtEntry2.TableCaption(),_KorberItemAdjmtEntry2."Entry No.",_KorberItemAdjmtEntry2."Item No."),'');
            until _KorberItemAdjmtEntry.Next() = 0;
        _KorberItemAdjmtEntry.Reset();
    end;

    procedure SetEntryNoToProcess(_EntryNoToProcess: BigInteger)
    begin
        EntryNoToProcess := _EntryNoToProcess;
    end;

    procedure ShowItem(_ItemAdjmtEntry: Record "ARC Korber Item Adjmt. Entry")
    var
        _Item: Record Item;
    begin
        _Item.Get(_ItemAdjmtEntry."Item No.");
        _Item.SetRecFilter();
        Page.Run(Page::"Item Card",_Item);
    end;

    procedure ShowItemLedgEntry(_ItemAdjmtEntry: Record "ARC Korber Item Adjmt. Entry")
    var
        _ItemLedgEntry: Record "Item Ledger Entry";
    begin
        _ItemAdjmtEntry.TestField(_ItemAdjmtEntry."Item Ledger Entry No.");
        _ItemLedgEntry.Get(_ItemAdjmtEntry."Item Ledger Entry No.");
        _ItemLedgEntry.SetRecFilter();
        Page.Run(Page::"Item Ledger Entries",_ItemLedgEntry);
    end;

    procedure ShowItemUom(_ItemAdjmtEntry: Record "ARC Korber Item Adjmt. Entry")
    var
        _ItemUom: Record "Item Unit of Measure";
    begin
        _ItemUom.SetRange("Item No.",_ItemAdjmtEntry."Item No.");
        Page.Run(Page::"Item Units of Measure",_ItemUom);
    end;

    procedure ShowLocation(_ItemAdjmtEntry: Record "ARC Korber Item Adjmt. Entry")
    var
        _Location: Record Location;
    begin
        _Location.Get(_ItemAdjmtEntry."Location Code");
        _Location.SetRecFilter();
        Page.Run(Page::"Location Card",_Location);
    end;

    local procedure WriteLog(_logLevel: Integer; _relatedEntryNo: BigInteger; _relatedDataEntryNo: BigInteger; _msg: Text; _err: Text)
    var
        _KorberMgt: Codeunit "ARC KorberMgt";
    begin
        _KorberMgt.WriteLog(_logLevel,Codeunit::"ARC KorberItemAdjmtMgt",'KORITMADJMGT',_relatedEntryNo,_relatedDataEntryNo,_msg,_err);
    end;
}
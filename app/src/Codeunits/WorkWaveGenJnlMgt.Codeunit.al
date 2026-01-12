codeunit 50051 "ARC WorkWave Gen. Jnl Mgt."
{
    trigger OnRun();
    begin
    end;

    procedure SuggestCashRcptJnl(var WorkWaveEntry: Record "ARC Workwave Entry"): Date;
    var
        LastGenJournalLine: Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        ActTypeJnlBatch: Record "ARC WW Acct. Type GenJnl Batch";
        Balance: Decimal;
        TotalBalance: Decimal;
        ShowBalance: Boolean;
        ShowTotalBalance: Boolean;
        LineNo: Integer;
    begin
        case WorkWaveEntry."Card Type" of
            'Visa': ActTypeJnlBatch.Get(ActTypeJnlBatch."Account Type"::Visa);
            'Mastercard': ActTypeJnlBatch.Get(ActTypeJnlBatch."Account Type"::MasterCard);
            'AmericanExpress': ActTypeJnlBatch.Get(ActTypeJnlBatch."Account Type"::"American Express");
            'Discover':ActTypeJnlBatch.Get(ActTypeJnlBatch."Account Type"::Discover);
            'DinersClub':ActTypeJnlBatch.Get(ActTypeJnlBatch."Account Type"::"Diner's Club");
            'Jcb': ActTypeJnlBatch.Get(ActTypeJnlBatch."Account Type"::"JCB Card");
        end;
        if StrPos(UpperCase(WorkWaveEntry."Payment Acct Type"),'ACH') <> 0 then
          ActTypeJnlBatch.Get(ActTypeJnlBatch."Account Type"::EBT);
        GenJnlTemplate.Get(ActTypeJnlBatch."Gen. Journal Template");
        GenJnlBatch.Get(ActTypeJnlBatch."Gen. Journal Template",ActTypeJnlBatch."Temp Gen. Journal Batch");

        LastGenJournalLine.Reset;
        LastGenJournalLine.SetRange("Journal Template Name", ActTypeJnlBatch."Gen. Journal Template");
        LastGenJournalLine.SetRange("Journal Batch Name", ActTypeJnlBatch."Temp Gen. Journal Batch");
        if LastGenJournalLine.FindLast then
            LineNo := Round(LastGenJournalLine."Line No." + 1, 10000, '>')
        else
            LineNo := 10000;
        GenJournalLine.CopyFilters(LastGenJournalLine);
        CalcBalance(GenJournalLine, LastGenJournalLine, Balance, TotalBalance, ShowBalance, ShowTotalBalance);
        GenJournalLine.Init;
        GenJournalLine.Validate("Journal Template Name", ActTypeJnlBatch."Gen. Journal Template");
        GenJournalLine.Validate("Journal Batch Name", ActTypeJnlBatch."Temp Gen. Journal Batch");
        GenJournalLine.Validate("Line No.", LineNo);
        //Commit;
        SetUpNewLine(GenJournalLine, LastGenJournalLine, Balance, TRUE);
        case ActTypeJnlBatch."Populate External Doc. No." of
            ActTypeJnlBatch."Populate External Doc. No."::"Posting Date+Base":
              GenJournalLine.Validate("External Document No.", Format(GenJournalLine."Posting Date") + ActTypeJnlBatch."External Doc. No. Base");
            ActTypeJnlBatch."Populate External Doc. No."::"Work Date+Base":
              GenJournalLine.Validate("External Document No.", Format(Workdate) + ActTypeJnlBatch."External Doc. No. Base");
            ActTypeJnlBatch."Populate External Doc. No."::"Today+Base":
              GenJournalLine.Validate("External Document No.", Format(Today) + ActTypeJnlBatch."External Doc. No. Base");
            ActTypeJnlBatch."Populate External Doc. No."::"Base+Posting Date":
              GenJournalLine.Validate("External Document No.", ActTypeJnlBatch."External Doc. No. Base" + Format(GenJournalLine."Posting Date"));
            ActTypeJnlBatch."Populate External Doc. No."::"Base+Work Date":
              GenJournalLine.Validate("External Document No.", ActTypeJnlBatch."External Doc. No. Base" + Format(Workdate));
            ActTypeJnlBatch."Populate External Doc. No."::"Base+Today":
              GenJournalLine.Validate("External Document No.", ActTypeJnlBatch."External Doc. No. Base" + Format(Today));
            ActTypeJnlBatch."Populate External Doc. No."::Base:
              GenJournalLine.Validate("External Document No.", ActTypeJnlBatch."External Doc. No. Base");
            ActTypeJnlBatch."Populate External Doc. No."::"Approval/Authorization Number":
              If WorkWaveEntry."Approval No." <> '' then
                GenJournalLine.Validate("External Document No.", WorkWaveEntry."Approval No.")
              else
                GenJournalLine.Validate("External Document No.", WorkWaveEntry.Reference);
        end;
        GenJournalLine.Insert(true);
        GenJournalLine."Posting Date" := DT2Date(WorkWaveEntry."Created On");
        GenJournalLine.Validate(Amount,WorkWaveEntry.Amount * -1);
        if ActTypeJnlBatch."Bal. Account No." <> '' then begin
            GenJournalLine."Bal. Account Type" := ActTypeJnlBatch."Bal. Account Type";
            GenJournalLine."Bal. Account No." := ActTypeJnlBatch."Bal. Account No.";
        end;
        GenJournalLine.Validate("ARC WorkWave Entry No.",WorkWaveEntry."Entry No.");
        GenJournalLine.Validate(Amount,WorkWaveEntry.Amount * -1);
        GenJournalLine.Modify(true);
        Exit(GenJournalLine."Posting Date");
    end;

    local procedure CalcBalance(var GenJnlLine: Record "Gen. Journal Line"; LastGenJnlLine: Record "Gen. Journal Line"; var Balance: Decimal; var TotalBalance: Decimal; var ShowBalance: Boolean; var ShowTotalBalance: Boolean);
    var
        GenJnlLine2: Record "Gen. Journal Line";
    begin
        GenJnlLine2.CopyFilters(GenJnlLine);
        ShowTotalBalance := GenJnlLine2.CalcSums("Balance (LCY)");
        if ShowTotalBalance then begin
            TotalBalance := GenJnlLine2."Balance (LCY)";
            if GenJnlLine."Line No." = 0 then
                TotalBalance := TotalBalance + LastGenJnlLine."Balance (LCY)";
        end;

        if GenJnlLine."Line No." <> 0 then begin
            GenJnlLine2.SetRange("Line No.", 0, GenJnlLine."Line No.");
            ShowBalance := GenJnlLine2.CalcSums("Balance (LCY)");
            if ShowBalance then
                Balance := GenJnlLine2."Balance (LCY)";
        end else begin
            GenJnlLine2.SetRange("Line No.", 0, LastGenJnlLine."Line No.");
            ShowBalance := GenJnlLine2.CalcSums("Balance (LCY)");
            if ShowBalance then begin
                Balance := GenJnlLine2."Balance (LCY)";
                GenJnlLine2.CopyFilters(GenJnlLine);
                GenJnlLine2 := LastGenJnlLine;
                if GenJnlLine2.Next = 0 then
                    Balance := Balance + LastGenJnlLine."Balance (LCY)";
            end;
        end;

    end;

    local procedure SetupNewLine(var NewGenJnlLine: Record "Gen. Journal Line"; LastGenJnlLine: Record "Gen. Journal Line"; Balance: Decimal; BottomLine: Boolean);
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlTemplate.Get(NewGenJnlLine."Journal Template Name");
        GenJnlBatch.Get(NewGenJnlLine."Journal Template Name", NewGenJnlLine."Journal Batch Name");
        NewGenJnlLine."Posting Date" := WorkDate;
        NewGenJnlLine."Document Date" := WorkDate;
        if GenJnlBatch."No. Series" <> '' then begin
            Clear(NoSeriesMgt);
            NewGenJnlLine."Document No." := NoSeriesMgt.GetNextNo(GenJnlBatch."No. Series",WorkDate,true);
        end;
        
        if GenJnlTemplate.Recurring then
            NewGenJnlLine."Recurring Method" := LastGenJnlLine."Recurring Method";
        NewGenJnlLine."Account Type" := LastGenJnlLine."Account Type";
        NewGenJnlLine."Document Type" := LastGenJnlLine."Document Type";
        NewGenJnlLine."Source Code" := GenJnlTemplate."Source Code";
        NewGenJnlLine."Reason Code" := GenJnlBatch."Reason Code";
        NewGenJnlLine."Posting No. Series" := GenJnlBatch."Posting No. Series";
        NewGenJnlLine."Bal. Account Type" := GenJnlBatch."Bal. Account Type";
        if(NewGenJnlLine."Account Type" IN [NewGenJnlLine."Account Type"::Customer,
                                     NewGenJnlLine."Account Type"::Vendor,
                                     NewGenJnlLine."Account Type"::"Fixed Asset"]) and
            (NewGenJnlLine."Bal. Account Type" IN [NewGenJnlLine."Bal. Account Type"::Customer,
                                         NewGenJnlLine."Bal. Account Type"::Vendor,
                                         NewGenJnlLine."Bal. Account Type"::"Fixed Asset"])
        then
            NewGenJnlLine."Account Type" := NewGenJnlLine."Account Type"::"G/L Account";
        NewGenJnlLine.VALIDATE("Bal. Account No.", GenJnlBatch."Bal. Account No.");
        NewGenJnlLine.Description := '';
    end;

    var
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        NoSeriesMgt: Codeunit NoSeriesManagement;
}
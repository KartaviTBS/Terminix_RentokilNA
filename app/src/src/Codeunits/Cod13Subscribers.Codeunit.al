codeunit 50053 "ARC Codeunit 13 Subscribers"
{
    trigger OnRun();
    begin
    end;
    

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeUpdateAndDeleteLines', '', true, true)]
    local procedure "Gen. Jnl.-Post Batch_OnBeforeUpdateAndDeleteLines"(var GenJournalLine: Record "Gen. Journal Line")
    var 
        GenJnlLine2: Record "Gen. Journal Line";
        WorkWaveEntry: Record "ARC Workwave Entry";
    begin
        GenJnlLine2.Copy(GenJournalLine);
        GenJnlLine2.SetFilter("ARC WorkWave Entry No.",'<>%1',0);
        if GenJnlLine2.FindSet then 
            repeat
                if WorkWaveEntry.Get(GenJnlLine2."ARC WorkWave Entry No.") then begin 
                    if WorkWaveEntry.Status = WorkWaveEntry.Status::Batched then begin 
                        WorkWaveEntry.Status := WorkWaveEntry.Status::Settled;
                        WorkWaveEntry.Modify;
                    end;
                end;

            until GenJnlLine2.Next = 0;
    end;

    var
        myInt : Integer;
}
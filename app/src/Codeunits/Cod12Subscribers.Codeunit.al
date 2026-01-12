codeunit 50019 "ARC Codeunit 12 Subscribers"
{
    Permissions =   TableData "Cust. Ledger Entry" = rimd,
                    TableData "Vendor Ledger Entry" = rimd,
                    TableData "Bank Account Ledger Entry" = rimd,
                    TableData "Detailed Cust. Ledg. Entry" = rimd,
                    TableData "Detailed Vendor Ledg. Entry" = rimd;

    trigger OnRun();
    begin
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInsertGlobalGLEntry', '', false, false)]
    local procedure "Gen. Jnl.-Post Line_OnAfterInsertGlobalGLEntry"(var GLEntry: Record "G/L Entry")
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        BankAcctLedgEntry: Record "Bank Account Ledger Entry";
    begin
        If CustLedgEntry.Get(GLEntry."Entry No.") then begin
            CustLedgEntry."ARC WorkWave Entry No." := GLEntry."ARC WorkWave Entry No.";
            CustLedgEntry.Modify;
        end;
        If BankAcctLedgEntry.Get(GLEntry."Entry No.") then begin
            BankAcctLedgEntry."ARC WorkWave Entry No." := GLEntry."ARC WorkWave Entry No.";
            BankAcctLedgEntry.Modify;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGLEntryBuffer', '', false, false)]
    local procedure OnBeforeInsertGLEntryBuffer(var TempGLEntryBuf: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        TempGLEntryBuf."ARC WorkWave Entry No." := GenJournalLine."ARC WorkWave Entry No.";
    end;

    var
        myInt: Integer;
}
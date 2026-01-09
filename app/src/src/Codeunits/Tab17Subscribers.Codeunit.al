codeunit 50027 "ARC Table 17 Subscribers"
{

    [EventSubscriber(ObjectType::Table, 17, 'OnAfterCopyGLEntryFromGenJnlLine', '', false, false)]
    local procedure OnAfterCopyGLEntryFromGenJnlLine(var GLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line");
    var
        ShortCutDimCode: array[8] of Code[20];
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.GetShortcutDimensions(GenJournalLine."Dimension Set ID",ShortCutDimCode);
        GLEntry."ARC Global Dimension 3 Code" := ShortCutDimCode[3];      
        GLEntry."Global Dimension 3 Code" := ShortCutDimCode[3];
    end; 

  
    
}
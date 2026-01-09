codeunit 50080 "Table Record Link Subscribers"
{
    trigger OnRun();
    begin
    end;

    [EventSubscriber(ObjectType::Table, 2000000068, 'OnBeforeInsertEvent', '', false, false)]
    local procedure BeforeInsertNote(var Rec: Record "Record Link"; RunTrigger: Boolean)
    var
    begin
        if (Rec.Type = Rec.Type::Note) and (Rec."To User ID" <> '') then
            Rec.Notify := true;
    end;
}
codeunit 50015 "ARC Table 1301 Subscribers"
{
    trigger OnRun();
    begin
    end;
    
    var
        myInt : Integer;

    [EventSubscriber(ObjectType::Table, 1301, 'OnAfterCreateFieldRefArray', '', false, false)]
    local procedure OnAfterCreateFieldRefArray(var FieldRefArray: Array[30] of FieldRef; RecRef: RecordRef; var I: Integer);
    begin
        FieldRefArray[I] := RecRef.Field(50000);      
    end;    
}
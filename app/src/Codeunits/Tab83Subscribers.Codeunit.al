codeunit 50023 "ARC Table 83 Subscribers"
{
    
    [EventSubscriber(ObjectType::Table, 83, 'OnBeforeValidateEvent', 'Location Code', false, false)]
    local procedure OnBeforeValidateLocationCode(var Rec: Record "Item Journal Line"; var xRec: Record "Item Journal Line"; CurrFieldNo: Integer);
    var
        Location: Record Location;
    begin
        if rec."Location Code" <> xRec."Location Code" then begin 
            if Location.Get(Rec."Location Code") then begin 
                if Location."Shortcut Dimension 1 Code" <> '' then
                    Rec.Validate("Shortcut Dimension 1 Code",Location."Shortcut Dimension 1 Code");
                if Location."Shortcut Dimension 2 Code" <> '' then
                    Rec.Validate("Shortcut Dimension 2 Code",Location."Shortcut Dimension 2 Code");
            end;
        end;
    end;     
}
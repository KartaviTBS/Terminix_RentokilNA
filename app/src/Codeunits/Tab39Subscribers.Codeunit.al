codeunit 50024 "ARC Table 39 Subscribers"
{

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeValidateEvent', 'Location Code', false, false)]
    local procedure OnBeforeValidateLocationCode(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer);
    var
        Location: Record Location;
    begin
        if rec."Location Code" <> xRec."Location Code" then begin
            if Location.Get(Rec."Location Code") then begin
                if Location."Shortcut Dimension 1 Code" <> '' then
                    Rec.Validate("Shortcut Dimension 1 Code", Location."Shortcut Dimension 1 Code");
                if Location."Shortcut Dimension 2 Code" <> '' then
                    Rec.Validate("Shortcut Dimension 2 Code", Location."Shortcut Dimension 2 Code");
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure OnAfterValidateItemNo(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer);
    var
        Item: Record Item;
    begin
        if rec."No." <> xRec."No." then begin
            if Rec.Type = Rec.Type::Item then begin
                if Item.Get(Rec."No.") and Item."ARC Purchase Block" then
                    Error(PurchBlockErrorTxt,Item."No.")
            end;
        end;
    end;

    var
        PurchBlockErrorTxt: Label 'You cannot purchase the item %1, because it is blocked';
}
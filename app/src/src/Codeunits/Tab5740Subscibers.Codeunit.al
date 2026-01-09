codeunit 50000 "ARC Table 5740 Subscribers"
{

    [EventSubscriber(ObjectType::Table, 5740, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertTransferHeader(var Rec: Record "Transfer Header"; RunTrigger: Boolean);
    var
    begin
        if not RunTrigger then
            exit;
        Rec."ARC Created By" := UserId;
        Rec."ARC Created On" := CurrentDateTime;
    end;

    [EventSubscriber(ObjectType::Table, 5740, 'OnBeforeValidateEvent', 'Transfer-from Code', false, false)]
    local procedure OnBeforeValidateLocationCode(var Rec: Record "Transfer Header"; var xRec: Record "Transfer Header"; CurrFieldNo: Integer);
    var
        Location: Record Location;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        GLSetup: Record "General Ledger Setup";
        oldDimID: Integer;
    begin
        if(rec."Transfer-from Code" <> xRec."Transfer-from Code") then begin
            GLSetup.Get;
            if Location.Get(Rec."Transfer-from Code") then begin
                oldDimID := Rec."Dimension Set ID";
                DimMgt.GetDimensionSet(TempDimSetEntry, Rec."Dimension Set ID");
                if Location."Shortcut Dimension 1 Code" <> '' then begin
                    UpdateDimSet(Rec, TempDimSetEntry, GLSetup."Global Dimension 1 Code", Location."Shortcut Dimension 1 Code");
                    Rec."Shortcut Dimension 1 Code" := Location."Shortcut Dimension 1 Code";
                end;
                if Location."Shortcut Dimension 2 Code" <> '' then begin
                    UpdateDimSet(Rec, TempDimSetEntry, GLSetup."Global Dimension 1 Code", Location."Shortcut Dimension 1 Code");
                    Rec."Shortcut Dimension 2 Code" := Location."Shortcut Dimension 1 Code";
                end;
                Rec."Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
                if oldDimID <> Rec."Dimension Set ID" then begin
                    if Rec.HasTransferLines then begin
                        Rec.UpdateAllLineDim(Rec."Dimension Set ID", oldDimID);
                    end;
                end;
                Rec.UpdateTransLines(Rec,Rec.FieldNo("Transfer-from Code"));
            end;
        end;
    end;



    local procedure UpdateDimSet(var TransHeader: Record "Transfer Header"; var TempDimSetEntry: Record "Dimension Set Entry" temporary; DimCode: Code[20]; DimValueCode: Code[20])
    begin
        if DimCode = '' then
            exit;
        if TempDimSetEntry.Get(TransHeader."Dimension Set ID", DimCode) then
            TempDimSetEntry.Delete;
        if DimValueCode <> '' then begin
            DimVal.Get(DimCode, DimValueCode);
            TempDimSetEntry.Init;
            TempDimSetEntry."Dimension Set ID" := TransHeader."Dimension Set ID";
            TempDimSetEntry."Dimension Code" := DimCode;
            TempDimSetEntry."Dimension Value Code" := DimValueCode;
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.Insert;

        end;
    end;

    var
        DimVal: Record "Dimension Value";
        DimMgt: Codeunit DimensionManagement;

}
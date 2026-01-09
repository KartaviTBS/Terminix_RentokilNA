codeunit 50021 "ARC Table 38 Subscribers"
{
    /*
    [EventSubscriber(ObjectType::Table, 38, 'OnBeforeValidateEvent', 'Location Code', false, false)]
    local procedure OnBeforeValidateLocationCode(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; CurrFieldNo: Integer);
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
    */

    [EventSubscriber(ObjectType::Table, 38, 'OnBeforeValidateEvent', 'Location Code', false, false)]
    local procedure OnBeforeValidateLocationCode(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; CurrFieldNo: Integer);
    var
        Location: Record Location;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        GLSetup: Record "General Ledger Setup";
        oldDimID: Integer;
    begin
        if (rec."Location Code" <> xRec."Location Code") then begin 
            GLSetup.Get;
            if Location.Get(Rec."Location Code") then begin 
               oldDimID := Rec."Dimension Set ID";
               DimMgt.GetDimensionSet(TempDimSetEntry, Rec."Dimension Set ID");
               if Location."Shortcut Dimension 1 Code" <> '' then begin 
                 UpdateDimSet(Rec,TempDimSetEntry,GLSetup."Global Dimension 1 Code",Location."Shortcut Dimension 1 Code");
                 Rec."Shortcut Dimension 1 Code" := Location."Shortcut Dimension 1 Code";
               end;  
               if Location."Shortcut Dimension 2 Code" <> '' then begin 
                 UpdateDimSet(Rec,TempDimSetEntry,GLSetup."Global Dimension 1 Code",Location."Shortcut Dimension 1 Code");
                 Rec."Shortcut Dimension 2 Code" := Location."Shortcut Dimension 2 Code";
               end;  
               Rec."Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
               if oldDimID <> Rec."Dimension Set ID" then begin 
                   if Rec.PurchLinesExist then begin 
                     Rec.UpdateAllLineDim(Rec."Dimension Set ID",oldDimID);
                   end;
               end;
               Rec.UpdatePurchLines(Rec.FieldName("Location Code"),false);
            end;
        end;
    end;   

   

    local procedure UpdateDimSet(var PurchHeader: Record "Purchase Header";var TempDimSetEntry: Record "Dimension Set Entry" temporary; DimCode: Code[20]; DimValueCode: Code[20])
    begin
        if DimCode = '' then
            exit;
        if TempDimSetEntry.Get(PurchHeader."Dimension Set ID", DimCode) then
            TempDimSetEntry.Delete;
        if DimValueCode <> '' then begin
            DimVal.Get(DimCode, DimValueCode);
            TempDimSetEntry.Init;
            TempDimSetEntry."Dimension Set ID" := PurchHeader."Dimension Set ID";
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
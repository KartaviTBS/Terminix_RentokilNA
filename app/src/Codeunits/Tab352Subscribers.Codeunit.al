codeunit 50060 "ARC Table 352 Subscribers"
{
    trigger OnRun();
    begin
    end;

    [EventSubscriber(ObjectType::Table, 352, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertDefaultDim(var Rec: Record "Default Dimension"; RunTrigger: Boolean);
    var
        Salesperson: Record "Salesperson/Purchaser";
    begin
        if(Rec."Table ID" = Database::"Salesperson/Purchaser") and
           (Salesperson.GET(Rec."No.")) then
            UpdateSalespersonDimension(Salesperson, Rec, 'Insert');
    end;

    [EventSubscriber(ObjectType::Table, 352, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteDefaultDim(var Rec: Record "Default Dimension"; RunTrigger: Boolean);
    var
        Salesperson: Record "Salesperson/Purchaser";
    begin
        if(Rec."Table ID" = Database::"Salesperson/Purchaser") and
           (Salesperson.GET(Rec."No.")) then
            UpdateSalespersonDimension(Salesperson, Rec, 'Delete');
    end;

    [EventSubscriber(ObjectType::Table, 352, 'OnAfterValidateEvent', 'Dimension Value Code', false, false)]
    local procedure OnAfterValidateDimValue(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; CurrFieldNo: Integer);
    var
        Salesperson: Record "Salesperson/Purchaser";
    begin
        if(Rec."Table ID" = Database::"Salesperson/Purchaser") and
           (Salesperson.GET(Rec."No.")) then
            UpdateSalespersonDimension(Salesperson, Rec, 'Modify');
    end;

    local procedure UpdateSalespersonDimension(Salesperson: Record "Salesperson/Purchaser"; DefaultDim: Record "Default Dimension"; UpdateOption: text[10]);
    var
        RNASetup: Record "ARC RNA Setup";
    begin
        RNASetup.GET;
        if DefaultDim."Dimension Code" = RNASetup."SalesPerson Dimension 1" then begin
            if UpdateOption in ['Insert', 'Modify'] then
                Salesperson."ARC Salesperson Dimension 1" := DefaultDim."Dimension Value Code"
            else if UpdateOption in ['Delete'] then
                    Clear(Salesperson."ARC Salesperson Dimension 1");
            end else if DefaultDim."Dimension Code" = RNASetup."SalesPerson Dimension 2" then begin
                    if UpdateOption in ['Insert', 'Modify'] then
                        Salesperson."ARC Salesperson Dimension 2" := DefaultDim."Dimension Value Code"
                    else if UpdateOption in ['Delete'] then
                            Clear(Salesperson."ARC Salesperson Dimension 2");
                end else if DefaultDim."Dimension Code" = RNASetup."SalesPerson Dimension 3" then begin
                        if UpdateOption in ['Insert', 'Modify'] then
                            Salesperson."ARC Salesperson Dimension 3" := DefaultDim."Dimension Value Code"
                        else if UpdateOption in ['Delete'] then
                                Clear(Salesperson."ARC Salesperson Dimension 3");
                    end else if DefaultDim."Dimension Code" = RNASetup."SalesPerson Dimension 4" then begin
                            if UpdateOption in ['Insert', 'Modify'] then
                                Salesperson."ARC Salesperson Dimension 4" := DefaultDim."Dimension Value Code"
                            else if UpdateOption in ['Delete'] then
                                    Clear(Salesperson."ARC Salesperson Dimension 4");
                        end else if DefaultDim."Dimension Code" = RNASetup."SalesPerson Dimension 5" then begin
                                if UpdateOption in ['Insert', 'Modify'] then
                                    Salesperson."ARC Salesperson Dimension 5" := DefaultDim."Dimension Value Code"
                                else if UpdateOption in ['Delete'] then
                                        Clear(Salesperson."ARC Salesperson Dimension 5");
                            end else if DefaultDim."Dimension Code" = RNASetup."SalesPerson Dimension 6" then begin
                                    if UpdateOption in ['Insert', 'Modify'] then
                                        Salesperson."ARC Salesperson Dimension 6" := DefaultDim."Dimension Value Code"
                                    else if UpdateOption in ['Delete'] then
                                            Clear(Salesperson."ARC Salesperson Dimension 6");
                                end else if DefaultDim."Dimension Code" = RNASetup."SalesPerson Dimension 7" then begin
                                        if UpdateOption in ['Insert', 'Modify'] then
                                            Salesperson."ARC Salesperson Dimension 7" := DefaultDim."Dimension Value Code"
                                        else if UpdateOption in ['Delete'] then
                                                Clear(Salesperson."ARC Salesperson Dimension 7");
                                    end;
        SalesPerson.Modify;
    end;

}
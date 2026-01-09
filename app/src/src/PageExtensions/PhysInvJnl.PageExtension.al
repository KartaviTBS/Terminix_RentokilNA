pageextension 50083 "ARC Phys. Inv. Journal" extends "Phys. Inventory Journal"
{
    layout
    {
    }

    actions
    {
        addafter(CalculateInventory)
        {
            action(PopDims)
            {
                ApplicationArea = All;
                Image = ChangeDimensions;
                Promoted = true;
                PromotedCategory = Process;
                Caption = 'Populate Dims.';

                trigger OnAction()
                var
                    _Location: Record Location;
                    _LineNo: Integer;
                begin
                    _LineNo := Rec."Line No.";
                    if Rec.FindSet(true) then
                        repeat
                            if Rec."Shortcut Dimension 1 Code" = '' then
                                if Rec."Location Code" <> '' then
                                    if _Location.Get(Rec."Location Code") then
                                        if _Location."Shortcut Dimension 1 Code" <> '' then begin
                                            Rec.Validate("Shortcut Dimension 1 Code",CopyStr(_Location."Shortcut Dimension 1 Code",1,MaxStrLen(Rec."Shortcut Dimension 1 Code")));
                                            Rec.Modify();
                                        end;
                        until Rec.Next() = 0;
                    if _LineNo <> 0 then begin
                        Rec.SetRange("Line No.",_LineNo);
                        if Rec.FindFirst() then;
                        Rec.SetRange("Line No.");
                    end;
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
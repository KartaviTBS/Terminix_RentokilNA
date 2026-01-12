pageextension 50085 "ARC Sales Line Details" extends "Sales Line FactBox"
{
    layout
    {
        // Add changes to page layout here
        addlast(Item)
        {
            field(ARCRankingCode;RankCode)
            {
                ApplicationArea = all;
                Caption = 'Ranking Code';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Item.Get("No.") then
            RankCode := Item."ARC Ranking Code"
        else
            Clear(RankCode);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if Item.Get("No.") then
            RankCode := Item."ARC Ranking Code"
        else
            Clear(RankCode);
    end;
    
    var
        Item : Record Item;
        RankCode: Code[20];
}
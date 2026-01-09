pageextension 50013 "ARC Item Substitutions" extends "Item Substitution Entry"
{
    layout
    {
        addafter(Interchangeable)
        {
            field("ARC Commission Ranking";"ARC Commission Ranking")
            {
                ApplicationArea = All;
            }
            
        }
    }
}
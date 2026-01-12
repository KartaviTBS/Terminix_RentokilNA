query 50044 "ARC VFM Entries"
{
    elements
    {
        dataitem(APL; "ARC VFM Entry")
        {
            DataItemTableFilter = "Entry No." = FILTER(>0);
            column(ItemNo;"Item No.")
            {
            }
            column(Desc;Description)
            {
            }
            column(SubstNo;"Substitution No.")
            {
            }
            column(SubstDesc;"Subst. Description")
            {
            }
            column(Ranking;Ranking)
            {
            }
            column(Uom;"Unit of Measure Code")
            {
            }
            column(CostPerAppln; "Cost per Application")
            {
            }
            column(ApplnsPerUom; "Applications per UOM")
            {
            }
            dataitem(Item; Item)
            {
                DataItemLink = "No." = APL."Item No.";
                column(BaseUom;"Base Unit of Measure")
                {
                }
                column(SalesUom;"Sales Unit of Measure")
                {
                }
                column(PurchUom;"Purch. Unit of Measure")
                {
                }
            }
        }
    }
    
    var
        myInt : Integer;

    trigger OnBeforeOpen();
    begin
    end;
}
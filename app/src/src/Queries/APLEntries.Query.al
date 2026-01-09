query 50042 "ARC APL Entries"
{
    elements
    {
        dataitem(APL; "ARC APL Entry")
        {
            DataItemTableFilter = "NAV Processed" = CONST(1);
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
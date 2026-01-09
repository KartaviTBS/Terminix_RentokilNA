codeunit 50007 "ARC Delete Contract Prices"
{
    trigger OnRun();
    begin
        DeleteContractPrices();
    end;
    
    
    local procedure DeleteContractPrices();
    var
        PriceEntry: Record "ARC Price Entry";
        RNASetup: Record "ARC RNA Setup";
        ExpireDate: Date;
    begin
        PriceEntry.Reset;
        PriceEntry.SetCurrentKey("Delete Entry");
        PriceEntry.SetRange("Delete Entry",true);
        If PriceEntry.FindSet then
            repeat
                PriceEntry.Delete(true);
            until PriceEntry.Next = 0;
        RNASetup.Get;
        If format(RNASetup."Contract Price Expiry") = '' then
            exit;
        ExpireDate := CalcDate(RNASetup."Contract Price Expiry",Today);

        PriceEntry.Reset;
        PriceEntry.SetCurrentKey("Expiration Date");
        PriceEntry.SetFilter("Expiration Date",'<%1',ExpireDate);
        If PriceEntry.FindSet then
            repeat
                PriceEntry.Delete(true);
            until PriceEntry.Next = 0;        
    end;


}
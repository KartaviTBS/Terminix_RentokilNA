codeunit 50028 "ARC Table 302 Subscribers"
{
    trigger OnRun();
    begin
    end;

  
    [EventSubscriber(ObjectType::Table, 302, 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure OnAfterValidateDimValue(var Rec: Record "Finance Charge Memo Header"; var xRec: Record "Finance Charge Memo Header"; CurrFieldNo: Integer);
    var
        Location: Record Location;
        RNASetup: Record "ARC RNA Setup";
        Customer: Record Customer;
    begin
        If Customer.Get(Rec."Customer No.") then begin 
            If Customer."Location Code" <> '' then begin 
                Location.Get(Customer."Location Code");
                Rec.Validate("Shortcut Dimension 1 Code",Location."Shortcut Dimension 1 Code");
            end;
            RNASetup.Get;
            If RNASetup."Default Fin. Charge Funct Code" <> '' then begin 
                Rec.Validate("Shortcut Dimension 2 Code",RNASetup."Default Fin. Charge Funct Code");
            end;
        end; 
        
            
    end;
}
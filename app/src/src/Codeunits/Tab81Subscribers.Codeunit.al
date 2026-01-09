codeunit 50052 "ARC Table 81 Subscribers"
{
    trigger OnRun();
    begin
    end;



    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'ARC Workwave Entry No.', false, false)]
    local procedure "OnAfterValidateEventWorkWaveEntryNo"(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line"; CurrFieldNo: Integer)
    var
        WorkWaveEntry: Record "ARC Workwave Entry";
        DimMgt: Codeunit DimensionManagement;
        Cust: Record Customer;
        GenJnlTemplate: Record "Gen. Journal Template";
        ICPartner: Record "IC Partner";
        BankAcc2: Record "Bank Account";
    begin
        if(Rec."ARC WorkWave Entry No." <> xRec."ARC WorkWave Entry No.") then begin
            WorkWaveEntry.Get(Rec."ARC WorkWave Entry No.");
            Rec."Account Type" := Rec."Account Type"::Customer;
            Rec."Account No." := WorkWaveEntry."Bill-to Customer No.";
            if Rec."Account No." = '' then begin
                Rec.UpdateLineBalance;
                Rec.UpdateSource;
                Rec.CreateDim(
                DimMgt.TypeToTableID1(Rec."Account Type"), Rec."Account No.",
                DimMgt.TypeToTableID1(Rec."Bal. Account Type"), Rec."Bal. Account No.",
                DATABASE::Job, Rec."Job No.",
                DATABASE::"Salesperson/Purchaser", Rec."Salespers./Purch. Code",
                DATABASE::Campaign, Rec."Campaign No.");
                if xRec."Account No." <> '' then begin
                    Rec."Gen. Posting Type" := Rec."Gen. Posting Type"::" ";
                    Rec."Gen. Bus. Posting Group" := '';
                    Rec."Gen. Prod. Posting Group" := '';
                    Rec."VAT Bus. Posting Group" := '';
                    Rec."VAT Prod. Posting Group" := '';
                    Rec."Tax Area Code" := '';
                    Rec."Tax Liable" := FALSE;
                    Rec."Tax Group Code" := '';
                END;
            end else begin
                Rec."IC Partner Code" := '';
                Cust.Get(Rec."Account No.");
                if(Cust."IC Partner Code" <> '') then begin
                    if GenJnlTemplate.GET(Rec."Journal Template Name") then;
                    if(Cust."IC Partner Code" <> '') AND(ICPartner.GET(Cust."IC Partner Code")) then begin
                        ICPartner.CheckICPartnerIndirect(FORMAT(Rec."Account Type"), Rec."Account No.");
                        Rec."IC Partner Code" := Cust."IC Partner Code";
                    end;
                end;
                Rec.Description := Cust.Name;
                Rec."Posting Group" := Cust."Customer Posting Group";
                Rec."Salespers./Purch. Code" := Cust."Salesperson Code";
                Rec."Payment Terms Code" := Cust."Payment Terms Code";
                Rec.Validate("Bill-to/Pay-to No.", Rec."Account No.");
                Rec.Validate("Sell-to/Buy-from No.", Rec."Account No.");
                Rec."Currency Code" := '';
                if Rec."Bal. Account No." <> '' then
                    if Rec."Bal. Account Type" = Rec."Bal. Account Type"::"Bank Account" then
                        if BankAcc2.GET(Rec."Bal. Account No.") then
                            Rec."Currency Code" := BankAcc2."Currency Code";
                if Rec."Currency Code" <> '' then
                    Cust.TestField("Currency Code", Rec."Currency Code")
                else
                    Rec."Currency Code" := Cust."Currency Code";
                Rec."Gen. Posting Type" := 0;
                Rec."Gen. Bus. Posting Group" := '';
                Rec."Gen. Prod. Posting Group" := '';
                Rec."VAT Bus. Posting Group" := '';
                Rec."VAT Prod. Posting Group" := '';
                Rec.Validate("Payment Terms Code");
                Rec.Validate("Currency Code");
                Rec.Validate("VAT Prod. Posting Group");
                Rec.UpdateLineBalance;
                Rec.UpdateSource;
                Rec.CreateDim(
                DimMgt.TypeToTableID1(Rec."Account Type"), Rec."Account No.",
                DimMgt.TypeToTableID1(Rec."Bal. Account Type"), Rec."Bal. Account No.",
                    DATABASE::Job, Rec."Job No.",
                    DATABASE::"Salesperson/Purchaser", Rec."Salespers./Purch. Code",
                    DATABASE::Campaign, Rec."Campaign No.");

            end;

            Rec.Validate(Description, STRSUBSTNO('%1 %2 - %3', WorkWaveEntry."Transaction Type",
                                                        WorkWaveEntry."Transaction Status",
                                                        WorkWaveEntry."Bill-to Customer No."));
            Rec."Document Type" := Rec."Document Type"::Payment;
            IF WorkWaveEntry."Amount Captured" <> 0 THEN
                Rec.Validate(Amount, -WorkWaveEntry."Amount Captured");
        end;

    end;



    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Applies-to Doc. No.', false, false)]
    local procedure "OnAfterValidateEvent_AppliestoDocNo"  ( var Rec: Record "Gen. Journal Line";  var xRec: Record "Gen. Journal Line";  CurrFieldNo: Integer)
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if Rec."Document Type" <> Rec."Document Type"::Payment then 
            exit;
        if (Rec."Applies-to Doc. No." <> xRec."Applies-to Doc. No.") and (Rec."Applies-to Doc. No." <> '') then begin
            if Rec."Applies-to Doc. Type" = Rec."Applies-to Doc. Type"::Invoice then begin 
                IF SalesInvHeader.GET(Rec."Applies-to Doc. No.") then begin 
                    Rec.Validate("Dimension Set ID",SalesInvHeader."Dimension Set ID")
                end;
            end;
            if Rec."Applies-to Doc. Type" = Rec."Applies-to Doc. Type"::"Credit Memo" then begin 
                IF SalesCrMemoHeader.GET(Rec."Applies-to Doc. No.") then begin 
                    Rec.Validate("Dimension Set ID",SalesCrMemoHeader."Dimension Set ID")
                end;
            end;

        end;

    end;



    var
        myInt: Integer;
}
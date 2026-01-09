codeunit 50049 "ARC Workwave Management"
{
    trigger OnRun();
    begin
    end;

    procedure MakePaymentOnBeforeSalesPost(var SalesHeader: Record "Sales Header");
    var
        WorkWaveEntry: Record "ARC Workwave Entry";
        WorkWaveSetup: Record "ARC Workwave Setup";
        ShipAmt: Decimal;
        SourceDocMgt: Codeunit "ARC Source Doc Mgt.";
        diffAmt: Decimal;
        chargeAmt: Decimal;
        OutStdAmt: Decimal;
        BackOrder: Boolean;
        BackOrderAmt: Decimal;
        Status: Text;
    begin
        If SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then 
            exit;
        if not SalesHeader."ARC Workwave Order" then 
            exit;
        if SalesHeader."ARC ACH Order" then 
            exit;
        SalesHeader.CalcFields("ARC WW Amount Authorized","ARC WW Amount Charged","ARC WW Amount Charge Settled","ARC WW Amount Charged Open");    
        ShipAmt := SourceDocMgt.GetSalesAmounts(SalesHeader,2); 
        OutStdAmt := SourceDocMgt.GetSalesAmounts(SalesHeader,0);
        If ShipAmt < OutStdAmt then begin 
            BackOrderAmt := OutStdAmt - ShipAmt;
            BackOrder := true;
        end;
        
        If (SalesHeader."ARC WW Amount Charged" >= ShipAmt) or (SalesHeader."ARC WW Amount Charged Open" >= ShipAmt) then 
            exit;
        WorkWaveSetup.Get;
        WorkWaveEntry.Reset;
        WorkWaveEntry.SetRange("Sales Order No.",SalesHeader."No.");
        WorkWaveEntry.SetRange("Transaction Type",'Authorization');
        WorkWaveEntry.SetRange("Transaction Status",'Authorized');
        WorkWaveEntry.SetRange(Status,WorkWaveEntry.Status::Open);   
        if not WorkWaveEntry.FindFirst then begin
            if not SalesHeader."ARC Allow Ship & Invoice" then
                Error(Text002);
        end else begin 
           if ShipAmt > WorkWaveEntry.Amount then begin
                diffAmt := ShipAmt - WorkWaveEntry.Amount;
                chargeAmt := WorkWaveEntry.Amount;
           end else
            chargeAmt := ShipAmt;   
           Status := ChargeTransaction(SalesHeader."No.",WorkWaveEntry."Transaction ID",chargeAmt,WorkWaveEntry."Entry No.");
           if Status = 'Approved' then begin 
               WorkWaveEntry.Status := WorkWaveEntry.Status::Used;
               WorkWaveEntry."Updated On" := CurrentDateTime;
               WorkWaveEntry.Modify;
               if (WorkWaveSetup."Auth/Charge Diff Amount") and (diffAmt > 0) then begin 
                   Status := AuthorizeTransaction(SalesHeader."No.",WorkWaveEntry."Payment Acct Token",diffAmt,SalesHeader."No.");
                   if Status = 'Authorized' then begin
                        Status := ChargeTransaction(SalesHeader."No.",AuthWorkWaveEntry."Transaction ID",AuthWorkWaveEntry.Amount,AuthWorkWaveEntry."Entry No.");
                        if Status = 'Approved' then begin 
                            AuthWorkWaveEntry.Status := WorkWaveEntry.Status::Used;
                            AuthWorkWaveEntry."Updated On" := CurrentDateTime;
                            AuthWorkWaveEntry.Modify;
                            Commit;
                        end else
                            Error(Text010,Status)
                    end else 
                        Error(Text010,Status)
               end;
               if (BackOrder) and (WorkWaveSetup."Reauth. On Partial Inv.") then begin 
                   if AuthorizeTransaction(SalesHeader."No.",WorkWaveEntry."Payment Acct Token",BackOrderAmt,SalesHeader."No.") <> 'Authorized' then
                        Message(Text009);
               end;
               Commit;
           end else
              Error(CardNotCharged);   
        end;
        
    end;

    procedure UpdatePaymentOnSalesOrder(var SalesHeader: Record "Sales Header"; SalesInvHdrNo: Code[20])
    var
        WorkWaveEntry: Record "ARC Workwave Entry";
        WorkWaveEntry2: Record "ARC Workwave Entry";
        WorkWaveSetup: Record "ARC Workwave Setup";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalLine2: Record "Gen. Journal Line";
        LastGenJournalLine: Record "Gen. Journal Line";
        ActTypeJnlBatch: Record "ARC WW Acct. Type GenJnl Batch";
        ShipAmt: Decimal;
        SourceDocMgt: Codeunit "ARC Source Doc Mgt.";
        LineNo : Integer;
        diffAmt: Decimal;
        chargeAmt: Decimal;
    begin
        if not SalesHeader."ARC Workwave Order" then 
            exit;
          
        WorkWaveSetup.Get;
        WorkWaveEntry.Reset;
        WorkWaveEntry.SetRange("Sales Order No.",SalesHeader."No.");
        WorkWaveEntry.SetRange("Transaction Type",'Authorization');
        WorkWaveEntry.SetRange("Transaction Status",'Approved');
        WorkWaveEntry.SetRange(Status,WorkWaveEntry.Status::Open);   
        if WorkWaveEntry.FindFirst then begin 
            case WorkWaveEntry."Card Type" of
                'Visa': ActTypeJnlBatch.Get(ActTypeJnlBatch."Account Type"::Visa);
                'Mastercard': ActTypeJnlBatch.Get(ActTypeJnlBatch."Account Type"::MasterCard);
                'AmericanExpress': ActTypeJnlBatch.Get(ActTypeJnlBatch."Account Type"::"American Express");
                'Discover':ActTypeJnlBatch.Get(ActTypeJnlBatch."Account Type"::Discover);
                'DinersClub':ActTypeJnlBatch.Get(ActTypeJnlBatch."Account Type"::"Diner's Club");
                'Jcb': ActTypeJnlBatch.Get(ActTypeJnlBatch."Account Type"::"JCB Card");
            end;
            LastGenJournalLine.Reset;
            LastGenJournalLine.SetRange("Journal Template Name", ActTypeJnlBatch."Gen. Journal Template");
            LastGenJournalLine.SetRange("Journal Batch Name", ActTypeJnlBatch."Gen. Journal Batch");
            if LastGenJournalLine.FindLast then
                LineNo := Round(LastGenJournalLine."Line No." + 1, 10000, '>')
            else
                LineNo := 10000;  
            repeat
                GenJournalLine.Reset;
                GenJournalLine.SetRange("Journal Template Name", ActTypeJnlBatch."Gen. Journal Template");
                GenJournalLine.SetRange("Journal Batch Name", ActTypeJnlBatch."Temp Gen. Journal Batch");
                GenJournalLine.SetRange("ARC WorkWave Entry No.",WorkWaveEntry."Entry No.");
                if GenJournalLine.FindSet then 
                    repeat
                      GenJournalLine2 := GenJournalLine;
                      GenJournalLine2."Journal Batch Name" := ActTypeJnlBatch."Gen. Journal Batch";
                      GenJournalLine2.Validate("Applies-to Doc. Type",GenJournalLine2."Applies-to Doc. Type"::Invoice);
                      GenJournalLine2.Validate("Applies-to Doc. No.",SalesInvHdrNo);
                      GenJournalLine2."Line No." := LineNo;
                      GenJournalLine2.Insert;
                      GenJournalLine.Delete;
                      LineNo += 10000;
                    until GenJournalLine.Next = 0;
                WorkWaveEntry2.Get(WorkWaveEntry."Entry No.");
                WorkWaveEntry2.Status := WorkWaveEntry2.Status::Batched;
                WorkWaveEntry2.Modify;    
            until WorkWaveEntry.Next = 0;    
        end;
    end;
    
    procedure GetTransaction(TransID: Text): Text;
    var
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        TempBlob: Record TempBlob;
        WorkWaveSetup: Record "ARC Workwave Setup";
        ResponseStream: InStream;
        ResponseText: Text;
        ChunkText: Text;
    begin
        WorkWaveSetup.Get;
        WorkWaveSetup.TestField("Transactions Url");
        TempBlob.Init;
        TempBlob.Blob.CreateInStream(ResponseStream);
        HttpWebRequestMgt.Initialize(StrSubstNo(WorkWaveSetup."Transactions Url",TransID));
        HttpWebRequestMgt.DisableUI;
        HttpWebRequestMgt.SetReturnType('application/json');
        HttpWebRequestMgt.AddHeader('Accept-Encoding','utf-8');
        HttpWebRequestMgt.AddHeader('Authorization',GetBasicAuth(WorkWaveSetup."User Name",WorkWaveSetup.Password));
        HttpWebRequestMgt.AddHeader('apiKey',WorkWaveSetup."Api Key");
        HttpWebRequestMgt.SetMethod('GET');
        If not HttpWebRequestMgt.GetResponseStream(ResponseStream) then 
            Error('Process Failed');
        while not ResponseStream.EOS do begin
            ResponseStream.ReadText(ChunkText);
            ResponseText += ChunkText;
        end;    
        RetrieveResponse('',ResponseText,0);
    end;


    procedure RetrieveSettleTran(WorkWaveEntry: Record "ARC Workwave Entry"): Text;
    var
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        TempBlob: Record TempBlob;
        WorkWaveSetup: Record "ARC Workwave Setup";
        ResponseStream: InStream;
        ResponseText: Text;
        ChunkText: Text;
    begin
        WorkWaveSetup.Get;
        WorkWaveSetup.TestField("Transactions Url");
        TempBlob.Init;
        TempBlob.Blob.CreateInStream(ResponseStream);
        HttpWebRequestMgt.Initialize(StrSubstNo(WorkWaveSetup."Transactions Url",WorkWaveEntry."Transaction ID"));
        HttpWebRequestMgt.DisableUI;
        HttpWebRequestMgt.SetReturnType('application/json');
        HttpWebRequestMgt.AddHeader('Accept-Encoding','utf-8');
        HttpWebRequestMgt.AddHeader('Authorization',GetBasicAuth(WorkWaveSetup."User Name",WorkWaveSetup.Password));
        HttpWebRequestMgt.AddHeader('apiKey',WorkWaveSetup."Api Key");
        HttpWebRequestMgt.SetMethod('GET');
        If not HttpWebRequestMgt.GetResponseStream(ResponseStream) then 
            Error('Process Failed');
        while not ResponseStream.EOS do begin
            ResponseStream.ReadText(ChunkText);
            ResponseText += ChunkText;
        end;    
        RetrieveResponse(WorkWaveEntry."Sales Order No.",ResponseText,0);
    end;

    procedure ChargeTransaction(OrderNo: Code[20]; TransID: Text; Amt: Decimal; AuthEntryNo: Integer) : Text;
    var
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        TempBlob: Record TempBlob;
        ResponseStream: InStream;
        ResponseText: Text;
        ChunkText: Text;
        WorkWaveSetup: Record "ARC Workwave Setup";
        WorkWaveJnlMgt: Codeunit "ARC WorkWave Gen. Jnl Mgt.";
    begin
        WorkWaveSetup.Get;
        WorkWaveSetup.TestField("Capture Url");
        OpenWindow('Charge');
        TempBlob.Init;
        TempBlob.Blob.CreateInStream(ResponseStream);
        HttpWebRequestMgt.Initialize(StrSubstNo(WorkWaveSetup."Capture Url",TransID,Amt,'true'));
        HttpWebRequestMgt.DisableUI;
        HttpWebRequestMgt.SetReturnType('application/json');
        HttpWebRequestMgt.AddHeader('Accept-Encoding','utf-8');
        HttpWebRequestMgt.AddHeader('Authorization',GetBasicAuth(WorkWaveSetup."User Name",WorkWaveSetup.Password));
        HttpWebRequestMgt.AddHeader('apiKey',WorkWaveSetup."Api Key");
        HttpWebRequestMgt.SetMethod('POST');
        HttpWebRequestMgt.SetContentLength(0);
        If not HttpWebRequestMgt.GetResponseStream(ResponseStream) then begin
            HttpWebRequestMgt.ProcessFaultResponse('');
            exit('');
        end;    
        while not ResponseStream.EOS do begin
           ResponseStream.ReadText(ChunkText);
           ResponseText += ChunkText;
        end;    
        exit(RetrieveResponse(OrderNo,ResponseText,AuthEntryNo)); 

        CloseWindow();
    end;

    procedure AuthorizeTransaction(OrderNo: Code[20]; token: Text; Amt: Decimal;SalesOrderNo: Code[20]) : Text;
    var
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        TempBlob: Record TempBlob;
        ResponseStream: InStream;
        ResponseText: Text;
        ChunkText: Text;
        WorkWaveSetup: Record "ARC Workwave Setup";
        
    begin
        WorkWaveSetup.Get;
        WorkWaveSetup.TestField("Authorize Url");
        OpenWindow('Authorize');
        TempBlob.Init;
        TempBlob.Blob.CreateInStream(ResponseStream);
        HttpWebRequestMgt.Initialize(StrSubstNo(WorkWaveSetup."Authorize Url",token,Amt,OrderNo,'true'));
        HttpWebRequestMgt.DisableUI;
        HttpWebRequestMgt.SetReturnType('application/json');
        HttpWebRequestMgt.AddHeader('Accept-Encoding','utf-8');
        HttpWebRequestMgt.AddHeader('Authorization',GetBasicAuth(WorkWaveSetup."User Name",WorkWaveSetup.Password));
        HttpWebRequestMgt.AddHeader('apiKey',WorkWaveSetup."Api Key");
        HttpWebRequestMgt.SetMethod('POST');
        HttpWebRequestMgt.SetContentLength(0);
        If not HttpWebRequestMgt.GetResponseStream(ResponseStream) then begin
            HttpWebRequestMgt.ProcessFaultResponse('');
            exit('');
        end;    
        while not ResponseStream.EOS do begin
           ResponseStream.ReadText(ChunkText);
           ResponseText += ChunkText;
        end;    
        exit(RetrieveResponse(OrderNo,ResponseText,0));
        CloseWindow();
    end;


    local procedure RetrieveResponse(OrderNo: Code[20];JsonText:Text; RelatedEntryNo: Integer): Text;
    var
        JSONMgt : Codeunit "JSON Management";
        WorkWaveEntry: Record "ARC Workwave Entry";
        SalesHeader: Record "Sales Header";
        WorkWaveJnlMgt: Codeunit "ARC WorkWave Gen. Jnl Mgt.";
        ActTypeJnlBatch: Record "ARC WW Acct. Type GenJnl Batch";
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order,OrderNo);
        JSONMgt.InitializeObject(JsonText);
        WorkWaveEntry.Init;
        WorkWaveEntry."Entry No." := 0;
        WorkWaveEntry."Transaction ID" := JSONMgt.GetValue('transactionId');
        if Evaluate(WorkWaveEntry.Amount,JSONMgt.GetValue('amount')) then;
        WorkWaveEntry."Transaction Status" := JSONMgt.GetValue('transactionStatus');
        WorkWaveEntry."Transaction Type" := JSONMgt.GetValue('transactionType');
        WorkWaveEntry."Payment Acct Type" := JSONMgt.GetValue('paymentAccountType');
        WorkWaveEntry."Card Type" := JSONMgt.GetValue('cardType');
        WorkWaveEntry."Masked Card No." := JSONMgt.GetValue('maskedCardNumber');
        if Evaluate(WorkWaveEntry."Amount Captured",JSONMgt.GetValue('amountCaptured')) then;
        WorkWaveEntry."Approval No." := JSONMgt.GetValue('approvalNumber');
        WorkWaveEntry."Payment Acct Token" := JSONMgt.GetValue('paymentAccountToken');
        WorkWaveEntry."Employee ID":= JSONMgt.GetValue('idempotencyId');
        WorkWaveEntry."Billing Address" := JSONMgt.GetValue('billingAddress');
        WorkWaveEntry."Billing PostCode" := JSONMgt.GetValue('billingPostalCode');
        WorkWaveEntry.Reference := JsonMgt.GetValue('reference');
        WorkWaveEntry."Payment Acct Reference":= JsonMgt.GetValue('paymentAccountReference');
        WorkWaveEntry."Sales Order No." := OrderNo;
        WorkWaveEntry."Created On" := CurrentDateTime;
        WorkWaveEntry."Related Entry No." := RelatedEntryNo;
        WorkWaveEntry."Sell-to Customer No." := SalesHeader."Sell-to Customer No.";
        WorkWaveEntry."Bill-to Customer No." := SalesHeader."Bill-to Customer No.";
        if WorkWaveEntry."Transaction ID" <> '' then begin
            WorkWaveEntry.Insert(true);
            Commit;
        end;     
        if WorkWaveEntry."Transaction Status" = 'Authorized' then 
            AuthWorkWaveEntry := WorkWaveEntry;
        if (WorkWaveEntry."Transaction Status" = 'Approved') or (WorkWaveEntry."Transaction Status" = 'Settled') then begin
            WorkWaveJnlMgt.SuggestCashRcptJnl(WorkWaveEntry);
        end;    

        exit(WorkWaveEntry."Transaction Status");
    end;

    
    procedure GetBasicAuth(Username:Text; Password:Text): Text
    var
        TempBlob : Record TempBlob;
    begin
        TempBlob.WriteAsText(StrSubstNo('%1:%2',Username,Password),TextEncoding::UTF8);
        exit(StrSubstNo('Basic %1', TempBlob.ToBase64String()));
    end;

    procedure OpenWindow(MethodName: Text);
    begin
        ShowDialog := (GuiAllowed) and (not HideDialog);
        if ShowDialog then Window.Open(Text003 + '\' + Text004);
        if ShowDialog then Window.Update(1, MethodName);
        if showDialog then Window.Update(2,1);
        if showDialog then Window.Update(3,1);
    end;

    procedure CloseWindow();
    var
        myInt : Integer;
    begin
        if ShowDialog then Window.Close;
    end;

    procedure setHideDialog();
    begin
        hideDialog := true;
    end;

    var
        AuthWorkWaveEntry: Record "ARC Workwave Entry";
        showDialog: Boolean;
        hideDialog: Boolean;
        Window: Dialog;
        Text001: Label 'There are no approved authorizations, do you want to authorize and charge?';  
        Text002: Label 'Please contact workwave adminstrator, you cannot ship without approval';  
        CardNotCharged: Label 'Credit card payment is not successful, please contact administrator';
        Text003: Label 'Method Name  #1################\';
        Text004: Label 'Attempt      #2###### \Max. Attempts#3######\';
        Text006: Label 'HTTP Error %1 (%2)';
        Text008: Label '%3\%1 %2\\There was a problem processing a %4 for the following reason:\%5.';
        Text009: Label 'Authorization failed on BackOrder. Please contact workwave administrator.';
        Text010: Label 'Credit card transaction is %1, please contact workwave administrator';
        

}
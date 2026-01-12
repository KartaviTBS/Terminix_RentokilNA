codeunit 50058 "ARC Workwave ACH Management"
{
    Permissions = tabledata "ARC Workwave Entry" = im, tabledata "ARC Event Log Entry" = i;

    trigger OnRun();
    begin
        Initialize();
        if EntryNoToProcess <> 0 then begin
            ProcessEntry();
            exit;
        end;
        ProcessEntries();
    end;

    procedure MarkWorkwaveEntryToProcess(_SalesInvNo: Code[20])
    var
        _SalesInvHeader: Record "Sales Invoice Header";
        _WorkwaveEntry: Record "ARC Workwave Entry";
        _Text000Err: Label 'Method MarkWorkwaveEntryToProcess(): SalesInv %1, ACH %2, entry not found using filters: %3';
        _Text001Err: Label 'Method MarkWorkwaveEntryToProcess(): unable to retrieve posted sales invoice %1';
    begin
        if _SalesInvNo = '' then
            exit;
        if not _SalesInvHeader.Get(_SalesInvNo) then begin
            WriteToLog(_WorkwaveEntry."Entry No.",'',StrSubstNo(_Text001Err,_SalesInvNo));
            exit;
        end;
        if not _SalesInvHeader."ARC ACH Order" then
            exit;
        _SalesInvHeader.CalcFields("Amount Including VAT");
        _WorkwaveEntry.LockTable();
        _WorkwaveEntry.SetCurrentKey(Process,Processed);
        _WorkwaveEntry.SetRange(Process,false);
        _WorkwaveEntry.SetRange(Processed,0);
        _WorkwaveEntry.SetRange("Sales Order No.",_SalesInvHeader."Order No.");
        _WorkwaveEntry.SetRange("Transaction Type",'Authorization');
        _WorkwaveEntry.SetRange("Transaction Status",'Authorized');
        _WorkwaveEntry.SetRange(Status,_WorkWaveEntry.Status::Open);
        if _WorkwaveEntry.FindFirst() then begin
            _WorkwaveEntry.Process := true;
            _WorkwaveEntry."Sales Invoice No." := CopyStr(_SalesInvNo,1,MaxStrLen(_WorkwaveEntry."Sales Invoice No."));
            _WorkwaveEntry."Sales Invoice Amount" := _SalesInvHeader."Amount Including VAT";
            _WorkwaveEntry.Modify();
        end else begin
            WriteToLog(_WorkwaveEntry."Entry No.",'',StrSubstNo(_Text000Err,_SalesInvNo,_SalesInvHeader."ARC ACH Order",
                _WorkwaveEntry.GetFilters()));
        end;
    end;

    procedure TransferACHTransaction(_WorkwaveEntry: Record "ARC Workwave Entry")
    var
        _SalesInvHeader: Record "Sales Invoice Header";
        TempBlob: Record TempBlob;
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        WorkWaveMgt: Codeunit "ARC Workwave Management";
        _amt: Decimal;
        ResponseStream: InStream;
        paymentToken: Text;
        ResponseText: Text;
        ChunkText: Text;
        Url: Text;
        _Text000Msg: Label 'Method TransferACHTransaction(): %1: %2 %3';
        _Text001Err: Label 'Method TransferACHTransaction(): HttpWebRequestMgt.GetResponseStream() was not successful for %1 %2 token %3';
    begin
        WorkWaveSetup.Get;
        WorkWaveSetup.TestField("ACH Transfer Url");
        _WorkwaveEntry.TestField("Payment Acct Token");
        paymentToken := CopyStr(_WorkwaveEntry."Payment Acct Token",1,MaxStrLen(paymentToken));
        _SalesInvHeader.SetCurrentKey("Order No.");
        _SalesInvHeader.SetRange("Order No.",_WorkwaveEntry."Sales Order No.");
        _SalesInvHeader.SetAutoCalcFields("Amount Including VAT");
        if _SalesInvHeader.FindSet(false) then
            repeat
                if SalesInvHeaderNo = '' then
                    SalesInvHeaderNo := CopyStr(_SalesInvHeader."No.",1,MaxStrLen(SalesInvHeaderNo));
                OutbDataContent.AddText(StrSubstNo(_Text000Msg,Format(CurrentDateTime()),_SalesInvHeader."No.",_SalesInvHeader."Amount Including VAT"));
                if _SalesInvHeader."Amount Including VAT" > _amt then begin
                    _amt := _SalesInvHeader."Amount Including VAT";
                    SalesInvHeaderNo := CopyStr(_SalesInvHeader."No.",1,MaxStrLen(SalesInvHeaderNo));
                end;
            until _SalesInvHeader.Next() = 0;
        if _WorkwaveEntry.Amount > _amt then
            _amt := _WorkwaveEntry.Amount;
        OutbDataContent.AddText(StrSubstNo(_Text000Msg,Format(CurrentDateTime()),'final selection of amount',Format(_amt)));
        TempBlob.Init;
        TempBlob.Blob.CreateInStream(ResponseStream);
        OutbDataContent.AddText(StrSubstNo(_Text000Msg,Format(CurrentDateTime()),'Url (setup)',WorkWaveSetup."ACH Transfer Url") + CRLF);
        Url := CopyStr(StrSubstNo(WorkWaveSetup."ACH Transfer Url",paymentToken,_amt,_WorkwaveEntry."Sales Order No.",'true'),1,MaxStrLen(Url));
        OutbDataContent.AddText(StrSubstNo(_Text000Msg,Format(CurrentDateTime()),'Url (formatted)',Url) + CRLF);
        HttpWebRequestMgt.Initialize(Url);
        HttpWebRequestMgt.DisableUI;
        HttpWebRequestMgt.SetReturnType('application/json');
        HttpWebRequestMgt.AddHeader('Accept-Encoding','utf-8');
        HttpWebRequestMgt.AddHeader('Authorization',WorkWaveMgt.GetBasicAuth(WorkWaveSetup."User Name",WorkWaveSetup.Password));
        HttpWebRequestMgt.AddHeader('apiKey',WorkWaveSetup."Api Key");
        HttpWebRequestMgt.SetMethod('POST');
        HttpWebRequestMgt.SetContentLength(0);
        If not HttpWebRequestMgt.GetResponseStream(ResponseStream) then begin
            InbDataContent.AddText(CRLF + StrSubstNo(_Text001Err,_WorkwaveEntry.TableCaption(),_WorkwaveEntry."Entry No.",_WorkwaveEntry."Payment Acct Token") + CRLF);
            HttpWebRequestMgt.ProcessFaultResponse('');
            exit;
        end;
        InbDataContent.AddText(CRLF + StrSubstNo(_Text000Msg,Format(CurrentDateTime()),'beginResponse','****************') + CRLF);
        while not ResponseStream.EOS do begin
           ResponseStream.ReadText(ChunkText);
           ResponseText += ChunkText;
           InbDataContent.AddText(ChunkText);
        end;
        InbDataContent.AddText(CRLF + StrSubstNo(_Text000Msg,Format(CurrentDateTime()),'endResponse','****************') + CRLF);
        CreateACHWorkWaveEntry(_WorkwaveEntry,ResponseText);
    end;

    local procedure CreateACHWorkWaveEntry(_oldWorkwaveEntry: Record "ARC Workwave Entry"; JsonText:Text)
    var
        JSONMgt : Codeunit "JSON Management";
        _newWorkWaveEntry: Record "ARC Workwave Entry";
        SalesInvHeader: Record "Sales Invoice Header";
        WorkWaveJnlMgt: Codeunit "ARC WorkWave Gen. Jnl Mgt.";
        ActTypeJnlBatch: Record "ARC WW Acct. Type GenJnl Batch";
        AuthWorkWaveEntry: Record "ARC Workwave Entry";
        _Text000Msg: Label 'Method CreateACHWorkWaveEntry(): %1: %2 %3';
    begin
        InbDataContent.AddText(CRLF + StrSubstNo(_Text000Msg,Format(CurrentDateTime()),'begin','') + CRLF);
        if not SalesInvHeader.Get(_oldWorkwaveEntry."Sales Invoice No.") then
            if not SalesInvHeader.Get(SalesInvHeaderNo) then begin
                SalesInvHeader.SetCurrentKey("Order No.");
                SalesInvHeader.SetRange("Order No.",_oldWorkwaveEntry."Sales Order No.");
                if not SalesInvHeader.FindFirst() then begin
                    OutbDataContent.AddText(StrSubstNo(_Text000Msg,Format(CurrentDateTime()),'unable to locate posted sales invoice using order no.',_oldWorkwaveEntry."Sales Order No."));
                    Clear(SalesInvHeader);
                end;
            end;
        JSONMgt.InitializeObject(JsonText);
        _newWorkWaveEntry.Init;
        _newWorkWaveEntry."Entry No." := 0;
        _newWorkWaveEntry."Transaction ID" := JSONMgt.GetValue('transactionId');
        if Evaluate(_newWorkWaveEntry.Amount,JSONMgt.GetValue('amount')) then;
        _newWorkWaveEntry."Transaction Status" := JSONMgt.GetValue('transactionStatus');
        _newWorkWaveEntry."Transaction Type" := JSONMgt.GetValue('transactionType');
        _newWorkWaveEntry."Payment Acct Type" := JSONMgt.GetValue('paymentAccountType');
        _newWorkWaveEntry."Card Type" := JSONMgt.GetValue('cardType');
        _newWorkWaveEntry."Masked Card No." := JSONMgt.GetValue('maskedCardNumber');
        if Evaluate(_newWorkWaveEntry."Amount Captured",JSONMgt.GetValue('amountCaptured')) then;
        _newWorkWaveEntry."Approval No." := JSONMgt.GetValue('approvalNumber');
        _newWorkWaveEntry."Payment Acct Token" := JSONMgt.GetValue('paymentAccountToken');
        _newWorkWaveEntry."Employee ID":= JSONMgt.GetValue('idempotencyId');
        _newWorkWaveEntry."Billing Address" := JSONMgt.GetValue('billingAddress');
        _newWorkWaveEntry."Billing PostCode" := JSONMgt.GetValue('billingPostalCode');
        _newWorkWaveEntry.Reference := JsonMgt.GetValue('reference');
        _newWorkWaveEntry."Payment Acct Reference":= JsonMgt.GetValue('paymentAccountReference');
        _newWorkWaveEntry."Masked Routing No." := JsonMgt.GetValue('maskedRoutingNumber');
        _newWorkWaveEntry."Masked Account No." := JsonMgt.GetValue('maskedAccountNumber');
        _newWorkWaveEntry."Sales Order No." := CopyStr(_oldWorkwaveEntry."Sales Order No.",1,MaxStrLen(_newWorkWaveEntry."Sales Order No."));
        _newWorkWaveEntry."Created On" := CurrentDateTime;
        _newWorkWaveEntry."Related Entry No." := _oldWorkwaveEntry."Entry No.";
        _newWorkWaveEntry."Sell-to Customer No." := CopyStr(SalesInvHeader."Sell-to Customer No.",1,MaxStrLen(_newWorkWaveEntry."Sell-to Customer No."));
        _newWorkWaveEntry."Bill-to Customer No." := CopyStr(SalesInvHeader."Bill-to Customer No.",1,MaxStrLen(_newWorkWaveEntry."Bill-to Customer No."));
        _newWorkWaveEntry."Sales Invoice No." := CopyStr(_oldWorkwaveEntry."Sales Invoice No.",1,MaxStrLen(_newWorkWaveEntry."Sales Invoice No."));
        if _newWorkWaveEntry."Transaction ID" <> '' then
            _newWorkWaveEntry.Process := true;
        _newWorkWaveEntry.Insert(true);
        InbDataContent.AddText(CRLF + StrSubstNo(_Text000Msg,Format(CurrentDateTime()),'end','Workwave Entry record inserted') + CRLF);
    end;

    procedure GetTransactionStatus(_WorkwaveEntry: Record "ARC Workwave Entry"): Text;
    var
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        TempBlob: Record TempBlob;
        WorkWaveSetup: Record "ARC Workwave Setup";
        WorkWaveMgt: Codeunit "ARC Workwave Management";
        JSONMgt : Codeunit "JSON Management";
        ResponseStream: InStream;
        ResponseText: Text;
        ChunkText: Text;
        Url: Text;
        txStatus: Text;
        _Text000Msg: Label 'Method GetTransactionStatus(): %1: %2 %3';
        _Text001Err: Label 'Method GetTransactionStatus(): HttpWebRequestMgt.GetResponseStream() was not successful for %1 %2 token %3';
        _Text002Msg: Label 'transactionStatus: %1';
    begin
        WorkWaveSetup.Get;
        WorkWaveSetup.TestField("Transactions Url");
        TempBlob.Init;
        TempBlob.Blob.CreateInStream(ResponseStream);
        OutbDataContent.AddText(StrSubstNo(_Text000Msg,Format(CurrentDateTime()),'Url (setup)',WorkWaveSetup."Transactions Url") + CRLF);
        Url := CopyStr(StrSubstNo(WorkWaveSetup."Transactions Url",_WorkwaveEntry."Transaction ID"),1,MaxStrLen(Url));
        OutbDataContent.AddText(StrSubstNo(_Text000Msg,Format(CurrentDateTime()),'Url (formatted)',Url) + CRLF);
        HttpWebRequestMgt.Initialize(Url);
        HttpWebRequestMgt.DisableUI;
        HttpWebRequestMgt.SetReturnType('application/json');
        HttpWebRequestMgt.AddHeader('Accept-Encoding','utf-8');
        HttpWebRequestMgt.AddHeader('Authorization',WorkWaveMgt.GetBasicAuth(WorkWaveSetup."User Name",WorkWaveSetup.Password));
        HttpWebRequestMgt.AddHeader('apiKey',WorkWaveSetup."Api Key");
        HttpWebRequestMgt.SetMethod('GET');
        If not HttpWebRequestMgt.GetResponseStream(ResponseStream) then begin
            InbDataContent.AddText(CRLF + StrSubstNo(_Text001Err,_WorkwaveEntry.TableCaption(),_WorkwaveEntry."Entry No.",_WorkwaveEntry."Payment Acct Token") + CRLF);
            HttpWebRequestMgt.ProcessFaultResponse('');
            exit('Error');
        end;
        InbDataContent.AddText(CRLF + StrSubstNo(_Text000Msg,Format(CurrentDateTime()),'beginResponse','****************') + CRLF);
        while not ResponseStream.EOS do begin
            ResponseStream.ReadText(ChunkText);
            ResponseText += ChunkText;
            InbDataContent.AddText(ChunkText);
        end;
        InbDataContent.AddText(CRLF + StrSubstNo(_Text000Msg,Format(CurrentDateTime()),'endResponse','****************') + CRLF);
        JSONMgt.InitializeObject(ResponseText);
        txStatus := CopyStr(JSONMgt.GetValue('transactionStatus'),1,MaxStrLen(txStatus));
        InbDataContent.AddText(StrSubstNo(_Text002Msg,txStatus));
        exit(txStatus);
    end;

    procedure GetInbDataContent(var _InbDataContent: BigText)
    begin
        _InbDataContent := InbDataContent;
    end;

    procedure GetOutbDataContent(var _OutbDataContent: BigText)
    begin
        _OutbDataContent := OutbDataContent;
    end;

    local procedure Initialize()
    begin
      charCR := 13;
      charLF := 10;
      CRLF := FORMAT(charCR) + FORMAT(charLF);
      diagCode := CopyStr('WORKWAVE-ACH',1,MaxStrLen(diagCode));
    end;

    local procedure ProcessEntries()
    var
        _WorkwaveEntry: Record "ARC Workwave Entry";
        _WorkwaveEntry2: Record "ARC Workwave Entry";
        _DataMgt: Codeunit "ARC DataMgt";
        _WorkwaveACHMgt: Codeunit "ARC Workwave ACH Management";
        _result: Boolean;
    begin
        _WorkwaveEntry.SetCurrentKey(Process,Processed);
        _WorkwaveEntry.SetRange(Process,true);
        _WorkwaveEntry.SetRange(Processed,0);
        if _WorkwaveEntry.FindSet(false) then
            repeat
                Clear(_WorkwaveACHMgt);
                _WorkwaveACHMgt.SetEntryNoToProcess(_WorkwaveEntry."Entry No.");
                Commit();
                _result := _WorkwaveACHMgt.Run();
                if not _result then begin
                    Clear(_WorkwaveEntry2);
                    _WorkwaveEntry2.Reset();
                    _WorkwaveEntry2.LockTable();
                    _WorkwaveEntry2.Get(_WorkwaveEntry."Entry No.");
                    _WorkwaveEntry2."Processed at DateTime" := CurrentDateTime();
                    _WorkwaveEntry2."Processed No. of Attempts" := _WorkwaveEntry2."Processed No. of Attempts" + 1;
                    _WorkwaveEntry2."Processed Error Text" := CopyStr(GetLastErrorText(),1,MaxStrLen(_WorkwaveEntry2."Processed Error Text"));
                    if _WorkwaveEntry2."Processed No. of Attempts" > 1000 then
                        _WorkwaveEntry2.Processed := -1;
                    _WorkwaveACHMgt.GetInbDataContent(InbDataContent);
                    _WorkwaveACHMgt.GetOutbDataContent(OutbDataContent);
                    _WorkwaveEntry2."Transmit Data Entry No." := _DataMgt.NewDataEntry(diagCode,'outbound WorkwaveACH',OutbDataContent);
                    _WorkwaveEntry2."Receipt Data Entry No." := _DataMgt.NewDataEntry(diagCode,'inbound WorkwaveACH',InbDataContent);
                    _WorkwaveEntry2.Modify();
                    _WorkwaveEntry2.Reset();
                end;
            until _WorkwaveEntry.Next() = 0;
    end;

    local procedure ProcessEntry()
    var
        _WorkwaveEntry: Record "ARC Workwave Entry";
        _WorkwaveEntry2: Record "ARC Workwave Entry";
        _DataMgt: Codeunit "ARC DataMgt";
        _WorkwaveJnlMgt: Codeunit "ARC WorkWave Gen. Jnl Mgt.";
        _markAsProcessed: Boolean;
        _updatedDate: Date;
        _txStatus: Text;
        _Text000Err: Label 'EntryNoToProcess must not be zero.';
    begin
        if EntryNoToProcess = 0 then
            Error(_Text000Err);
        _WorkwaveEntry.Get(EntryNoToProcess);
        if _WorkwaveEntry."Transaction ID" = '' then begin
            // initial transmission to Workwave
            TransferACHTransaction(_WorkwaveEntry);
            _markAsProcessed := true;
        end else begin
            // continue petitioning Workwave for successful completion of ACH transaction
            if (not (LowerCase(_WorkwaveEntry."Transaction Status") in ['approved','settled'])) then
                _txStatus := CopyStr(GetTransactionStatus(_WorkwaveEntry),1,MaxStrLen(_txStatus));
            if (StrPos(LowerCase(_txStatus),'approved') <> 0) or (StrPos(LowerCase(_txStatus),'settled') <> 0) or
               (StrPos(LowerCase(_WorkwaveEntry."Transaction Status"),'approved') <> 0) or (StrPos(LowerCase(_WorkwaveEntry."Transaction Status"),'settled') <> 0)
            then begin
                _markAsProcessed := true;
                _updatedDate := _WorkwaveJnlMgt.SuggestCashRcptJnl(_WorkwaveEntry);
            end;
        end;
        Clear(_WorkwaveEntry2);
        _WorkwaveEntry2.Reset();
        _WorkwaveEntry2.LockTable();
        _WorkwaveEntry2.Get(_WorkwaveEntry."Entry No.");
        if _txStatus <> '' then
            _WorkwaveEntry2."Transaction Status" := CopyStr(_txStatus,1,MaxStrLen(_WorkwaveEntry2."Transaction Status"));
        if _markAsProcessed then
            _WorkwaveEntry2.Processed := 1;
        _WorkwaveEntry2."Processed at DateTime" := CurrentDateTime();
        _WorkwaveEntry2."Processed No. of Attempts" := _WorkwaveEntry2."Processed No. of Attempts" + 1;
        _WorkwaveEntry2."Transmit Data Entry No." := _DataMgt.NewDataEntry(diagCode,'outbound WorkwaveACH',OutbDataContent);
        _WorkwaveEntry2."Receipt Data Entry No." := _DataMgt.NewDataEntry(diagCode,'inbound WorkwaveACH',InbDataContent);
        if _updatedDate <> 0D then
            _WorkwaveEntry2."Updated On" := CreateDateTime(_updatedDate,0T);
        _WorkwaveEntry2.Modify();
        _WorkwaveEntry2.Reset();
    end;

    procedure SetEntryNoToProcess(_EntryNoToProcess: Integer)
    begin
        EntryNoToProcess := _EntryNoToProcess;
    end;

    procedure setHideDialog();
    begin
        hideDialog := true;
    end;

    local procedure WriteToLog(_relatedEntryNo: BigInteger; _msgText: Text; _errText: Text)
    var
        _EventLogEntry: Record "ARC Event Log Entry";
        _status: Integer;
    begin
        if _errText <> '' then
            _status := _EventLogEntry.Status::Error
        else
            _status := _EventLogEntry.Status::Message;
        _EventLogEntry.NewEventLogEntry(diagCode,_EventLogEntry."Object Type"::Codeunit,Codeunit::"ARC Workwave ACH Management",
            _relatedEntryNo,_status,_msgText,_errText,false,'')
    end;
    
    var
        WorkWaveSetup : Record "ARC Workwave Setup";
        InbDataContent: BigText;
        OutbDataContent: BigText;
        showDialog: Boolean;
        hideDialog: Boolean;
        charCR: Char;
        charLF: Char;
        diagCode: Code[20];
        SalesInvHeaderNo: Code[20];
        Window: Dialog;
        EntryNoToProcess: Integer;
        CRLF: Text;
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
page 50093 "ARC Inventory Balances"
{
    // SOW13 Adobe eCommerce to CSM to NAV 2018

    PageType = List;
    SourceTable = "ARC Buffer";
    SourceTableTemporary = true;
    Editable = false;
    Permissions = tabledata "ARC Data Entry" = ri,
                  tabledata Item = r,
                  tabledata "Item Ledger Entry" = r;
    Caption = 'Inventory Balances';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(entryNo; Rec."Entry No.") { }
                field(itemNo; Rec."Code 01") { }
                field(itemDesc; Rec."Text 01") { }
                field(locCode; Rec."Code 02") { }
                field(locName; Rec."Text 02") { }
                field(qtyOnHand; Rec."Decimal 01") { }
                field(grossReqmnt; Rec."Decimal 02") { }
                field(schedRcpt; Rec."Decimal 03") { }
                field(availToPromise; Rec."Decimal 04") { }
                field(itemLedgEntryNo; Rec."Integer 07") { }
                field(createdAtDateTime; Rec."DateTime 07") { }
                field(dateTimeFilterToUse; Rec."Text 07") { }
            }
        }
        area(factboxes) { }
    }

    actions
    {
        area(processing) { }
    }

    var
        KorberSetup: Record "ARC Korber Setup";
        DiagText: BigText;
        DiagCode: Code[20];
        CRNL: Text;
        DateTimeFilterToUse: Text;
        DiagDesc: Text;

    trigger OnOpenPage()
    begin
        Rec.DeleteAll();
        Initialize();
        DeriveDateTimeFilterToUse();
        CollectInvBalEntries();
    end;

    local procedure AppendText(_diagtext: Text)
    var
        datetimetext: Text;
        textline: Text;
        text000Lbl: Label '%1 -- %2';
    begin
        datetimetext := CopyStr(Format(CurrentDateTime(),0,9),1,MaxStrLen(datetimetext));
        textline := CopyStr(StrSubstNo(text000Lbl,datetimetext,_diagtext) + CRNL,1,MaxStrLen(textline));
        DiagText.AddText(textline);
    end;

    local procedure CollectInvBalEntries()
    var
        InvBalEntry: Record "ARC Inventory Balance Entry";
        Item: Record Item;
        AvailableToPromise: Codeunit "Available to Promise";
        DataMgt: Codeunit "ARC DataMgt";
        entryNo: BigInteger;
        LookaheadDateformula: DateFormula;
        AvailableQuantity: Decimal;
        GrossRequirement: Decimal;
        ScheduledReceipt: Decimal;
        PeriodType: Option Day,Week,Month,Quarter,Year;
        text099Lbl: Label 'Method CollectInvBalEntries(): %1';
    begin
        AppendText(StrSubstNo(text099Lbl,'begin'));
        if Evaluate(LookaheadDateformula, '<0D>') then;
        if DateTimeFilterToUse <> '' then
            InvBalEntry.SetFilter("Created at DateTime",DateTimeFilterToUse)
        else
            InvBalEntry.SetRange("Created at DateTime",CreateDateTime(CalcDate('<-7D>',Today()),0T),CurrentDateTime());
        AppendText(StrSubstNo(text099Lbl,'Created at DateTime Filter: ' + InvBalEntry.GetFilter("Created at DateTime")));
        AppendText(StrSubstNo(text099Lbl,'InvBalEntry count(): ' + Format(InvBalEntry.Count())));
        InvBalEntry.SetAutoCalcFields("Item Description","Location Name");
        if InvBalEntry.FindSet(false) then
            repeat
                Clear(AvailableToPromise);
                Clear(AvailableQuantity);
                Clear(GrossRequirement);
                Clear(ScheduledReceipt);
                Clear(Item);
                Item.Reset();
                if not Item.Get(InvBalEntry."Item No.") then
                    Item.Init()
                else begin
                    Item.SetRange("Location Filter", InvBalEntry."Location Code");
                    Item.CalcFields(Inventory);
                    AvailableQuantity := AvailableToPromise.QtyAvailabletoPromise(Item,GrossRequirement,ScheduledReceipt,Today(),PeriodType::Day,LookaheadDateformula);
                end;
                entryNo += 1;
                Rec.Init();
                Rec."Entry No." := entryNo;
                Rec."Code 01" := CopyStr(InvBalEntry."Item No.",1,MaxStrLen(Rec."Code 01"));
                Rec."Text 01" := CopyStr(InvBalEntry."Item Description",1,MaxStrLen(Rec."Text 01"));
                Rec."Code 02" := CopyStr(InvBalEntry."Location Code",1,MaxStrLen(Rec."Code 02"));
                Rec."Text 02" := CopyStr(InvBalEntry."Location Name",1,MaxStrLen(Rec."Text 02"));
                Rec."Decimal 01" := Item.Inventory;
                Rec."Decimal 02" := GrossRequirement;
                Rec."Decimal 03" := ScheduledReceipt;
                Rec."Decimal 04" := AvailableQuantity;
                Rec."DateTime 07" := InvBalEntry."Created at DateTime";
                Rec."Integer 07" := InvBalEntry."Item Ledger Entry No.";
                Rec."Text 07" := CopyStr(InvBalEntry.GetFilter("Created at DateTime"),1,MaxStrLen(Rec."Text 07"));
                Rec.Insert();
            until InvBalEntry.Next() = 0;
        Rec.SetRange("DateTime 07");
        AppendText(StrSubstNo(text099Lbl,'end'));
        if KorberSetup."Log Level" in [KorberSetup."Log Level"::Verbose] then
            DataMgt.NewDataEntry(DiagCode,DiagDesc,DiagText);
    end;

    local procedure DeriveDateTimeFilterToUse()
    var
        x: Integer;
        text000Lbl: Label 'FilterGroup(%1): DateTimeFilterToUse: %2';
        text099Lbl: Label 'Method DeriveDateTimeFilterToUse(): %1';
    begin
        AppendText(StrSubstNo(text099Lbl,'begin'));
        for x := 0 to 255 do begin
            Rec.FilterGroup(x);
            if Rec.GetFilter("DateTime 07") <> '' then
                if DateTimeFilterToUse = '' then begin
                    DateTimeFilterToUse := CopyStr(Rec.GetFilter("DateTime 07"),1,MaxStrLen(DateTimeFilterToUse));
                    AppendText(StrSubstNo(text099Lbl,StrSubstNo(text000Lbl,x,DateTimeFilterToUse)));
                end;
        end;
        Rec.FilterGroup(0);
        AppendText(StrSubstNo(text099Lbl,'end'));
    end;

    local procedure Initialize()
    var
        KorberMgt: Codeunit "ARC KorberMgt";
        text099Lbl: Label 'Method Initialize(): %1';
    begin
        AppendText(StrSubstNo(text099Lbl,'begin'));
        if not KorberSetup.Get() then
            KorberSetup.Init()
        else
            AppendText(StrSubstNo(text099Lbl,'Log Level: ' + Format(KorberSetup."Log Level")));
        CRNL := CopyStr(KorberMgt.GetCRNL(),1,MaxStrLen(CRNL));
        DiagCode := CopyStr('INVBALANCE',1,MaxStrLen(DiagCode));
        DiagDesc := CopyStr('Inventory Balance Entries diagnostic text',1,MaxStrLen(DiagDesc));
        AppendText(StrSubstNo(text099Lbl,'DiagCode: ' + DiagCode));
        AppendText(StrSubstNo(text099Lbl,'DiagDesc: ' + DiagDesc));
        AppendText(StrSubstNo(text099Lbl,'end'));
    end;
}
page 50094 "ARC eCommerce History Entries"
{
    // SOW13 Adobe eCommerce to CSM to NAV 2018

    PageType = List;
    SourceTable = "ARC Buffer";
    SourceTableTemporary = true;
    Editable = false;
    Permissions = tabledata "ARC Data Entry" = ri,
                  tabledata "ARC eCommerce Entry" = r,
                  tabledata "ARC Order Translation Entry" = r,
                  tabledata "Sales Shipment Header" = r,
                  tabledata "Sales Shipment Line" = r;
    Caption = 'eCommerce History Entries';

    layout
    {
        area(content)
        {
            repeater(HistoryEntries)
            {
                field(eComEntryNo; Rec."BigInteger 01") { }
                field(eComOrderId; Rec."Code 01") { }
                field(eComType; Rec."Code 05") { }
                field(eComNo; Rec."Code 06") { }
                field(eComCreatedDate; Rec."Date 01") { }
                field(eComCreatedDateTime; Rec."DateTime 01") { }
                field(ordTranslEntryNo; Rec."BigInteger 02") { }
                field(ordTranslDocNo; Rec."Code 02") { }
                field(ordTranslCreatedDate; Rec."Date 02") { }
                field(ordTranslCreatedDateTime; Rec."DateTime 02") { }
                field(ordTranslDocLineNo; Rec."Integer 02") { }
                field(ordTranslUpdDocNo; Rec."Code 03") { }
                field(ordTranslRelDateTime; Rec."DateTime 03") { }
                field(ordTranslUpdDocLineNo; Rec."Integer 03") { }
                field(ordTranslUpdLocCode; Rec."Text 03") { }
                field(shptLineDocNo; Rec."Code 04") { }
                field(shptLineLineNo; Rec."Integer 04") { }
                field(shptLineQty; Rec."Decimal 04") { }
                field(shptHdrPkgTrkNo; Rec."Text 04") { }
                field(eComCustNo; Rec."Code 07") { }
                field(salesShptHeaderFilters; Rec."Text 05") { }
                field(ordTranslEntryFilters; Rec."Text 06") { }
                field(eCommerceEntryFilters; Rec."Text 07") { }
                field(dateFilter; Rec."Date 07") { }
                field(tempEntryNo; Rec."Entry No.") { }
            }
        }
        area(factboxes) { }
    }

    actions
    {
        area(processing) { }
    }

    var
        RNASetup: Record "ARC RNA Setup";
        DiagText: BigText;
        DiagCode: Code[20];
        CRNL: Text;
        DateFilterToUse: Text;
        DiagDesc: Text;

    trigger OnOpenPage()
    begin
        Rec.DeleteAll();
        Initialize();
        DeriveDateFilterToUse();
        CollectHistoryEntries();
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

    local procedure DeriveDateFilterToUse()
    var
        x: Integer;
        text000Lbl: Label 'FilterGroup(%1): DateFilterToUse: %2';
        text099Lbl: Label 'Method DeriveDateFilterToUse(): %1';
    begin
        AppendText(StrSubstNo(text099Lbl,'begin'));
        for x := 0 to 255 do begin
            Rec.FilterGroup(x);
            if Rec.GetFilter("Date 07") <> '' then
                if DateFilterToUse = '' then begin
                    DateFilterToUse := CopyStr(Rec.GetFilter("Date 07"),1,MaxStrLen(DateFilterToUse));
                    AppendText(StrSubstNo(text099Lbl,StrSubstNo(text000Lbl,x,DateFilterToUse)));
                end;
        end;
        Rec.FilterGroup(0);
        AppendText(StrSubstNo(text099Lbl,'end'));
    end;

    local procedure CollectHistoryEntries()
    var
        eCommerceEntry: Record "ARC eCommerce Entry";
        KorberSetup: Record "ARC Korber Setup";
        OrdTranslEntry: Record "ARC Order Translation Entry";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesShptLine: Record "Sales Shipment Line";
        DataMgt: Codeunit "ARC DataMgt";
        entryNo: BigInteger;
        _duration: Duration;
        timeBegin: Time;
        timeEnd: Time;
        text000Lbl: Label ' > eComEntry %1, eComOrderId %2, eComCustNo %3, eComType %4, eComNo %5, DocNo %6, DocLineNo %7, CreatedDate %8';
        text001Lbl: Label ' >  > ordTranslEntry %1, ordTranslDocNo %2, ordTranslDocLineNo %3, ordTranslUpdDocNo %4, ordTranslUpdDocLineNo %5';
        text002Lbl: Label ' >  >  > SalesShptHeader %1, OrderNo %2, PostingDate %3, TrkNo %4';
        text003Lbl: Label ' >  >  >  > SalesShptLine %1, Type %2, No %3, Qty %4';
        text099Lbl: Label 'Method CollectHistoryEntries(): %1';
    begin
        // sales order lines in D365BC SaaS are transmitted to NAV 2018 and arrive as eCommerce Entries - we will use these as a starting point to gather data
        timeBegin := Time();
        AppendText(StrSubstNo(text099Lbl,'time begin: ' + Format(timeBegin)));
        eCommerceEntry.SetCurrentKey("Created at Date");
        if DateFilterToUse = '' then
            eCommerceEntry.SetRange("Created at Date",CalcDate('-7D',Today()),Today())
        else
            eCommerceEntry.SetFilter("Created at Date",DateFilterToUse);
        eCommerceEntry.SetFilter("eCom Type",'G/L Account|Item|Resource');
        AppendText(StrSubstNo(text099Lbl,'eCommerceEntry Filters: ' + eCommerceEntry.GetFilters()));
        if eCommerceEntry.FindSet(false) then
            repeat
                // filter the Order Translation Entries, where original order lines are "split" based on predefined criteria
                AppendText(StrSubstNo(text099Lbl,'------------------------------------------------------------------------------------------'));
                AppendText(StrSubstNo(text099Lbl,StrSubstNo(text000Lbl,eCommerceEntry."Entry No.",eCommerceEntry."eCom Order ID",
                    eCommerceEntry."eCom Customer No.",eCommerceEntry."eCom Type",eCommerceEntry."eCom No.",eCommerceEntry."Document No.",
                    eCommerceEntry."Document Line No.",eCommerceEntry."Created at Date")));
                Clear(OrdTranslEntry);
                OrdTranslEntry.Reset();
                OrdTranslEntry.SetCurrentKey("Document Area","Document Type","Document No.","Document Line No.");
                OrdTranslEntry.SetRange("Document Area",OrdTranslEntry."Document Area"::Sales);
                OrdTranslEntry.SetRange("Document Type",OrdTranslEntry."Document Type"::Order);
                OrdTranslEntry.SetRange("Document No.",eCommerceEntry."Document No.");
                OrdTranslEntry.SetRange("Document Line No.",eCommerceEntry."Document Line No.");
                OrdTranslEntry.SetRange(Analyze,false);
                AppendText(StrSubstNo(text099Lbl,'OrdTranslEntry Filters: ' + OrdTranslEntry.GetFilters()));
                if OrdTranslEntry.FindSet(false) then
                    repeat
                        // filter the posted sales shpts according to the Updated Document No. in Order Translation Entries
                        AppendText(StrSubstNo(text099Lbl,StrSubstNo(text001Lbl,OrdTranslEntry."Entry No.",OrdTranslEntry."Document No.",
                            OrdTranslEntry."Document Line No.",OrdTranslEntry."Updated Document No.",OrdTranslEntry."Updated Document Line No.")));
                        Clear(SalesShptHeader);
                        SalesShptHeader.Reset();
                        SalesShptHeader.SetCurrentKey("Order No.");
                        SalesShptHeader.SetRange("Order No.",OrdTranslEntry."Updated Document No.");
                        AppendText(StrSubstNo(text099Lbl,'SalesShptHeader Filters: ' + SalesShptHeader.GetFilters()));
                        if SalesShptHeader.FindSet(false) then
                            repeat
                                AppendText(StrSubstNo(text099Lbl,StrSubstNo(text002Lbl,SalesShptHeader."No.",SalesShptHeader."Order No.",
                                    SalesShptHeader."Posting Date",SalesShptHeader."Package Tracking No.")));
                                Clear(SalesShptLine);
                                SalesShptLine.Reset();
                                SalesShptLine.SetRange("Document No.",SalesShptHeader."No.");
                                SalesShptLine.SetFilter(Type,'%1|%2',SalesShptLine.Type::Item,SalesShptLine.Type::Resource);
                                SalesShptLine.SetRange("No.",eCommerceEntry."eCom No.");
                                SalesShptLine.SetFilter(Quantity,'<>0');
                                AppendText(StrSubstNo(text099Lbl,'SalesShptLine Filters: ' + SalesShptLine.GetFilters()));
                                if SalesShptLine.FindSet(false) then
                                    repeat
                                        AppendText(StrSubstNo(text099Lbl,StrSubstNo(text003Lbl,SalesShptLine."Line No.",SalesShptLine.Type,
                                            SalesShptLine."No.",SalesShptLine.Quantity)));
                                        entryNo += 1;
                                        Rec.Init();
                                        Rec."Entry No." := entryNo;
                                        Rec."BigInteger 01" := eCommerceEntry."Entry No.";
                                        Rec."Code 01" := CopyStr(GetRevisedOrderID(eCommerceEntry."eCom Order ID"),1,MaxStrLen(Rec."Code 01"));
                                        Rec."Date 01" := eCommerceEntry."Created at Date";
                                        Rec."DateTime 01" := eCommerceEntry."Created at DateTime";
                                        Rec."BigInteger 02" := OrdTranslEntry."Entry No.";
                                        Rec."Code 02" := CopyStr(OrdTranslEntry."Document No.",1,MaxStrLen(Rec."Code 02"));
                                        Rec."Date 02" := OrdTranslEntry."Created at Date";
                                        Rec."DateTime 02" := OrdTranslEntry."Created at DateTime";
                                        Rec."Integer 02" := OrdTranslEntry."Document Line No.";
                                        Rec."Code 03" := CopyStr(OrdTranslEntry."Updated Document No.",1,MaxStrLen(Rec."Code 03"));
                                        Rec."DateTime 03" := OrdTranslEntry."Released at DateTime";
                                        Rec."Integer 03" := OrdTranslEntry."Updated Document Line No.";
                                        Rec."Text 03" := CopyStr(OrdTranslEntry."Updated Location Code",1,MaxStrLen(Rec."Text 03"));
                                        Rec."Code 04" := CopyStr(SalesShptLine."Document No.",1,MaxStrLen(Rec."Code 04"));
                                        Rec."Integer 04" := SalesShptLine."Line No.";
                                        Rec."Decimal 04" := SalesShptLine.Quantity;
                                        Rec."Text 04" := CopyStr(GetTrackingNo(SalesShptHeader,SalesShptLine,OrdTranslEntry),1,MaxStrLen(Rec."Text 04"));
                                        Rec."Code 05" := CopyStr(eCommerceEntry."eCom Type",1,MaxStrLen(Rec."Code 05"));
                                        Rec."Code 06" := CopyStr(eCommerceEntry."eCom No.",1,MaxStrLen(Rec."Code 06"));
                                        Rec."Code 07" := CopyStr(eCommerceEntry."eCom Customer No.",1,MaxStrLen(Rec."Code 07"));
                                        Rec."Date 07" := eCommerceEntry."Created at Date";
                                        Rec."Text 05" := CopyStr('SalesShptHeader Filters: ' + SalesShptHeader.GetFilters(),1,MaxStrLen(Rec."Text 05"));
                                        Rec."Text 06" := CopyStr('OrdTranslEntry Filters: ' + OrdTranslEntry.GetFilters(),1,MaxStrLen(Rec."Text 06"));
                                        Rec."Text 07" := CopyStr('eCommerceEntry Filters: ' + eCommerceEntry.GetFilters(),1,MaxStrLen(Rec."Text 07"));
                                        Rec.Insert();
                                    until SalesShptLine.Next() = 0
                                else begin
                                    // no sales shpt line recs were found, insert a placeholder record
                                    entryNo += 1;
                                    Rec.Init();
                                    Rec."Entry No." := entryNo;
                                    Rec."BigInteger 01" := eCommerceEntry."Entry No.";
                                    Rec."Code 01" := CopyStr(GetRevisedOrderID(eCommerceEntry."eCom Order ID"),1,MaxStrLen(Rec."Code 01"));
                                    Rec."Date 01" := eCommerceEntry."Created at Date";
                                    Rec."DateTime 01" := eCommerceEntry."Created at DateTime";
                                    Rec."BigInteger 02" := OrdTranslEntry."Entry No.";
                                    Rec."Code 02" := CopyStr(OrdTranslEntry."Document No.",1,MaxStrLen(Rec."Code 02"));
                                    Rec."Date 02" := OrdTranslEntry."Created at Date";
                                    Rec."DateTime 02" := OrdTranslEntry."Created at DateTime";
                                    Rec."Integer 02" := OrdTranslEntry."Document Line No.";
                                    Rec."Code 03" := CopyStr(OrdTranslEntry."Updated Document No.",1,MaxStrLen(Rec."Code 03"));
                                    Rec."DateTime 03" := OrdTranslEntry."Released at DateTime";
                                    Rec."Integer 03" := OrdTranslEntry."Updated Document Line No.";
                                    Rec."Text 03" := CopyStr(OrdTranslEntry."Updated Location Code",1,MaxStrLen(Rec."Text 03"));
                                    Rec."Text 04" := CopyStr(SalesShptHeader."Package Tracking No.",1,MaxStrLen(Rec."Text 01"));
                                    Rec."Code 05" := CopyStr(eCommerceEntry."eCom Type",1,MaxStrLen(Rec."Code 05"));
                                    Rec."Code 06" := CopyStr(eCommerceEntry."eCom No.",1,MaxStrLen(Rec."Code 06"));
                                    Rec."Code 07" := CopyStr(eCommerceEntry."eCom Customer No.",1,MaxStrLen(Rec."Code 07"));
                                    Rec."Date 07" := eCommerceEntry."Created at Date";
                                    Rec."Text 05" := CopyStr('SalesShptHeader Filters: ' + SalesShptHeader.GetFilters(),1,MaxStrLen(Rec."Text 05"));
                                    Rec."Text 06" := CopyStr('OrdTranslEntry Filters: ' + OrdTranslEntry.GetFilters(),1,MaxStrLen(Rec."Text 06"));
                                    Rec."Text 07" := CopyStr('eCommerceEntry Filters: ' + eCommerceEntry.GetFilters(),1,MaxStrLen(Rec."Text 07"));
                                    Rec.Insert();
                                end;
                            until SalesShptHeader.Next() = 0
                        else begin
                            // no sales shpt header recs were found, insert a placeholder record
                            entryNo += 1;
                            Rec.Init();
                            Rec."Entry No." := entryNo;
                            Rec."BigInteger 01" := eCommerceEntry."Entry No.";
                            Rec."Code 01" := CopyStr(GetRevisedOrderID(eCommerceEntry."eCom Order ID"),1,MaxStrLen(Rec."Code 01"));
                            Rec."Date 01" := eCommerceEntry."Created at Date";
                            Rec."DateTime 01" := eCommerceEntry."Created at DateTime";
                            Rec."BigInteger 02" := OrdTranslEntry."Entry No.";
                            Rec."Code 02" := CopyStr(OrdTranslEntry."Document No.",1,MaxStrLen(Rec."Code 02"));
                            Rec."Date 02" := OrdTranslEntry."Created at Date";
                            Rec."DateTime 02" := OrdTranslEntry."Created at DateTime";
                            Rec."Integer 02" := OrdTranslEntry."Document Line No.";
                            Rec."Code 03" := CopyStr(OrdTranslEntry."Updated Document No.",1,MaxStrLen(Rec."Code 03"));
                            Rec."DateTime 03" := OrdTranslEntry."Released at DateTime";
                            Rec."Integer 03" := OrdTranslEntry."Updated Document Line No.";
                            Rec."Text 03" := CopyStr(OrdTranslEntry."Updated Location Code",1,MaxStrLen(Rec."Text 03"));
                            Rec."Code 05" := CopyStr(eCommerceEntry."eCom Type",1,MaxStrLen(Rec."Code 05"));
                            Rec."Code 06" := CopyStr(eCommerceEntry."eCom No.",1,MaxStrLen(Rec."Code 06"));
                            Rec."Code 07" := CopyStr(eCommerceEntry."eCom Customer No.",1,MaxStrLen(Rec."Code 07"));
                            Rec."Date 07" := eCommerceEntry."Created at Date";
                            Rec."Text 05" := CopyStr('SalesShptHeader Filters: ' + SalesShptHeader.GetFilters(),1,MaxStrLen(Rec."Text 05"));
                            Rec."Text 06" := CopyStr('OrdTranslEntry Filters: ' + OrdTranslEntry.GetFilters(),1,MaxStrLen(Rec."Text 06"));
                            Rec."Text 07" := CopyStr('eCommerceEntry Filters: ' + eCommerceEntry.GetFilters(),1,MaxStrLen(Rec."Text 07"));
                            Rec.Insert();
                        end;
                    until OrdTranslEntry.Next() = 0
                else begin
                    // no order translation entry recs were found, insert a placeholder record
                    entryNo += 1;
                    Rec.Init();
                    Rec."Entry No." := entryNo;
                    Rec."BigInteger 01" := eCommerceEntry."Entry No.";
                    Rec."Code 01" := CopyStr(GetRevisedOrderID(eCommerceEntry."eCom Order ID"),1,MaxStrLen(Rec."Code 01"));
                    Rec."Date 01" := eCommerceEntry."Created at Date";
                    Rec."DateTime 01" := eCommerceEntry."Created at DateTime";
                    Rec."Code 05" := CopyStr(eCommerceEntry."eCom Type",1,MaxStrLen(Rec."Code 05"));
                    Rec."Code 06" := CopyStr(eCommerceEntry."eCom No.",1,MaxStrLen(Rec."Code 06"));
                    Rec."Code 07" := CopyStr(eCommerceEntry."eCom Customer No.",1,MaxStrLen(Rec."Code 07"));
                    Rec."Date 07" := eCommerceEntry."Created at Date";
                    Rec."Text 06" := CopyStr('OrdTranslEntry Filters: ' + OrdTranslEntry.GetFilters(),1,MaxStrLen(Rec."Text 06"));
                    Rec."Text 07" := CopyStr('eCommerceEntry Filters: ' + eCommerceEntry.GetFilters(),1,MaxStrLen(Rec."Text 07"));
                    Rec.Insert();
                end;
            until eCommerceEntry.Next() = 0;
        AppendText(StrSubstNo(text099Lbl,'------------------------------------------------------------------------------------------'));
        // remove date filter specified in ODataV4 URI, example:
        //   https://ecommerce-uat.rentokilna.com:8448/DynamicsNAV110-external/ODataV4/Company('TSP_US')/eCommerceHistoryEntries?$filter=dateFilter ge 2023-01-01
        Rec.SetRange("Date 07");

        timeEnd := Time();
        _duration := timeEnd - timeBegin;
        AppendText(StrSubstNo(text099Lbl,'time end: ' + Format(timeEnd)));
        AppendText(StrSubstNo(text099Lbl,'duration: ' + Format(_duration)));
        if KorberSetup.Get() then
            if KorberSetup."Log Level" = KorberSetup."Log Level"::Verbose then
                if DiagText.Length() > 0 then
                    DataMgt.NewDataEntry(DiagCode,DiagDesc,DiagText);
    end;

    local procedure GetRevisedOrderID(oldOrderID: Text) newOrderID: Text
    begin
        newOrderID := CopyStr(oldOrderID,1,MaxStrLen(newOrderID));
        if RNASetup."eCommerce Strip Leading Chars." <= 0 then
            exit;
        if (not (RNASetup."eCommerce Strip Leading Chars." in [1..99])) then
            exit;
        if StrLen(newOrderID) < RNASetup."eCommerce Strip Leading Chars." + 1 then
            exit;
        newOrderID := CopyStr(newOrderID,RNASetup."eCommerce Strip Leading Chars." + 1);
    end;

    procedure GetTrackingNo(
        SalesShptHeader: Record "Sales Shipment Header";
        SalesShptLine: Record "Sales Shipment Line";
        OrderTranslationEntry: Record "ARC Order Translation Entry"): Text
    var
        Location: Record Location;
        LocationCode: Code[10];
    begin
        if SalesShptHeader."Package Tracking No." <> '' then
            exit(SalesShptHeader."Package Tracking No.");
        if SalesShptLine."Location Code" <> '' then
            LocationCode := CopyStr(SalesShptLine."Location Code",1,MaxStrLen(LocationCode));
        if LocationCode = '' then
            LocationCode := CopyStr(OrderTranslationEntry."Updated Location Code",1,MaxStrLen(LocationCode));
        if LocationCode = '' then
            exit('');
        if not Location.Get(LocationCode) then
            exit('');
        if Location."ARC Enable Korber WMS" then
            exit(GetTrackingNoKorberEdge(OrderTranslationEntry))
        else
            exit(GetTrackingNoLanhamEShip(SalesShptHeader));
    end;

    local procedure GetTrackingNoKorberEdge(OrderTranslationEntry: Record "ARC Order Translation Entry"): Text
    var
        KorberShptEntry: Record "ARC Korber Shpt. Entry";
    begin
        KorberShptEntry.SetCurrentKey("Document Area","Document Type","Document No.","Document Line No.");
        KorberShptEntry.SetRange("Document Area",KorberShptEntry."Document Area"::Sales);
        KorberShptEntry.SetRange("Document Type",KorberShptEntry."Document Type"::Order);
        KorberShptEntry.SetRange("Document No.",OrderTranslationEntry."Updated Document No.");
        KorberShptEntry.SetRange(Process,true);
        KorberShptEntry.SetRange(Processed,1);
        KorberShptEntry.SetFilter("Track Trace Number",'<>%1','');
        if not KorberShptEntry.FindLast() then
            KorberShptEntry.Init();
        exit(KorberShptEntry."Track Trace Number");
    end;

    local procedure GetTrackingNoLanhamEShip(SalesShptHeader: Record "Sales Shipment Header"): Text
    var
        PostedPkg: Record "Posted Package";
    begin
        PostedPkg.SetCurrentKey("Source Type","Source Subtype","Posted Source ID","Bill of Lading No.");
        PostedPkg.SetRange("Source Type",Database::"Sales Header");
        PostedPkg.SetRange("Source Subtype",PostedPkg."Source Subtype"::"1");
        PostedPkg.SetRange("Posted Source ID",SalesShptHeader."No.");
        PostedPkg.SetFilter("External Tracking No.",'<>%1','');
        if not PostedPkg.FindFirst() then
            PostedPkg.Init();
        exit(PostedPkg."External Tracking No.");
    end;

    local procedure Initialize()
    var
        KorberMgt: Codeunit "ARC KorberMgt";
    begin
        if not RNASetup.Get() then
            RNASetup.Init();
        CRNL := CopyStr(KorberMgt.GetCRNL(),1,MaxStrLen(CRNL));
        DiagCode := CopyStr('ECOM_HIST',1,MaxStrLen(DiagCode));
        DiagDesc := CopyStr('eCommerce History Entries diagnostic text',1,MaxStrLen(DiagDesc));
    end;
}
xmlport 50041 "ARC ReOrder Import"
{
    Direction = Import;
    FieldDelimiter = '<None>';
    FieldSeparator = '<TAB>';
    Format = VariableText;
    Permissions = tabledata "ARC ReOrder Entry" = ri;
    UseRequestPage = false;
    Caption = 'ReOrder Import';

    schema
    {
        textelement(Root)
        {
            tableelement(Table2000000026;Integer)
            {
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                XmlName = 'Integer';

                textelement(ReOrderID) { }
                textelement(ReOrderCount) { }
                textelement(CustNo) { }
                textelement(ItemNo) { }
                textelement(Qty) { }
                textelement(RqstDelivDate) { }

                trigger OnBeforeInsertRecord()
                begin
                    ImportRecord;
                    Clear(ReOrderID);
                    Clear(ReOrderCount);
                    Clear(CustNo);
                    Clear(ItemNo);
                    Clear(Qty);
                    Clear(RqstDelivDate);
                    currXMLport.Skip;
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    var
        _ReOrderMgt: Codeunit "ARC ReOrderMgt";
    begin
        _ReOrderMgt.SetJobQueueEntryOnHold();
    end;

    trigger OnPostXmlPort()
    var
        _ReOrderMgt: Codeunit "ARC ReOrderMgt";
    begin
        _ReOrderMgt.SetJobQueueEntryReady();
    end;

    local procedure ImportRecord()
    var
        _ReOrderEntry: Record "ARC ReOrder Entry";
        _dt: DateTime;
    begin
        _dt := CurrentDateTime();
        _ReOrderEntry.Init();
        _ReOrderEntry."Entry No." := 0;
        _ReOrderEntry."ReOrder ID" := CopyStr(ReOrderID,1,MaxStrLen(_ReOrderEntry."ReOrder ID"));
        Evaluate(_ReOrderEntry."ReOrder ID Line Count",ReOrderCount);
        _ReOrderEntry.SellToCustNo := CopyStr(CustNo,1,MaxStrLen(_ReOrderEntry.SellToCustNo));
        _ReOrderEntry.ItemNo := CopyStr(ItemNo,1,MaxStrLen(_ReOrderEntry.ItemNo));
        Evaluate(_ReOrderEntry.Quantity,Qty);
        Evaluate(_ReOrderEntry.RequestedDeliveryDate,RqstDelivDate);
        _ReOrderEntry."Created at DateTime" := _dt;
        _ReOrderEntry.Insert(true);
    end;
}
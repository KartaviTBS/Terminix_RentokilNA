page 50189 "ARC eCommerce Item Attributes"
{
    PageType = List;
    SourceTable = "ARC Buffer";
    SourceTableTemporary = true;
    Editable = false;
    Caption = 'eCommerce Item Attributes';

    layout
    {
        area(content)
        {
            repeater(Attributes)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                    ToolTip = 'Specifies Entry No.';
                }
                field("Code 01"; Rec."Code 01")
                {
                    Caption = 'Item No.';
                    ToolTip = 'Specifies Item No.';
                }
                field("Integer 01"; Rec."Integer 01")
                {
                    Caption = 'Attribute Name ID';
                    ToolTip = 'Specifies Attribute Name ID';
                }
                field("Text 01"; Rec."Text 01")
                {
                    Caption = 'Attribute Name';
                    ToolTip = 'Specifies Attribute Name';
                }
                field("Integer 02"; Rec."Integer 02")
                {
                    Caption = 'Attribute Value ID';
                    ToolTip = 'Specifies Attribute Value ID';
                }
                field("Text 02"; Rec."Text 02")
                {
                    Caption = 'Attribute Value';
                    ToolTip = 'Specifies Attribute Value';
                }
            }
        }
        area(factboxes) { }
    }

    actions
    {
        area(processing) { }
    }

    var
        ItemFilter: Text;

    trigger OnOpenPage()
    var
        x: Integer;
    begin
        for x := 0 to 255 do begin
            Rec.FilterGroup(x);
            if Rec.GetFilter("Code 01") <> '' then
                if ItemFilter = '' then
                    ItemFilter := CopyStr(Rec.GetFilter("Code 01"),1,MaxStrLen(ItemFilter));
        end;
        GetItemAttributes(Rec);
    end;

    procedure GetItemAttributes(var tempBuf: Record "ARC Buffer")
    var
        Item: Record Item;
        ItemAttrib: Record "Item Attribute";
        ItemAttribValue: Record "Item Attribute Value";
        ItemAttribValueMapping: Record "Item Attribute Value Mapping";
        entryNo: BigInteger;
        recCount: Integer;
        text000Err: Label 'Leveraging this page *requires* a filter for Item No. limiting the Item recordset to a dozen; the filter specified was: %1';
    begin
        tempBuf.DeleteAll();
        if ItemFilter <> '' then
            Item.SetFilter("No.",ItemFilter);
        recCount := Item.Count();
        if recCount > 12 then
            Error(text000Err,ItemFilter);
        ItemAttribValueMapping.SetRange("Table ID",Database::Item);
        if Item.FindSet(false) then
            repeat
                ItemAttribValueMapping.SetRange("No.",Item."No.");
                if ItemAttribValueMapping.FindSet(false) then
                    repeat
                        if not ItemAttrib.Get(ItemAttribValueMapping."Item Attribute ID") then
                            ItemAttrib.Init();
                        if not ItemAttribValue.Get(ItemAttribValueMapping."Item Attribute ID",ItemAttribValueMapping."Item Attribute Value ID") then
                            ItemAttribValue.Init();
                        entryNo += 1;
                        tempBuf.Init();
                        tempBuf."Entry No." := entryNo;
                        tempBuf."Code 01" := CopyStr(Item."No.",1,MaxStrLen(tempBuf."Code 01"));
                        tempBuf."Integer 01" := ItemAttribValueMapping."Item Attribute ID";
                        tempBuf."Text 01" := CopyStr(ItemAttrib.Name,1,MaxStrLen(tempBuf."Text 01"));
                        tempBuf."Integer 02" := ItemAttribValueMapping."Item Attribute Value ID";
                        tempBuf."Text 02" := CopyStr(ItemAttribValue.Value,1,MaxStrLen(tempBuf."Text 02"));
                        tempBuf.Insert();
                    until ItemAttribValueMapping.Next() = 0;
            until Item.Next() = 0;
    end;
}
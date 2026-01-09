xmlport 50117 "ARC Cubiscan Import"
{
    // SOW11 Körber Edge WMS Integration - CO2 Cubiscan Integration

    Direction = Import;
    Format = VariableText;
    UseRequestPage = false;
    Permissions = tabledata "ARC Cubiscan Entry" = ri;
    FieldSeparator = '<TAB>';
    Caption = 'Cubiscan Import';

    schema
    {
        textelement(Root)
        {
            tableelement(Table2000000026;Integer)
            {
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                SourceTableView = sorting(Number);
                XmlName = 'Integer';

                textelement(ItemNo) { }
                textelement(UomCode) { }
                textelement(Description) { }
                textelement(Description2) { }
                textelement(Length) { }
                textelement(Width) { }
                textelement(Height) { }
                textelement(Weight) { }
                textelement(Volume) { }
                textelement(DimWght) { }
                textelement(DimUnit) { }
                textelement(WghtUnit) { }
                textelement(VolUnit) { }
                textelement(SiteId) { }
                textelement(FieldDateTime) { }
                textelement(BaseUom) { }
                textelement(SaleUom) { }
                textelement(Cubage) { }
                textelement(Opt5) { }
                textelement(Opt6) { }
                textelement(Opt7) { }
                textelement(Opt8) { }
                textelement(ImageFile) { }
                textelement(Updated) { }

                trigger OnBeforeInsertRecord();
                begin
                    ImportRecord;
                    currXMLport.Skip;
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
    
        actions
        {
            area(processing)
            {
            }
        }
    }

    var
        EntryNoToReference: BigInteger;
        DateTimeBegin: DateTime;
        TimeBegin: Time;

    trigger OnPreXmlPort()
    begin
        TimeBegin := Time();
        DateTimeBegin := CreateDateTime(Today(),TimeBegin);
    end;

    local procedure ImportRecord()
    var
        _CubiscanEntry: Record "ARC Cubiscan Entry";
        _CubiscanEntryCopy: Record "ARC Cubiscan Entry";
    begin
        _CubiscanEntry.Init();
        if EntryNoToReference <> 0 then begin
            _CubiscanEntryCopy.Get(EntryNoToReference);
            _CubiscanEntry := _CubiscanEntryCopy;
            _CubiscanEntry.Import := false;
        end;
        if StrPos(UpperCase(ItemNo),'ITEM') = 0 then begin
            _CubiscanEntry."Entry No." := 0;
            _CubiscanEntry."Item No." := CopyStr(ItemNo,1,MaxStrLen(_CubiscanEntry."Item No."));
            _CubiscanEntry."Unit of Measure Code" := CopyStr(UomCode,1,MaxStrLen(_CubiscanEntry."Unit of Measure Code"));
            _CubiscanEntry."Base Unit of Measure" := CopyStr(BaseUom,1,MaxStrLen(_CubiscanEntry."Base Unit of Measure"));
            _CubiscanEntry."Selling Unit of Measure" := CopyStr(SaleUom,1,MaxStrLen(_CubiscanEntry."Selling Unit of Measure"));
            _CubiscanEntry.Description := CopyStr(Description,1,MaxStrLen(_CubiscanEntry.Description));
            _CubiscanEntry."Description 2" := CopyStr(Description2,1,MaxStrLen(_CubiscanEntry."Description 2"));
            _CubiscanEntry.Length := CopyStr(Length,1,MaxStrLen(_CubiscanEntry.Length));
            _CubiscanEntry.Width := CopyStr(Width,1,MaxStrLen(_CubiscanEntry.Width));
            _CubiscanEntry.Height := CopyStr(Height,1,MaxStrLen(_CubiscanEntry.Height));
            _CubiscanEntry.Weight := CopyStr(Weight,1,MaxStrLen(_CubiscanEntry.Weight));
            _CubiscanEntry.Volume := CopyStr(Volume,1,MaxStrLen(_CubiscanEntry.Volume));
            _CubiscanEntry."Dim. Weight" := CopyStr(DimWght,1,MaxStrLen(_CubiscanEntry."Dim. Weight"));
            _CubiscanEntry."Dim. Unit" := CopyStr(DimUnit,1,MaxStrLen(_CubiscanEntry."Dim. Unit"));
            _CubiscanEntry."Wgt. Unit" := CopyStr(WghtUnit,1,MaxStrLen(_CubiscanEntry."Wgt. Unit"));
            _CubiscanEntry."Vol. Unit" := CopyStr(VolUnit,1,MaxStrLen(_CubiscanEntry."Vol. Unit"));
            _CubiscanEntry.Cubage := CopyStr(Cubage,1,MaxStrLen(_CubiscanEntry.Cubage));
            _CubiscanEntry."Site Id" := CopyStr(SiteId,1,MaxStrLen(_CubiscanEntry."Site Id"));
            _CubiscanEntry."Date/Time" := CopyStr(FieldDateTime,1,MaxStrLen(_CubiscanEntry."Date/Time"));
            _CubiscanEntry."Optional Info. 5" := CopyStr(Opt5,1,MaxStrLen(_CubiscanEntry."Optional Info. 5"));
            _CubiscanEntry."Optional Info. 6" := CopyStr(Opt6,1,MaxStrLen(_CubiscanEntry."Optional Info. 6"));
            _CubiscanEntry."Optional Info. 7" := CopyStr(Opt7,1,MaxStrLen(_CubiscanEntry."Optional Info. 7"));
            _CubiscanEntry."Optional Info. 8" := CopyStr(Opt8,1,MaxStrLen(_CubiscanEntry."Optional Info. 8"));
            _CubiscanEntry."Image File" := CopyStr(ImageFile,1,MaxStrLen(_CubiscanEntry."Image File"));
            _CubiscanEntry.Updated := StrPos(UpperCase(Updated),'Y') <> 0;
            _CubiscanEntry."Created at Date" := Today();
            _CubiscanEntry."Created at DateTime" := DateTimeBegin;
            _CubiscanEntry."Created at Time" := TimeBegin;
            _CubiscanEntry.Process := true;
            _CubiscanEntry.Insert(false);
        end;
        // clear xmlport variables
        Clear(ItemNo);
        Clear(UomCode);
        Clear(Description);
        Clear(Description2);
        Clear(Length);
        Clear(Width);
        Clear(Height);
        Clear(Weight);
        Clear(Volume);
        Clear(DimWght);
        Clear(DimUnit);
        Clear(WghtUnit);
        Clear(VolUnit);
        Clear(SiteId);
        Clear(FieldDateTime);
        Clear(BaseUom);
        Clear(SaleUom);
        Clear(Cubage);
        Clear(Opt5);
        Clear(Opt6);
        Clear(Opt7);
        Clear(Opt8);
        Clear(ImageFile);
        Clear(Updated);
    end;

    procedure SetEntryNoToReference(_EntryNoToReference: BigInteger)
    begin
        EntryNoToReference := _EntryNoToReference;
    end;
}
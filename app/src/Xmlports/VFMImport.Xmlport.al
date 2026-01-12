xmlport 50044 "ARC VFM Import"
{
    Caption = 'VFM Import';
    Direction = Import;
    FieldDelimiter = '<None>';
    FieldSeparator = '<TAB>';
    Format = VariableText;
    Permissions = tabledata 50044=ri;
    UseRequestPage = false;

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

                textelement(ItemNo)
                {
                }
                textelement(SubstNo)
                {
                }
                textelement(Ranking)
                {
                }
                textelement(Uom)
                {
                }
                textelement(CostPerAppln)
                {
                }
                textelement(ApplnsPerUom)
                {
                }

                trigger OnBeforeInsertRecord();
                begin
                    ImportRecord;
                    Clear(ItemNo);
                    Clear(SubstNo);
                    Clear(Ranking);
                    Clear(Uom);
                    Clear(CostPerAppln);
                    Clear(ApplnsPerUom);
                    currXMLport.Skip;
                end;
            }
        }
    }

    local procedure ImportRecord()
    var
        _VFMEntry: Record "ARC VFM Entry";
        _Item: Record Item;
    begin
        if ItemNo = 'ItemNo' then
            exit;
        _VFMEntry.Init;
        _VFMEntry."Entry No." := 0;
        _VFMEntry."Item No." := CopyStr(ItemNo,1,MaxStrLen(_VFMEntry."Item No."));
        _VFMEntry."Substitution No." := CopyStr(SubstNo,1,MaxStrLen(_VFMEntry."Substitution No."));
        if Evaluate(_VFMEntry.Ranking,Ranking) then;
        _VFMEntry."Unit of Measure Code" := CopyStr(Uom,1,MaxStrLen(_VFMEntry."Unit of Measure Code"));
        if Evaluate(_VFMEntry."Cost per Application",CostPerAppln) then;
        if Evaluate(_VFMEntry."Applications per UOM",ApplnsPerUom) then;
        _VFMEntry.Insert(true);
    end;
}
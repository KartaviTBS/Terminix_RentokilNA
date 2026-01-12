xmlport 50042 "ARC APL Import"
{
    Caption = 'APL Import';
    Direction = Import;
    FieldDelimiter = '<None>';
    FieldSeparator = '<TAB>';
    Format = VariableText;
    Permissions = tabledata 50042=ri;
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
        _APLEntry: Record "ARC APL Entry";
        _Item: Record Item;
    begin
        if ItemNo = 'ItemNo' then
            exit;
        _APLEntry.Init;
        _APLEntry."Entry No." := 0;
        _APLEntry."Item No." := CopyStr(ItemNo,1,MaxStrLen(_APLEntry."Item No."));
        _APLEntry."Substitution No." := CopyStr(SubstNo,1,MaxStrLen(_APLEntry."Substitution No."));
        if Evaluate(_APLEntry.Ranking,Ranking) then;
        _APLEntry."Unit of Measure Code" := CopyStr(Uom,1,MaxStrLen(_APLEntry."Unit of Measure Code"));
        if Evaluate(_APLEntry."Cost per Application",CostPerAppln) then;
        if Evaluate(_APLEntry."Applications per UOM",ApplnsPerUom) then;
        _APLEntry.Insert(true);
    end;
}
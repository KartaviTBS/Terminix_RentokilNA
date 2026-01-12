table 50035 "ARC Promotion"
{
    Caption = 'Promotion';
    DataClassification =  CustomerContent;
    LookupPageId = "ARC Promotions";
    DrillDownPageId = "ARC Promotions";
    
    fields
    {
        field(1;Code;Code[20])
        {
           
        }
        field(2;Description;Text[100])
        {
            
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
    
   

    trigger OnInsert();
    begin
    end;

    trigger OnModify();
    begin
    end;

    trigger OnDelete();
    begin
    end;

    trigger OnRename();
    begin
    end;

}
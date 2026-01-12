table 50071 "ARC AR Aging Summary"
{
    DataClassification = CustomerContent;
    Caption = 'AR Aging Summary';
    
    fields
    {
        field(10;"Account type";Option)
        {
         OptionMembers = " ", Total, "Credit Total", "Debit total", Credit, Debit;
         OptionCaption = ' ,Total,Credit Total,Debit Total,Credit,Debit';
        }

        field(20;"Aging Days";Integer)
        {
           
        }
        field(30;"Global Dimension 1 Code";Code[20])
        {
           TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
        }
        field(40;Amount;Decimal)
        {
           
        }
        field(50;Account;Code[10])
        {
           
        }      
    }

    keys
    {
        key(PK;"Account Type","Aging Days","Global Dimension 1 Code")
        {
            Clustered = true;
        }
        Key(key2;Account)
        {}
        Key(key3;"Global Dimension 1 Code")
        {}
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
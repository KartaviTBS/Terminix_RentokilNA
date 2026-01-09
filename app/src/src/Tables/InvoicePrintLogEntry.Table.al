table 50046 "ARC Invoice Print Log Entry"
{
    Caption = 'Invoice Print Log Entry';
    
    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
        }
        field(2;"No. of Invoices";Integer)
        {
            
        }
        field(3;"Starting Invoice No.";Code[20])
        {
            
        }
        field(4;"Last Invoice No.";Code[20])
        {
            
        }
        field(10;"Created On";DateTime)
        {
           
        }
        field(11;"Created By";DateTime)
        {
           ObsoleteState = Pending;
        }
        field(12;"Created User";Code[50])
        {
           
        }
        field(13; Type;Option)
        {
            OptionMembers = Invoice,"Cr. Memo";
            OptionCaption = 'Inovice,Cr. Memo';
        }
    }

    keys
    {
        key(PK;"Entry No.")
        {
            Clustered = true;
        }
    }
    
    var
        myInt : Integer;

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
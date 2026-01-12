table 50032 "ARC Alloc8 Export Entry"
{
    Caption ='Alloc8 Export Entry';
    DataClassification = CustomerContent;
    
    fields
    {
        field( 1;"Entry No.";Integer)
        {
           AutoIncrement = true;
        }
        field(2;"Entry Type"; Option)
        {
            OptionCaption = ' ,Customer,Invoice';
            OptionMembers = " ",Customer,Invoice;
        }
        field(3;"Export Date/Time";DateTime)
        {
            
        }        
        field(4;"No. of Transactions";Integer)
        {
            
        }
      
    }

    keys
    {
        key(Key1;"Entry No.")
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
table 50031 "ARC OnGuard Trans. Register"
{
    Caption ='OnGuard Transaction Register';
    DataClassification = CustomerContent;
    
    fields
    {
        field( 1;"Entry No.";Integer)
        {
           
        }
        field(2;"Export Date";Date)
        {
            
        }
        field(3;"Export Time";Time)
        {
            
        }
        field(4;"No. of Transactions";Integer)
        {
            
        }
        field(5;"From Entry No.";Integer)
        {
            
        }
        field(6;"To Entry No.";Integer)
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
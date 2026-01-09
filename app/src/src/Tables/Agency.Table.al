table 50061 "ARC Agency"
{
    DataClassification = CustomerContent;
    Caption = 'Agency';
    DrillDownPageID = 50061;
    LookupPageID = 50061; 

    fields
    {
        field(1;Code;Code[20])
        {
            NotBlank = true; 
            DataClassification = CustomerContent;
        }
        field(2;Description;tEXT[100])
        {
            DataClassification = CustomerContent;  
        }
        field(3;"Payment Terms Code";Code[20])
        {
            TableRelation = "Payment Terms";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK;Code )
        {
        }
    }
    
 }
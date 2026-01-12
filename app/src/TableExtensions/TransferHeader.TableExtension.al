tableextension 50002 "ARC Transfer Header" extends  "Transfer Header"
{
    fields
    {
        field(50001;"ARC Created By";Code[50])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
            Editable = false;
            
        }
        field(50002;"ARC Created On";DateTime)
        {
            Caption = 'Created On';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
  
}
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
        field(50003; "2Ship Label Link"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;  
            Caption = '2Ship Label Link';        
        }
        field(50004; "2Ship BOL Link"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;          
            Caption = '2Ship BOL Link';
        }
        field(50005; "2Ship Tracking No."; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;          
            Caption = '2Ship Tracking No.';
        }
        field(50006; "2Ship Get Edit URL"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;          
            Caption = '2Ship Get Edit URL';
        }
    }
  
}
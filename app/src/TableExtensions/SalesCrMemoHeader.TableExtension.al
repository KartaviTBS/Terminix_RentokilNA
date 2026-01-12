tableextension 50012 "ARC Sales Cr. Memo Header" extends "Sales Cr.Memo Header"
{
    
    fields
    {
        field(50079; "2Ship Label Link"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;  
            Caption = '2Ship Label Link';        
        }
        field(50080; "2Ship BOL Link"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;          
            Caption = '2Ship BOL Link';
        }
        field(50081; "2Ship Tracking No."; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;          
            Caption = '2Ship Tracking No.';
        }
        field(50083; "2Ship Get Edit URL"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;          
            Caption = '2Ship Get Edit URL';
        }
        field(50085; "Priority_Korber"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Priority_Korber';
        }
        field(50900; "ARC Contract No."; Text[20])
        {
            Caption = 'Contact No.';
        }
        field(50901; "ARC Contract Commence Date"; Date)
        {
            Caption = 'Contract Commence Date';
        }
        field(50902; "ARC Contract Renew Date"; Date)
        {
            Caption = 'Contract Renew Date';
        }
        field(50903; "ARC Invoice Type"; Text[5])
        {
            Caption = 'Invoice Type';
        }
        field(50904; "ARC Invoice Period Start"; Date)
        {
            Caption = 'Invoice Period Start';
        }
        field(50905; "ARC Invoice Period End"; Date)
        {
            Caption = 'Invoice Period End';
        }
        field(50906; "ARC Service Branch No."; Text[30])
        {
            Caption = 'Service Branch No.';
        }
        field(50907; "ARC Service Technician"; Text[10])
        {
            Caption = 'Service Technician';
        }
        field(50908; "ARC Service Employee Name"; Text[60])
        {
            Caption = 'Service Employee Name';
        }
       field(50065;"ARC Workwave Order";Boolean)
        {
            Caption = 'WorkWave Order';
            Editable = true;
        }
         field(50072;"ARC ACH Order";Boolean)
        {
            Caption = 'ACH Order';
            Editable = false;
        }
    }



}
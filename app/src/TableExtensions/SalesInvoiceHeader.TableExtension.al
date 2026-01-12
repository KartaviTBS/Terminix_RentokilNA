tableextension 50011 "ARC Sales Invocie Header" extends "Sales Invoice Header"
{
    fields
    {
        field(50012;"Sell-to Territory Code";Code[10])
        {
            Caption = 'Territory Code';
            Description = 'RENT.SK.01';
            TableRelation = Territory;
            Editable = false;        
        }
        field(50013;"Bill-to Territory Code";Code[10])
        {
            Caption = 'Territory Code';
            Description = 'RENT.SK.01';
            TableRelation = Territory;
            Editable = false;
        }
        field(50014;"Ship-to Territory Code";Code[10])
        {
            Caption = 'Territory Code';
            Description = 'RENT.SK.01';
            TableRelation = Territory;
            Editable = false;
        }        
        field(50053; "ARC Order Source Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Order Source Code';
        }
        field(50065;"ARC Workwave Order";Boolean)
        {
            Caption = 'WorkWave Order';
            Editable = false;
        }
         field(50072;"ARC ACH Order";Boolean)
        {
            Caption = 'ACH Order';
            Editable = false;
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
    }
}
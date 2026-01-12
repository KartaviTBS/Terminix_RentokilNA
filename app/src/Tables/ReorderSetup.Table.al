table 50119 "ARC Reorder Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Reorder Setup';
    
    fields
    {
        field(1;Code;Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(1001; "Order Nos."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(1051; "Max Entries to Process"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(1101; "SMTP Errors Notif. Email From"; Text[80])
        {
            DataClassification = CustomerContent;
        }
        field(1102; "SMTP Errors Notif. Email To"; Text[80])
        {
            DataClassification = CustomerContent;
        }
        field(1103; "SMTP Errors Notif. Email Subj."; Text[80])
        {
            DataClassification = CustomerContent;
        }
        field(2001; "Order Source"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "ARC Order Source";
        }
    }

    keys
    {
        key(PK;Code)
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
table 50048 "2Ship Integration Log"
{
    Caption = '2Ship Integration Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
            AutoIncrement = true;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(3; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = ' ,Success,Failed';
            OptionMembers = " ",Success,Failed;
        }
        field(4; "Date & Time"; DateTime)
        {
            Caption = 'Date & Time';
            Editable = false;
        }
        field(5; "User Id"; Code[50])
        {
            Caption = 'User Id';
            Editable = false;
        }
        field(6; "JSON Response Blob"; Blob)
        {
            Caption = 'Json Response Received';
        }
        field(7; "Json Request Blob"; Blob)
        {
            Caption = 'Json Request sent';
        }
        field(8; "Error"; Blob)
        {
            Caption = 'Error Message';
        }
        field(9; "Request Type"; Option)
        {
            Caption = 'Request Type';
            OptionMembers = " ",Ship,DeleteShipment,GetEditUrl;
            OptionCaption = ' ,Ship,DeleteShipment,GetEditUrl';
        }
    }

    keys
    {
        key(Primarykey; "Entry No.")
        {
            Clustered = true;
        }
    }
}
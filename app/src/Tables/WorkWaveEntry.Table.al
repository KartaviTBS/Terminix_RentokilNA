table 50050 "ARC Workwave Entry"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "ARC Workwave Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Transaction ID"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Transaction Status"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Transaction Type"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Payment Acct Type"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(6; "Card Type"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(7; "Masked Card No."; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(8; "Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(9; "Amount Captured"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Approval No."; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(11; "Payment Acct Token"; Text[150])
        {
            DataClassification = CustomerContent;
        }
        field(12; "Employee ID"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(13; "Billing Address"; Text[80])
        {
            DataClassification = CustomerContent;
        }
        field(14; "Billing City"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(15; "Billing State"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(16; "Reference"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(17; "Payment Acct Reference"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(18; "Web Order No."; Code[30])
        {
            DataClassification = CustomerContent;
        }
        field(19; "Sales Order No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(20; "Sell-to Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(21; "Billing PostCode"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(25; "Created On"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(26; "Updated On"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27; Status; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = Open, Used, Batched, Settled, Declined, ;
            OptionCaption = 'Open,Used,Batched,Settled,Declined';

        }
        field(28; "Related Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(29; "Batch No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(30; "Bill-to Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(31; "Masked Account No."; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(32; "Masked Routing No."; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(40; "Sales Invoice No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(41; "Sales Invoice Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(5000; Process; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(5001; Processed; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(5002; "Processed at DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(5003; "Processed No. of Attempts"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(5004; "Processed Error Text"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(5021; "Transmit Data Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
        }
        field(5022; "Receipt Data Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Process; Process, Processed, "Sales Order No.") { }
        key(Key2; "Sales Order No.", "Transaction Status")
{
    MaintainSQLIndex = true;
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

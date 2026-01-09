table 50039 "ARC AR Hold Log Entry"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1;"Entry No.";Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';        
        }
        field(3;"Customer Name";Text[50])
        {
            Caption = 'Customer Name';
        }
        field(4;"Sales Order No.";Code[20])
        {
            Caption = 'Sales Order No.';
        }
        field(5;"Credit Limit Amount";Decimal)
        {
            Caption = 'Credit Limit Amount';
        }
        field(6;"Order Amount";Decimal)
        {
            Caption = 'Order Amount';
        }
        field(7;Status;Option)
        {
            Caption = 'Status';
            OptionMembers = Open,Approved,Declined;
            OptionCaption = 'Open,Approved,Declined';
        }
        field(8;"Balance Due"; Boolean)
        {
            Caption = 'Balance Due';
        }
        field(9;"Balance Due Amount"; Decimal)
        {
            Caption = 'Balance Due Amount';
        }
        field(10;"Created By";Text[50])
        {
           Caption = 'Created By';
        }
        field(11;"Created On";DateTime)
        {
            Caption = 'Created On';
        }
        field(12;"Modified By";Text[50])
        {
           Caption = 'Modified By';
        }
        field(13;"Modified On";DateTime)
        {
            Caption = 'Modified On';
        }
        field(14; "Approved By"; Code[50])
        {
            Caption = 'Approved By';
            TableRelation = User."User Name";
            Editable = false;
        }
        field(15; "Approved On"; DateTime)
        {
            Caption = 'Approved On';
            Editable = false;
        }

    }

    keys
    {
        key(PK;"Entry No.")
        {
            Clustered = true;
        }
    }
    
    
    trigger OnInsert();
    begin
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
    end;

    trigger OnModify();
    begin
        "Modified By" := UserId;
        "Modified On" := CurrentDateTime;
    end;

    trigger OnDelete();
    begin
    end;

    trigger OnRename();
    begin
    end;

}
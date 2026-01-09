table 50052 "ARC WW Acct. Type GenJnl Batch"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1;"Account Type";Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ","Visa","MasterCard","American Express","Discover","Diner's Club","JCB Card","Other","Gift Card","EBT","Check","Laser","Maestro","Solo","Switch","UnionPay";
            OptionCaption = ' ,Visa,MasterCard,American Express,Discover,Diner''s Club,JCB Card,Other,Gift Card,EBT,Check,Laser,Maestro,Solo,Switch,UnionPay';
        }
        field(2;"Populate Cash Receipt Jnl.";Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(3;"Gen. Journal Template";Code[20])
        {
           DataClassification = CustomerContent;
           TableRelation = "Gen. Journal Template" WHERE (Type = CONST ("Cash Receipts"));

            trigger OnValidate();
            begin
                Validate("Gen. Journal Batch",'');
            end;

        }
        field(4;"Gen. Journal Batch";Code[20])
        {
           DataClassification = CustomerContent;
           TableRelation = "Gen. Journal Batch".Name WHERE ("Journal Template Name" = FIELD ("Gen. Journal Template"));
        }
        
        field(5;"Populate External Doc. No.";Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = Base,"Base+Posting Date","Base+Work Date","Base+Today","Posting Date+Base","Work Date+Base","Today+Base","Approval/Authorization Number","Check Number";
            OptionCaption = 'Base,Base+Posting Date,Base+Work Date,Base+Today,Posting Date+Base,Work Date+Base,Today+Base,Approval/Authorization Number,Check Number';
        }
        field(6;"External Doc. No. Base";Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(7;"Bal. Account Type";Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "G/L Account",Customer,"Vendor","Bank Account","Fixed Asset","IC Partner",Employee;
            OptionCaption = 'G/L Account,Customer,Vendor,Bank Account,Fixed Asset,IC Partner,Employee';
        }
        field(8;"Bal. Account No.";Code[20])
        {
           
            TableRelation = IF ("Bal. Account Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Bal. Account Type" = CONST(Customer)) Customer
            ELSE
            IF ("Bal. Account Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Bal. Account Type" = CONST("Bank Account")) "Bank Account"
            ELSE
            IF ("Bal. Account Type" = CONST("Fixed Asset")) "Fixed Asset"
            ELSE 
            IF ("Bal. Account Type"  =CONST("IC Partner")) "IC Partner" 
            ELSE 
            IF ("Bal. Account Type"=CONST(Employee)) Employee;
        }
        field(9;"Temp Gen. Journal Batch";Code[20])
        {
           DataClassification = CustomerContent;
           TableRelation = "Gen. Journal Batch".Name WHERE ("Journal Template Name" = FIELD ("Gen. Journal Template"));
        }
        
    }

    keys
    {
        key(PK;"Account Type")
        {
            Clustered = true;
        }
    }
    
    var
        myInt : Integer;

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
table 50051 "ARC Workwave Setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {

        }
        field(2; "Api Key"; Text[250])
        {

        }
        field(3; "User Name"; Text[100])
        {

        }
        field(4; "Password"; Text[100])
        {

        }
        field(5; "Capture Url"; Text[250])
        {

        }
        field(6; "Authorize Url"; Text[250])
        {

        }
        field(7; "Transactions Url"; Text[250])
        {

        }
        field(8; "Refund Url"; Text[250])
        {

        }
        field(9; "Void Url"; Text[250])
        {

        }
        field(10; "Credit Url"; Text[250])
        {

        }
        field(15; "Enable Debugging"; Boolean)
        {

        }
        field(16; "Reauth. On Partial Inv."; Boolean)
        {

        }
        field(17; "Gen. Journal Template"; Code[10])
        {
            TableRelation = "Gen. Journal Template" WHERE (Type = CONST ("Cash Receipts"));

            trigger OnValidate();
            begin
                Validate("Gen. Journal Batch",'');
            end;

        }
        field(18; "Gen. Journal Batch"; Code[10])
        {
            TableRelation = "Gen. Journal Batch".Name WHERE ("Journal Template Name" = FIELD ("Gen. Journal Template"));

        }
        
        field(19;"Auth/Charge Diff Amount";Boolean)
        {
            
        }
        field(20;"Retry Count";Integer)
        {
            
        }
        field(21;"ACH Transfer Url";Text[250])
        {
            
        }
        

    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

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
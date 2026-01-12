table 50069 "ARC Supplemental Charge"
{
    DataClassification = CustomerContent;
    Caption = 'Supplemental Charge';
    DrillDownPageID = 50068;
    LookupPageID = 50068;

    fields
    {
        field(1; Code; Code[10])
        {
            DataClassification = CustomerContent;
        }

        field(2; Description; Text[50])
        {
            DataClassification = CustomerContent;
        }

        field(3; "Resource No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Resource;
        } 
        
        field(4; "Rate %"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 2:5;               
        }          
        
        field(5; "Fixed amount"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 2:5;               
        }  
        
        field(6; "Ship-to County"; Text[30])
        {
            DataClassification = CustomerContent;
        }  

        field(7; "Last Update"; Date)
        {
            DataClassification = CustomerContent;
        }  
        
        field(8; "Changed By"; Code[50])
        {
            DataClassification = CustomerContent;
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
        "Changed By" := UserId;
        "Last Update" := Today;
    end;

    trigger OnModify();
    begin
        "Changed By" := UserId;
        "Last Update" := Today;       
        ItemSupplCharge.SETRANGE(Code,Code);
        if ItemSupplCharge.FINDSET THEN begin
            repeat
                ItemSupplCharge.Description := Description;
                ItemSupplCharge."Resource No." := "Resource No.";
                ItemSupplCharge."Rate %" := "Rate %";
                ItemSupplCharge."Fixed amount" := "Fixed amount";
                ItemSupplCharge."Ship-to County" := "Ship-to County";
                ItemSupplCharge."Last Update" := "Last Update";
                ItemSupplCharge."Changed By" := "Changed By";
                ItemSupplCharge.MODIFY;
            until ItemSupplCharge.NEXT = 0;
        end;
    end;

    trigger OnDelete();
    begin
        ItemSupplCharge.SETRANGE(Code,Code);
        ItemSupplCharge.DeleteAll(false); 
    end;

    trigger OnRename();
    begin
       ItemSupplCharge.SETRANGE(Code,xrec.Code); 
       if ItemSupplCharge.FINDSET then begin
            repeat
                ItemSupplCharge.Code := Code;
                ItemSupplCharge.Modify(false);
            UNTIL ItemSupplCharge.NEXT = 0;
       end;       
    end;

    Var
        ItemSupplCharge : Record "ARC Item Supplemental Charge";
}
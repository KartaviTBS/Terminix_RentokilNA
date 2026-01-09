table 50070 "ARC Item Supplemental Charge"
{
    DataClassification = CustomerContent;
    Caption = 'Item Supplemental Charge';
    DrillDownPageID = 50070;
    LookupPageID = 50070;

    fields
    {
        field(1; Code; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "ARC Supplemental Charge";

            trigger OnValidate()

            begin
                if SupplCharge.GET(Code) then begin
                    Description := SupplCharge.Description;
                    "Resource No." := SupplCharge."Resource No.";
                    "Rate %" := SupplCharge."Rate %";
                    "Fixed amount" := SupplCharge."Fixed amount";
                    "Ship-to County" := SupplCharge."Ship-to County";
                    "Last Update" := SupplCharge."Last Update";
                    "Changed By" := SupplCharge."Changed By";
                end;
            end;            
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
        field(9; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Item;
        }         


    }
           
    keys
    {
        key(PK;"Item No.",Code)
        {
            Clustered = true;
        }
    }
    
    var

    trigger OnInsert();
    begin
        "Last Update" := Today;
        "Changed By" := UserId;        
    end;

    trigger OnModify();
    begin
        "Last Update" := Today;
        "Changed By" := UserId;       
    end;

    trigger OnDelete();
    begin
    end;

    trigger OnRename();
    begin
        "Last Update" := Today;
        "Changed By" := UserId;        
    end;
            
    var
        SupplCharge : Record "ARC Supplemental Charge";

}
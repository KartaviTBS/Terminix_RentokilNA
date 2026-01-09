table 50045 "ARC System Mapping"
{
    DataClassification = ToBeClassified;
    Caption = 'System Mapping';
    
    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
            Editable = false;
        }
        field(11;"Source System";Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = NAV2009, GreatPlains, Sage;
        }
        field(21;"Source Type";Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Customer, Item, Vendor, Location, SalesPerson;
        }
        field(22;"Source No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation=IF ("Source Type"=CONST(Customer)) Customer 
            ELSE IF ("Source Type"=CONST(Item)) Item 
            ELSE IF ("Source Type"=CONST(Vendor)) Vendor 
            ELSE IF ("Source Type"=CONST(Location)) Location
            ELSE IF ("Source Type"=CONST(SalesPerson)) "Salesperson/Purchaser";
            ValidateTableRelation = false;
        }
        field(31;"Destination No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4991;"Created by";Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = User;
            ValidateTableRelation = false;
            Editable = false;
        }
        field(4992;"Created at DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    keys
    {
        key(PK;"Entry No.")
        {
            Clustered = true;
        }
        key(Src; "Source System","Source Type","Source No.")
        {
        }
        key(Dest; "Destination No.")
        {
        }
    }
    
    var
        RecRef: RecordRef;
        xRecRef:  RecordRef;
        DVPSynchTriggerPublisher :Codeunit "NTN Synch Trigger Publisher";

    trigger OnInsert();
    var
        _Text000Err: TextConst ENU='Not allowed.';
    begin
        if GuiAllowed() then
            Error(_Text000Err);
        RecRef.GetTable(Rec);
        DVPSynchTriggerPublisher.OnInsertSynchTrigger(RecRef);    
    end;

    trigger OnModify();
    var
        _Text000Err: TextConst ENU='Not allowed.';
    begin
        if GuiAllowed() then
            Error(_Text000Err);
        RecRef.GetTable(Rec);
        DVPSynchTriggerPublisher.OnModifySynchTrigger(RecRef);    
    end;

    trigger OnDelete();
    var
        _Text000Err: TextConst ENU='Not allowed.';
    begin
        if GuiAllowed() then
            Error(_Text000Err);
        RecRef.GetTable(Rec);
        DVPSynchTriggerPublisher.OnDeleteSynchTrigger(RecRef);
    end;

    trigger OnRename();
    var
        _Text000Err: TextConst ENU='Not allowed.';
    begin
        if GuiAllowed() then
            Error(_Text000Err);
        RecRef.GetTable(Rec);
        xRecRef.GetTable(xRec);
        DVPSynchTriggerPublisher.OnRenameSynchTrigger(RecRef,xRecRef);    
    end;
}
table 50001 "ARC Price Review Entry"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "ARC Price Review Entry List";
    LookupPageId = "ARC Price Review Entry List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Document Area"; Option)
        {
            OptionMembers = Sales, Purchases, Service;
            OptionCaption = 'Sales,Purchases,Service';
        }
        field(3; "Document Type"; Option)
        {
            OptionMembers = Quote, Order, Invoice, "Credit Memo", "Blanket Order", "Return Order";
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
        }
        field(4; "Document No."; Code[20])
        {

        }
        field(5; "Entity Type"; Option)
        {
            OptionMembers = Customer, Vendor, Contact;
            OptionCaption = 'Customer,Vendor,Contact';
        }
        field(40; "Entity No."; Code[20])
        {
            trigger OnValidate()
            var
                Customer: Record Customer;
                Vendor: Record Vendor;
                Contact: Record Contact;
            begin
                case "Entity Type" of
                    "Entity Type"::Customer :
                        if Customer.Get("Entity No.") then
                    "Entity Name" := Customer.Name;
                "Entity Type"::Vendor :
                        if Vendor.Get("Entity No.") then
                    "Entity Name" := Vendor.Name;
                "Entity Type"::Contact :
                        if Contact.Get("Entity No.") then
                    "Entity Name" := Contact.Name;
                end;
            end;

        }
        field(6; "Entity Name"; Text[50])
        {
            Editable = false;
        }
        field(7; Type; Option)
        {
            OptionMembers = Item, Resource;
            OptionCaption = 'Item,Resource';
        }
        field(8; "No."; code[20])
        {
            trigger OnValidate()
            var
                Item: Record Item;
                Resource: Record Resource;
            begin
                case Type of
                    Type::Item :
                        if Item.Get("No.") then begin
                    "No. 2" := Item."No. 2";
                    Description := Item.Description;
                    "Minimum Price" := Item."ARC Minimum Price"; 
                end;
                Type::"Resource" :
                        if Resource.Get("No.") then
                    Description := Resource.Name;
                end;
            end;
        }
        field(9; "No. 2"; code[20])
        {

        }
        field(10; Description; code[50])
        {

        }
        field(11; "Unit Price"; Decimal)
        {

        }
        field(12; "Unit Cost"; Decimal)
        {

        }
        field(13; "Line Discount Amount"; Decimal)
        {

        }
        field(14; "Line Amount Excl. Tax"; Decimal)
        {

        }
        field(15; "Net Unit Price"; Decimal)
        {

        }
        field(16; "Margin %"; Decimal)
        {

        }
        field(17; "Price Entry No."; Integer)
        {

        }
        field(18; "Promotional Entry No."; Integer)
        {

        }
        field(19; Status; Option)
        {
            OptionMembers = Message, Error, Review, Approved, Rejected;
            OptionCaption = 'Message,Error,Review,Approved,Rejected';
            Editable = false;
        }
        field(20; "Last Entry"; Boolean)
        {

        }
        field(21; "Entry Text"; Text[250])
        {

        }
        field(22; "Created By"; Code[50])
        {
            TableRelation = User."User Name";
            Editable = false;
            ValidateTableRelation = false;
        }
        field(23; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(24; "Approved By"; Code[50])
        {
            TableRelation = User."User Name";
            Editable = false;
        }
        field(25; "Approved On"; DateTime)
        {
            Editable = false;
        }
        field(26; Approver; Code[50])
        {
            
        }
        field(27; "Document Line No."; Integer)
        {

        }
        field(28;"Minimum Price";Decimal)
        {
           
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Document Area", "Document Type", "Document No.", "Last Entry")
        {

        }
    }

    var
        myInt: Integer;

    trigger OnInsert();
    begin
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
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
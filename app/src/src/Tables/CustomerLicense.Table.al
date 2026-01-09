table 50016 "ARC Customer License"
{
   
    Caption = 'Customer License';
    DrillDownPageID = 50019;
    LookupPageID = 50019;

    fields
    {
        field(1;"Customer No.";Code[20])
        {
            NotBlank = true;
            TableRelation = Customer;
        }
        field(2;"Ship-to Code";Code[10])
        {
            TableRelation = "Ship-to Address".Code WHERE ("Customer No."=FIELD("Customer No."));
        }
        field(3;"Country/Region Code";Code[10])
        {
            TableRelation = "Country/Region";
        }
        field(4;County;Text[30])
        {
            Caption = 'State';
            TableRelation = "ARC County".Code WHERE ("Country/Region Code"=FIELD("Country/Region Code"));
        }
        field(6;"Locality Code";Code[20])
        {
            TableRelation = "ARC Locality".Code WHERE ("Country/Region Code"=FIELD("Country/Region Code"),
                                                 County=FIELD(County));
        }
        field(7;"Business Type Code";Code[10])
        {
            TableRelation = "ARC Business Type";
        }
        field(8;"License Type Code";Code[20])
        {
            TableRelation = "ARC License Type";
        }
        field(10;"License No.";Text[30])
        {
        }
        field(11;"Licensee Name";Text[50])
        {
        }
        field(12;"Expiration Date";Date)
        {
        }
        field(20;Exemption;Text[50])
        {
        }
        field(50;Comments;Boolean)
        {
            CalcFormula = Exist("ARC Customer Lic. Comment Line" WHERE ("Customer No."=FIELD("Customer No."),
                                                                       "Ship-to Code"=FIELD("Ship-to Code"),
                                                                       "Country/Region Code"=FIELD("Country/Region Code"),
                                                                       County=FIELD(County),
                                                                       "Locality Code"=FIELD("Locality Code"),
                                                                       "Business Type Code"=FIELD("Business Type Code"),
                                                                       "License Type Code"=FIELD("License Type Code"),
                                                                       "License No."=FIELD("License No.")));
            Description = 'Flowfield';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100;Restricted;Boolean)
        {
            CalcFormula = Exist("ARC Customer License CAS Code" WHERE ("Customer No."=FIELD("Customer No."),
                                                                   "Ship-to Code"=FIELD("Ship-to Code"),
                                                                   "Business Type Code"=FIELD("Business Type Code"),
                                                                   "License Type Code"=FIELD("License Type Code")));
            Description = 'Flowfield';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101;"Customer Name";Text[50])
        {
            CalcFormula = Lookup(Customer.Name WHERE ("No."=FIELD("Customer No.")));
            Description = 'Flowfield';
            Editable = false;
            FieldClass = FlowField;
        }
        field(102;"Ship-to City";Text[30])
        {
            CalcFormula = Lookup("Ship-to Address".City WHERE ("Customer No."=FIELD("Customer No."),
                                                               Code=FIELD("Ship-to Code")));
            Description = 'Flowfield';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Customer No.","Ship-to Code","Country/Region Code",County,"Locality Code","Business Type Code","License Type Code","License No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        CustomerLicenseCASCode.SETRANGE("Customer No.","Customer No.");
        CustomerLicenseCASCode.SETRANGE("Ship-to Code","Ship-to Code");
        CustomerLicenseCASCode.SETRANGE("Country/Region Code","Country/Region Code");
        CustomerLicenseCASCode.SETRANGE(County,County);
        CustomerLicenseCASCode.SETRANGE("Locality Code","Locality Code");
        CustomerLicenseCASCode.SETRANGE("Business Type Code","Business Type Code");
        CustomerLicenseCASCode.SETRANGE("License Type Code","License Type Code");
        CustomerLicenseCASCode.SETRANGE("License No.","License No.");
        CustomerLicenseCASCode.DELETEALL;

        CustomerLicenseCommentLine.SETRANGE("Customer No.","Customer No.");
        CustomerLicenseCommentLine.SETRANGE("Ship-to Code","Ship-to Code");
        CustomerLicenseCommentLine.SETRANGE("Country/Region Code","Country/Region Code");
        CustomerLicenseCommentLine.SETRANGE(County,County);
        CustomerLicenseCommentLine.SETRANGE("Locality Code","Locality Code");
        CustomerLicenseCommentLine.SETRANGE("Business Type Code","Business Type Code");
        CustomerLicenseCommentLine.SETRANGE("License Type Code","License Type Code");
        CustomerLicenseCommentLine.SETRANGE("License No.","License No.");
        CustomerLicenseCommentLine.DELETEALL;
    end;

    trigger OnRename();
    begin
        CustomerLicenseCASCode.SETRANGE("Customer No.","Customer No.");
        CustomerLicenseCASCode.SETRANGE("Ship-to Code","Ship-to Code");
        CustomerLicenseCASCode.SETRANGE("Country/Region Code","Country/Region Code");
        CustomerLicenseCASCode.SETRANGE(County,County);
        CustomerLicenseCASCode.SETRANGE("Locality Code","Locality Code");
        CustomerLicenseCASCode.SETRANGE("Business Type Code","Business Type Code");
        CustomerLicenseCASCode.SETRANGE("License Type Code","License Type Code");
        CustomerLicenseCASCode.SETRANGE("License No.","License No.");
        if not CustomerLicenseCASCode.ISEMPTY then
          ERROR(Text001);

        CustomerLicenseCommentLine.SETRANGE("Customer No.","Customer No.");
        CustomerLicenseCommentLine.SETRANGE("Ship-to Code","Ship-to Code");
        CustomerLicenseCommentLine.SETRANGE("Country/Region Code","Country/Region Code");
        CustomerLicenseCommentLine.SETRANGE(County,County);
        CustomerLicenseCommentLine.SETRANGE("Locality Code","Locality Code");
        CustomerLicenseCommentLine.SETRANGE("Business Type Code","Business Type Code");
        CustomerLicenseCommentLine.SETRANGE("License Type Code","License Type Code");
        CustomerLicenseCommentLine.SETRANGE("License No.","License No.");
        CustomerLicenseCommentLine.DELETEALL;
        if not CustomerLicenseCommentLine.ISEMPTY then
          ERROR(Text001);
    end;

    var
        CustomerLicenseCASCode : Record "ARC Customer License CAS Code";
        CustomerLicenseCommentLine : Record "ARC Customer Lic. Comment Line";
        Text001 : Label 'Rename not allowed';
}


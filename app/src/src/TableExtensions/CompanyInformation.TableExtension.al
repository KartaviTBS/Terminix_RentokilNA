tableextension 50010 "ARC Company Information" extends "Company Information"
{
    fields
    {
        field(50001; "ARC Company Identifier"; Code[50])
        {
            Caption = 'Company Identifier';
        }
        field(50002; "ARC Company Code"; Code[50])
        {
            Caption = 'Company Code';
        }
        field(50061; "ARC Remit to Name"; Text[50])
        {
            Caption = 'Remit to Name';
        }
        field(50062; "ARC Remit to Address"; Text[50])
        {
            Caption = 'Remit to Address';
        }
        field(50063; "ARC Remit to City"; Text[30])
        {
            Caption = 'Remit to City';
            TableRelation = IF("ARC Remit to Country/Region" = CONST ()) "Post Code".City ELSE IF("ARC Remit to Country/Region" = FILTER (<> '')) "Post Code".City WHERE ("Country/Region Code" = FIELD ("ARC Remit to Country/Region"));
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                PostCode : Record "Post Code";
            begin
                PostCode.ValidateCity("ARC Remit to City","ARC Remit to Post Code","ARC Remit to County","ARC Remit to Country/Region",(CurrFieldNo <> 0) AND GUIALLOWED);
            end;

            trigger OnLookup()
            var
                PostCode : Record "Post Code";
            begin
                PostCode.LookupPostCode(City,"Post Code",County,"Country/Region Code");
            end;
        }
        field(50064; "ARC Remit to County"; Text[30])
        {
            Caption = 'Remit to County';
        }
        field(50065; "ARC Remit to Post Code"; Code[20])
        {
            Caption = 'Remit to Post Code';
            TableRelation = IF ("ARC Remit to Country/Region"=CONST()) "Post Code" ELSE IF ("ARC Remit to Country/Region"=FILTER(<>'')) "Post Code" WHERE ("Country/Region Code"=FIELD("ARC Remit to Country/Region"));
            ValidateTableRelation = false;

            trigger OnValidate();
            var
                PostCode : Record "Post Code";
            begin
                PostCode.ValidatePostCode("ARC Remit to City","ARC Remit to Post Code","ARC Remit to County","ARC Remit to Country/Region",(CurrFieldNo <> 0) AND GUIALLOWED);  
            end;

            trigger OnLookup();
            var
                PostCode : Record "Post Code";
            begin
                PostCode.LookupPostCode("ARC Remit to City","ARC Remit to Post Code","ARC Remit to County","ARC Remit to Country/Region");
            end;
        }
        field(50066; "ARC Remit to Phone No."; Code[30])
        {
            Caption = 'Remit to Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(50067; "ARC Remit to Country/Region"; Code[70])
        {
            Caption = 'Remit to Country/Region';
            TableRelation = "Country/Region";

            trigger OnValidate();
            var
                PostCode : Record "Post Code";
            begin
                PostCode.CheckClearPostCodeCityCounty("ARC Remit to City","ARC Remit to Post Code","ARC Remit to County","ARC Remit to Country/Region",xRec."ARC Remit to Country/Region");   
            end;
        }    
    }
}
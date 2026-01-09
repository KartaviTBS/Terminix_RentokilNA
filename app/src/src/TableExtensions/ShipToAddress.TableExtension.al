tableextension 50008 "ARC Ship-to Address" extends "Ship-to Address"
{
    fields
    {
        field(50001; "ARC Locality Code"; Code[20])
        {
            Caption = 'Locality Code';
            TableRelation = "ARC Locality".Code where ("Country/Region Code" = FIELD ("Country/Region Code"),
                                            County = FIELD ("County"), "Post Code" = FIELD ("Post Code"));                                          
        }

        field(50002; "ARC Business Type Code"; Code[20])
        {
            Caption = 'Business Type Code';
            TableRelation = "ARC Customer Business Type"."Business Type Code" where ("Customer No." = FIELD ("Customer No."),
                                                                        "Ship-to Code" = FIELD (Code));
        }
        field(50003;"ARC Shipping Note";Text[250])
        {
            Caption = 'Shippping Note';
            
        }
        field(50061;"ARC Salesperson Code";Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
    }

}
page 50022 "ARC Customer License CAS List"
{
    PageType = List;
    SourceTable = "ARC Customer License CAS Code";
    Caption = 'Customer License CAS List';
    RefreshOnActivate = true;
    

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Editable = CustNoEditable;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    ApplicationArea = All;
                    Editable = ShipToCodeEditable;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                    Editable = CountryEditable;
                }
                field(County; County)
                {
                    ApplicationArea = All;
                    Editable = CountyEditable;
                }
                field("Locality Code"; "Locality Code")
                {
                    ApplicationArea = All;
                    Editable = LocalityCodeEditable;
                }
                field("Locality Description"; "Locality Description")
                {
                    ApplicationArea = All;
                }
                field("Business Type Code"; "Business Type Code")
                {
                    ApplicationArea = All;
                    Editable = BusTypeCodeEditable;
                }
                field("Product Type Restriction Code"; "Product Type Restriction Code")
                {
                    ApplicationArea = All;
                    Editable = ProdTypeRestCodeEditable;
                }
                field("License Type Code"; "License Type Code")
                {
                    ApplicationArea = All;
                    Editable = LicTypeCodeEditable;
                }
                field("License No."; "License No.")
                {
                    ApplicationArea = All;
                    Editable = LicenseNoEditable;
                }
                field("CAS Code"; "CAS Code")
                {
                    ApplicationArea = All;
                    Editable = CasCodeEditable;
                }
                field("Chemical Name"; "Chemical Name")
                {
                    ApplicationArea = All;
                }

            }
        }

    }

    [Scope('Personalization')]
    procedure SetFields(CalledFrom: Integer);
    begin
        case CalledFrom of
            Database::"ARC CAS" :
            begin
                CustNoEditable := true;
                ShipToCodeEditable := true;
                CountryEditable := true;
                CountyEditable := true;
                LocalityCodeEditable := true;
                BusTypeCodeEditable := true;
                ProdTypeRestCodeEditable := true;
                LicTypeCodeEditable := true;
                LicenseNoEditable := true;
                CasCodeEditable := false;
            end;

            Database::"ARC Customer License" :
            begin
                CustNoEditable := false;
                ShipToCodeEditable := false;
                CountryEditable := false;
                CountyEditable := false;
                LocalityCodeEditable := false;
                BusTypeCodeEditable := false;
                ProdTypeRestCodeEditable := true;
                LicTypeCodeEditable := false;
                LicenseNoEditable := false;
                CasCodeEditable := true;
            end;
        end;
    end;

    var
        CustNoEditable: Boolean;
        ShipToCodeEditable: Boolean;
        CountryEditable: Boolean;
        CountyEditable: Boolean;
        LocalityCodeEditable: Boolean;
        BusTypeCodeEditable: Boolean;
        ProdTypeRestCodeEditable: Boolean;
        LicTypeCodeEditable: Boolean;
        LicenseNoEditable: Boolean;
        CasCodeEditable: Boolean;

}
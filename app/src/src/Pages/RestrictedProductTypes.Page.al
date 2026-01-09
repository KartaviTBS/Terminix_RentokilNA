page 50018 "ARC Restricted Product Types"
{
    PageType = List;
    SourceTable = "ARC Restricted Prod. Lic. Type";
    Caption = 'Restricted Product Types';
    RefreshOnActivate = true;
    UsageCategory = Lists;
    
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("License Type Code"; "License Type Code")
                {
                    ApplicationArea = All;
                    Visible = LicenseTypeCodeVisible;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                    Visible = CountryRegionVisible;
                }
                field(County; County)
                {
                    ApplicationArea = All;
                    Visible = CountyVisible;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    Visible = PostCodeVisible;
                }
                field("Locality Code"; "Locality Code")
                {
                    ApplicationArea = All;
                    Visible = LocalityVisible;
                }
                field("Business Type Code"; "Business Type Code")
                {
                    ApplicationArea = All;
                }
                field("Product Type Restriction Code"; "Product Type Restriction Code")
                {
                    ApplicationArea = All;
                }
            }
        }

    }

    trigger OnOpenPage();
    begin 
        if not ExternallyCalled then begin 
            BusTypeCodeVisible := true;
            LicenseTypeCodeVisible := true;
            CountryRegionVisible := true;
            CountyVisible := true;
            PostCodeVisible := true;
            LocalityVisible := true;
        end;
    end;

    [Scope('Personalization')]
    procedure SetFields(CalledFrom: Integer);
    begin
        ExternallyCalled := true;

        case CalledFrom of
               Database::"ARC Business Type" :
        begin
            BusTypeCodeVisible := false;
            LicenseTypeCodeVisible := true;
            CountryRegionVisible := true;
            CountyVisible := true;
            PostCodeVisible := true;
            LocalityVisible := true;

        end;
        Database::"ARC License Type" :
        begin
            BusTypeCodeVisible := false;
            LicenseTypeCodeVisible := false;
            CountryRegionVisible := false;
            CountyVisible := false;
            PostCodeVisible := false;
            LocalityVisible := true;
        end;
        end;
    end;

    var
        BusTypeCodeVisible: Boolean;
        LicenseTypeCodeVisible: Boolean;
        CountryRegionVisible: Boolean;
        CountyVisible: Boolean;
        PostCodeVisible: Boolean;
        LocalityVisible: Boolean;
         ExternallyCalled: Boolean;

}
page 50017 "ARC Product Use License Types"
{
    PageType = List;
    SourceTable = "ARC Product Use License Type";
    Caption = 'Product Use License Type List';
    RefreshOnActivate = true;
    DelayedInsert = true;
    ApplicationArea = All;
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
                    Editable = LicenseTypeCodeEditable;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                    Editable = CountryRegionEditable;
                }
                field(County; County)
                {
                    ApplicationArea = All;
                    Editable = CountyEditable;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    Editable = PostCodeEditable;
                }
                field("Locality Code"; "Locality Code")
                {
                    ApplicationArea = All;
                    Editable = LocalityEditable;
                }
                field("Business Type Code"; "Business Type Code")
                {
                    ApplicationArea = All;
                }
                field("Product Use"; "Product Use")
                {
                    ApplicationArea = All;
                }
            }
        }

    }

    trigger OnOpenPage();
    begin
        if not ExternalyCalled then begin
            BusTypeCodeEditable := true;
            LicenseTypeCodeEditable := true;
            CountryRegionEditable := true;
            CountyEditable := true;
            PostCodeEditable := true;
            LocalityEditable := true;
        end;
    end;

    [Scope('Personalization')]
    procedure SetFields(CalledFrom: Integer);
    begin
        ExternalyCalled := true;
        case CalledFrom of
            Database::"ARC Business Type" :
        begin
            BusTypeCodeEditable := false;
            LicenseTypeCodeEditable := true;
            CountryRegionEditable := true;
            CountyEditable := true;
            PostCodeEditable := true;
            LocalityEditable := true;

        end;
        Database::"ARC License Type" :
        begin
            BusTypeCodeEditable := false;
            LicenseTypeCodeEditable := false;
            CountryRegionEditable := false;
            CountyEditable := false;
            PostCodeEditable := false;
            LocalityEditable := true;
        end;
        end;
    end;

    var
        BusTypeCodeEditable: Boolean;
        LicenseTypeCodeEditable: Boolean;
        CountryRegionEditable: Boolean;
        CountyEditable: Boolean;
        PostCodeEditable: Boolean;
        LocalityEditable: Boolean;
        ExternalyCalled: Boolean;
}
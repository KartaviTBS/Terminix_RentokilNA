page 50016 "ARC Cust. Business Type List"
{
    PageType = List;
    SourceTable = "ARC Customer Business Type";
    Caption = 'Customer Business Type List';
    DelayedInsert = true;
    RefreshOnActivate = true;
    ApplicationArea = All;
    UsageCategory = Lists;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Visible = CustomerNoVisible;
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = All;
                    Visible = CustomerNameVisible;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    ApplicationArea = All;
                    Visible = ShipToCodeVisible;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(County; County)
                {
                    ApplicationArea = All;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                }
                field("Locality Code"; "Locality Code")
                {
                    ApplicationArea = All;
                }
                field("Business Type Code"; "Business Type Code")
                {
                    ApplicationArea = All;
                    Visible = BusTypeCodeVisible;
                }

            }
        }

    }

    trigger OnOpenPage();
    begin
        if not ExternallyCalled then begin
            BusTypeCodeVisible := true;
            CustomerNoVisible := true;
            CustomerNameVisible := true;
            ShipToCodeVisible := true;
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
            CustomerNoVisible := true;
            CustomerNameVisible := true;
            ShipToCodeVisible := true;
        end;
        Database::Customer :
        begin
            BusTypeCodeVisible := true;
            CustomerNoVisible := false;
            CustomerNameVisible := true;
            ShipToCodeVisible := true;

        end;
        Database::"Ship-to Address" :
        begin
            BusTypeCodeVisible := true;
            CustomerNoVisible := false;
            CustomerNameVisible := false;
            ShipToCodeVisible := true;
        end;
        end;
    end;

    var
        BusTypeCodeVisible: Boolean;
        CustomerNoVisible: Boolean;
        CustomerNameVisible: Boolean;
        ShipToCodeVisible: Boolean;
        ExternallyCalled: Boolean;


}
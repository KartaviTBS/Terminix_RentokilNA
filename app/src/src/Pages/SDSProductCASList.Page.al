page 50006 "ARC SDS Product CAS List"
{
    PageType = List;
    SourceTable = "ARC SDS Product CAS";
    Caption = 'SDS Product CAS List';
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("SDS Product Code"; "SDS Product Code")
                {
                    ApplicationArea = All;
                    Visible = SDSProductCodeVisible;
                }
                field("CAS Code"; "CAS Code")
                {
                    ApplicationArea = All;
                    Visible = CasCodeVisible;
                }
                field("Ingredient %"; "Ingredient %")
                {
                    ApplicationArea = All;
                }
                field("SDS Product Description"; "SDS Product Description")
                {
                    ApplicationArea = All;
                }
                field("CAS Chemical Name"; "CAS Chemical Name")
                {
                    ApplicationArea = All;
                }
                field(Restricted; Restricted)
                {
                    ApplicationArea = All;
                }
            }
        }

        
    }

    trigger OnOpenPage()
    begin
        if not ExternallyCalled then begin
            CasCodeVisible := true;
            SDSProductCodeVisible := true;
        end;
    end;

    [Scope('Personalization')]
    procedure SetFields(CalledFrom: Integer)
    begin
        ExternallyCalled := true;
        case CalledFrom of
            Database::"ARC CAS" :
            begin
                CasCodeVisible := false;
                SDSProductCodeVisible := true;                
            end;

            Database::"ARC SDS Product" :
            begin
                CasCodeVisible := true;
                SDSProductCodeVisible := false;
            end;
            else begin
                CasCodeVisible := true;
                SDSProductCodeVisible := true;
            end;
        end;
    end;

    var
        CasCodeVisible : Boolean;
        SDSProductCodeVisible: Boolean;
        ExternallyCalled: Boolean;


}
page 50051 "ARC NAPC Bill of Lading"
{

    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "ARC NAPC BOL Header";
    Caption = 'NAPC Bill of Lading';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Source Doc. Type"; "Source Doc. Type")
                {
                    ApplicationArea = All;
                }
                field("Source Doc. No."; "Source Doc. No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = All;
                }
                field("E-Ship Agent Service"; "E-Ship Agent Service")
                {
                    ApplicationArea = All;
                }
                field("Manifest No."; "Manifest No.")
                {
                    ApplicationArea = All;
                }
            }
            group("Ship-to")
            {


                field("Ship-to Type"; "Ship-to Type")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Source No."; "Ship-to Source No.")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Name 2"; "Ship-to Name 2")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Address"; "Ship-to Address")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Address 2"; "Ship-to Address 2")
                {
                    ApplicationArea = All;
                }
                field("Ship-to City"; "Ship-to City")
                {
                    ApplicationArea = All;
                }
                field("Ship-to County"; "Ship-to County")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Post Code"; "Ship-to Post Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Country/Region Code"; "Ship-to Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Contact"; "Ship-to Contact")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Phone No."; "Ship-to Phone No.")
                {
                    ApplicationArea = All;
                }
            }
            group("Ship-from")
            {
                field("Ship-from Type"; "Ship-from Type")
                {
                    ApplicationArea = All;
                }
                field("Ship-from Source No."; "Ship-from Source No.")
                {
                    ApplicationArea = All;
                }
                field("Ship-from Code"; "Ship-from Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-from Name"; "Ship-from Name")
                {
                    ApplicationArea = All;
                }
                field("Ship-from Name 2"; "Ship-from Name 2")
                {
                    ApplicationArea = All;
                }
                field("Ship-from Address"; "Ship-from Address")
                {
                    ApplicationArea = All;
                }
                field("Ship-from Address 2"; "Ship-from Address 2")
                {
                    ApplicationArea = All;
                }
                field("Ship-from City"; "Ship-from City")
                {
                    ApplicationArea = All;
                }
                field("Ship-from County"; "Ship-from County")
                {
                    ApplicationArea = All;
                }
                field("Ship-from Post Code"; "Ship-from Post Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-from Country/Region Code"; "Ship-from Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-from Contact"; "Ship-from Contact")
                {
                    ApplicationArea = All;
                }
                field("Ship-from Phone No."; "Ship-from Phone No.")
                {
                    ApplicationArea = All;
                }

            }
            part(BOLLines; "ARC NAPC BOL Subform")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Document No." = field ("No.");
                UpdatePropagation = Both;
            }
        }
    }
    actions
    {
        area(reporting)
        {
            Action(BOLReport)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bill Of Lading Report';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";

                trigger OnAction()
                var
                    SalesShptHeader: Record "Sales Shipment Header";
                    NAPCBOLSalesShipment: Report "ARC NAPC BOL Report";
                    NAPCBOLHeader: Record "ARC NAPC BOL Header";
                    NAPCBOLCustomerShipment: Report "ARC NAPC BOL Customer Report";
                    TransferShptHeader: Record "Transfer Shipment Line";
                    NAPCBOLTransferShipment: Report "ARC NAPC BOL Transfer Report";

                begin
                    case "Source Doc. Type" of
                        "Source Doc. Type"::"Sales Shipment" :
                    begin
                        if SalesShptHeader.Get("Source Doc. No.") then begin
                            SalesShptHeader.SetRecFilter;
                            NAPCBOLSalesShipment.SetTableView(SalesShptHeader);
                            NAPCBOLSalesShipment.Run;
                        end;
                    end;
                    "Source Doc. Type"::" " :
                    begin
                        NAPCBOLHeader.Get("No.");
                        NAPCBOLHeader.SetRecFilter;
                        NAPCBOLCustomerShipment.SetTableView(NAPCBOLHeader);
                        NAPCBOLCustomerShipment.Run;
                    end;
                    "Source Doc. Type"::"Transfer Shipment" :
                        if TransferShptHeader.Get("Source Doc. No.") then begin
                            TransferShptHeader.SetRecFilter;
                            NAPCBOLTransferShipment.SetTableView(TransferShptHeader);
                            NAPCBOLTransferShipment.Run;
                        end;
                    end;
                end;
            }
        }
    }

}

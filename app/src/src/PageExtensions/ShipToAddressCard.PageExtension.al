pageextension 50008 "ARC Ship-to Address" extends "Ship-to Address"
{
    layout
    {
       addafter(Name)
        {
            field("Name 2";"Name 2")
            {
                ApplicationArea = All;
            }
        }
        
        addafter("Post Code")
        {
            field("ARC Locality Code"; "ARC Locality Code")
            {
                ApplicationArea = All;
            }
            field("ARC Business Type Code"; "ARC Business Type Code")
            {
                ApplicationArea = All;
            }

        }
       
        addlast(General)
        {
            field("ARC Salesperson Code"; "ARC Salesperson Code")
            {
                Importance = Promoted;
                ApplicationArea = All;
            }
            group("Shipping Note")
            {
                Caption = 'Shipping Note';
                field("ARC Shipping Note"; "ARC Shipping Note")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    MultiLine = true;
                    ShowCaption = false;

                }
            }
        }    
        
        modify("Tax Liable")
        {
            Enabled = false;
        }
        modify("Tax Area Code")
        {
            Enabled = false;
        }
        modify("CCH Exemption Code")
        {
            Enabled = false;
        }        
    }


    actions
    {
        addlast("&Address")
        {
            group(Regulatory)
            {
                Caption = '&Regulatory';
                Image = ProductDesign;
                action("ARCBusinessTypes")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Business Types';
                    Image = BusinessRelation;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;



                    trigger OnAction();
                    var
                        CustomerBusinessType: Record "ARC Customer Business Type";
                        CustomerBusinessTypeList: Page "ARC Cust. Business Type List";
                    begin

                        CLEAR(CustomerBusinessTypeList);
                        CustomerBusinessType.SetRange("Customer No.", "Customer No.");
                        CustomerBusinessType.SetRange("Ship-to Code", Code);
                        CustomerBusinessTypeList.SetFields(DATABASE::"Ship-to Address");
                        CustomerBusinessTypeList.SetTableView(CustomerBusinessType);
                        CustomerBusinessTypeList.RunModal;

                    end;

                }
                action("ARCLocalities")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Localities';
                    Image = ShipAddress;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "ARC Localities";
                    RunPageLink = "Country/Region Code" = FIELD ("Country/Region Code"), County = FIELD (County), "Post Code" = FIELD ("Post Code");
                    RunPageView = sorting ("Country/Region Code", County, "Post Code", Code);

                }
                action("ARCLicenses")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Licenses';
                    Image = LimitedCredit;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "ARC Customer License List";
                    RunPageLink = "Customer No." = FIELD ("Customer No."), "Ship-to Code" = FIELD (Code);

                }
            }
        }
    }
}
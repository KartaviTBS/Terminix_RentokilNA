pageextension 50014 "ARC Ship-to Address List" extends "Ship-to Address List"
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
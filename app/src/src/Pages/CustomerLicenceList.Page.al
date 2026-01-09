page 50019 "ARC Customer License List"
{
    PageType = List;
    SourceTable = "ARC Customer License";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Customer Licenses List';
    RefreshOnActivate = true;
    DelayedInsert = true;
    PromotedActionCategories = 'New,Process,Report,Navigate';
    CardPageId = "ARC Customer License Card";
    
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to City"; "Ship-to City")
                {
                    ApplicationArea = All;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(County; County)
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
                }
                field("License Type Code"; "License Type Code")
                {
                    ApplicationArea = All;
                }
                field("License No."; "License No.")
                {
                    ApplicationArea = All;
                }
                field("Licensee Name"; "Licensee Name")
                {
                    ApplicationArea = All;
                }
                field("Expiration Date"; "Expiration Date")
                {
                    ApplicationArea = All;
                }
                field(Comments; Comments)
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

    actions
    {
        area(Navigation)
        {
            action(CommentsAct)
            {
                ApplicationArea = All;
                Caption = 'Comments';
                Image = ViewComments;
                Promoted = true;
                PromotedCategory = Category4;
                RunObject = Page "ARC Cust. Lic. Comments Part";
                RunPageLink = "Customer No." = FIELD ("Customer No.");
            }
            action(CASList)
            {
                ApplicationArea = All;
                Caption = 'CAS List';
                Image = CheckList;
                Promoted = true;
                PromotedCategory = Category4;


                trigger OnAction()
                var
                    CustLicenseCASCode: Record "ARC Customer License CAS Code";
                    CustLicenseCASList: page "ARC Customer License CAS List";
                begin
                    Clear(CustLicenseCASList);
                    CustLicenseCASCode.SetRange("Customer No.", "Customer No.");
                    CustLicenseCASCode.SetRange("Ship-to Code", "Ship-to Code");
                    CustLicenseCASCode.SetRange("Country/Region Code", "Country/Region Code");
                    CustLicenseCASCode.SetRange(County, County);
                    CustLicenseCASCode.SetRange("Locality Code", "Locality Code");
                    CustLicenseCASCode.SetRange("Business Type Code", "Business Type Code");
                    CustLicenseCASCode.SetRange("License Type Code", "License Type Code");
                    CustLicenseCASCode.SetRange("License No.", "License No.");
                    CustLicenseCASList.SetTableView(CustLicenseCASCode);
                    CustLicenseCASList.SetFields(DATABASE::"ARC Customer License");
                    CustLicenseCASList.RunModal;
                end;
            }
        }
    }
}
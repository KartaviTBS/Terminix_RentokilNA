page 50015 "ARC Business Types"
{
    PageType = List;
    SourceTable = "ARC Business Type";
    Caption = 'Business Types';
    RefreshOnActivate = true;
    ApplicationArea = All;
    PromotedActionCategories = 'New,Process,Report,Navigate';
    UsageCategory = Lists;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
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
            action(Customers)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Customers';
                Image = CustomerList;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    CustBusType: Record "ARC Customer Business Type";
                    CustBusTypeList: Page "ARC Cust. Business Type List";
                begin
                    Clear(CustBusTypeList);
                    CustBusType.Reset;
                    CustBusType.SetRange("Business Type Code", Code);
                    CustBusTypeList.SetTableView(CustBusType);
                    CustBusTypeList.SetFields(Database::"ARC Business Type");
                    CustBusTypeList.RunModal;
                end;
            }
            action(ProductUses)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Product Uses';
                Image = ItemGroup;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    ProdUseLicType: Record "ARC Product Use License Type";
                    ProdUseLicTypes: Page "ARC Product Use License Types";
                begin
                    Clear(ProdUseLicTypes);
                    ProdUseLicType.Reset;
                    ProdUseLicType.SetRange("Business Type Code", Code);
                    ProdUseLicTypes.SetTableView(ProdUseLicType);
                    ProdUseLicTypes.SetFields(Database::"ARC Business Type");
                    ProdUseLicTypes.RunModal;
                end;
            }
            action(RestrictedProductUses)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Restricted Product Types';
                Image = ItemRegisters;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    RestrictedProdLicType: Record "ARC Restricted Prod. Lic. Type";
                    RestrictedProdTypes: Page "ARC Restricted Product Types";
                begin
                    Clear(RestrictedProdLicType);
                    RestrictedProdLicType.Reset;
                    RestrictedProdLicType.SetRange("Business Type Code", Code);
                    RestrictedProdTypes.SetTableView(RestrictedProdLicType);
                    RestrictedProdTypes.SetFields(Database::"ARC Business Type");
                    RestrictedProdTypes.RunModal;
                end;
            }
        }
    }
}
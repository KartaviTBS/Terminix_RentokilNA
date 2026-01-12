page 50003 "ARC SDS Product Card"
{
    PageType = Card;
    SourceTable = "ARC SDS Product";
    Caption = 'SDS Product Card';
    RefreshOnActivate = true;
    PromotedActionCategories = 'New,Process,Report,Navigate';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Manufacturer Code"; "Manufacturer Code")
                {
                    ApplicationArea = All;
                }
                field("Revision Date"; "Revision Date")
                {
                    ApplicationArea = All;
                }
                field("Matter State"; "Matter State")
                {
                    ApplicationArea = All;
                }
                field("EPA Code"; "EPA Code")
                {
                    ApplicationArea = All;
                }
                field("Hazard Class Code"; "Hazard Class Code")
                {
                    ApplicationArea = All;
                }
                field("NFPA Placard Health Code"; "NFPA Placard Health Code")
                {
                    ApplicationArea = All;
                }
                field("NFPA Placard Flame Code"; "NFPA Placard Flame Code")
                {
                    ApplicationArea = All;
                }
                field("NFPA Placard Reactive Code"; "NFPA Placard Reactive Code")
                {
                    ApplicationArea = All;
                }
                field(Chronic; Chronic)
                {
                    ApplicationArea = All;
                }
                field("Product Use"; "Product Use")
                {
                    ApplicationArea = All;
                }
                field("CAS Ingredients"; "CAS Ingredients")
                {
                    ApplicationArea = All;
                }
                field("License Types"; "License Types")
                {
                    ApplicationArea = All;
                }
                field("BOL/UN/Ground Code"; "BOL/UN/Ground Code")
                {
                    ApplicationArea = All;
                }
                field("BOL/UN/Air Code"; "BOL/UN/Air Code")
                {
                    ApplicationArea = All;
                }
                field("BOL/UN/Water Code"; "BOL/UN/Water Code")
                {
                    ApplicationArea = All;
                }

            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&SDS Product")
            {
                Caption = '&SDS Product';
                Image = ProductDesign;
                action("Ship-From Blocks")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'SDS Ship-From Blocks';
                    Image = ShipAddress;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        SDSShipFromBlock: Record "ARC SDS Ship-from Block";   
                        SDSShipFromBlocks: page "ARC SDS Ship-From Block List";                    
                    begin
                        Clear(SDSShipfromBlocks);
                        SDSShipfromBlock.SetRange("SDS Code",Code);
                        SDSShipfromBlocks.SetTableView(SDSShipfromBlock);
                        SDSShipfromBlocks.SetFields(Database::"ARC SDS Product");
                        SDSShipfromBlocks.RunModal
                    end;


                }
                action("SDS Region Blocks")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'SDS Region Blocks';
                    Image = CountryRegion;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var                        
                        SDSRegionBlock: Record "ARC SDS Region Block";                       
                        SDSRegionBlocks: Page "ARC SDS Region Blocks";
                    begin
                        CLEAR(SDSRegionBlocks);
                        SDSRegionBlock.SetRange("SDS Code",Code);
                        SDSRegionBlocks.SetTableView(SDSRegionBlock);
                        SDSRegionBlocks.SetFields(Database::"ARC SDS Product");
                        SDSRegionBlocks.RunModal;
                    end;
                    

                }
                action("CAS List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'CAS List';
                    Image = ShipAddress;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger onAction()
                    var                        
                        SDSProductCAS: Record "ARC SDS Product CAS";      
                        SDSProductCASList: Page "ARC SDS Product CAS List";                  
                    begin
                        CLEAR(SDSProductCASList);
                        SDSProductCAS.SetRange("SDS Product Code",Code);
                        SDSProductCASList.SetTableView(SDSProductCAS);
                        SDSProductCASList.SetFields(Database::"ARC SDS Product");
                        SDSProductCASList.RunModal
                    end;
                    
                }
            }
        }
    }

}
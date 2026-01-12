page 50077 "ARC Location Priorities"
{
    // SOW11 Körber Edge WMS Integration / RDCs (Regional Distribution Centers) located in Charlotte, NC and Salt Lake City, UT
    //   agreement between ArcherPoint and Rentokil-NA executed 29 Mar 2022
    //   reference:
    //     Case 109188 Sales Order Item Routing
    //     CO1 Sales Order Item Routing - Reqmnt 1 Loc Priority
    //     CO4 Order Management
    // table 50077 "ARC Location Priority" marked obsolete b/c of fields/PK/destructiveSchemaChange - Tue 11 Oct 2022
    // table 50079 "ARC Location Pri. Ver.20221011" will be leveraged going forward - Tue 11 Oct 2022

    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    DelayedInsert = true;
    SourceTable = "ARC Location Pri. Ver.20221011";
    Caption = 'Location Priorities';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sales Line Location Code"; Rec."Sales Line Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = '(PK1) Specifies the Location Code that defaults on the Sales Line from Customer or Ship-to Address';

                    trigger OnDrillDown()
                    begin
                        Rec.TestField("Sales Line Location Code");
                        LocationPriorityMgt.ShowLocation(Rec."Sales Line Location Code");
                    end;
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    ToolTip = '(PK2) Specifies the priority or search order; the lower the value, the higher the priority';
                }
                field("Override Location Code"; Rec."Override Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Override Location Code that will REPLACE the default location code on sales orders';

                    trigger OnDrillDown()
                    begin
                        Rec.TestField("Override Location Code");
                        LocationPriorityMgt.ShowLocation(Rec."Override Location Code");
                    end;
                }
            }
        }
        area(factboxes)
        {
        }
    }

    actions
    {
        area(Processing)
        {
            action(MoreInformation)
            {
                ApplicationArea = All;
                Image = Info;
                Caption = 'More Information';
                ToolTip = 'Displays source table information';

                trigger OnAction()
                begin
                    Message('source table 50079 "ARC Location Pri. Ver.20221011" results from refactoring - SOW11 Körber Edge WMS, CO1 Sales Order Item Routing, Reqmnt 1 Loc Priority; CO4 Order Mgt - Tue 11 Oct 2022');
                end;
            }
        }
    }

    var
        LocationPriorityMgt: Codeunit "ARC LocationPriorityMgt";
}
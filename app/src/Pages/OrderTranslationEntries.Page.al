page 50078 "ARC Order Translation Entries"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    SourceTable = "ARC Order Translation Entry";
    //DeleteAllowed = false;
    //InsertAllowed = false;
    //ModifyAllowed = false;
    ShowFilter = true;
    Editable = false;
    Caption = 'Order Translation Entries';

    layout
    {
        area(content)
        {
            group(Filters)
            {
                Visible = false;

                field(CustNoFilter; CustNoFilter)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify a Customer No. filter';
                    Caption = 'Customer No. Filter';

                    trigger OnValidate()
                    begin
                        Rec.Reset();
                        Rec.Ascending(false);  // show most recent first
                        if CustNoFilter <> '' then begin
                            Rec.SetCurrentKey("Sell-to Customer No.");
                            Rec.SetFilter("Sell-to Customer No.",'@*' + CustNoFilter + '*');
                            Rec.Ascending(true);
                        end;
                        Clear(DocNoFilter);
                        Clear(ExtDocNoFilter);
                        Clear(UpdDocNoFilter);
                        CurrPage.Update(false);
                    end;
                }
                field(DocNoFilter; DocNoFilter)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify a Document No. filter (original Order No. comprising the entirety of the order, prior to split)';
                    Caption = 'Document No. Filter';

                    trigger OnValidate()
                    begin
                        Rec.Reset();
                        Rec.Ascending(false);  // show most recent first
                        if DocNoFilter <> '' then begin
                            Rec.SetCurrentKey("Document Area","Document Type","Document No.");
                            Rec.SetRange("Document Area",Rec."Document Area"::Sales);
                            Rec.SetRange("Document Type",Rec."Document Type"::Order);
                            Rec.SetFilter("Document No.",'@*' + DocNoFilter + '*');
                            Rec.Ascending(true);
                        end;
                        Clear(CustNoFilter);
                        Clear(ExtDocNoFilter);
                        Clear(UpdDocNoFilter);
                        CurrPage.Update(false);
                    end;
                }
                field(UpdDocNoFilter; UpdDocNoFilter)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify an Updated Document No. filter (after the original order was split)';
                    Caption = 'Updated Doc. No. Filter';

                    trigger OnValidate()
                    begin
                        Rec.Reset();
                        Rec.Ascending(false);  // show most recent first
                        if UpdDocNoFilter <> '' then begin
                            Rec.SetCurrentKey("Updated Document No.");
                            Rec.SetFilter("Updated Document No.",'@*' + UpdDocNoFilter + '*');
                            Rec.Ascending(true);  // show in Line No. order
                        end;
                        Clear(CustNoFilter);
                        Clear(DocNoFilter);
                        Clear(ExtDocNoFilter);
                        CurrPage.Update(false);
                    end;
                }
                field(ExtDocNoFilter; ExtDocNoFilter)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify an External Document No. filter';
                    Caption = 'Ext. Doc. No. Filter';

                    trigger OnValidate()
                    begin
                        Rec.Reset();
                        Rec.Ascending(false);  // show most recent first
                        if ExtDocNoFilter <> '' then begin
                            Rec.SetCurrentKey("External Document No.");
                            Rec.SetFilter("External Document No.",'@*' + ExtDocNoFilter + '*');
                            Rec.Ascending(true);  // show in Line No. order
                        end;
                        Clear(CustNoFilter);
                        Clear(DocNoFilter);
                        Clear(UpdDocNoFilter);
                        CurrPage.Update(false);
                    end;
                }
            }
            group(Entries1)
            {
                Caption = 'Entries';

                repeater(Entries)
                {
                    field("Entry No."; Rec."Entry No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Entry No.';
                    }
                    field("Document Area"; Rec."Document Area")
                    {
                        ApplicationArea = All;
                        Visible = false;
                        Editable = false;
                        ToolTip = 'Specifies the Document Area';
                    }
                    field("Document Type"; Rec."Document Type")
                    {
                        ApplicationArea = All;
                        Visible = false;
                        Editable = false;
                        ToolTip = 'Specifies the Document Type';
                    }
                    field("Document No."; Rec."Document No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the original Document No.';

                        trigger OnDrillDown()
                        begin
                            OrderMgt.ShowDocument(Rec);
                        end;
                    }
                    field("Document Line No."; Rec."Document Line No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the Document Line No.';
                    }
                    field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the Sell-to Customer No.';
                    }
                    field("Customer Name"; Rec."Customer Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Customer Name';
                    }
                    field("External Document No."; Rec."External Document No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the External Document No.';
                    }
                    field("Location Code"; Rec."Location Code")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the original Location Code';

                        trigger OnDrillDown()
                        begin
                            OrderMgt.ShowLocation(Rec."Location Code");
                        end;
                    }
                    field(Type; Rec.Type)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the Type';
                    }
                    field("No."; Rec."No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the No.';

                        trigger OnDrillDown()
                        begin
                            OrderMgt.ShowNo(Rec);
                        end;
                    }
                    field("Item Description"; Rec."Item Description")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Item Description';
                    }
                    field("Item Description 2"; Rec."Item Description 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Item Description 2';
                    }
                    field(Quantity; Rec.Quantity)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the Quantity';
                    }
                    field("Unit of Measure Code"; Rec."Unit of Measure Code")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the Unit of Measure Code';
                    }
                    field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the Qty. per Unit of Measure';
                    }
                    field("Quantity (Base)"; Rec."Quantity (Base)")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the Quantity in the base unit of measure';
                    }
                    field("Payment Terms Code"; Rec."Payment Terms Code")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the Payment Terms Code';
                    }
                    field("Updated Document No."; Rec."Updated Document No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the updated Document No.';

                        trigger OnDrillDown()
                        begin
                            OrderMgt.ShowUpdatedDocument(Rec);
                        end;
                    }
                    field("Updated Document Line No."; Rec."Updated Document Line No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the updated Document Line No.';
                    }
                    field("Updated Location Code"; Rec."Updated Location Code")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the updated Location Code';

                        trigger OnDrillDown()
                        begin
                            OrderMgt.ShowLocation(Rec."Updated Location Code");
                        end;
                    }
                    field("Updated Document Exists"; Rec."Updated Document Exists")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether the open document still exists';
                    }
                    field("Updated Status"; Rec."Updated Status")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the current Status of the document (Open, Released)';
                    }
                    field("Created by"; Rec."Created by")
                    {
                        ApplicationArea = All;
                        Style = Subordinate;
                        ToolTip = 'Specifies the credential that created the entry';
                    }
                    field("Created at Date"; Rec."Created at Date")
                    {
                        ApplicationArea = All;
                        Style = Subordinate;
                        ToolTip = 'Specifies the date the entry was created';
                    }
                    field("Created at DateTime"; Rec."Created at DateTime")
                    {
                        ApplicationArea = All;
                        Style = Subordinate;
                        ToolTip = 'Specifies the date and time the entry was created';
                    }
                    field("Created at Time"; Rec."Created at Time")
                    {
                        ApplicationArea = All;
                        Visible = false;
                        Style = Subordinate;
                        ToolTip = 'Specifies the time the entry was created';
                    }
                    field(Analyze; Rec.Analyze)
                    {
                        ApplicationArea = All;
                        Style = StrongAccent;
                        ToolTip = 'Specifies whether the entry should be analyzed';
                    }
                    field(Analyzed; Rec.Analyzed)
                    {
                        ApplicationArea = All;
                        Style = StrongAccent;
                        ToolTip = 'Specifies whether the entry was analyzed';
                    }
                    field("Analyzed at DateTime"; Rec."Analyzed at DateTime")
                    {
                        ApplicationArea = All;
                        Style = StrongAccent;
                        ToolTip = 'Specifies the date and time the entry was analyzed';
                    }
                    field("Analyzed No. of Attempts"; Rec."Analyzed No. of Attempts")
                    {
                        ApplicationArea = All;
                        Style = StrongAccent;
                        ToolTip = 'Specifies the no. of attempts made to analyze';
                    }
                    field("Analyzed Duration"; Rec."Analyzed Duration")
                    {
                        ApplicationArea = All;
                        Style = StrongAccent;
                        ToolTip = 'Specifies the duration of the analysis';
                    }
                    field("Analyzed Error Text"; Rec."Analyzed Error Text")
                    {
                        ApplicationArea = All;
                        Style = StrongAccent;
                        ToolTip = 'Specifies any error text associated with the analysis';

                        trigger OnDrillDown()
                        begin
                            Message(Rec."Analyzed Error Text");
                        end;
                    }
                    field("Analyzed Data Entry No."; Rec."Analyzed Data Entry No.")
                    {
                        ApplicationArea = All;
                        Style = StrongAccent;
                        ToolTip = 'Specifies any text recorded during the analytical process';

                        trigger OnDrillDown()
                        var
                            _DataMgt: Codeunit "ARC DataMgt";
                        begin
                            Rec.TestField("Analyzed Data Entry No.");
                            _DataMgt.ShowValueFromEntryNo(Rec."Analyzed Data Entry No.");
                        end;
                    }
                    field(Release; Rec.Release)
                    {
                        ApplicationArea = All;
                        Style = Strong;
                        ToolTip = 'Specifies the ';
                    }
                    field(Released; Rec.Released)
                    {
                        ApplicationArea = All;
                        Style = Strong;
                        ToolTip = 'Specifies the result of the release attempt (0 = unprocessed, -1 = ultimate fail, 1 = success)';
                    }
                    field("Released at DateTime"; Rec."Released at DateTime")
                    {
                        ApplicationArea = All;
                        Style = Strong;
                        ToolTip = 'Specifies the DateTime when the system attempted to release the document';
                    }
                    field("Released Duration (new)"; Rec."Released Duration (new)")
                    {
                        ApplicationArea = All;
                        Style = Strong;
                        ToolTip = 'Specifies the duration of the latest release attempt';
                        Caption = 'Released Duration';
                    }
                    field("Released No. of Attempts"; Rec."Released No. of Attempts")
                    {
                        ApplicationArea = All;
                        Style = Strong;
                        ToolTip = 'Specifies the number of times the system attempted to release the updated document';
                    }
                    field("Released Error Text"; Rec."Released Error Text")
                    {
                        ApplicationArea = All;
                        Style = Strong;
                        ToolTip = 'Specifies any error text as a result of the attempt to release';

                        trigger OnDrillDown()
                        begin
                            Message(Rec."Released Error Text");
                        end;
                    }
                    field("ARC Ranking Code";Rec."ARC Ranking Code")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
        area(factboxes)
        {
        }
    }

    actions
    {
        area(Navigation)
        {
            action(JobQueue)
            {
                Image = Job;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Job Queue';
                ToolTip = 'Shows the Job Queue';

                trigger OnAction()
                var
                    _OrderMgt: Codeunit "ARC OrderManagement";
                begin
                    _OrderMgt.ShowJobQueue();
                end;
            }
            action(EventLog)
            {
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Event Log';
                ToolTip = 'Shows related errors/messages in the Event Log Entry table';

                trigger OnAction()
                begin
                    OrderMgt.ShowEventLog();
                end;
            }
            action(Shipments)
            {
                Image = Shipment;
                ApplicationArea = All;
                ToolTip = 'Show posted shipments for Updated Document No.';

                trigger OnAction()
                begin
                    OrderMgt.ShowUpdatedDocumentPostedShpts(Rec);
                end;
            }
            action(Invoices)
            {
                Image = Invoice;
                ApplicationArea = All;
                ToolTip = 'Show posted invoices for Updated Document No.';

                trigger OnAction()
                begin
                    OrderMgt.ShowUpdatedDocumentPostedInvcs(Rec);
                end;
            }
            action(Items)
            {
                Image = Item;
                ApplicationArea = All;
                ToolTip = 'Show items';

                trigger OnAction()
                var
                    _Item: Record Item;
                begin
                    if Rec.Type = Rec.Type::Item then
                    if Rec."No." <> '' then begin
                        _Item.SetRange("No.",Rec."No.");
                        if _Item.FindFirst() then;
                        _Item.SetRange("No.");
                    end;
                    Page.Run(Page::"Item List",_Item);
                end;
            }
            action(KorberShpts)
            {
                Image = Shipment;
                ApplicationArea = All;
                Caption = 'Körber Shpts.';
                ToolTip = 'Show related Körber WMS shipments';

                trigger OnAction()
                begin
                    OrderMgt.ShowKorberShptEntries(Rec);
                end;
            }
            action(OrderList)
            {
                Image = ListPage;
                ApplicationArea = All;
                Caption = 'Order List';
                ToolTip = 'Shows the Sales Order List';

                trigger OnAction()
                begin
                    OrderMgt.ShowOrderList(Rec);
                end;
            }
            action(eCommerceEntries)
            {
                Image = GetOrder;
                ApplicationArea = All;
                Caption = 'eCommerce Entries';
                ToolTip = 'Show eCommerce Entries';

                trigger OnAction()
                var
                    eCommerceMgt: Codeunit "ARC eCommerceMgt";
                begin
                    eCommerceMgt.ShoweCommerceEntriesFrOrdTranslEntries(Rec);
                end;
            }
        }
        area(Processing)
        {
            action(NewSalesOrder)
            {
                Image = NewDocument;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'New Sales Order';
                ToolTip = 'Create a new Sales Order';

                trigger OnAction()
                begin
                    OrderMgt.NewSalesOrder();
                end;
            }
        }
    }

    var
        OrderMgt: Codeunit "ARC OrderManagement";
        Initialized: Boolean;
        CustNoFilter: Text[250];
        DocNoFilter: Text[250];
        ExtDocNoFilter: Text[250];
        UpdDocNoFilter: Text[250];

    trigger OnOpenPage()
    begin
        if Initialized then
            exit;
        if Rec.FindLast() then;
        Rec.Ascending(false);
    end;

    procedure SetDoc(_docArea: Integer; _docType: Integer; _docNo: Code[20])
    begin
        Rec.SetCurrentKey("Document Area");
        Rec.SetRange("Document Area",_docArea);
        Rec.SetRange("Document Type",_docType);
        Rec.SetRange("Document No.",_docNo);
        DocNoFilter := CopyStr(_docNo,1,MaxStrLen(DocNoFilter));
        Initialized := true;
    end;
}
report 50030 "ARC PO Update QtytoReceive"
{
    Caption = 'PO Update QtytoReceive';
    ProcessingOnly = true;
    UsageCategory = Administration;

    dataset
    {
        dataitem("ARC Inventory Journal Errors"; "ARC Inventory Journal Errors")
        {
            DataItemTableView = SORTING ("Purchase Order No.") WHERE ("Reason Code" = filter ('GRNI' | 'SoldNotInv'));
            RequestFilterFields = "Purchase Order No.";
            
            trigger OnAfterGetRecord()
            var
            begin
                UpdatePO("ARC Inventory Journal Errors"."Purchase Order No.","ARC Inventory Journal Errors"."Document Line No.");
            end;

            trigger OnPostDataItem()
            var
            begin
                Window.Close;
                Message(ProcessComplete);
            end;
        }
    }



    local procedure UpdatePO(PONo: Code[20];POLineNo: Integer);
    var
    begin
        
        if POHeader.GET(POHeader."Document Type"::Order,PONo) then begin
            Window.Update(1, POHeader."No.");
            POHeader."Reason Code" := "ARC Inventory Journal Errors"."Reason Code";
            POHeader.MODIFY(false);
            POLine.SetRange("Document Type",POHeader."Document Type");
            POLine.SetRange("Document No.",POHeader."No.");
            POLine.SetRange("Line No.",POLineNo);
            if POLine.FindFirst then begin
                POLine."Return Reason Code" := "ARC Inventory Journal Errors"."Reason Code";
                if POLine."Qty. to Receive" = 0 then 
                    POLine.Validate(Quantity,"ARC Inventory Journal Errors"."Rem. Quantity")
                else 
                    POLine.Validate(Quantity,(POLine.Quantity + "ARC Inventory Journal Errors"."Rem. Quantity"));
                POLine.Validate("Qty. to Receive",POLine.Quantity);
                POLine."Bin Code" := "ARC Inventory Journal Errors"."Bin Code";
                POLine.MODIFY(FALSE);
            end;
        end;
    end;

    trigger OnPreReport()
    var
    begin
        Window.OPEN('#1##########');
    end;

    var
        POHeader: Record "Purchase Header";
        POLine: Record "Purchase Line";
        PostOption: Boolean;
        Window: Dialog;
        ProcessComplete: Label 'PO Update Complete'; 
        ProcessCompleteandPosted: Label 'PO Update Complete and Posted';        
        //PostReport: Report "Batch Post Purchase Orders";
}   


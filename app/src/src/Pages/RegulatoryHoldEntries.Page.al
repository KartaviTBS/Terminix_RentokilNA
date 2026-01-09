page 50025 "ARC Regulatory Hold Entries"
{
    PageType = List;
    SourceTable = "ARC Regulatory Hold Buffer";
    SourceTableTemporary = true;
    Caption = 'Regulatory Hold Entries';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                
                IndentationColumn =  Indentation;
                IndentationControls = "Business Type Code";
                ShowAsTree = true;
                ShowCaption = false;

                field("Business Type Code"; "Business Type Code")
                {
                    ApplicationArea = All;
                    Style = Strong;
                }
                field("License Type Code"; "License Type Code")
                {
                    ApplicationArea = All;
                }
               
                field("Product Type Restriction Code"; "Product Type Restriction Code")
                {
                    ApplicationArea = All;
                }
                field("Product Use"; "Product Use")
                {
                    ApplicationArea = All;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                }
                field("SDS Product Code"; "SDS Product Code")
                {
                    ApplicationArea = All;
                }
                field("CAS Code"; "CAS Code")
                {
                    ApplicationArea = All;
                }
                field("Chemical Name"; "Chemical Name")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Doc. Line No."; "Doc. Line No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                }

            }
        }
    }

    var

        TempRegulatoryHoldBufferDetail: Record "ARC Regulatory Hold Buffer" temporary;
        ProductTypeRestriction: Record "ARC Product Type Restriction";
        RegulatoryManagement: Codeunit "ARC Regulatory Management";
        ActualExpansionStatus: Integer;
        

    trigger OnOpenPage();
    begin
        InitTempTable;
    end;

    local procedure InitTempTable();
    begin
        CopyRegHoldBufferToTemp(false);
    end;

    local procedure CopyRegHoldBufferToTemp(OnlyRoot: Boolean)
    var
        RegHoldBuffer: Record "ARC Regulatory Hold Buffer" temporary;
    begin
        LoadRegHoldBufFromTempDetail(RegHoldBuffer);
        Reset;
        DeleteAll;
        if OnlyRoot then
            RegHoldBuffer.SetRange(Indentation, 0);
        if RegHoldBuffer.Find('-') then
            repeat
                Rec := RegHoldBuffer;
                Insert;
            until RegHoldBuffer.Next = 0;
        if FindFirst then;
        
    end;

    [Scope('Personalization')]
    procedure LoadRegHoldBufFromTempDetail(var RegHoldBuffer: Record "ARC Regulatory Hold Buffer" temporary);
    begin
        RegHoldBuffer.DeleteAll;
        IF TempRegulatoryHoldBufferDetail.FindSet then 
        repeat
            RegHoldBuffer := TempRegulatoryHoldBufferDetail;
            RegHoldBuffer.Insert;
         until TempRegulatoryHoldBufferDetail.Next = 0;
    end;

    [Scope('Personalization')]
    procedure LoadRegHoldBufToTempDetail(var RegHoldBuffer: Record "ARC Regulatory Hold Buffer" temporary);
    begin
        TempRegulatoryHoldBufferDetail.DeleteAll;
        if RegHoldBuffer.FindSet then 
            repeat
                TempRegulatoryHoldBufferDetail := RegHoldBuffer;
                TempRegulatoryHoldBufferDetail.INSERT;
            until RegHoldBuffer.NEXT = 0;
    end;

    Local procedure TestOverrides();
     var
        RegHoldBuffer: Record "ARC Regulatory Hold Buffer" temporary;
        CntAll :Integer;
        CntOverrides: Integer;
        LText001: Label 'Not all overrides have been completed';
    begin
        LoadRegHoldBufFromTempDetail(RegHoldBuffer);
        RegHoldBuffer.SetRange(Indentation, 1);
        CntAll := RegHoldBuffer.COUNT;
        RegHoldBuffer.SetRange(Override, TRUE);
        CntOverrides := RegHoldBuffer.COUNT;
        if CntAll > CntOverrides then
            Message(LText001);

    end;


}
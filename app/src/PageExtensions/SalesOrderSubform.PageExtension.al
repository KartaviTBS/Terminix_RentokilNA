pageextension 50009 "ARC Sales Order Subform" extends "Sales Order Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Description 2";"Description 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Appl.-to Item Entry")
        {
            field("ARC Price Entry No.";"ARC Price Entry No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("ARC Business Type Code";"ARC Business Type Code")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("ARC Promotion Entry No.";"ARC Promotion Entry No.")
            {
                ApplicationArea = All;
            }
            field("ARC Promotion Code";"ARC Promotion Code")
            {
                ApplicationArea = All;
            }  
            field(Pack;Pack)
            {
                ApplicationArea = All;
                Visible = false;
                Editable = true;
            }                           
        }   

        addafter("Unit Price")
        {
            field("ARC Sales Cost";"ARC Sales Cost")
            {
                ApplicationArea = All;
            }
            field("ARC Margin %";"ARC Margin %")
            {
                ApplicationArea = All;
                
                trigger OnValidate()
                begin
                    if Rec."Line No." = 0 then begin 
                        CurrPage.SaveRecord();                   
                        CurrPage.Update(true);
                        PriceMgt.CreatePriceReviewEntry(Rec);
                    end;    
                end;
            }            
            field("ARC Price Review Exist";"ARC Price Review Exist")
            {
                ApplicationArea = All;
                Style = Attention;
            }

            field("ARC Supplemental Charge Code";"ARC Supplemental Charge Code")
            {
                ApplicationArea = All;
                Visible = false;
             } 
            field("ARC Supplemental Charge Rate";"ARC Supplemental Charge Rate")
            {
                ApplicationArea = All;
                 Visible = false;               
            }  
            field("ARC Supplemental Fixed Amount";"ARC Supplemental Fixed Amount")
            {
                ApplicationArea = All;
                Visible = false;                
            }                    

            
        }
        addlast(Control1)
        {
            field(AttachedToLineNo;AttachedToLineNo)
            {
                ApplicationArea = All;
                Caption = 'Attached to Line No.';

                trigger OnValidate()
                begin
                    if AttachedToLineNo <> Rec."Attached to Line No." then
                        Rec."Attached to Line No." := AttachedToLineNo;
                end;
            }
        }
        modify("Unit Price")
        {
            trigger OnAfterValidate()
            begin
                if Rec."Line No." = 0 then begin 
                    CurrPage.SaveRecord();                   
                    CurrPage.Update(true);
                    PriceMgt.CreatePriceReviewEntry(Rec);
                end;
            end;
        }
    }

    actions
    {
    }

    var
        PriceMgt: Codeunit "ARC Price Management";
        AttachedToLineNo: Integer;

    trigger OnAfterGetCurrRecord()
    begin
        AttachedToLineNo := Rec."Attached to Line No.";
    end;

    trigger OnAfterGetRecord()
    begin
        AttachedToLineNo := Rec."Attached to Line No.";
    end;
}
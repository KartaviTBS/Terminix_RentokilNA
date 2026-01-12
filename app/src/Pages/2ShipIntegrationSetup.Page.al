page 50055 "2Ship Integration Setup"
{
    PageType = Card;
    SourceTable = "2Ship Integration Setup";
    Caption = '2Ship Integration Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    UsageCategory = Administration;
    ApplicationArea = all;

    layout
    {
        area(content)
        {

            group(General)
            {
                Caption = 'General';
                field("Ship  URL"; Rec."Ship URL")
                {
                    ToolTip = 'Specifies the value of the Ship URL field.', Comment = '%';
                }
                field("Delete Shipment URL"; Rec."Delete Shipment URL")
                {
                    ApplicationArea = All;
                }
                
                field(WS_Key; Rec.WS_Key)
                {
                    ToolTip = 'Specifies the value of the WS_Key field.', Comment = '%';
                }
                field("Get Edit URL";"Get Edit URL")
                {
                    ApplicationArea =all;
                }
            }
        }
    }


    trigger OnOpenPage();
    Var
        AccessTokeninstr: InStream;
        MRAKeyInstr: InStream;
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}


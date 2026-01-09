tableextension 50022 "ARC G/L Entry" extends "G/L Entry"
{
    fields
    {
        field(50001;"ARC Global Dimension 3 Code";Code[20])
        {
            Caption = 'ARC Global Dimension 3 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(3));
           
        }
        field(50002;"ARC WorkWave Entry No.";Integer)
        {
            Caption = 'Workwave Entry No.';
        }
        field(50003; "Exported To JDE"; Boolean)
        {
            Caption = 'Exported To JDE';
        }
        field(50004; "Shortcut Dimension 3 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 3 Code';            
        }
    }
    
    var
        myInt : Integer;
}
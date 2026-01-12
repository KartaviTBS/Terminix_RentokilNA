tableextension 50006 "ARC Location" extends Location
{
    fields
    {
        field(50000; "ARC Location IC Code"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Location IC Code';
        }
        field(50001; "Shortcut Dimension 1 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (1));
        }
        field(50002; "Shortcut Dimension 2 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (2));
        }
        field(50003; "ARC Regulaotry Workflow Group Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Regulatory Workflow Group Code';
            TableRelation = "Workflow User Group".Code;
        }
        field(50004;"ARC COI Location Code";Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'COI Location Code';
            TableRelation = Location.Code;
        }
        field(50102; "ARC Enable Korber WMS"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable Korber WMS';
        }
        field(50103; "ARC Korber Location Code"; Text[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Korber Location Code';
        }
        field(50104; "ARC Korber Order Hdr. Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Korber Order Header Code';
        }
    }
}
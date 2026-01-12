tableextension 50009 "ARC Customer" extends Customer
{
    fields
    {
        field(50001; "ARC Customer Type"; Text[50])
        {
            Caption = 'Customer Type';
        }
        field(50002; "ARC Annual Revenue"; Decimal)
        {
            Caption = 'Annual Revenue';
        }

        field(50003; "ARC Group Account No."; Text[30])
        {
            Caption = 'Group Account No.';
        }

        field(50004; "ARC Group Account Name"; Text[50])
        {
            Caption = 'Group Account Name';
        }

        field(50005; "ARC Contact Position"; Text[30])
        {
            Caption = 'Contact Position';
        }

        field(50006; "ARC Contact Department"; Text[30])
        {
            Caption = 'Contact Department';
        }

        field(50007; "ARC Contact Mobile"; Text[30])
        {
            Caption = 'Contact Mobile';
        }
        field(50008; "ARC Customer Group"; Text[10])
        {
            Caption = 'Customer Group';
        }

        field(50009; "ARC Customer Type Description"; Text[40])
        {
            Caption = 'Customer Type Description';
        }
        field(50010; "ARC Sales Employee Name"; Text[60])
        {
            Caption = 'Sales Employee Name';
        }
        field(50011; "ARC Service Technician"; Text[10])
        {
            Caption = 'Service Technician';
        }
        field(50012; "ARC Service Technician Name"; Text[60])
        {
            Caption = 'Service Technician Name';
        }
        field(50013; "ARC Contract/Job"; Text[20])
        {
            Caption = 'Contract/Job';
        }
        field(50014; "ARC Job/Product Sales Value"; Decimal)
        {
            Caption = 'Job/Product Sales Value';
        }
        field(50015; "ARC Invoice Text 1"; Text[50])
        {
            Caption = 'Invoice Text 1';
        }
        field(50016; "ARC Invoice Text 2"; Text[50])
        {
            Caption = 'Invoice Text 2';
        }
        field(50017; "ARC Invoice Text 3"; Text[50])
        {
            Caption = 'Invoice Text 3';
        }
        field(50018; "ARC Invoice Text 4"; Text[50])
        {
            Caption = 'Invoice Text 4';
        }
        field(50019; "ARC Invoice Text 5"; Text[50])
        {
            Caption = 'Invoice Text 5';
        }
        field(50020; "ARC Portfolio Value"; Decimal)
        {
            Caption = 'Portfolio Value';
        }
        field(50021; "ARC Company No."; Text[20])
        {
            Caption = 'Company No.';
        }
        field(50022; "ARC Registration No."; Text[20])
        {
            Caption = 'Registration No.';
        }
        field(50023; "ARC Live/Terminated"; Text[10])
        {
            Caption = 'Live/Terminated';
        }
        field(50024; "ARC Customer Ranking"; Code[10])
        {
            Caption = 'Customer Ranking';
        }
        field(50025;"ARC COI Permit";Boolean)
        {
            Caption = 'COI Permit';
        }
        field(50026;"ARC Created By";Code[50])
        {
           Caption = 'Created By';
           Editable = false;
        }
        field(50027;"ARC Modified By";Code[50])
        {
           Caption = 'Modified By';
           Editable = false;
        }
        field(50028;"ARC Created On";DateTime)
        {
           Caption = 'Created On';
           Editable = false;
        }
        field(50029;"ARC Modified On";DateTime)
        {
           Caption = 'Modified On';
           Editable = false;
        }
        field(50042;"ARC LOB Lift %";Decimal)
        {
            Caption = 'LOB Lift %';
        }
        field(50043; "ARC Internal Customer"; Boolean)
        {
            Caption = 'Internal Customer';
        }
        field(50044; "ARC ReOrder Referecne"; Text[30])
        {
            Caption = 'Reorder Reference';
        }
        field(50099; "ARC eCommerce Enabled"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'eCommerce Enabled';
        }
        field(50100;"ARC PestPac Customer ID";Text[50])
        {
            Caption = 'PestPac Customer ID';        
        }
        field(60001;"ARC Credit Control";Boolean)
        {
           Caption = 'Credit Control';
        }
        field(60002;"ARC Person Job";Text[50])
        {
            Caption = 'Person Job';
        }
    }
}
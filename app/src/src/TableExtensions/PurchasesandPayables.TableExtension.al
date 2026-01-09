tableextension 50062 "ARC Purchases & Payables Setup" extends "Purchases & Payables Setup"
{
    fields
    {
        field(50061; "ARC AP Sweep Folder"; Text[250])
        {
            Caption = 'AP Sweep Folder';
        }
        field(50062; "ARC AP Sweep File Name"; Text[250])
        {
            Caption = 'AP Sweep File Name';
        }
        field(50063; "ARC AP Sweep Account Type"; Text[250])
        {
            Caption = 'AP Sweep Account Type';
        }
        field(50064; "ARC AP Sweep Bal. Account Type"; Text[250])
        {
            Caption = 'AP Sweep Bal. Account Type';
        }
        field(50065; "ARC AP Sweep Bal. Account No."; Text[250])
        {
            Caption = 'AP Sweep Bal. Account No.';
            TableRelation = "G/L Account";
        }
        field(50000; "JDE AP Export File Path"; Text[250])
        {
            Caption = 'JDE AP Export File Path';
            
        }
        field(50001; "JDE Last Export File Name"; Text[250])
        {
            Caption = 'JDE Last Export File Name';
            
        }

    }

    var
        myInt: Integer;
}
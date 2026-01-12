tableextension 50031 "ARC Sales Header Archive" extends "Sales Header Archive"
{
    fields
    {
        field(50000; "ARC Locality Code"; Code[20])
        {
            Caption = 'Locality Code';
            TableRelation = "ARC Locality".Code where ("Country/Region Code" = FIELD ("Ship-to Country/Region Code"),
                                            County = FIELD ("Ship-to County"), "Post Code" = FIELD ("Ship-to Post Code"));
        }
        field(50001; "ARC Business Type Code"; Code[20])
        {
            Caption = 'Business Type Code';
            TableRelation = "ARC Customer Business Type"."Business Type Code" where ("Customer No." = FIELD ("Sell-to Customer No."));
        }
        field(50003;"ARC Expiration Date";Date)
        {
            Caption = 'Expiration Date';
            Editable = false;
        }
        field(50004;"ARC Created By";Code[50])
        {
            Caption = 'Created By';
            TableRelation = User."User Name";
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50005;"ARC Regulatory Hold";Boolean)
        {
            Caption = 'Regulatory Hold';
            Editable = false;
        }
        field(50006;"ARC COI Order";Boolean)
        {
            Caption = 'COI Order';
        }
        field(50007;"ARC COI Location Code";Code[20])
        {
            Caption = 'COI Location Code';
            TableRelation = Location.Code;
        }
        field(50008;"ARC Use Location Address";Boolean)
        {
            Caption = 'Use Location Address';
        }
        field(50009;"ARC Total Quantity";Decimal)
        {
            CalcFormula = Sum ("Sales Line".Quantity WHERE("Document Type" = FIELD("Document Type"),
                                                                             "Document No." = FIELD("No.")));
            Caption = 'Total Quantity';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50010;"ARC Oustanding Quantity";Decimal)
        {
            CalcFormula = Sum ("Sales Line"."Outstanding Quantity" WHERE("Document Type" = FIELD("Document Type"),
                                                                             "Document No." = FIELD("No.")));
            Caption = 'Outstanding Quantity';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50011;"ARC AR Hold";Boolean)
        {
            Caption = 'AR Hold';
            Editable = false;
        }
        field(50012;"Sell-to Territory Code";Code[10])
        {
            Caption = 'Territory Code';
            Description = 'RENT.SK.01';
            TableRelation = Territory;
            Editable = false;        
        }
        field(50013;"Bill-to Territory Code";Code[10])
        {
            Caption = 'Territory Code';
            Description = 'RENT.SK.01';
            TableRelation = Territory;
            Editable = false;
        }
        field(50014;"Ship-to Territory Code";Code[10])
        {
            Caption = 'Territory Code';
            Description = 'RENT.SK.01';
            TableRelation = Territory;
            Editable = false;
        }
        field(50053; "ARC Order Source Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "ARC Order Source";
            Caption = 'Order Source Code';
        }
        field(50061;"ARC NAPC Bill of Lading No.";Code[20])
        {
           CalcFormula = lookup("ARC NAPC BOL Header"."No." where ("Source Doc. Type" = const("Sales Order"), "Source Doc. No." = field("No.")));
           FieldClass = FlowField;
           Editable = false;         
        }
        field(50065;"ARC Workwave Order";Boolean)
        {
            Caption = 'WorkWave Order';
            Editable = true;
        }
        field(50067;"ARC Allow Ship & Invoice";Boolean)
        {
            Caption = 'Allow Ship & Invoice';
        }
        field(50068;"ARC WW Amount Authorized";Decimal)
        {
            Caption = 'WW Amount Authorized';
            FieldClass = FlowField;
            CalcFormula= sum("ARC Workwave Entry".Amount where ("Sales Order No." = field("No."), "Transaction Status" = const('Authorized')));
            Editable =  false;
        }
        field(50069;"ARC WW Amount Charged";Decimal)
        {
            Caption = 'WW Amount Charged';
            FieldClass = FlowField;
            CalcFormula= sum("ARC Workwave Entry"."Amount Captured" where ("Sales Order No." = field("No."),  "Transaction Status" = const('Approved'), Status = const(Batched)));
            Editable =  false;
        }
        field(50070;"ARC WW Amount Charge Settled";Decimal)
        {
            Caption = 'WW Amount Charge Settled';
            FieldClass = FlowField;
            CalcFormula= sum("ARC Workwave Entry"."Amount Captured" where ("Sales Order No." = field("No."), "Transaction Status" = const('Approved'), Status = const(Settled)));
            Editable =  false;
        }
        field(50071;"ARC WW Amount Charged Open";Decimal)
        {
            Caption = 'WW Amount Charged Open';
            FieldClass = FlowField;
            CalcFormula= sum("ARC Workwave Entry"."Amount Captured" where ("Sales Order No." = field("No."),  "Transaction Status" = const('Approved'), Status = const(Open)));
            Editable =  false;
        }
        field(50072;"ARC ACH Order";Boolean)
        {
            Caption = 'ACH Order';
            Editable = false;
        }
        field(50078; "ARC Order Mgt. Status"; Option)
        {
            DataClassification = CustomerContent;
            Editable = false;
            OptionMembers = " ",Queued,Analyzed,Updated;
            OptionCaption = ' ,Queued,Analyzed,Updated';
            Caption = 'Order Mgt. Status';
        }
          field(50079; "2Ship Label Link"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;  
            Caption = '2Ship Label Link';        
        }
        field(50080; "2Ship BOL Link"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;          
            Caption = '2Ship BOL Link';
        }          
        field(50081; "2Ship Tracking No."; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;          
            Caption = '2Ship Tracking No.';
        }
        field(50083; "2Ship Get Edit URL"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;          
            Caption = '2Ship Get Edit URL';
        }
        field(50085; "Priority_Korber"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Priority_Korber';
        } 
    }
}
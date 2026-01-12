report 50007 "ARC Update Price Entity"
{
    Caption = 'Update Price Entry Entity Types';
    ProcessingOnly = true;
    UsageCategory = Administration;

    dataset
    {
        dataitem("ARC Price Entry"; "ARC Price Entry")
        {
            DataItemTableView =SORTING("Entry No.") WHERE("Entity Type" = CONST(Customer), "Entity No." = FILTER(''));
            
            trigger OnAfterGetRecord();
            begin 
                window.update(1,"Entry No.");
                "Entity Type" := "Entity Type"::"All Customers";
                Modify(true);
            end;
            
        }
    }
    
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                   
                }
            }
        }
    
        actions
        {
            area(processing)
            {
                
            }
        }
    }
    
    trigger OnPreReport();
    begin 
        window.open(Text001);
    end;

    trigger OnPostReport();
    begin 
        window.Close;
    end;
    var
        myInt : Integer;
        window: Dialog;
        Text001: Label 'Updating Price Record #1################';
}
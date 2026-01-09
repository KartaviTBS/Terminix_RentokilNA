query 50045 "ARC System Mappings"
{
    Caption = 'System Mappings';

    elements
    {
        dataitem(SysMap; "ARC System Mapping")
        {
            column(Entry_No; "Entry No.")
            {
            }
            column(Source_System; "Source System")
            {
            }
            column(Source_Type;"Source Type")
            {
            }
            column(Source_No;"Source No.")
            {
            }
            column(Destination_No_;"Destination No.")
            {
            }
            column(Created_by;"Created by")
            {
            }
            column(Created_at_DateTime;"Created at DateTime")
            {
            }
        }
    }
    
    var
        myInt : Integer;

    trigger OnBeforeOpen();
    begin
    end;
}
tableextension 50019 "ARC Sales Cue" extends "Sales Cue"
{
    fields
    {
        field(50000; "Price Review Entries"; Integer)
        {
            CalcFormula = Count ("ARC Price Review Entry" WHERE(Approver = FIELD("User ID Filter"),
                                                         Status = FILTER(Review)));
            Caption = 'Open Price Review Entries';
            Editable = false;
            FieldClass = FlowField;
        }
    }    
   
}
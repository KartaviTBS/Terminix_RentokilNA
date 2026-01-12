codeunit 50010 "ARC Alloc8 Customer Export"
{
    trigger OnRun();
    begin
        Intialize;
        ExportCustomers;
    end;

    procedure ExportCustomers();
    var
        Customer: Record Customer;
        OutputFile: File;
        FileName: Text;
        OStream: OutStream;
        CompanyInformation: Record "Company Information";
        Addr3 : Text;
        NoOfCust: Integer;
        
    begin
        CompanyInformation.Get;
        Customer.Reset;
        OutputFile.WriteMode(true);
        FileName := Alloc8Setup."Customer File Export Path" + 'Customers-' + Format(Today, 0, '<Day,2><Month,2><Year4>') + '.txt';
        OutputFile.Create(FileName);
        OutputFile.CreateOutStream(OStream);
        If Alloc8Setup."Incremental Export" then
            Customer.SetFilter("Last Modified Date Time", '>%1', LastExportDateTime);
        If Alloc8Setup."Cust Gen. Bus Posting Group" <> '' then
            Customer.SetRange("Gen. Bus. Posting Group",Alloc8Setup."Cust Gen. Bus Posting Group");    
        if Customer.findset then begin
            repeat
                Addr3 := Customer.City;
                if Addr3 = '' then
                    Addr3 := Customer.County
                else
                    Addr3 := Addr3 + ', ' + Customer.County;
                OStream.WriteText
                   (Format(CompanyInformation."ARC Company Code",10) +
                    Format(Customer."No.",20) +
                    Format('',20)+ 
                    Format(Customer.Contact,30) +
                    Format(Customer."Phone No.",30) +
                    Format(Customer."Global Dimension 1 Code",10) +
                    Format(Customer.Name,32) +
                    Format(Customer.Address,32) +
                    Format(Customer."Address 2",32) +
                    Format(Addr3,32) +
                    Format('',32) +
                    Format(Customer."Post Code",32) +
                    Format('',10) +
                    Format('',8) +
                    Format('',8)+
                    Format('',4) +
                    Format('',4) +
                    Format('',8) +
                    Format('',8)                                         
                    );
                    oStream.WriteText;
                    NoOfCust += 1;
            until Customer.Next = 0;
            Alloc8ExportEntry."No. of Transactions" := NoOfCust;
            Alloc8ExportEntry.Insert(true);
            OutputFile.Close;
        end;
    end;

    local procedure Intialize();
    begin
        Alloc8Setup.Get;
        Alloc8Setup.TestField("Customer File Export Path");
        CR := 13;
        LF := 10;
        If Alloc8Setup."Incremental Export" then begin
            Alloc8ExportEntry.Reset;
            Alloc8ExportEntry.SetRange("Entry Type", Alloc8ExportEntry."Entry Type"::Customer);
            If Alloc8ExportEntry.FindLast then
                LastExportDateTime := Alloc8ExportEntry."Export Date/Time"
            else
                LastExportDateTime := 0DT;
        end;
        Alloc8ExportEntry.Init;
        Alloc8ExportEntry."Entry Type" := Alloc8ExportEntry."Entry Type"::Customer;
        Alloc8ExportEntry."Export Date/Time" := CurrentDateTime;         

    end;

    var
        Alloc8Setup: Record "ARC Alloc8 Setup";
        Alloc8ExportEntry: Record "ARC Alloc8 Export Entry";
        LastExportDateTime: DateTime;
        CR : Char;
        LF : Char;

}
report 50069 "ARC Comments Import"
{
    Caption = 'Comments Import';
    ProcessingOnly = true;
    UsageCategory = Administration;

    dataset
    {
        dataitem(CommentsImport; Integer)
        {
            DataItemTableView = SORTING (Number) WHERE (Number = CONST (1));

            trigger OnAfterGetRecord()
            var
            begin
                ReadData;
            end;

            trigger OnPostDataItem()
            var
            begin
                Window.Close;
                Message(ProcessComplete);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(FileNameControl; FileName)
                    {
                        ApplicationArea = Suite;
                        Caption = 'File Name';
                        ToolTip = 'Specifies the name of the file that you want Import';
                        AssistEdit = true;

                        trigger OnAssistEdit()
                        var
                        begin
                            FilePath := FileManagement.OpenFileDialog(Text031, FileName, FileManagement.GetToFilterText('', '.txt'));
                            if ClientTypeMgt.GetCurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop] then
                                ServerFileName := FilePath;
                            FileName := FilePath;
                        end;
                    }
                    field(SourceSystem;SourceSystem)
                    {
                        Caption = 'Import from';
                    }                   

                }
            }
        }

        trigger OnInit()
        var
        begin
            OnWebClient := ClientTypeMgt.GetCurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop];
        end;

        Trigger OnOpenPage()
        var
        begin
            
        end;

    }

    local procedure ReadData();
    var
        ImpFile: File;
        StreamInFile: InStream;
        Buffer: Text;
    begin
        ImpFile.Open(FileName);
        ImpFile.CreateInStream(StreamInFile);
        while not StreamInFile.EOS do begin
            ClearVariables;
            StreamInFile.ReadText(Buffer);
            Evaluate(CommentTableName, GetSubString(Buffer, 1));
            Evaluate(CommentNo, GetSubString(Buffer, 2));
            Evaluate(CommentLineNo, GetSubString(Buffer, 3));
            Evaluate(CommentDate, GetSubString(Buffer, 4));
            Evaluate(CommentCode, GetSubString(Buffer, 5));
            Evaluate(CommentText, GetSubString(Buffer, 6));
            Window.Update(1, CommentNo);
            ImportData;
        end;
        ImpFile.Close;
    end;

    local procedure ImportData();
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Item: Record Item;
        CommentLine: Record "Comment Line";
    begin
        CommentError := false;
        if CommentTableName = CommentTableName::Customer then begin
          CommentNo := GetMapping('Customer', CommentNo);
            if not Customer.GET(CommentNo) then 
              CommentError := True;
        end;
        if CommentTableName = CommentTableName::Vendor then begin
          CommentNo := GetMapping('Vendor', CommentNo);
            if not Vendor.GET(CommentNo) then 
              CommentError := True;
        end;
        if CommentTableName = CommentTableName::Item then begin
          CommentNo := GetMapping('Item', CommentNo);
            if not Item.GET(CommentNo) then 
              CommentError := True;
        end;

            if not CommentError then begin
                Clear(CommentLine);
                CommentLine.Validate("Table Name", CommentTableName);
                CommentLine."No." := CommentNo;
                CommentLine."Line No." := CommentLineNo;
                CommentLine.Date := CommentDate;
                CommentLine.Code := CommentCode;
                CommentLine.Comment := COPYSTR(CommentText,1,80);
                CommentLine.Insert(true);
            end;
    end;



    trigger OnPreReport()
    var
    begin
        Window.OPEN('#1##########');
        if not OnWebClient then begin
            if FileName = '' then
                Error(Text000);
            ServerFileName := FileManagement.UploadFileSilent(FilePath);
        end;
    end;

    local procedure ClearVariables();
    var
    begin
        Clear(CommentNo);
        Clear(CommentTableName);
        Clear(CommentLineNo);
        Clear(CommentDate);
        Clear(CommentCode);
        Clear(CommentText);
    end;

    local procedure GetFileName(FilePath: Text): Text
    var
    begin
        exit(FileManagement.GetFileName(FilePath));
    end;

    local procedure GetSubString(TextString: Text[1024]; ItemNumber: Integer): Text[100];
    VAR
        ReturnValue: Text[100];
        Counter: Integer;
        Char: Text[1];
        TempString: Text[100];
        TabCounter: Integer;
        CharIn: Char;
    begin
        CharIn := 9;
        Counter := 0;
        if TextString <> '' then
            WHILE STRLEN(TextString) > 0 do begin
                Counter += 1;
                if STRPOS(TextString, FORMAT(CharIn)) <> 0 then begin
                    TabCounter += 1;
                    if TabCounter = ItemNumber then
                        exit(DELCHR((COPYSTR(TextString, 1, STRPOS(TextString, FORMAT(CharIn)) - 1)), '<>', '"'));
                    TextString := COPYSTR(TextString, STRPOS(TextString, FORMAT(CharIn)) + 1);
                end else begin
                    TabCounter += 1;
                    if TabCounter = ItemNumber then
                        exit(DELCHR(TextString, '<>', '"'))
                    else
                        exit('');
                end;
            end;
        exit('');
    end;

    procedure GetMapping(MapType: Text[20]; MapNo: Code[20]): Code[20];
    var
        SystemMapping: Record "ARC System Mapping";
        NewNo: Code[20];
    begin
        SystemMapping.SetRange("Source System", SourceSystem);
        Case MapType of
        'Customer' :
          SystemMapping.SetRange("Source Type", SystemMapping."Source Type"::Customer);
         'Vendor' :
          SystemMapping.SetRange("Source Type", SystemMapping."Source Type"::Vendor);
         'Item' :
          SystemMapping.SetRange("Source Type", SystemMapping."Source Type"::Item);                  
        end;
        SystemMapping.SetRange("Source No.", MapNo);
        if SystemMapping.FindFirst then
            NewNo := SystemMapping."Destination No."
        else
            NewNo := MapNo;
        exit(NewNo);
    end;

    var
        CommentError: Boolean;
        CommentNo: Code[20];
        CommentCode: Code[10];
        ClientTypeMgt: Codeunit ClientTypeManagement;
        FileManagement: Codeunit "File Management";
        CommentDate: Date;
        Window: Dialog;
        RecInfo: File;
        CommentLineNo: Integer;
        ProcessComplete: Label 'Import Complete';
        Text031: Label 'Import from Text File';
        Text000: Label 'Enter the file name.';
        SourceSystem: Option NAV2009, GreatPlains, Sage;          
        CommentTableName: Option "G/L Account",Customer,Vendor,Item,Resource,Job,,"Resource Group","Bank Account",Campaign,"Fixed Asset",Insurance,"Nonstock Item","IC Partner"; 
        CommentText: Text[100];
        FileName: Text;
        FilePath: Text;
        ServerFileName: Text;

        [InDataSet]
        OnWebClient: Boolean;

}
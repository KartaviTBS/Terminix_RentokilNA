codeunit 50016 "ARC Extension Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
      PopulateNewFields();
      UpgradeKorberMgt();
    end;

    local procedure CheckIfInstallingAppVersionCompatibleWithInstalledVersion() : Boolean
    begin
        exit((GetInstallingVersionNo() = '2.0.0.0') and (GetCurrentlyInstalledVersionNo() = '1.0.0.0'));
    end;

    procedure GetInstallingVersionNo(): Text
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(Format(AppInfo.AppVersion()));
    end;

    
    procedure GetCurrentlyInstalledVersionNo(): Text
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(Format(AppInfo.DataVersion()));
    end;

       

    local procedure PopulateNewFields()
    begin
    end;

    local procedure UpgradeItemPriceEntry()
    begin
       PopulateNewFields();
    end;

    local procedure UpgradeKorberMgt()
    var
        _KorberMgt: Codeunit "ARC KorberMgt";
    begin
        _KorberMgt.OnUpgradeKorberPerCompany();  // SOW11 Körber Edge WMS Integration
    end;
}
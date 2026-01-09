codeunit 50040 ARCExtensionInstallation
{
    Subtype = Install;

    trigger OnRun()
    begin
    end;

    trigger OnInstallAppPerCompany();
    var
        myAppInfo: ModuleInfo;
    begin
        // https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-extension-install-code
        
        // NavApp.GetCurrentModuleInfo(myAppInfo); // Get info about the currently executing module
        // if myAppInfo.DataVersion = Version.Create(0, 0, 0, 0) then // A 'DataVersion' of 0.0.0.0 indicates a 'fresh/new' install
        //     HandleFreshInstallPerCompany()
        // else
        //     HandleReinstallPerCompany();
        InstallKorberMgt();
    end;

    trigger OnInstallAppPerDatabase();
    var
        myAppInfo: ModuleInfo;
    begin
    end;

    local procedure HandleFreshInstallPerCompany();
    begin
        // Do work needed the first time this extension is ever installed for this tenant.
        // Some possible usages:
        // - Service callback/telemetry indicating that extension was installed
        // - Initial data setup for use

        // InstallReOrder();  // US28839 ReOrder
        // InstallOnGuard();  // US28812 OnGuard
        // InstallAPLVFM();   // US28708 APL-VFM
        // InstallSystemMappings();  // US30337 Ref NAV2009 ItemNo
        // InstallExpiredArchiveQuoteJQ(); // US28833 Sales Quote
    end;

    local procedure HandleReinstallPerCompany();
    begin
        // Do work needed when reinstalling the same version of this extension back on this tenant.
        // Some possible usages:
        // - Service callback/telemetry indicating that extension was reinstalled
        // - Data 'patchup' work, for example, detecting if new 'base' records have been changed while you have been working 'offline'.
        // - Setup 'welcome back' messaging for next user access.

        // InstallReOrder();  // US28839 ReOrder
        // InstallOnGuard();  // US28812 OnGuard
        // InstallAPLVFM();   // US28708 APL-VFM
        // InstallSystemMappings();  // US30337 Ref NAV2009 ItemNo
        // InstallExpiredArchiveQuoteJQ(); // US28833 Sales Quote
    end;

    local procedure InstallReOrder();
    var
        _ReOrderMgt: Codeunit "ARC ReOrderMgt";
    begin
        _ReOrderMgt.InstallReOrder();  // US28839 ReOrder
    end;

    local procedure InstallOnGuard();
    var
        SetupOnGuardRegister: Codeunit "ARC Set up OnGuard Register";
    begin
        SetupOnGuardRegister.SetupOnGuard();        
    end;

    local procedure InstallExpiredArchiveQuoteJQ();
    var
        ArchiveExpiredQuotes: Codeunit "ARC Archive Expired Quotes";
    begin
       ArchiveExpiredQuotes.SetupArchiveQuotes();     
    end;

    local procedure InstallAPLVFM();
    var
        _APLMgt: Codeunit "ARC APL Management";
        _VFMMgt: Codeunit "ARC VFM Management";
    begin
        _APLMgt.InstallAPL();
        _VFMMgt.InstallVFM();
    end;

    local procedure InstallSystemMappings()
    var
        _SysMapMgt: Codeunit "ARC SystemMappingMgt";
    begin
        _SysMapMgt.InstallSystemMapping();
    end;

    local procedure InstallKorberMgt()
    var
        _KorberMgt: Codeunit "ARC KorberMgt";
    begin
        _KorberMgt.OnUpgradeKorberPerCompany();  // SOW11 Körber Edge WMS Integration
    end;
}
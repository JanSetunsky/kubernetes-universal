#region >> [ PROJECT INSTALL VERIFICATION ]
$PROJECT_INSTALL_VERIFICATION_SC = {
    $RightsResult   = Get-PowerShell_Rights_Management -OperatingSystem $OS_TYPE -Configuration $ConfigData -MeasureDuration $False -ErrorAction Stop
    $VersionResult  = Get-PowerShell_Version_Recognition -OperatingSystem $OS_TYPE -Configuration $ConfigData -MeasureDuration $False -ErrorAction Stop
    $GitHubResult   = Get-GitHub_Availability -OperatingSystem $OS_TYPE -Configuration $ConfigData -GitHubDatabase $GitHubData -MeasureDuration $False -ErrorAction Stop
    $GitLabResult   = Get-GitLab_Availability -OperatingSystem $OS_TYPE -Configuration $ConfigData -GitLabDatabase $GitLabData -MeasureDuration $False -ErrorAction Stop
    $ModulesResult  = Get-Modules_Availability -OperatingSystem $OS_TYPE -Configuration $ConfigData -ModuleDatabase $ModulesData -MeasureDuration $False -ErrorAction Stop
    $PackagesResult = Get-Packages_Availability -OperatingSystem $OS_TYPE -Configuration $ConfigData -PackageDatabase $PackagesData -MeasureDuration $False -ErrorAction Stop
    if($null -eq $(($RightsResult,$VersionResult,$GitHubResult,$GitLabResult,$ModulesResult,$PackagesResult) -match $False)){
        CONTINUE
    }
    else{
        Write-Warning 'Verification failed!'
        BREAK
    }
}
#endregion [ PROJECT INSTALL VERIFICATION ]
#region >> [ PROJECT BUILD VERIFICATION ]
$PROJECT_BUILD_VERIFICATION_SC = {
    $RightsResult   = Get-PowerShell_Rights_Management -OperatingSystem $OS_TYPE -Configuration $BuildData -MeasureDuration $False -ErrorAction Stop
    $VersionResult  = Get-PowerShell_Version_Recognition -OperatingSystem $OS_TYPE -Configuration $BuildData -MeasureDuration $False -ErrorAction Stop
    $GitHubResult   = Get-GitHub_Availability -OperatingSystem $OS_TYPE -Configuration $BuildData -GitHubDatabase $GitHubData -MeasureDuration $False -ErrorAction Stop
    $GitLabResult   = Get-GitLab_Availability -OperatingSystem $OS_TYPE -Configuration $BuildData -GitLabDatabase $GitLabData -MeasureDuration $False -ErrorAction Stop
    $ModulesResult  = Get-Modules_Availability -OperatingSystem $OS_TYPE -Configuration $BuildData -ModuleDatabase $ModulesData -MeasureDuration $False -ErrorAction Stop
    $PackagesResult = Get-Packages_Availability -OperatingSystem $OS_TYPE -Configuration $BuildData -PackageDatabase $PackagesData -MeasureDuration $False -ErrorAction Stop
    if($null -eq $(($RightsResult,$VersionResult,$GitHubResult,$GitLabResult,$ModulesResult,$PackagesResult) -match $False)){
        CONTINUE
    }
    else{
        Write-Warning 'Verification failed!'
        BREAK
    }
}
#endregion [ PROJECT BUILD VERIFICATION ]
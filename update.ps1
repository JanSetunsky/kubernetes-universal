#region >> [ PROJECT DEFINITION ]
$PROJECT_DEFINITION_SC = {
    $OS_DATA     = Get-Operating_System_Recognition -MeasureDuration $false
    $OS          = $OS_DATA.OS
    $OS_TYPE     = $OS_DATA.OS_TYPE
    $OS_PLATFORM = $OS_DATA.OS_PLATFORM
    if($OS_TYPE -eq 'Linux'){
        BREAK
    }
    elseif($OS_TYPE -eq 'MacOS'){
        BREAK
    }
    elseif($OS_TYPE -eq 'Windows'){
        # Default root path
        $DefaultPath      = $ScriptRoot
        # Runspace paths
        $RunspacePath     = $DefaultPath+'\runspace'
        # Project paths
        $ProjectsPath     = $RunspacePath+'\projects'
        # Environment paths
        $EnvironmentPath  = $DefaultPath+'\environment'
        $ConfigPath       = $EnvironmentPath+'\config.json'
        # Database paths
        $DatabasePath     = $DefaultPath+'\db'
        $GitHubPath       = $DatabasePath+'\github.json'
        $GitLabPath       = $DatabasePath+'\gitlab.json'
        $ModulesPath      = $DatabasePath+'\modules.json'
        $PackagesPath     = $DatabasePath+'\packages.json'        
        # CONFIG DATABASE
        if(Test-Path $ConfigPath){
            $ConfigGc    = Get-Content $ConfigPath -Force
            $ConfigData  = $ConfigGc|ConvertFrom-Json -Depth 100
            $ProjectName = $ConfigData.ProjectName
            $ConfigPath  = $ProjectsPath+'\'+$ProjectName+'\config.json'
            Write-Host $ConfigPath
            if(Test-Path $ConfigPath){
                $ConfigGc  = Get-Content $ConfigPath -Force
                $BuildData = $ConfigGc|ConvertFrom-Json -Depth 100
            }
            else{
                $BuildData = $null
            }
        }
        else{
            $BuildData = $null
        }
        # GITHUB DATABASE
        if(Test-Path $GitHubPath){
            $GitHubGc   = Get-Content $GitHubPath -Force
            $GitHubData = $GitHubGc|ConvertFrom-Json -Depth 100   
        }
        else{
            $GitHubData = $null
        }
        # GITLAB DATABASE
        if(Test-Path $GitLabPath){
            $GitLabGc   = Get-Content $GitLabPath -Force
            $GitLabData = $GitLabGc|ConvertFrom-Json -Depth 100   
        }
        else{
            $GitLabData = $null
        }
        # MODULES DATABASE
        if(Test-Path $ModulesPath){
            $ModulesGc   = Get-Content $ModulesPath -Force
            $ModulesData = $ModulesGc|ConvertFrom-Json -Depth 100
        }
        else{
            $ModulesData = $null
        }
        # PACKAGES DATABASE
        if(Test-Path $PackagesPath){
            $PackagesGc   = Get-Content $PackagesPath -Force
            $PackagesData = $PackagesGc|ConvertFrom-Json -Depth 100   
        }
        else{
            $PackagesData = $null
        }
    }
    else{
        BREAK
    }
}
#endregion [ PROJECT DEFINITION ]

#region >> [ PROJECT VERIFICATION ]
$PROJECT_VERIFICATION_SC = {
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
#endregion [ PROJECT VERIFICATION ]

#region >> [ PROJECT PROCEDURES ]
$PROJECT_PROCEDURES_SC = {
    $InvokeProcedure = Invoke-Project_Procedures -OperatingSystem $OS_TYPE -BuildData $BuildData -Procedures ('Update') -MeasureDuration $True -ErrorAction Stop
}
#endregion [ PROJECT PROCEDURES ]

#region >> [ TRIGGER SWITCH ]
$TRIGGER_SWITCH_SC = {
    switch (1..3) {
        1 { $PROJECT_DEFINITION_SC   | iex -ErrorAction SilentlyContinue }
        2 { $PROJECT_VERIFICATION_SC | iex -ErrorAction SilentlyContinue }
        3 { $PROJECT_PROCEDURES_SC   | iex -ErrorAction SilentlyContinue }
    }
}
#endregion [ DEFAULT SWITCH ]

$ScriptRoot     = $PSScriptRoot
$FunctionsPath  = Join-Path -Path $ScriptRoot -ChildPath 'functions.ps1' -Verbose
$ProceduresPath = Join-Path -Path $ScriptRoot -ChildPath 'procedures.ps1' -Verbose
Import-Module $FunctionsPath
Import-Module $ProceduresPath
$MeasureCommand = Measure-Command -Expression {
    $TRIGGER_SWITCH_SC | iex -ErrorAction SilentlyContinue
}
Write-Host ('OverallTime: '+$MeasureCommand)

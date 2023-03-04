#region >> [ PROJECT INSTALL DEFINITION ]
$PROJECT_INSTALL_DEFINITION_SC = {
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
        $DefaultPath      = $DefaultRoot
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
            $ConfigGc   = Get-Content $ConfigPath -Force
            $ConfigData = $ConfigGc|ConvertFrom-Json -Depth 100
            $ConfigData.InstallPath  = $EnvironmentPath
            $ConfigData.ProjectsPath = $ProjectsPath
            $ConfigData.RunspacePath = $RunspacePath
        }
        else{
            $ConfigData = $null
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
#endregion [ PROJECT INSTALL DEFINITION ]
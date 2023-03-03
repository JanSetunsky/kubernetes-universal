# BUILDER
function Build-Project_Environment  {
<#
.SYNOPSIS
    Build project environment process.

.DESCRIPTION
    First, the configuration file that was inserted into the envionment/config.json 
    folder before building is initialized ... Then the internal database github,gitlab,
    modules,packages is analyzed and compared with the configuration requirements for the build.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER Configuration
    PSCustomObject - The configuration parameter specifies all the necessary information to successfully
     run and complete the function.

.PARAMETER GitHubDatabase
    Internal github database in specific format from db/github.json file

.PARAMETER GitLabDatabase
    Internal gitlab database in specific format from db/gitlab.json file

.PARAMETER ModuleDatabase
    Internal modules database in specific format from db/modules.json file

.PARAMETER PackageDatabase
    Internal packages database in specific format from db/packages.json file

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.EXAMPLE
    Build-Project_Environment -OperatingSystem $OS_TYPE -Configuration $ConfigData -GitHubDatabase $GitHubData -GitLabDatabase $GitLabData -ModuleDatabase $ModulesData -PackageDatabase $PackagesData -MeasureDuration $False -ErrorAction Stop

.INPUTS
    PSCustomObject

.OUTPUTS
    PSCustomObject

.NOTES
    Author: Jan Setunsky
    GitHub: https://github.com/JanSetunsky
#>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [PSCustomObject]$OperatingSystem,
        [Parameter(Position=1,Mandatory=$True)]
        [PSCustomObject]$Configuration,
        [Parameter(Position=2,Mandatory=$True)]
        [AllowNull()]
        [PSCustomObject]$GitHubDatabase,
        [Parameter(Position=3,Mandatory=$True)]
        [AllowNull()]
        [PSCustomObject]$GitLabDatabase,
        [Parameter(Position=4,Mandatory=$True)]
        [AllowNull()]
        [PSCustomObject]$ModuleDatabase,
        [Parameter(Position=5,Mandatory=$True)]
        [AllowNull()]
        [PSCustomObject]$PackageDatabase,
        [Parameter(Position=6,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            $Autor                  = $Configuration.Autor
            $ProjectId              = $Configuration.ProjectId
            $ProjectName            = $Configuration.ProjectName
            $ProjectType            = $Configuration.ProjectType
            $ProjectVersion         = $Configuration.ProjectVersion
            $InstallPath            = $Configuration.InstallPath
            $RunspacePath           = $Configuration.RunspacePath
            $ProjectsPath           = $Configuration.ProjectsPath
            $OS                     = $Configuration.OS
            $Platform               = $Configuration.Platform
            $Architecture           = $Configuration.Architecture
            $EnviromentProvider     = $Configuration.EnviromentProvider
            $EnviromentType         = $Configuration.EnviromentType
            $Virtualization         = $Configuration.Virtualization
            $InstallingGitHub       = $Configuration.InstallingGitHub
            $InstallingGitLab       = $Configuration.InstallingGitLab
            $InstallingModules      = $Configuration.InstallingModules
            $InstallingPackages     = $Configuration.InstallingPackages
            $ListOfProcedures       = $Configuration.ListOfProcedures
            $ListOfGitHub           = $Configuration.ListOfGitHub
            $ListOfGitLab           = $Configuration.ListOfGitLab
            $ListOfModules          = $Configuration.ListOfModules
            $ListOfPackages         = $Configuration.ListOfPackages
            $GitHubDataList         = @()
            $GitLabDataList         = @()
            $ModulesDataList        = @()
            $PackagesDataList       = @()
            $GitHubConditionList    = @()
            $GitLabConditionList    = @()
            $ModulesConditionList   = @()
            $PackagesConditionList  = @()
            if(Test-Path $InstallPath){
                if($OperatingSystem -eq 'Linux'){
                    $Condition = $True
                }
                elseif($OperatingSystem -eq 'MacOS'){
                    $Condition = $True
                }            
                elseif($OperatingSystem -eq 'Windows'){
                    $Condition = $True
                    # Internet connection available
                    if(Test-Connection -ComputerName "www.google.com" -Quiet){
                        Write-Host "Internet connection available."
                        $InternetConnectionCondition = $True
                    }
                    else{
                        Write-Host "Internet connection not available."
                        $InternetConnectionCondition = $False
                    }
                    # Create project paths
                    $ProjectPath  = Join-Path -Path $ProjectsPath -ChildPath $ProjectName -Verbose
                    $GitHubPath   = Join-Path -Path $ProjectPath -ChildPath 'github' -Verbose
                    $GitLabPath   = Join-Path -Path $ProjectPath -ChildPath 'gitlab' -Verbose
                    $ModulesPath  = Join-Path -Path $ProjectPath -ChildPath 'modules' -Verbose
                    $PackagesPath = Join-Path -Path $ProjectPath -ChildPath 'packages' -Verbose
                    # GITHUB
                    if($InstallingGitHub -and $ListOfGitHub.Count -ge 1){
                        $GitHubListConditionList = @()
                        foreach($GitHub_Config in $ListOfGitHub){
                            $GitHub_Config_Id         = $GitHub_Config.Id
                            $GitHub_Config_NodeId     = $GitHub_Config.NodeId
                            $GitHub_Config_Login      = $GitHub_Config.Login
                            $GitHub_Config_Repository = $GitHub_Config.RepositoryList
                            $FindGitHubCondition      = $False
                            foreach($GitHub_DB in $GitHubDatabase){
                                $GitHub_DB_Id         = $GitHub_DB.Id
                                $GitHub_DB_NodeId     = $GitHub_DB.NodeId
                                $GitHub_DB_Login      = $GitHub_DB.Login
                                $GitHub_DB_Repository = $GitHub_DB.RepositoryList
                                if(
                                    $GitHub_Config_Id -eq $GitHub_DB_Id -and
                                    $GitHub_Config_NodeId -eq $GitHub_DB_NodeId -and
                                    $GitHub_Config_Login -eq $GitHub_DB_Login
                                ){
                                    $FindGitHubCondition = $True
                                    if($GitHub_Config_Login.Length -gt 0){
                                        $GitHubItemPath = $ConfigInstallPath+'\'+$GitHub_Config_Login
                                    }
                                    else{
                                        $GitHubItemPath = ''
                                    }
                                    $GitHubRepositoryDataList = @()
                                    $RepositoryIndex = 0
                                    foreach ($GitHub_Config_Repository_Item in $GitHub_Config_Repository) {
                                        $GitHub_Config_Repository_Item_Id        = $GitHub_Config_Repository_Item.Id
                                        $GitHub_Config_Repository_Item_NodeId    = $GitHub_Config_Repository_Item.NodeId
                                        $GitHub_Config_Repository_Item_Name      = $GitHub_Config_Repository_Item.Name
                                        $GitHub_Config_Repository_Item_FullName  = $GitHub_Config_Repository_Item.FullName
                                        $GitHub_Config_Repository_Item_Install   = $GitHub_Config_Repository_Item.Install
                                        $GitHub_Config_Repository_Item_OwnerShip = $GitHub_Config_Repository_Item.Ownership
                                        $GitHub_Config_Repository_Item_Branch    = $GitHub_Config_Repository_Item.Branch
                                        $GitHub_Config_Repository_Item_Private   = $GitHub_Config_Repository_Item.Private
                                        $GitHub_Config_Repository_Item_Token     = $GitHub_Config_Repository_Item.Token
                                        $GitHub_Config_Repository_Item_Update    = $GitHub_Config_Repository_Item.Update
                                        if($GitHub_DB_Repository.Count -ge 1){
                                            $FindGitHubRepositoryCondition = $False
                                            foreach ($GitHub_DB_Repository_Item in $GitHub_DB_Repository) {
                                                $GitHub_DB_Repository_Item_Id       = $GitHub_DB_Repository_Item.Id
                                                $GitHub_DB_Repository_Item_NodeId   = $GitHub_DB_Repository_Item.NodeId
                                                $GitHub_DB_Repository_Item_Name     = $GitHub_DB_Repository_Item.Name
                                                $GitHub_DB_Repository_Item_FullName = $GitHub_DB_Repository_Item.FullName
                                                if($GitHub_Config_Repository_Item_OwnerShip){
                                                    $GitHub_VARIABLE_Repository_Item_Install = $GitHub_Config_Repository_Item_Install
                                                    $GitHub_VARIABLE_Repository_Item_Branch  = $GitHub_Config_Repository_Item_Branch
                                                    $GitHub_VARIABLE_Repository_Item_Private = $GitHub_Config_Repository_Item_Private
                                                    $GitHub_VARIABLE_Repository_Item_Token   = $GitHub_Config_Repository_Item_Token
                                                    $GitHub_VARIABLE_Repository_Item_Update  = $GitHub_Config_Repository_Item_Update
                                                }
                                                else{
                                                    $GitHub_VARIABLE_Repository_Item_Install = $GitHub_DB_Repository_Item.Install
                                                    $GitHub_VARIABLE_Repository_Item_Branch  = $GitHub_DB_Repository_Item.Branch
                                                    $GitHub_VARIABLE_Repository_Item_Private = $GitHub_DB_Repository_Item.Private
                                                    $GitHub_VARIABLE_Repository_Item_Token   = $GitHub_DB_Repository_Item.Token
                                                    $GitHub_VARIABLE_Repository_Item_Update  = $GitHub_DB_Repository_Item.Update
                                                }
                                                $GitHub_DB_Repository_Item_Git_Url  = 'https://github.com/'+$GitHub_DB_Repository_Item_FullName+'.git'
                                                if(
                                                    $GitHub_Config_Repository_Item_Id -eq $GitHub_DB_Repository_Item_Id -and
                                                    $GitHub_Config_Repository_Item_NodeId -eq $GitHub_DB_Repository_Item_NodeId -and
                                                    $GitHub_Config_Repository_Item_Name -eq $GitHub_DB_Repository_Item_Name -and 
                                                    $GitHub_Config_Repository_Item_FullName -eq $GitHub_DB_Repository_Item_FullName
                                                ){
                                                    $CreateGitHubDirPath  = Join-Path -Path $GitHubPath -ChildPath $GitHub_Config_Login -Verbose
                                                    $CreateGitHubFilePath = Join-Path -Path $CreateGitHubDirPath -ChildPath ($GitHub_Config_Repository_Item_Name) -Verbose
                                                    if(Test-Path $CreateGitHubDirPath){
                                                        if(Test-Path $CreateGitHubFilePath){
                                                            Write-Host ('Already exists: '+$CreateGitHubFilePath)
                                                            if($GitHub_VARIABLE_Repository_Item_Update -eq 'clone'){
                                                                $GitHubDownloadCondition = 'clone'
                                                            }
                                                            elseif($GitHub_VARIABLE_Repository_Item_Update -eq 'fetch'){
                                                                $GitHubDownloadCondition = 'fetch'
                                                            }
                                                            elseif($GitHub_VARIABLE_Repository_Item_Update -eq 'pull'){
                                                                $GitHubDownloadCondition = 'pull'
                                                            }                                                            
                                                            else{
                                                                $GitHubDownloadCondition = 'not-allowed'
                                                            }
                                                        }
                                                        else{
                                                            Write-Host ('Downloading: '+$GitHub_DB_Repository_Item_Git_Url)
                                                            $GitHubDownloadCondition = 'clone'
                                                        }   
                                                    }
                                                    else{
                                                        $NewItem = New-Item -Path $CreateGitHubDirPath -ItemType Directory -Force -Verbose
                                                        if(Test-Path $CreateGitHubDirPath){
                                                            Write-Host ('Downloading: '+$GitHub_DB_Repository_Item_Git_Url)
                                                            $GitHubDownloadCondition = 'clone'
                                                        }
                                                        else{
                                                            $GitHubDownloadCondition = 'not-allowed'
                                                        }
                                                    }
                                                    if($GitHubDownloadCondition -eq 'clone' -and $InternetConnectionCondition){
                                                        # Download GitHub repositary process
                                                        if($GitHub_VARIABLE_Repository_Item_Private){
                                                            $GitHubTokenUrl = 'https://github.com/'+$GitHub_VARIABLE_Repository_Item_Token+'/'+$GitHub_DB_Repository_Item_FullName+'.git'
                                                            git clone $GitHubTokenUrl $CreateGitHubFilePath
                                                            if($LASTEXITCODE -eq 0){
                                                                $FindGitHubRepositoryCondition = $True
                                                                Write-Host 'Download was successful.'
                                                            }
                                                            else{
                                                                $FindGitHubRepositoryCondition = $False
                                                                Write-Warning 'Download failed.'
                                                            }
                                                        }
                                                        else{
                                                            git clone $GitHub_DB_Repository_Item_Git_Url $CreateGitHubFilePath
                                                            if($LASTEXITCODE -eq 0){
                                                                $FindGitHubRepositoryCondition = $True
                                                                Write-Host 'Download was successful.'
                                                            }
                                                            else{
                                                                $FindGitHubRepositoryCondition = $False
                                                                Write-Warning 'Download failed.'
                                                            }
                                                        }
                                                    }
                                                    elseif($GitHubDownloadCondition -eq 'fetch' -and $InternetConnectionCondition){
                                                        # Download GitHub repositary process
                                                        if($GitHub_VARIABLE_Repository_Item_Private){
                                                            $GitHubTokenUrl = 'https://github.com/'+$GitHub_VARIABLE_Repository_Item_Token+'/'+$GitHub_DB_Repository_Item_FullName+'.git'
                                                            $GetLocationPath = (Get-Location).path
                                                            cd $CreateGitHubFilePath
                                                            git remote set-url $GitHub_VARIABLE_Repository_Item_Branch $GitHubTokenUrl
                                                            git fetch
                                                            git reset --hard $GitHub_VARIABLE_Repository_Item_Branch
                                                            if($LASTEXITCODE -eq 0){
                                                                $FindGitHubRepositoryCondition = $True
                                                                Write-Host 'Download was successful.'
                                                            }
                                                            else{
                                                                $FindGitHubRepositoryCondition = $False
                                                                Write-Warning 'Download failed.'
                                                            }
                                                            cd $CreateGitHubFilePath
                                                        }
                                                        else{
                                                            $GetLocationPath = (Get-Location).path
                                                            cd $CreateGitHubFilePath
                                                            git fetch $GitHub_DB_Repository_Item_Git_Url
                                                            git reset --hard $GitHub_VARIABLE_Repository_Item_Branch
                                                            if($LASTEXITCODE -eq 0){
                                                                $FindGitHubRepositoryCondition = $True
                                                                Write-Host 'Download was successful.'
                                                            }
                                                            else{
                                                                $FindGitHubRepositoryCondition = $False
                                                                Write-Warning 'Download failed.'
                                                            }
                                                            cd $CreateGitHubFilePath
                                                        }
                                                    }
                                                    elseif($GitHubDownloadCondition -eq 'pull' -and $InternetConnectionCondition){
                                                        # Download GitHub repositary process
                                                        if($GitHub_VARIABLE_Repository_Item_Private){
                                                            $GitHubTokenUrl = 'https://github.com/'+$GitHub_VARIABLE_Repository_Item_Token+'/'+$GitHub_DB_Repository_Item_FullName+'.git'
                                                            $GetLocationPath = (Get-Location).path
                                                            cd $CreateGitHubFilePath
                                                            git pull $GitHubTokenUrl
                                                            if($LASTEXITCODE -eq 0){
                                                                $FindGitHubRepositoryCondition = $True
                                                                Write-Host 'Download was successful.'
                                                            }
                                                            else{
                                                                $FindGitHubRepositoryCondition = $False
                                                                Write-Warning 'Download failed.'
                                                            }
                                                            cd $CreateGitHubFilePath
                                                        }
                                                        else{
                                                            $GetLocationPath = (Get-Location).path
                                                            cd $CreateGitHubFilePath
                                                            git pull
                                                            if($LASTEXITCODE -eq 0){
                                                                $FindGitHubRepositoryCondition = $True
                                                                Write-Host 'Download was successful.'
                                                            }
                                                            else{
                                                                $FindGitHubRepositoryCondition = $False
                                                                Write-Warning 'Download failed.'
                                                            }
                                                            cd $CreateGitHubFilePath
                                                        }
                                                    }
                                                    elseif($InternetConnectionCondition -eq $False){
                                                        $FindGitHubRepositoryCondition = $False
                                                        Write-Host "Download failed, internet connection not available."
                                                    }
                                                    else{
                                                        Write-Warning 'Download failed.'
                                                        $FindGitHubRepositoryCondition = $False
                                                    }
                                                }
                                            }
                                            if($FindGitHubRepositoryCondition){
                                                $GitHubListConditionList += $True
                                                $GitHubRepositoryDataList += [PSCustomObject]@{
                                                    Id       = $GitHub_Config_Repository_Item_Id
                                                    NodeId   = $GitHub_Config_Repository_Item_NodeId
                                                    Name     = $GitHub_Config_Repository_Item_Name
                                                    FullName = $GitHub_Config_Repository_Item_FullName
                                                    Install  = $GitHub_VARIABLE_Repository_Item_Install
                                                    Branch   = $GitHub_VARIABLE_Repository_Item_Branch
                                                    Private  = $GitHub_VARIABLE_Repository_Item_Private
                                                    Token    = $GitHub_VARIABLE_Repository_Item_Token
                                                    Update   = $GitHub_VARIABLE_Repository_Item_Update
                                                    Status   = 'is-downloaded'
                                                    Path     = $CreateGitHubFilePath
                                                }
                                            }
                                            else{
                                                $GitHubListConditionList += $False
                                                $GitHubRepositoryDataList += [PSCustomObject]@{
                                                    Id       = $GitHub_Config_Repository_Item_Id
                                                    NodeId   = $GitHub_Config_Repository_Item_NodeId
                                                    Name     = $GitHub_Config_Repository_Item_Name
                                                    FullName = $GitHub_Config_Repository_Item_FullName
                                                    Install  = $GitHub_VARIABLE_Repository_Item_Install
                                                    Branch   = $GitHub_VARIABLE_Repository_Item_Branch
                                                    Private  = $GitHub_VARIABLE_Repository_Item_Private
                                                    Token    = $GitHub_VARIABLE_Repository_Item_Token
                                                    Update   = $GitHub_VARIABLE_Repository_Item_Update
                                                    Status   = 'is-not-downloaded'
                                                    Path     = 'None'
                                                }
                                            }
                                        }
                                        else{
                                            $GitHubListConditionList += $False
                                        }
                                    }
                                    $RepositoryIndex++
                                }
                            }
                            if($FindGitHubCondition){
                                $GitHubListConditionList += $True
                                $GitHubDataList += [PSCustomObject]@{
                                    Id             = $GitHub_Config_Id
                                    NodeId         = $GitHub_Config_NodeId
                                    Login          = $GitHub_Config_Login
                                    Status         = 'is-downloaded'
                                    RepositoryList = $GitHubRepositoryDataList
                                    Path           = $CreateGitHubDirPath
                                }
                            }
                            else{
                                $GitHubListConditionList += $False
                                $GitHubDataList += [PSCustomObject]@{
                                    Id             = $GitHub_Config_Id
                                    NodeId         = $GitHub_Config_NodeId
                                    Login          = $GitHub_Config_Login
                                    Status         = 'is-not-downloaded'
                                    RepositoryList = $GitHubRepositoryDataList
                                    Path           = $CreateGitHubDirPath
                                }
                            }
                            $Index++
                        }
                    }
                    else{
                        $GitHubConditionList += $False
                    }
                    # GITLAB
                    if($InstallingGitLab -and $ListOfGitLab.Count -ge 1){
                        foreach ($GitLab in $ListOfGitLab) {

                        }
                    }
                    else{
                        $GitLabConditionList += $False
                    }
                    # MODULES
                    if($InstallingModules -and $ListOfModules.Count -ge 1){
                        foreach ($Module in $ListOfModules) {
                            $ModuleId     = $Module.Id
                            $ModuleName   = $Module.Name
                            $ModuleStatus = $Module.Status
                            $ModuleFilter = $null
                            $ModuleFilter = $ModuleDatabase | ? {$_.Id -eq $ModuleId -and $_.Name -eq $ModuleName}
                            if($ModuleFilter.Count -eq 1){
                                $ModuleInstallMethod  = $ModuleFilter.InstallMethod
                                $ModuleInstallType    = $ModuleFilter.InstallType
                                $ModuleInstallCommand = $ModuleFilter.InstallCommand
                                $ModuleRepositoryPath = $ModuleFilter.RepositoryPath
                                if($ModuleInstallType -eq 'Decode-Command' -or $ModuleInstallType -eq 'Encode-Command'){
                                    $ModulesDataList += [PSCustomObject]@{
                                        Name      = $ModuleName
                                        Status    = $ModuleStatus
                                        Installer = $ModuleInstallMethod
                                        Command   = $ModuleInstallCommand
                                        Type      = $ModuleInstallType
                                        Path      = $ModuleRepositoryPath
                                    }
                                }
                                else{
                                    $ModulesConditionList += $False
                                }                            
                            }
                            else{
                                $ModulesConditionList += $False
                            }
                        }
                    }
                    else{
                        $ModulesConditionList += $False
                    }
                    # PACKAGES
                    if($InstallingPackages -and $ListOfPackages.Count -ge 1){
                        foreach ($Package in $ListOfPackages) {
                            $PackageId       = $Package.Id
                            $PackageName     = $Package.Name
                            $PackageStatus   = $Package.Status
                            $PackageToolList = $Package.ToolList
                            $PackageFilter   = $null
                            $PackageFilter   = $PackageDatabase | ? {$_.Id -eq $PackageId -and $_.Name -eq $PackageName}
                            if($PackageFilter.Count -eq 1){
                                $PackageInstallMethod  = $PackageFilter.InstallMethod
                                $PackageInstallType    = $PackageFilter.InstallType
                                $PackageInstallCommand = $PackageFilter.InstallCommand
                                $PackageRepositoryPath = $PackageFilter.RepositoryPath
                                if($PackageInstallType -eq 'Decode-Command' -or $PackageInstallType -eq 'Encode-Command'){
                                    $PackagesDataList += [PSCustomObject]@{
                                        Name      = $PackageName
                                        Status    = $PackageStatus
                                        Installer = $PackageInstallMethod
                                        Command   = $PackageInstallCommand
                                        Type      = $PackageInstallType
                                        Path      = $PackageRepositoryPath
                                        ToolList  = $PackageToolList
                                    }
                                }
                                elseif($PackageInstallType -eq 'exe' -or $PackageInstallType -eq 'msi'){
                                    $PackageFileName = $PackageName+'.'+$PackageInstallType
                                    $PackageDirPath  = Join-Path -Path $PackagesPath -ChildPath $PackageName -Verbose
                                    $ExecutablePath  = Join-Path -Path $PackageDirPath -ChildPath $PackageFileName -Verbose
                                    $NewItem         = New-Item -Path $PackageDirPath -ItemType Directory -Force -Verbose
                                    if(Test-Path $ExecutablePath){
        
                                    }
                                    else{
                                        $WebRequest = Invoke-WebRequest -OutFile $ExecutablePath -Uri $PackageRepositoryPath -UseBasicParsing -Verbose
                                    }                            
                                    $PackagesDataList += [PSCustomObject]@{
                                        Name      = $PackageName
                                        Status    = $PackageStatus
                                        Installer = $PackageInstallMethod
                                        Command   = $PackageInstallCommand
                                        Type      = $PackageInstallType                                    
                                        Path      = $ExecutablePath
                                        ToolList  = $PackageToolList
                                    }                                    
                                }
                                else{
                                    $PackagesConditionList += $False
                                }                            
                            }
                            else{
                                $PackagesConditionList += $False
                            }
                        }
                    }
                    else{
                        $PackagesConditionList += $False
                    }
                }
                else{
                    $Condition = $False
                }
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            # Verify GitHub conditions
            if($ListOfGitHub.Count -eq 1 -and $GitHubConditionList){
                $GitHubConditionResult = $True
            }
            elseif($ListOfGitHub.Count -gt 1 -and $null -eq $($GitHubConditionList -match $False)){
                $GitHubConditionResult = $True
            }
            else{
                $GitHubConditionResult = $False
            }
            # Verify GitLab conditions
            if($ListOfGitLab.Count -eq 1 -and $GitLabConditionList){
                $GitLabConditionResult = $True
            }
            elseif($ListOfGitLab.Count -gt 1 -and $null -eq $($GitLabConditionList -match $False)){
                $GitLabConditionResult = $True
            }
            else{
                $GitLabConditionResult = $False
            }
            # Verify Modules conditions
            if($ListOfModules.Count -eq 1 -and $ModulesConditionList){
                $ModulesConditionResult = $True
            }
            elseif($ListOfModules.Count -gt 1 -and $null -eq $($ModulesConditionList -match $False)){
                $ModulesConditionResult = $True
            }
            else{
                $ModulesConditionResult = $False
            }
            # Verify Packages conditions
            if($ListOfPackages.Count -eq 1 -and $PackagesConditionList){
                $PackagesConditionResult = $True
            }
            elseif($ListOfPackages.Count -gt 1 -and $null -eq $($PackagesConditionList -match $False)){
                $PackagesConditionResult = $True
            }
            else{
                $PackagesConditionResult = $False
            }                                    
            # GITHUB
            if($Condition -and $ListOfGitHub.Count -ge 1){
                $GitHubResult = 'Build GitHub success!'
                $GitHubResponseList = @()
                foreach ($GitHubItem in $ListOfGitHub) {
                    foreach ($GitHubRepositoryItem in $GitHubItem.RepositoryList) {
                        $GitHubResponseList += $GitHubRepositoryItem.FullName
                    }
                }
            }
            elseif($Condition -and $ListOfGitHub.Count -eq 0){
                $GitHubResult = 'GitHub is not available!'
                $GitHubResponseList = 'None'
            }
            else{
                $GitHubResult = 'Build GitHub failed!'
                $GitHubResponseList = 'None'
            }
            # GITLAB
            if($Condition -and $ListOfGitLab.Count -ge 1){
                $GitLabResult = 'Build GitLab success!'
                $GitLabResponseList = @()
                foreach ($GitLabItem in $ListOfGitLab) {
                    foreach ($GitLabRepositoryItem in $GitLabItem.RepositoryList) {
                        $GitLabResponseList += $GitLabRepositoryItem.FullName
                    }
                }
            }
            elseif($Condition -and $ListOfGitLab.Count -eq 0){
                $GitLabResult = 'GitLab is not available!'
                $GitLabResponseList = 'None'
            }
            else{
                $GitLabResult = 'Build GitLab failed!'
                $GitLabResponseList = 'None'
            }
            # MODULES
            if($Condition -and $ListOfModules.Count -ge 1){
                $ModulesResult = 'Build modules success!'
                $ModulesResponseList = $ListOfModules.Name
            }
            elseif($Condition -and $ListOfModules.Count -eq 0){
                $ModulesResult = 'Module is not available!'
                $ModulesResponseList = 'None'
            }
            else{
                $ModulesResult = 'Build modules failed!'
                $ModulesResponseList = 'None'
            }
            # PACKAGES
            if($Condition -and $ListOfPackages.Count -ge 1){
                $PackagesResult = 'Build packages success!'
                $PackagesResponseList = $ListOfPackages.Name
            }
            elseif($Condition -and $ListOfPackages.Count -eq 0){
                $PackagesResult = 'Packages is not available!'
                $PackagesResponseList = 'None'
            }            
            else{
                $PackagesResult = 'Build packages failed!'
                $PackagesResponseList = 'None'
            }
            # BUILDER
            if($Condition){
                if($ListOfGitHub.Count -ge 1 -or $ListOfGitLab.Count -ge 1 -or $ListOfPackages.Count -ge 1 -or $ListOfPackages.Count -ge 1){
                    # Revalidation of availability
                    if($ListOfGitHub.Status -eq 'is-not-downloaded'){
                        $GitHubRevalidation = Get-GitHub_Availability -OperatingSystem $OperatingSystem -Configuration $Configuration -GitHubDatabase $GitHubDatabase -MeasureDuration $False -ErrorAction Stop
                    }
                    else{
                        $GitHubRevalidation = $False
                    }
                    if($ListOfGitLab.Status -eq 'is-not-downloaded'){
                        $GitLabRevalidation = Get-GitLab_Availability -OperatingSystem $OperatingSystem -Configuration $Configuration -GitLabDatabase $GitLabDatabase -MeasureDuration $False -ErrorAction Stop
                    }
                    else{
                        $GitLabRevalidation = $False
                    }
                    if($ListOfModules.Status -eq 'is-not-installed'){
                        $ModulesRevalidation = Get-Modules_Availability -OperatingSystem $OperatingSystem -Configuration $Configuration -ModuleDatabase $ModuleDatabase -MeasureDuration $False -ErrorAction Stop
                    }
                    else{
                        $ModulesRevalidation = $False
                    }
                    if($ListOfPackages.Status -eq 'is-not-installed'){
                        $PackagesRevalidation = Get-Packages_Availability -OperatingSystem $OperatingSystem -Configuration $Configuration -PackageDatabase $PackageDatabase -MeasureDuration $False -ErrorAction Stop
                    }
                    else{
                        $PackagesRevalidation = $False
                    }                                                            
                    # Update configuration data by revalidation condition
                    <#
                    
                    
                    if($GitHubRevalidation){
                        $Configuration.ListOfGitHub = $GitHubDataList    
                    }
                    else{
                        
                    }
                    if($GitLabRevalidation){
                        $Configuration.ListOfGitLab = $GitLabDataList    
                    }
                    else{
                        
                    }
                    if($ModulesRevalidation){
                        $Configuration.ListOfModules = $ModulesDataList    
                    }
                    else{
                        
                    }
                    if($PackagesRevalidation){
                        $Configuration.ListOfPackages = $PackagesDataList    
                    }
                    else{
                        
                    }
                    #>
                    # Create builder
                    $BuilderPSCO = [PSCustomObject]@{
                        Autor              = $Configuration.Autor
                        ProjectId          = $Configuration.ProjectId
                        ProjectName        = $Configuration.ProjectName
                        ProjectType        = $Configuration.ProjectType
                        ProjectVersion     = $Configuration.ProjectVersion
                        InstallPath        = $Configuration.InstallPath
                        RunspacePath       = $Configuration.RunspacePath
                        ProjectsPath       = $Configuration.ProjectsPath
                        OS                 = $Configuration.OS
                        Platform           = $Configuration.Platform
                        Architecture       = $Configuration.Architecture
                        EnviromentProvider = $Configuration.EnviromentProvider
                        EnviromentType     = $Configuration.EnviromentType
                        Virtualization     = $Configuration.Virtualization
                        InstallingGitHub   = $Configuration.InstallingGitHub
                        InstallingGitLab   = $Configuration.InstallingGitLab
                        InstallingModules  = $Configuration.InstallingModules
                        InstallingPackages = $Configuration.InstallingPackages
                        ListOfProcedures   = $Configuration.ListOfProcedures
                        ListOfGitHub       = $GitHubDataList
                        ListOfGitLab       = $GitLabDataList
                        ListOfModules      = $ModulesDataList
                        ListOfPackages     = $PackagesDataList
                    }
                    <#
                    $BuilderJson = $BuilderPSCO | ConvertTo-Json -Depth 100
                    $BuilderPath = Join-Path -Path $InstallPath -ChildPath 'builder.json' -Verbose
                    if(Test-Path $BuilderPath){
                        $SetContent = Set-Content $BuilderPath -Value $BuilderJson -Force -Verbose
                    }
                    else{
                        $NewItem = New-Item -Path $BuilderPath -ItemType File -Force -Verbose
                        $SetContent = Set-Content $BuilderPath -Value $BuilderJson -Force -Verbose
                    }                    
                    #>
                    $Result = $BuilderPSCO
                }
                else{
                    $Result = $null
                }
            }
            else{
                $Result = $null
            }            
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
        Write-Host ('[ PROJECT BUILDER - Build-Project_Environment ]')
        Write-Host ('Autor:              '+$Autor)
        Write-Host ('ProjectName:        '+$ProjectName)
        Write-Host ('ProjectType:        '+$ProjectType)
        Write-Host ('ProjectVersion:     '+$ProjectVersion)
        Write-Host ('OS:                 '+$OS)
        Write-Host ('Platform:           '+$Platform)
        Write-Host ('Architecture:       '+$Architecture)
        Write-Host ('EnviromentProvider: '+$EnviromentProvider)
        Write-Host ('EnviromentType:     '+$EnviromentType)
        Write-Host ('Virtualization:     '+$Virtualization)
        Write-Host ('ListOfGitHub:       '+($GitHubResponseList -join ','))
        Write-Host ('ListOfGitLab:       '+($GitLabResponseList -join ','))
        Write-Host ('ListOfModules:      '+($ModulesResponseList -join ','))
        Write-Host ('ListOfPackages:     '+($PackagesResponseList -join ','))
        Write-Host ('ModulesResult:      '+$GitHubResult)
        Write-Host ('PackagesResult:     '+$GitLabResult)
        Write-Host ('ModulesResult:      '+$ModulesResult)
        Write-Host ('PackagesResult:     '+$PackagesResult)        
        Write-Host ''
        if($MeasureDuration){
            $DurationTotal = $DurationBegin+$DurationProcess
            Write-Host ('DurationBegin:      '+$DurationBegin)
            Write-Host ('DurationProcess:    '+$DurationProcess)
            Write-Host ('DurationTotal:      '+$DurationTotal)
            Write-Host ''
        }
        return $Result
    }
}

function Install-Project_Environment  {
<#
.SYNOPSIS
    Install project environment process.

.DESCRIPTION
    The PSCustomObject output from Build-Project_Environment is implemented as a new configuration 
    file and the conditions are compared if the dependencies are installed or not. Accordingly, 
    the next process of installing the necessary utilities into the system will take place.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject - output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.EXAMPLE
    Install-Project_Environment -OperatingSystem $OS_TYPE -BuildData $BuildData -MeasureDuration $False -ErrorAction Stop

.INPUTS
    PSCustomObject

.OUTPUTS
    Boolean

.NOTES
    Author: Jan Setunsky
    GitHub: https://github.com/JanSetunsky
#>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [PSCustomObject]$OperatingSystem,        
        [Parameter(Position=1,Mandatory=$True)]
        [PSCustomObject]$BuildData,
        [Parameter(Position=2,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            $Autor                  = $BuildData.Autor
            $ProjectId              = $BuildData.ProjectId
            $ProjectName            = $BuildData.ProjectName
            $InstallPath            = $BuildData.InstallPath
            $RunspacePath           = $BuildData.RunspacePath
            $ProjectsPath           = $BuildData.ProjectsPath
            $OS                     = $BuildData.OS
            $Platform               = $BuildData.Platform
            $Architecture           = $BuildData.Architecture
            $EnviromentProvider     = $BuildData.EnviromentProvider
            $EnviromentType         = $BuildData.EnviromentType
            $Virtualization         = $BuildData.Virtualization
            $InstallingGitHub       = $BuildData.InstallingGitHub
            $InstallingGitLab       = $BuildData.InstallingGitLab            
            $InstallingModules      = $BuildData.InstallingModules
            $InstallingPackages     = $BuildData.InstallingPackages
            $ListOfProcedures       = $BuildData.ListOfProcedures
            $ListOfGitHub           = $BuildData.ListOfGitHub
            $ListOfGitLab           = $BuildData.ListOfGitLab
            $ListOfModules          = $BuildData.ListOfModules
            $ListOfPackages         = $BuildData.ListOfPackages
            $ResponseList           = @()
            $ListOfGitHubResponse   = @()
            $ListOfGitLabResponse   = @()
            $ListOfModulesResponse  = @()
            $ListOfPackagesResponse = @()
            if(Test-Path $InstallPath){
                if($OperatingSystem -eq 'Linux'){
                    $Condition = $True
                }
                elseif($OperatingSystem -eq 'MacOS'){
                    $Condition = $True
                }            
                elseif($OperatingSystem -eq 'Windows'){
                    $Condition = $True
                    # GITHUB INSTALLER
                    $GitHubIndex = 0
                    foreach ($GitHub in $ListOfGitHub) {
                        $GitHubId             = $GitHub.Id
                        $GitHubNodeId         = $GitHub.NodeId
                        $GitHubLogin          = $GitHub.Login
                        $GitHubStatus         = $GitHub.Status
                        $GitHubRepositoryList = $GitHub.RepositoryList
                        $GitHubPath           = $GitHub.Path
                        $GitHubCondition      = $null
                        if($GitHubStatus -eq 'is-downloaded'){
                            $GitHubRepositoryIndex = 0
                            foreach ($GitHubRepository in $GitHubRepositoryList) {
                                $GitHubRepositoryName             = $GitHubRepository.Name
                                $GitHubRepositoryFullName         = $GitHubRepository.FullName
                                $GitHubRepositoryInstall          = $GitHubRepository.Install
                                $GitHubRepositoryStatus           = $GitHubRepository.Status
                                $GitHubRepositoryInstallCondition = $GitHubRepositoryInstall.Condition
                                $GitHubRepositoryInstallType      = $GitHubRepositoryInstall.Type
                                $GitHubRepositoryInstallCommand   = $GitHubRepositoryInstall.Command
                                if($GitHubRepositoryStatus -eq 'is-downloaded'){
                                    if($GitHubRepositoryInstallCondition -eq 'allowed'){
                                        <#
                                            This method is not tested and completed !!!
                                        #>
                                        if($GitHubRepositoryInstallType -eq 'Decode-Command' -or $PackageType -eq 'Encode-Command'){
                                            if($GitHubRepositoryInstallCommand.Length -ge 1){
                                                $GitHubCondition = New-Runspace -OperatingSystem $OperatingSystem -Name $GitHubRepositoryName -ScriptBlock $GitHubRepositoryInstallCommand -CommandType $GitHubRepositoryInstallType -WindowStyle 'Normal' -ErrorAction SilentlyContinue
                                                if($GitHubCondition){
                                                    $ResponseList += [PSCustomObject]@{
                                                        Name    = $GitHubRepositoryFullName
                                                        Message = 'GitHub repository is downloaded and installation has succeeded.'
                                                        Type    = 'Correctly'
                                                    }
                                                    (($BuildData.ListOfGitHub)[$GitHubIndex].RepositoryList)[$GitHubRepositoryIndex].Status = 'is-installed'
                                                    $ListOfGitHubResponse += 'is-installed'
                                                }
                                                else{
                                                    $ResponseList += [PSCustomObject]@{
                                                        Name    = $GitHubRepositoryFullName
                                                        Message = 'GitHub repository is downloaded and installation failed.'
                                                        Type    = 'Error'
                                                    }
                                                    (($BuildData.ListOfGitHub)[$GitHubIndex].RepositoryList)[$GitHubRepositoryIndex].Status = 'is-not-installed'
                                                    $ListOfGitHubResponse += 'is-not-installed'
                                                }
                                            }
                                            else{
                                                $ResponseList += [PSCustomObject]@{
                                                    Name    = $GitHubRepositoryFullName
                                                    Message = 'GitHub repository command length is not valid.'
                                                    Type    = 'Error'
                                                }
                                                (($BuildData.ListOfGitHub)[$GitHubIndex].RepositoryList)[$GitHubRepositoryIndex].Status = 'is-not-installed'
                                                $ListOfGitHubResponse += 'is-not-installed'
                                            }
                                        }
                                        elseif($GitHubRepositoryInstallType -eq 'implementation'){
                                            $ResponseList += [PSCustomObject]@{
                                                Name    = $GitHubRepositoryFullName
                                                Message = 'GitHub is downloaded and installation is a form of implementation.'
                                                Type    = 'Correctly'
                                            }
                                            (($BuildData.ListOfGitHub)[$GitHubIndex].RepositoryList)[$GitHubRepositoryIndex].Status = 'is-downloaded'
                                            $ListOfGitHubResponse += 'is-downloaded'
                                        }
                                        else{
                                            $ResponseList += [PSCustomObject]@{
                                                Name    = $GitHubRepositoryFullName
                                                Message = 'GitHub repository type is not valid.'
                                                Type    = 'Error'
                                            }
                                            (($BuildData.ListOfGitHub)[$GitHubIndex].RepositoryList)[$GitHubRepositoryIndex].Status = 'is-not-supported'
                                            $ListOfGitHubResponse += 'is-not-supported'
                                        }
                                    }
                                    elseif($GitHubRepositoryInstallCondition -eq 'forbidden'){
                                        $ResponseList += [PSCustomObject]@{
                                            Name    = $GitHubRepositoryFullName
                                            Message = 'GitHub is downloaded and installation is forbidden.'
                                            Type    = 'Warning'
                                        }
                                        (($BuildData.ListOfGitHub)[$GitHubIndex].RepositoryList)[$GitHubRepositoryIndex].Status = 'is-downloaded'
                                        $ListOfGitHubResponse += 'is-downloaded'
                                    }
                                    else{
                                        $GitHubResponseList += [PSCustomObject]@{
                                            Name    = $GitHubRepositoryFullName
                                            Message = 'GitHub repository type is not valid.'
                                            Type    = 'Error'
                                        }
                                        (($BuildData.ListOfGitHub)[$GitHubIndex].RepositoryList)[$GitHubRepositoryIndex].Status = 'is-not-supported'
                                        $ListOfGitHubResponse += 'is-not-supported'
                                    }
                                }
                                elseif($GitHubRepositoryStatus -eq 'is-not-downloaded'){
                                    $ResponseList += [PSCustomObject]@{
                                        Name    = $GitHubRepositoryFullName
                                        Message = 'GitHub repository is not downloaded.'
                                        Type    = 'Error'
                                    }
                                    (($BuildData.ListOfGitHub)[$GitHubIndex].RepositoryList)[$GitHubRepositoryIndex].Status = 'is-not-downloaded'
                                    $ListOfGitHubResponse += 'is-not-downloaded'
                                }
                                else{
                                    $GitHubResponseList += [PSCustomObject]@{
                                        Name    = $GitHubRepositoryFullName
                                        Message = 'GitHub repository status is not valid.'
                                        Type    = 'Error'
                                    }
                                    (($BuildData.ListOfGitHub)[$GitHubIndex].RepositoryList)[$GitHubRepositoryIndex].Status = 'is-not-supported'
                                    $ListOfGitHubResponse += 'is-not-supported'
                                }
                                $GitHubRepositoryIndex++
                            }
                        }
                        elseif($GitHubStatus -eq 'is-not-downloaded'){
                            $ResponseList += [PSCustomObject]@{
                                Name    = $GitHubLogin
                                Message = 'GitHub is not downloaded.'
                                Type    = 'Error'
                            }
                            ($BuildData.ListOfGitHub)[$GitHubIndex].Status = 'is-not-downloaded'
                            $ListOfGitHubResponse += 'is-not-downloaded'
                        }
                        else{
                            $ResponseList += [PSCustomObject]@{
                                Name    = $GitHubLogin
                                Message = 'GitHub status is not valid.'
                                Type    = 'Error'
                            }
                            ($BuildData.ListOfGitHub)[$GitHubIndex].Status = 'is-not-supported'
                            $ListOfGitHubResponse += 'is-not-supported'
                        }
                        $GitHubIndex++
                    }
                    # GITLAB INSTALLER
                    $GitLabIndex = 0
                    foreach ($GitLab in $ListOfGitLab) {
                        $GitLabId             = $GitLab.Id
                        $GitLabNodeId         = $GitLab.NodeId
                        $GitLabLogin          = $GitLab.Login
                        $GitLabStatus         = $GitLab.Status
                        $GitLabRepositoryList = $GitLab.RepositoryList
                        $GitLabPath           = $GitLab.Path
                        $GitLabCondition      = $null
                        if($GitLabStatus -eq 'is-downloaded'){
                            $GitLabRepositoryIndex = 0
                            foreach ($GitLabRepository in $GitLabRepositoryList) {
                                $GitLabRepositoryName             = $GitLabRepository.Name
                                $GitLabRepositoryFullName         = $GitLabRepository.FullName
                                $GitLabRepositoryInstall          = $GitLabRepository.Install
                                $GitLabRepositoryStatus           = $GitLabRepository.Status
                                $GitLabRepositoryInstallCondition = $GitLabRepositoryInstall.Condition
                                $GitLabRepositoryInstallType      = $GitLabRepositoryInstall.Type
                                $GitLabRepositoryInstallCommand   = $GitLabRepositoryInstall.Command
                                if($GitLabRepositoryStatus -eq 'is-downloaded'){
                                    if($GitLabRepositoryInstallCondition -eq 'allowed'){
                                        <#
                                            This method is not tested and completed !!!
                                        #>
                                        if($GitLabRepositoryInstallType -eq 'Decode-Command' -or $PackageType -eq 'Encode-Command'){
                                            if($GitLabRepositoryInstallCommand.Length -ge 1){
                                                $GitLabCondition = New-Runspace -OperatingSystem $OperatingSystem -Name $GitLabRepositoryName -ScriptBlock $GitLabRepositoryInstallCommand -CommandType $GitLabRepositoryInstallType -WindowStyle 'Normal' -ErrorAction SilentlyContinue
                                                if($GitLabCondition){
                                                    $ResponseList += [PSCustomObject]@{
                                                        Name    = $GitLabRepositoryFullName
                                                        Message = 'GitLab repository is downloaded and installation has succeeded.'
                                                        Type    = 'Correctly'
                                                    }
                                                    (($BuildData.ListOfGitLab)[$GitLabIndex].RepositoryList)[$GitLabRepositoryIndex].Status = 'is-installed'
                                                    $ListOfGitLabResponse += 'is-installed'
                                                }
                                                else{
                                                    $ResponseList += [PSCustomObject]@{
                                                        Name    = $GitLabRepositoryFullName
                                                        Message = 'GitLab repository is downloaded and installation failed.'
                                                        Type    = 'Error'
                                                    }
                                                    (($BuildData.ListOfGitLab)[$GitLabIndex].RepositoryList)[$GitLabRepositoryIndex].Status = 'is-not-installed'
                                                    $ListOfGitLabResponse += 'is-not-installed'
                                                }
                                            }
                                            else{
                                                $ResponseList += [PSCustomObject]@{
                                                    Name    = $GitLabRepositoryFullName
                                                    Message = 'GitLab repository command length is not valid.'
                                                    Type    = 'Error'
                                                }
                                                (($BuildData.ListOfGitLab)[$GitLabIndex].RepositoryList)[$GitLabRepositoryIndex].Status = 'is-not-installed'
                                                $ListOfGitLabResponse += 'is-not-installed'
                                            }
                                        }
                                        elseif($GitLabRepositoryInstallType -eq 'implementation'){
                                            $ResponseList += [PSCustomObject]@{
                                                Name    = $GitLabRepositoryFullName
                                                Message = 'GitLab is downloaded and installation is a form of implementation.'
                                                Type    = 'Correctly'
                                            }
                                            (($BuildData.ListOfGitLab)[$GitLabIndex].RepositoryList)[$GitLabRepositoryIndex].Status = 'is-downloaded'
                                            $ListOfGitLabResponse += 'is-downloaded'
                                        }
                                        else{
                                            $ResponseList += [PSCustomObject]@{
                                                Name    = $GitLabRepositoryFullName
                                                Message = 'GitLab repository type is not valid.'
                                                Type    = 'Error'
                                            }
                                            (($BuildData.ListOfGitLab)[$GitLabIndex].RepositoryList)[$GitLabRepositoryIndex].Status = 'is-not-supported'
                                            $ListOfGitLabResponse += 'is-not-supported'
                                        }
                                    }
                                    elseif($GitLabRepositoryInstallCondition -eq 'forbidden'){
                                        $ResponseList += [PSCustomObject]@{
                                            Name    = $GitLabRepositoryFullName
                                            Message = 'GitLab is downloaded and installation is forbidden.'
                                            Type    = 'Warning'
                                        }
                                        (($BuildData.ListOfGitLab)[$GitLabIndex].RepositoryList)[$GitLabRepositoryIndex].Status = 'is-downloaded'
                                        $ListOfGitLabResponse += 'is-downloaded'
                                    }
                                    else{
                                        $GitLabResponseList += [PSCustomObject]@{
                                            Name    = $GitLabRepositoryFullName
                                            Message = 'GitLab repository type is not valid.'
                                            Type    = 'Error'
                                        }
                                        (($BuildData.ListOfGitLab)[$GitLabIndex].RepositoryList)[$GitLabRepositoryIndex].Status = 'is-not-supported'
                                        $ListOfGitLabResponse += 'is-not-supported'
                                    }
                                }
                                elseif($GitLabRepositoryStatus -eq 'is-not-downloaded'){
                                    $ResponseList += [PSCustomObject]@{
                                        Name    = $GitLabRepositoryFullName
                                        Message = 'GitLab repository is not downloaded.'
                                        Type    = 'Error'
                                    }
                                    (($BuildData.ListOfGitLab)[$GitLabIndex].RepositoryList)[$GitLabRepositoryIndex].Status = 'is-not-downloaded'
                                    $ListOfGitLabResponse += 'is-not-downloaded'
                                }
                                else{
                                    $GitLabResponseList += [PSCustomObject]@{
                                        Name    = $GitLabRepositoryFullName
                                        Message = 'GitLab repository status is not valid.'
                                        Type    = 'Error'
                                    }
                                    (($BuildData.ListOfGitLab)[$GitLabIndex].RepositoryList)[$GitLabRepositoryIndex].Status = 'is-not-supported'
                                    $ListOfGitLabResponse += 'is-not-supported'
                                }
                                $GitLabRepositoryIndex++
                            }
                        }
                        elseif($GitLabStatus -eq 'is-not-downloaded'){
                            $ResponseList += [PSCustomObject]@{
                                Name    = $GitLabLogin
                                Message = 'GitLab is not downloaded.'
                                Type    = 'Error'
                            }
                            ($BuildData.ListOfGitLab)[$GitLabIndex].Status = 'is-not-downloaded'
                            $ListOfGitLabResponse += 'is-not-downloaded'
                        }
                        else{
                            $ResponseList += [PSCustomObject]@{
                                Name    = $GitLabLogin
                                Message = 'GitLab status is not valid.'
                                Type    = 'Error'
                            }
                            ($BuildData.ListOfGitLab)[$GitLabIndex].Status = 'is-not-supported'
                            $ListOfGitLabResponse += 'is-not-supported'
                        }
                        $GitLabIndex++
                    }                                        
                    # MODULE INSTALLER
                    $ModuleIndex = 0
                    foreach ($Module in $ListOfModules) {
                        $ModuleName      = $Module.Name
                        $ModuleStatus    = $Module.Status
                        $ModuleInstaller = $Module.Installer
                        $ModuleCommand   = $Module.Command
                        $ModuleType      = $Module.Type
                        $ModulePath      = $Module.Path
                        $ModuleCondition = $null
                        if($ModuleStatus -eq 'is-installed'){
                            $ResponseList += [PSCustomObject]@{
                                Name    = $ModuleName
                                Message = 'Module is installed.'
                                Type    = 'Correctly'
                            }
                            ($BuildData.ListOfModules)[$ModuleIndex].Status = 'is-installed'
                            $ListOfModulesResponse += 'is-installed'
                        }
                        elseif($ModuleStatus -eq 'is-not-installed'){
                            if($ModuleType -eq 'Decode-Command' -or $ModuleType -eq 'Encode-Command'){
                                if($ModuleCommand.Length -ge 1 -and $ModuleInstaller -eq 'Runspace'){
                                    $ModuleCondition = New-Runspace -OperatingSystem $OperatingSystem -Name $ModuleName -ScriptBlock $ModuleCommand -CommandType $ModuleType -WindowStyle 'Normal' -ErrorAction SilentlyContinue
                                    if($ModuleCondition){
                                        $ResponseList += [PSCustomObject]@{
                                            Name    = $ModuleName
                                            Message = 'Module is installed.'
                                            Type    = 'Correctly'
                                        }
                                        ($BuildData.ListOfModules)[$ModuleIndex].Status = 'is-installed'
                                        $ListOfModulesResponse += 'is-installed'
                                    }
                                    else{
                                        $ResponseList += [PSCustomObject]@{
                                            Name    = $ModuleName
                                            Message = 'Module is not installed.'
                                            Type    = 'Error'
                                        }
                                        ($BuildData.ListOfModules)[$ModuleIndex].Status = 'is-not-installed'
                                        $ListOfModulesResponse += 'is-not-installed'
                                    }
                                }
                                else{
                                    $ResponseList += [PSCustomObject]@{
                                        Name    = $ModuleName
                                        Message = 'Module command length is not valid.'
                                        Type    = 'Error'
                                    }
                                    ($BuildData.ListOfModules)[$ModuleIndex].Status = 'is-not-supported'
                                    $ListOfModulesResponse += 'is-not-supported'
                                }                            
                            }
                            else{
                                $ResponseList += [PSCustomObject]@{
                                    Name    = $ModuleName
                                    Message = 'Module type is not valid.'
                                    Type    = 'Error'
                                }
                                ($BuildData.ListOfModules)[$ModuleIndex].Status = 'is-not-supported'
                                $ListOfModulesResponse += 'is-not-supported'
                            }
                        }
                        elseif($ModuleStatus -eq 'is-not-supported'){
                            $ResponseList += [PSCustomObject]@{
                                Name    = $ModuleName
                                Message = 'Module is not supported.'
                                Type    = 'Error'
                            }
                            ($BuildData.ListOfModules)[$ModuleIndex].Status = 'is-not-supported'
                            $ListOfModulesResponse += 'is-not-supported'
                        }                        
                        else{
                            $ResponseList += [PSCustomObject]@{
                                Name    = $ModuleName
                                Message = 'Module status is not valid.'
                                Type    = 'Error'
                            }
                            ($BuildData.ListOfModules)[$ModuleIndex].Status = 'is-not-supported'
                            $ListOfModulesResponse += 'is-not-supported'
                        }
                    }
                    # PACKAGE INSTALLER
                    $PackageIndex = 0
                    foreach ($Package in $ListOfPackages) {
                        $PackageName      = $Package.Name
                        $PackageStatus    = $Package.Status
                        $PackageInstaller = $Package.Installer
                        $PackageCommand   = $Package.Command
                        $PackageType      = $Package.Type
                        $PackagePath      = $Package.Path
                        $PackageCondition = $null
                        if($PackageStatus -eq 'is-installed'){
                            $ResponseList += [PSCustomObject]@{
                                Name    = $PackageName
                                Message = 'Package is installed.'
                                Type    = 'Correctly'
                            }
                            ($BuildData.ListOfPackages)[$PackageIndex].Status = 'is-installed'
                            $ListOfPackagesResponse += 'is-installed'
                        }
                        elseif($PackageStatus -eq 'is-duplicated'){
                            $ResponseList += [PSCustomObject]@{
                                Name    = $PackageName
                                Message = 'Package is installed.'
                                Type    = 'Correctly'
                            }
                            ($BuildData.ListOfPackages)[$PackageIndex].Status = 'is-installed'
                            $ListOfPackagesResponse += 'is-installed'
                        }                        
                        elseif($PackageStatus -eq 'is-not-installed'){
                            if($PackageType -eq 'Decode-Command' -or $PackageType -eq 'Encode-Command'){
                                if($PackageCommand.Length -ge 1){
                                    $PackageCondition = New-Runspace -OperatingSystem $OperatingSystem -Name $PackageName -ScriptBlock $PackageCommand -CommandType $PackageType -WindowStyle 'Normal' -ErrorAction SilentlyContinue
                                    if($PackageCondition){
                                        $ResponseList += [PSCustomObject]@{
                                            Name    = $PackageName
                                            Message = 'Package is installed.'
                                            Type    = 'Correctly'
                                        }
                                        ($BuildData.ListOfPackages)[$PackageIndex].Status = 'is-installed'
                                        $ListOfPackagesResponse += 'is-installed'
                                    }
                                    else{
                                        $ResponseList += [PSCustomObject]@{
                                            Name    = $PackageName
                                            Message = 'Package is not installed.'
                                            Type    = 'Error'
                                        }
                                        ($BuildData.ListOfPackages)[$PackageIndex].Status = 'is-not-installed'
                                        $ListOfPackagesResponse += 'is-not-installed'
                                    }                                    
                                }
                                else{
                                    $ResponseList += [PSCustomObject]@{
                                        Name    = $PackageName
                                        Message = 'Package command length is not valid.'
                                        Type    = 'Error'
                                    }
                                    ($BuildData.ListOfPackages)[$PackageIndex].Status = 'is-not-supported'
                                    $ListOfPackagesResponse += 'is-not-supported'
                                }
                            }
                            else{
                                $ResponseList += [PSCustomObject]@{
                                    Name    = $PackageName
                                    Message = 'Package type is not valid.'
                                    Type    = 'Error'
                                }
                                ($BuildData.ListOfPackages)[$PackageIndex].Status = 'is-not-supported'
                                $ListOfPackagesResponse += 'is-not-supported'
                            }
                        }
                        elseif($PackageStatus -eq 'is-not-supported'){
                            $ResponseList += [PSCustomObject]@{
                                Name    = $PackageName
                                Message = 'Package is not supported.'
                                Type    = 'Error'
                            }
                            ($BuildData.ListOfPackages)[$PackageIndex].Status = 'is-not-supported'
                            $ListOfPackagesResponse += 'is-not-supported'
                        }                        
                        else{
                            $ResponseList += [PSCustomObject]@{
                                Name    = $PackageName
                                Message = 'Package status is not valid.'
                                Type    = 'Error'
                            }
                            ($BuildData.ListOfPackages)[$PackageIndex].Status = 'is-not-supported'
                            $ListOfPackagesResponse += 'is-not-supported'
                        }
                    }                    
                }
                else{
                    $Condition = $False
                }
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            $IsDownloadedGitHub     = ($ListOfGitHubResponse | ? {$_ -eq 'is-downloaded'}).Count
            $IsNotDownloadedGitHub  = ($ListOfGitHubResponse | ? {$_ -eq 'is-not-downloaded'}).Count
            $IsInstalledGitHub      = ($ListOfGitHubResponse | ? {$_ -eq 'is-installed'}).Count
            $IsNotInstalledGitHub   = ($ListOfGitHubResponse | ? {$_ -eq 'is-not-installed'}).Count
            $IsNotSupportedGitHub   = ($ListOfGitHubResponse | ? {$_ -eq 'is-not-supported'}).Count                        
            $IsDownloadedGitLab     = ($ListOfGitLabResponse | ? {$_ -eq 'is-downloaded'}).Count
            $IsNotDownloadedGitLab  = ($ListOfGitLabResponse | ? {$_ -eq 'is-not-downloaded'}).Count
            $IsInstalledGitLab      = ($ListOfGitLabResponse | ? {$_ -eq 'is-installed'}).Count
            $IsNotInstalledGitLab   = ($ListOfGitLabResponse | ? {$_ -eq 'is-not-installed'}).Count
            $IsNotSupportedGitLab   = ($ListOfGitLabResponse | ? {$_ -eq 'is-not-supported'}).Count
            $IsInstalledModules     = ($ListOfModulesResponse | ? {$_ -eq 'is-installed'}).Count
            $IsNotInstalledModules  = ($ListOfModulesResponse | ? {$_ -eq 'is-not-installed'}).Count
            $IsNotSupportedModules  = ($ListOfModulesResponse | ? {$_ -eq 'is-not-supported'}).Count
            $IsInstalledPackages    = ($ListOfPackagesResponse | ? {$_ -eq 'is-installed'}).Count
            $IsNotInstalledPackages = ($ListOfPackagesResponse | ? {$_ -eq 'is-not-installed'}).Count
            $IsNotSupportedPackages = ($ListOfPackagesResponse | ? {$_ -eq 'is-not-supported'}).Count  
            if($Condition){
                $Result = 'Install success!'
            }
            else{
                $Result = 'Install failed!'
            }
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
        Write-Host ('[ PROJECT BUILDER - Install-Project_Environment ]')
        foreach ($Response in $ResponseList) {
            if($Response.Type -eq 'Correctly'){
                Write-Host ('Correctly:          '+$Response.Name+' - '+$Response.Message)                
            }
            elseif($Response.Type -eq 'Error'){
                Write-Host ('Error:              '+$Response.Name+' - '+$Response.Message)
            }
            elseif($Response.Type -eq 'Warning'){
                Write-Host ('Warning:            '+$Response.Name+' - '+$Response.Message)
            }
        }
        Write-Host ('is-downloaded | is-not-downloaded | is-installed | is-not-installed | is-not-supported')
        Write-Host ('GitHub:             '+$IsDownloadedGitHub+'|'+$IsNotDownloadedGitHub+'|'+$IsInstalledGitHub+'|'+$IsNotInstalledGitHub+'|'+$IsNotSupportedGitHub)
        Write-Host ('GitLab:             '+$IsDownloadedGitLab+'|'+$IsNotDownloadedGitLab+'|'+$IsInstalledGitLab+'|'+$IsNotInstalledGitLab+'|'+$IsNotSupportedGitLab)
        Write-Host ('Modules:            '+'0|0|'+$IsInstalledModules+'|'+$IsNotInstalledModules+'|'+$IsNotSupportedModules)
        Write-Host ('Packages:           '+'0|0|'+$IsInstalledPackages+'|'+$IsNotInstalledPackages+'|'+$IsNotSupportedPackages)        
        Write-Host ('ProcessResult:      '+$Result)
        Write-Host ''
        if($MeasureDuration){
            $DurationTotal = $DurationBegin+$DurationProcess
            Write-Host ('DurationBegin:      '+$DurationBegin)
            Write-Host ('DurationProcess:    '+$DurationProcess)
            Write-Host ('DurationTotal:      '+$DurationTotal)
            Write-Host ''
        }
        return $Condition
    }
}

function Save-Project_Environment  {
<#
.SYNOPSIS
    Save project environment process.

.DESCRIPTION
    Saving the project environment according to the condition. The conditions here are divided 
    according to the Operating System, according to the type of environment provider, according 
    to the type of environment and according to whether the system is virtualized. Accordingly, 
    the method of saving the project environment to the system is specified.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject - output from Build-Project_Environment and partly Install-Project_Environment .

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.EXAMPLE
    Save-Project_Environment -OperatingSystem $OS_TYPE -BuildData $BuildData -MeasureDuration $False -ErrorAction Stop

.INPUTS
    PSCustomObject

.OUTPUTS
    Boolean

.NOTES
    Author: Jan Setunsky
    GitHub: https://github.com/JanSetunsky
#>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [PSCustomObject]$OperatingSystem,        
        [Parameter(Position=1,Mandatory=$True)]
        [PSCustomObject]$BuildData,
        [Parameter(Position=2,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            $Autor                  = $BuildData.Autor
            $ProjectId              = $BuildData.ProjectId
            $ProjectName            = $BuildData.ProjectName
            $InstallPath            = $BuildData.InstallPath
            $RunspacePath           = $BuildData.RunspacePath
            $ProjectsPath           = $BuildData.ProjectsPath
            $OS                     = $BuildData.OS
            $Platform               = $BuildData.Platform
            $Architecture           = $BuildData.Architecture
            $EnviromentProvider     = $BuildData.EnviromentProvider
            $EnviromentType         = $BuildData.EnviromentType
            $Virtualization         = $BuildData.Virtualization
            $InstallingGitHub       = $BuildData.InstallingGitHub
            $InstallingGitLab       = $BuildData.InstallingGitLab            
            $InstallingModules      = $BuildData.InstallingModules
            $InstallingPackages     = $BuildData.InstallingPackages
            $ListOfProcedures       = $BuildData.ListOfProcedures
            $ListOfModules          = $BuildData.ListOfModules
            $ListOfPackages         = $BuildData.ListOfPackages

            $BuildConfigJson        = $BuildData | ConvertTo-Json -Depth 100
            $ProjectItemDirPath     = Join-Path -Path $ProjectsPath -ChildPath $ProjectName -Verbose
            $ProjectItemConfigPath  = Join-Path -Path $ProjectItemDirPath -ChildPath 'config.json' -Verbose

            if($ListOfPackages -match 'is-not-installed' -or $ListOfPackages -match 'is-not-supported'){
                $Condition = $False
            }
            else{
                if(Test-Path $InstallPath){
                    if($OperatingSystem -eq 'Linux'){
                        $Condition = $True
                    }
                    elseif($OperatingSystem -eq 'MacOS'){
                        $Condition = $True
                    }            
                    elseif($OperatingSystem -eq 'Windows'){
                        # Implementation runspace list
                        $RUNSPACE_001_SC = {
                            if(Test-Path $RunspacePath){
                                if(Test-Path $ProjectsPath){
                                    if(Test-Path $ProjectItemDirPath){
                                        if(Test-Path $ProjectItemConfigPath){
                                            $SetContent = Set-Content -Path $ProjectItemConfigPath -Value $BuildConfigJson -Force -Verbose -ErrorAction SilentlyContinue
                                        }
                                        else{
                                            $NewItem    = New-Item -Path $ProjectItemConfigPath -ItemType File -Force -Verbose -ErrorAction SilentlyContinue
                                            $SetContent = Set-Content -Path $ProjectItemConfigPath -Value $BuildConfigJson -Force -Verbose -ErrorAction SilentlyContinue
                                        }
                                    }
                                    else{
                                        $NewItem    = New-Item -Path $ProjectItemDirPath -ItemType Directory -Force -Verbose -ErrorAction SilentlyContinue
                                        $NewItem    = New-Item -Path $ProjectItemConfigPath -ItemType File -Force -Verbose -ErrorAction SilentlyContinue
                                        $SetContent = Set-Content -Path $ProjectItemConfigPath -Value $BuildConfigJson -Force -Verbose -ErrorAction SilentlyContinue
                                    }
                                }
                                else{
                                    $NewItem    = New-Item -Path $ProjectsPath -ItemType Directory -Force -Verbose -ErrorAction SilentlyContinue
                                    $NewItem    = New-Item -Path $ProjectItemDirPath -ItemType Directory -Force -Verbose -ErrorAction SilentlyContinue
                                    $NewItem    = New-Item -Path $ProjectItemConfigPath -ItemType File -Force -Verbose -ErrorAction SilentlyContinue
                                    $SetContent = Set-Content -Path $ProjectItemConfigPath -Value $BuildConfigJson -Force -Verbose -ErrorAction SilentlyContinue
                                }
                            }
                            else{
                                $NewItem    = New-Item -Path $RunspacePath -ItemType Directory -Force -Verbose -ErrorAction SilentlyContinue
                                $NewItem    = New-Item -Path $ProjectsPath -ItemType Directory -Force -Verbose -ErrorAction SilentlyContinue
                                $NewItem    = New-Item -Path $ProjectItemDirPath -ItemType Directory -Force -Verbose -ErrorAction SilentlyContinue
                                $NewItem    = New-Item -Path $ProjectItemConfigPath -ItemType File -Force -Verbose -ErrorAction SilentlyContinue
                                $SetContent = Set-Content -Path $ProjectItemConfigPath -Value $BuildConfigJson -Force -Verbose -ErrorAction SilentlyContinue
                            }
                        }
                        if($Architecture -eq 'AMD64' -and $EnviromentProvider -eq 'Localhost' -and $EnviromentType -eq 'On-premises' -and $Virtualization -eq 'None'){
                            $Condition  = $True
                            $RUNSPACE_001_SC | iex -ErrorAction SilentlyContinue
                        }
                        else{
                            $Condition = $False
                        }
                    }
                    else{
                        $Condition = $False
                    }
                }
                else{
                    $Condition = $False
                }
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'The configuration was saved successfully.'
            }
            else{
                $Result = 'Failed to save configuration!'
            }
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
        Write-Host ('[ PROJECT BUILDER - Save-Project_Environment ]')
        Write-Host ('ProcessResult:      '+$Result)
        Write-Host ''
        if($MeasureDuration){
            $DurationTotal = $DurationBegin+$DurationProcess
            Write-Host ('DurationBegin:      '+$DurationBegin)
            Write-Host ('DurationProcess:    '+$DurationProcess)
            Write-Host ('DurationTotal:      '+$DurationTotal)
            Write-Host ''
        }
        return $Condition
    }
}



# VERIFICATION
function Get-GitHub_Availability {
<#
.SYNOPSIS
    Validating the GitHub configuration schema and the GitHub database.

.DESCRIPTION
    Verifying the availability of the project's 
    dependencies on the GitHub database and the GitHub configuration schema.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER Configuration
    PSCustomObject - The configuration parameter specifies all the necessary information to successfully
     run and complete the function.

.PARAMETER GitHubDatabase
    PSCustomObject - Internal GitHub database in specific format from db/github.json file

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.EXAMPLE
    Get-GitHub_Availability -OperatingSystem $OS_TYPE -Configuration $ConfigData -GitHubDatabase $GitHubData -MeasureDuration $False -ErrorAction Stop

.INPUTS
    PSCustomObject

.OUTPUTS
    Boolean

.NOTES
    Author: Jan Setunsky
    GitHub: https://github.com/JanSetunsky
#>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [PSCustomObject]$OperatingSystem,
        [Parameter(Position=1,Mandatory=$True)]
        [PSCustomObject]$Configuration,
        [Parameter(Position=2,Mandatory=$True)]
        [AllowNull()]
        [PSCustomObject]$GitHubDatabase,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            if($OperatingSystem -eq 'Linux'){
                $GitHubValidation = $True
                # Command for Linux
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $GitHubValidation = $True
                # Command for MacOS
            }
            elseif($OperatingSystem -eq 'Windows'){
                # Command for Windows
                Write-Host ('[ VERIFICATION - GITHUB AVAILABILITY ]')
                $GitHubListConditionList = @()
                $ConfigProjectName       = $Configuration.ProjectName
                $ConfigProjectsPath      = $Configuration.ProjectsPath
                $ListOfGitHubConfig      = $Configuration.ListOfGitHub
                $ListOfGitHubConfigCount = $ListOfGitHubConfig.Count
                if($ListOfGitHubConfigCount -ge 1){
                    $Index = 0
                    foreach($GitHub_Config in $ListOfGitHubConfig){
                        $GitHub_Config_Id         = $GitHub_Config.Id
                        $GitHub_Config_NodeId     = $GitHub_Config.NodeId
                        $GitHub_Config_Login      = $GitHub_Config.Login
                        $GitHub_Config_Repository = $GitHub_Config.RepositoryList
                        $FindGitHubCondition      = $False
                        $GitHubConditionList      = @()
                        foreach($GitHub_DB in $GitHubDatabase){
                            $GitHub_DB_Id         = $GitHub_DB.Id
                            $GitHub_DB_NodeId     = $GitHub_DB.NodeId
                            $GitHub_DB_Login      = $GitHub_DB.Login
                            $GitHub_DB_Repository = $GitHub_DB.RepositoryList
                            if(
                                $GitHub_Config_Id -eq $GitHub_DB_Id -and
                                $GitHub_Config_NodeId -eq $GitHub_DB_NodeId -and
                                $GitHub_Config_Login -eq $GitHub_DB_Login
                            ){
                                $FindGitHubCondition = $True
                                if($GitHub_Config_Login.Length -gt 0){
                                    $GitHubItemPath = $ConfigProjectsPath+'\'+$ConfigProjectName+'\github\'+$GitHub_Config_Login
                                }
                                else{
                                    $GitHubItemPath = ''
                                }
                                if(Test-Path $GitHubItemPath){
                                    $RepositoryIndex = 0
                                    foreach ($GitHub_Config_Repository_Item in $GitHub_Config_Repository) {
                                        $GitHub_Config_Repository_Item_Id     = $GitHub_Config_Repository_Item.Id
                                        $GitHub_Config_Repository_Item_NodeId = $GitHub_Config_Repository_Item.NodeId
                                        $GitHub_Config_Repository_Item_Name   = $GitHub_Config_Repository_Item.Name
                                        if($GitHub_DB_Repository.Count -ge 1){
                                            $FindGitHubRepositoryCondition = $False
                                            $GitHubRepositoryConditionList = @()
                                            foreach ($GitHub_DB_Repository_Item in $GitHub_DB_Repository) {
                                                $GitHub_DB_Repository_Item_Id     = $GitHub_DB_Repository_Item.Id
                                                $GitHub_DB_Repository_Item_NodeId = $GitHub_DB_Repository_Item.NodeId
                                                $GitHub_DB_Repository_Item_Name   = $GitHub_DB_Repository_Item.Name
                                                if(
                                                    $GitHub_Config_Repository_Item_Id -eq $GitHub_DB_Repository_Item_Id -and
                                                    $GitHub_Config_Repository_Item_NodeId -eq $GitHub_DB_Repository_Item_NodeId -and
                                                    $GitHub_Config_Repository_Item_Name -eq $GitHub_DB_Repository_Item_Name
                                                ){
                                                    $FindGitHubRepositoryCondition = $True
                                                    if($GitHub_Config_Repository_Item_Name.Length -gt 0){
                                                        $GitHubSubItemPath = $GitHubItemPath+'\'+$GitHub_Config_Repository_Item_Name
                                                    }
                                                    else{
                                                        $GitHubItemPath = ''
                                                    }                                                
                                                    if(Test-Path $GitHubSubItemPath){
                                                        Write-Host ('GitHub '+$GitHub_Config_Repository_Item_Name+' is downloaded.')
                                                        (($Configuration.ListOfGitHub)[$Index].RepositoryList)[$RepositoryIndex].Status = 'is-downloaded'
                                                        $GitHubRepositoryConditionList += $True                
                                                    }
                                                    else{
                                                        Write-Warning ('GitHub '+$GitHub_Config_Repository_Item_Name+' is not downloaded.')
                                                        (($Configuration.ListOfGitHub)[$Index].RepositoryList)[$RepositoryIndex].Status = 'is-not-downloaded'
                                                        $GitHubRepositoryConditionList += $False
                                                    }
                                                }
                                            }
                                            if($FindGitHubRepositoryCondition){
                                                $GitHubListConditionList += [PSCustomObject]@{
                                                    Permeable   = $GitHubRepositoryConditionList
                                                    Impermeable = $True
                                                }
                                            }
                                            else{
                                                $GitHubListConditionList += [PSCustomObject]@{
                                                    Permeable   = $GitHubRepositoryConditionList
                                                    Impermeable = $False
                                                }
                                            }
                                        }
                                        else{
                                            Write-Warning ('GitHub '+$GitHub_Config_Repository_Item_Name+' is not downloaded.')
                                            (($Configuration.ListOfGitHub)[$Index].RepositoryList)[$RepositoryIndex].Status = 'is-not-downloaded'
                                            $GitHubConditionList += $False
                                        }
                                    }
                                    $RepositoryIndex++
                                }
                                else{
                                    Write-Warning ('GitHub '+$GitHub_Config_Login+' is not downloaded.')
                                    ($Configuration.ListOfGitHub)[$Index].Status = 'is-not-downloaded'
                                    $GitHubConditionList += $False
                                }
                            }
                        }
                        if($FindGitHubCondition){
                            $GitHubListConditionList += [PSCustomObject]@{
                                Permeable   = $GitHubConditionList
                                Impermeable = $True
                            }
                            ($Configuration.ListOfGitHub)[$Index].Status = 'is-downloaded'
                        }
                        else{
                            $GitHubListConditionList += [PSCustomObject]@{
                                Permeable   = $GitHubConditionList
                                Impermeable = $False
                            }
                            ($Configuration.ListOfGitHub)[$Index].Status = 'is-not-downloaded'
                        }
                        $Index++
                    }  
                }
            }        
            else{
                BREAK
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($ListOfGitHubConfigCount -ge 1){
                $PermeableConditionList   = $GitHubListConditionList.Permeable
                $ImpermeableConditionList = $GitHubListConditionList.Impermeable
                # Verify permeable conditions 
                if($PermeableConditionList.Count -eq 1 -and $PermeableConditionList){
                    $PermeableCondition = $True
                }
                elseif($PermeableConditionList.Count -gt 1 -and $null -eq $($PermeableConditionList -match $False)){
                    $PermeableCondition = $True
                }
                else{
                    $PermeableCondition = $False
                }
                # Verify impermeable conditions
                if($ImpermeableConditionList.Count -eq 1 -and $ImpermeableConditionList){
                    $ImpermeableCondition = $True
                }
                elseif($ImpermeableConditionList.Count -gt 1 -and $null -eq $($ImpermeableConditionList -match $False)){
                    $ImpermeableCondition = $True
                }
                else{
                    $ImpermeableCondition = $False
                }
                if($ImpermeableCondition){
                    if($PermeableCondition){
                        Write-Host "GitHub include all applicable terms and conditions."
                        $GitHubValidation = $True
                    }
                    else{
                        Write-Warning "GitHub contain an permeable condition."
                        $GitHubValidation = $True
                    }
                }
                else{
                    Write-Warning "GitHub contain an impermeable condition!"
                    $GitHubValidation = $False
                }
            }
            else{
                Write-Host "List of GitHub is empty."
                $GitHubValidation = $True
            }
        }
    }
    end{
        if($MeasureDuration){
            $DurationTotal = $DurationBegin+$DurationProcess
            Write-Host ('DurationBegin:      '+$DurationBegin)
            Write-Host ('DurationProcess:    '+$DurationProcess)
            Write-Host ('DurationTotal:      '+$DurationTotal)
            Write-Host ''
        }
        return $GitHubValidation
    }
}

function Get-GitLab_Availability {
<#
.SYNOPSIS
    !!!GITLAB HAS NOT YET BEEN TESTED IN PRACTICE AND SPECIFIC BINDINGS AND LOGIC NEED TO BE CREATED.!!!
    Validating the GitLab configuration schema and the GitLab database.

.DESCRIPTION
    Verifying the availability of the project's 
    dependencies on the GitLab database and the GitLab configuration schema.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER Configuration
    PSCustomObject - The configuration parameter specifies all the necessary information to successfully
     run and complete the function.

.PARAMETER GitLabDatabase
    PSCustomObject - Internal GitLab database in specific format from db/gitlab.json file

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.EXAMPLE
    Get-GitLab_Availability -OperatingSystem $OS_TYPE -Configuration $ConfigData -GitLabDatabase $GitLabData -MeasureDuration $False -ErrorAction Stop

.INPUTS
    PSCustomObject

.OUTPUTS
    Boolean

.NOTES
    Author: Jan Setunsky
    GitHub: https://github.com/JanSetunsky
#>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [PSCustomObject]$OperatingSystem,
        [Parameter(Position=1,Mandatory=$True)]
        [PSCustomObject]$Configuration,
        [Parameter(Position=2,Mandatory=$True)]
        [AllowNull()]
        [PSCustomObject]$GitLabDatabase,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            if($OperatingSystem -eq 'Linux'){
                $GitLabValidation = $True
                # Command for Linux
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $GitLabValidation = $True
                # Command for MacOS
            }
            elseif($OperatingSystem -eq 'Windows'){
                # Command for Windows
                Write-Host ('[ VERIFICATION - GITLAB AVAILABILITY ]')
                $GitLabListConditionList = @()
                $ConfigProjectName       = $Configuration.ProjectName
                $ConfigProjectsPath      = $Configuration.ProjectsPath
                $ListOfGitLabConfig      = $Configuration.ListOfGitLab
                $ListOfGitLabConfigCount = $ListOfGitLabConfig.Count
                if($ListOfGitLabConfigCount -ge 1){
                    $Index = 0
                    foreach($GitLab_Config in $ListOfGitLabConfig){
                        $GitLab_Config_Id         = $GitLab_Config.Id
                        $GitLab_Config_NodeId     = $GitLab_Config.NodeId
                        $GitLab_Config_Login      = $GitLab_Config.Login
                        $GitLab_Config_Repository = $GitLab_Config.RepositoryList
                        $FindGitLabCondition      = $False
                        $GitLabConditionList      = @()
                        foreach($GitLab_DB in $GitLabDatabase){
                            $GitLab_DB_Id         = $GitLab_DB.Id
                            $GitLab_DB_NodeId     = $GitLab_DB.NodeId
                            $GitLab_DB_Login      = $GitLab_DB.Login
                            $GitLab_DB_Repository = $GitLab_DB.RepositoryList
                            if(
                                $GitLab_Config_Id -eq $GitLab_DB_Id -and
                                $GitLab_Config_NodeId -eq $GitLab_DB_NodeId -and
                                $GitLab_Config_Login -eq $GitLab_DB_Login
                            ){
                                $FindGitLabCondition = $True
                                if($GitLab_Config_Login.Length -gt 0){
                                    $GitLabItemPath = $ConfigProjectsPath+'\'+$ConfigProjectName+'\gitlab\'+$GitLab_Config_Login
                                }
                                else{
                                    $GitLabItemPath = ''
                                }
                                if(Test-Path $GitLabItemPath){
                                    $RepositoryIndex = 0
                                    foreach ($GitLab_Config_Repository_Item in $GitLab_Config_Repository) {
                                        $GitLab_Config_Repository_Item_Id     = $GitLab_Config_Repository_Item.Id
                                        $GitLab_Config_Repository_Item_NodeId = $GitLab_Config_Repository_Item.NodeId
                                        $GitLab_Config_Repository_Item_Name   = $GitLab_Config_Repository_Item.Name
                                        if($GitLab_DB_Repository.Count -ge 1){
                                            $FindGitLabRepositoryCondition = $False
                                            $GitLabRepositoryConditionList = @()
                                            foreach ($GitLab_DB_Repository_Item in $GitLab_DB_Repository) {
                                                $GitLab_DB_Repository_Item_Id     = $GitLab_DB_Repository_Item.Id
                                                $GitLab_DB_Repository_Item_NodeId = $GitLab_DB_Repository_Item.NodeId
                                                $GitLab_DB_Repository_Item_Name   = $GitLab_DB_Repository_Item.Name
                                                if(
                                                    $GitLab_Config_Repository_Item_Id -eq $GitLab_DB_Repository_Item_Id -and
                                                    $GitLab_Config_Repository_Item_NodeId -eq $GitLab_DB_Repository_Item_NodeId -and
                                                    $GitLab_Config_Repository_Item_Name -eq $GitLab_DB_Repository_Item_Name
                                                ){
                                                    $FindGitLabRepositoryCondition = $True
                                                    if($GitLab_Config_Repository_Item_Name.Length -gt 0){
                                                        $GitLabSubItemPath = $GitLabItemPath+'\'+$GitLab_Config_Repository_Item_Name
                                                    }
                                                    else{
                                                        $GitLabItemPath = ''
                                                    }                                                
                                                    
                                                    if(Test-Path $GitLabSubItemPath){
                                                        Write-Host ('GitLab '+$GitLab_Config_Repository_Item_Name+' is downloaded.')
                                                        (($Configuration.ListOfGitLab)[$Index].RepositoryList)[$RepositoryIndex].Status = 'is-downloaded'
                                                        $GitLabRepositoryConditionList += $True                
                                                    }
                                                    else{
                                                        Write-Warning ('GitLab '+$GitLab_Config_Repository_Item_Name+' is not downloaded.')
                                                        (($Configuration.ListOfGitLab)[$Index].RepositoryList)[$RepositoryIndex].Status = 'is-not-downloaded'
                                                        $GitLabRepositoryConditionList += $False
                                                    }
                                                }
                                            }
                                            if($FindGitLabRepositoryCondition){
                                                $GitLabListConditionList += [PSCustomObject]@{
                                                    Permeable   = $GitLabRepositoryConditionList
                                                    Impermeable = $True
                                                }
                                            }
                                            else{
                                                $GitLabListConditionList += [PSCustomObject]@{
                                                    Permeable   = $GitLabRepositoryConditionList
                                                    Impermeable = $False
                                                }                        
                                            }
                                        }
                                        else{
                                            Write-Warning ('GitLab '+$GitLab_Config_Repository_Item_Name+' is not downloaded.')
                                            (($Configuration.ListOfGitLab)[$Index].RepositoryList)[$RepositoryIndex].Status = 'is-not-downloaded'
                                            $GitLabConditionList += $False
                                        }
                                    }
                                    $RepositoryIndex++
                                }
                                else{
                                    Write-Warning ('GitLab '+$GitLab_Config_Login+' is not downloaded.')
                                    ($Configuration.ListOfGitLab)[$Index].Status = 'is-not-downloaded'
                                    $GitLabConditionList += $False
                                }
                            }
                        }
                        if($FindGitLabCondition){
                            $GitLabListConditionList += [PSCustomObject]@{
                                Permeable   = $GitLabConditionList
                                Impermeable = $True
                            }
                        }
                        else{
                            $GitLabListConditionList += [PSCustomObject]@{
                                Permeable   = $GitLabConditionList
                                Impermeable = $False
                            }                        
                        }
                        $Index++
                    }  
                }
            }        
            else{
                BREAK
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($ListOfGitLabConfigCount -ge 1){
                $PermeableConditionList   = $GitLabListConditionList.Permeable
                $ImpermeableConditionList = $GitLabListConditionList.Impermeable
                # Verify permeable conditions 
                if($PermeableConditionList.Count -eq 1 -and $PermeableConditionList){
                    $PermeableCondition = $True
                }
                elseif($PermeableConditionList.Count -gt 1 -and $null -eq $($PermeableConditionList -match $False)){
                    $PermeableCondition = $True
                }
                else{
                    $PermeableCondition = $False
                }
                # Verify impermeable conditions
                if($ImpermeableConditionList.Count -eq 1 -and $ImpermeableConditionList){
                    $ImpermeableCondition = $True
                }
                elseif($ImpermeableConditionList.Count -gt 1 -and $null -eq $($ImpermeableConditionList -match $False)){
                    $ImpermeableCondition = $True
                }
                else{
                    $ImpermeableCondition = $False
                }
                if($ImpermeableCondition){
                    if($PermeableCondition){
                        Write-Host "GitLab include all applicable terms and conditions."
                        $GitLabValidation = $True
                    }
                    else{
                        Write-Warning "GitLab contain an permeable condition."
                        $GitLabValidation = $True
                    }
                }
                else{
                    Write-Warning "GitLab contain an impermeable condition!"
                    $GitLabValidation = $False
                }
            }
            else{
                Write-Host "List of GitLab is empty."
                $GitLabValidation = $True
            }
        }
    }
    end{
        if($MeasureDuration){
            $DurationTotal = $DurationBegin+$DurationProcess
            Write-Host ('DurationBegin:      '+$DurationBegin)
            Write-Host ('DurationProcess:    '+$DurationProcess)
            Write-Host ('DurationTotal:      '+$DurationTotal)
            Write-Host ''
        }
        return $GitLabValidation
    }
}

function Get-Modules_Availability {
<#
.SYNOPSIS
    Validating the PowerShell Modules configuration schema and the PowerShell Modules database.

.DESCRIPTION
    Verifying the availability of the project's 
    dependencies on the PowerShell Modules database and the PowerShell Modules configuration schema.

.PARAMETER OperatingSystem
    String - String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER Configuration
    PSCustomObject - The configuration parameter specifies all the necessary information to successfully
    run and complete the function.

.PARAMETER ModuleDatabase
    PSCustomObject - Internal PowerShell Modules database in specific format from db/modules.json file

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.EXAMPLE
    Get-Modules_Availability -OperatingSystem $OS_TYPE -Configuration $ConfigData -ModuleDatabase $ModulesData -MeasureDuration $False -ErrorAction Stop

.INPUTS
    PSCustomObject

.OUTPUTS
    Boolean

.NOTES
    Author: Jan Setunsky
    GitHub: https://github.com/JanSetunsky
#>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [PSCustomObject]$OperatingSystem,
        [Parameter(Position=1,Mandatory=$True)]
        [PSCustomObject]$Configuration,
        [Parameter(Position=2,Mandatory=$True)]
        [AllowNull()]
        [PSCustomObject]$ModuleDatabase,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            if($OperatingSystem -eq 'Linux'){
                $ModulesValidation = $True
                # Command for Linux
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $ModulesValidation = $True
                # Command for MacOS
            }
            elseif($OperatingSystem -eq 'Windows'){
                # Command for Windows
                Write-Host ('[ VERIFICATION - MODULES AVAILABILITY ]')
                $ModulesConditionList     = @()
                $ModulesListConditionList = @()
                $ListOfModules            = $Configuration.ListOfModules
                $ListOfModulesId          = $ListOfModules.Id
                $ListOfModulesCount       = $ListOfModules.Count
                $Index = 0
                if($ListOfModulesCount -ge 1){
                    foreach($Module_Config_Id in $ListOfModulesId){
                        $FindModuleCondition = $False
                        foreach($Module_DB in $ModuleDatabase){
                            if($Module_Config_Id -eq $Module_DB.Id){
                                $FindModuleCondition = $True
                                $Module_DB_Name     = $Module_DB.Name
                                $Module_DB_FullName = $Module_DB.FullName
                                $Module_DB_Method   = $Module_DB.VerificationMethod
                                if($Module_DB_Method -eq 'Get-Module'){
                                    $ModuleCondition = Get-Module -ListAvailable -Name $Module_DB_Name -ErrorAction SilentlyContinue
                                    if($ModuleCondition){
                                        Write-Host ($Module_DB_FullName+' module is installed.')
                                        ($Configuration.ListOfModules)[$Index].Status = 'is-installed'
                                        $ModulesConditionList += $True
                                    }
                                    else{
                                        Write-Warning ($Module_DB_FullName+' module is not installed.')
                                        ($Configuration.ListOfModules)[$Index].Status = 'is-not-installed'
                                        $ModulesConditionList += $False
                                    }
                                }
                                else{
                                    Write-Warning ($Module_DB_FullName+' module method '+$Module_DB_Method+' is not supported.')
                                    ($Configuration.ListOfModules)[$Index].Status = 'is-not-supported'
                                    $ModulesConditionList += $False        
                                }                            
                            }
                        }
                        if($FindModuleCondition){
                            $ModulesListConditionList += [PSCustomObject]@{
                                Permeable   = $ModulesConditionList
                                Impermeable = $True
                            }
                        }
                        else{
                            $ModulesListConditionList += [PSCustomObject]@{
                                Permeable   = $ModulesConditionList
                                Impermeable = $False
                            }
                        }
                        $Index++
                    }  
                }
            }        
            else{
                BREAK
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($ListOfModulesCount -ge 1){
                $PermeableConditionList   = $ModulesListConditionList.Permeable
                $ImpermeableConditionList = $ModulesListConditionList.Impermeable
                # Verify permeable conditions 
                if($PermeableConditionList.Count -eq 1 -and $PermeableConditionList){
                    $PermeableCondition = $True
                }
                elseif($PermeableConditionList.Count -gt 1 -and $null -eq $($PermeableConditionList -match $False)){
                    $PermeableCondition = $True
                }
                else{
                    $PermeableCondition = $False
                }
                # Verify impermeable conditions
                if($ImpermeableConditionList.Count -eq 1 -and $ImpermeableConditionList){
                    $ImpermeableCondition = $True
                }
                elseif($ImpermeableConditionList.Count -gt 1 -and $null -eq $($ImpermeableConditionList -match $False)){
                    $ImpermeableCondition = $True
                }
                else{
                    $ImpermeableCondition = $False
                }
                # Verify conditions
                if($ImpermeableCondition){
                    if($PermeableCondition){
                        Write-Host "Modules include all applicable terms and conditions."
                        $ModulesValidation = $True
                    }
                    else{
                        Write-Warning "Modules contain an permeable condition."
                        $ModulesValidation = $True
                    }
                }
                else{
                    Write-Warning "Modules contain an impermeable condition!"
                    $ModulesValidation = $False
                }
            }
            else{
                Write-Host "List of modules is empty."
                $ModulesValidation = $True
            }       
        }
    }
    end{
        if($MeasureDuration){
            $DurationTotal = $DurationBegin+$DurationProcess
            Write-Host ('DurationBegin:      '+$DurationBegin)
            Write-Host ('DurationProcess:    '+$DurationProcess)
            Write-Host ('DurationTotal:      '+$DurationTotal)
            Write-Host ''
        }
        return $ModulesValidation
    }
}

function Get-Packages_Availability {
<#
.SYNOPSIS
    Validating the Packages configuration schema and the Packages database.

.DESCRIPTION
    Verifying the availability of the project's 
    dependencies on the Packages database and the Packages configuration schema.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER Configuration
    PSCustomObject - The configuration parameter specifies all the necessary information to successfully
     run and complete the function.

.PARAMETER PackageDatabase
    PSCustomObject - Internal Packages database in specific format from db/packages.json file

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.EXAMPLE
    Get-Packages_Availability -OperatingSystem $OS_TYPE -Configuration $ConfigData -PackageDatabase $PackagesData -MeasureDuration $False -ErrorAction Stop

.INPUTS
    PSCustomObject

.OUTPUTS
    Boolean

.NOTES
    Author: Jan Setunsky
    GitHub: https://github.com/JanSetunsky
#>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [PSCustomObject]$OperatingSystem,
        [Parameter(Position=1,Mandatory=$True)]
        [PSCustomObject]$Configuration,
        [Parameter(Position=2,Mandatory=$True)]
        [AllowNull()]
        [PSCustomObject]$PackageDatabase,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            if($OperatingSystem -eq 'Linux'){
                # Command for Linux
                $PackagesValidation = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                # Command for MacOS
                $PackagesValidation = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                # Command for Windows
                Write-Host ('[ VERIFICATION - PACKAGES AVAILABILITY ]')
                $PackageListConditionList = @()
                $ListOfPackages      = $Configuration.ListOfPackages
                $ListOfPackagesCount = $ListOfPackages.Count
                if($ListOfPackagesCount -ge 1){
                    $PackageIndex = 0
                    foreach($Package_Config in $ListOfPackages){
                        $Package_Config_Id         = $Package_Config.Id
                        $Package_Config_ToolList   = $Package_Config.ToolList
                        $Package_Config_ToolListId = $Package_Config_ToolList.Id
                        $FindPackageCondition        = $False
                        $PackagesConditionList       = @()
                        foreach($Package_DB in $PackageDatabase){
                            if($Package_Config_Id -eq $Package_DB.Id){
                                $FindPackageCondition = $True
                                $Package_DB_Name          = $Package_DB.Name
                                $Package_DB_FullName      = $Package_DB.FullName
                                $Package_DB_ToolList      = $Package_DB.ToolList
                                $Packages_DB_ToolKit      = @()
                                $PackageToolConditionList = @()
                                Write-Host ('[Package][Toolkit] - '+$Package_DB_FullName)
                                # Tool list validation
                                if($Package_DB_ToolList.Count -ge 1){
                                    $PackageToolIndex = 0
                                    foreach($Package_DB_Tool in $Package_DB_ToolList){
                                        $Package_DB_ToolItem = $Package_DB_Tool
                                        $Package_DB_ToolId   = $Package_DB_ToolItem.Id
                                        if($Package_Config_ToolListId -eq $Package_DB_ToolId){
                                            $Package_DB_ToolCommandMethod = $Package_DB_ToolItem.CommandMethod
                                            $Package_DB_ToolName          = $Package_DB_ToolItem.Name
                                            $Package_DB_ToolVersion       = $Package_DB_ToolItem.Version
                                            $Package_DB_ToolSource        = $Package_DB_ToolItem.Source
                                            if($Package_DB_ToolCommandMethod -eq 'Get-Package'){
                                                $Package_DB_ToolProviderName = $Package_DB_ToolItem.ProviderName
                                                $GetToolItem                 = Get-Package ($Package_DB_ToolName+'*') -ErrorAction SilentlyContinue
                                                $GetToolItemCount            = $GetToolItem.Count
                                                if($GetToolItemCount -eq 1){
                                                    $GetToolName         = $GetToolItem.Name
                                                    $GetToolProviderName = $GetToolItem.ProviderName
                                                    $GetToolVersion      = $GetToolItem.Version
                                                    $GetToolSource       = $GetToolItem.Source
                                                    $ToolKitCondition    = $True
                                                    if($Package_DB_ToolProviderName -eq 'Uknown'){
                                                        $ToolKitProviderName = $GetToolProviderName
                                                    }
                                                    elseif($Package_DB_ToolProviderName -eq $GetToolProviderName){
                                                        $ToolKitProviderName = $GetToolProviderName
                                                    }
                                                    else{
                                                        $ToolKitCondition    = $False
                                                        $ToolKitProviderName = 'Uknown'
                                                    }
                                                    if($Package_DB_ToolVersion -eq 'Uknown'){
                                                        $ToolKitVersion = $GetToolVersion
                                                    }
                                                    elseif($Package_DB_ToolVersion -eq $GetToolVersion){
                                                        $ToolKitVersion = $GetToolVersion
                                                    }
                                                    else{
                                                        $ToolKitCondition = $False
                                                        $ToolKitVersion   = 'Uknown'
                                                    }
                                                    if($Package_DB_ToolSource -eq 'Uknown'){
                                                        $ToolKitSource = $GetToolSource
                                                    }
                                                    elseif($Package_DB_ToolSource -eq $GetToolSource){
                                                        $ToolKitSource = $GetToolSource
                                                    }
                                                    else{
                                                        $ToolKitCondition = $False
                                                        $ToolKitSource    = 'Uknown'
                                                    }
                                                    if($ToolKitCondition){
                                                        $PackageToolConditionList += $True
                                                        $ToolKitStatus = 'is-installed'
                                                        Write-Host ([string]$GetToolName+' package tool is installed.')
                                                    }
                                                    else{
                                                        $PackageToolConditionList += $False
                                                        $ToolKitStatus = 'is-not-installed'
                                                        Write-Warning ([string]$GetToolName+' package tool parameters is not valid.')
                                                    }
                                                    $Packages_DB_ToolKit += [PSCustomObject]@{
                                                        Id            = $Package_DB_ToolId
                                                        CommandMethod = $Package_DB_ToolCommandMethod
                                                        ProviderName  = $ToolKitProviderName
                                                        Name          = $GetToolName
                                                        Version       = $ToolKitVersion
                                                        Source        = $Package_DB_ToolSource
                                                        Status        = $ToolKitStatus
                                                    }
                                                }
                                                elseif($GetToolItemCount -gt 1){
                                                    foreach ($DuplicatedItem in $GetToolItem) {
                                                        $GetToolName         = $DuplicatedItem.Name
                                                        $GetToolProviderName = $DuplicatedItem.ProviderName
                                                        $GetToolVersion      = $DuplicatedItem.Version
                                                        $GetToolSource       = $DuplicatedItem.Source
                                                        $ToolKitCondition    = $True
                                                        if($Package_DB_ToolProviderName -eq 'Uknown'){
                                                            $ToolKitCommandType = $GetToolProviderName
                                                        }
                                                        elseif($Package_DB_ToolProviderName -eq $GetToolProviderName){
                                                            $ToolKitCommandType = $GetToolProviderName
                                                        }
                                                        else{
                                                            $ToolKitCondition   = $False
                                                            $ToolKitCommandType = 'Uknown'
                                                        }
                                                        if($Package_DB_ToolVersion -eq 'Uknown'){
                                                            $ToolKitVersion = $GetToolVersion
                                                        }
                                                        elseif($Package_DB_ToolVersion -eq $GetToolVersion){
                                                            $ToolKitVersion = $GetToolVersion
                                                        }
                                                        else{
                                                            $ToolKitCondition = $False
                                                            $ToolKitVersion   = 'Uknown'
                                                        }
                                                        if($Package_DB_ToolSource -eq 'Uknown'){
                                                            $ToolKitSource = $GetToolSource
                                                        }
                                                        elseif($Package_DB_ToolSource -eq $GetToolSource){
                                                            $ToolKitSource = $GetToolSource
                                                        }
                                                        else{
                                                            $ToolKitCondition = $False
                                                            $ToolKitSource    = 'Uknown'
                                                        }
                                                        if($ToolKitCondition){
                                                            $PackageToolConditionList += $True
                                                            $ToolKitStatus = 'is-duplicated'
                                                            Write-Host ([string]$GetToolName+' package tool is duplicated.')
                                                        }
                                                        else{
                                                            $PackageToolConditionList += $False
                                                            $ToolKitStatus = 'is-not-installed'
                                                            Write-Warning ([string]$GetToolName+' package tool parameters is not valid.')
                                                        }
                                                        $Packages_DB_ToolKit += [PSCustomObject]@{
                                                            Id            = $Package_DB_ToolId
                                                            CommandMethod = $Package_DB_ToolCommandMethod
                                                            ProviderName  = $ToolKitProviderName
                                                            Name          = $GetToolName
                                                            Version       = $ToolKitVersion
                                                            Source        = $ToolKitSource
                                                            Status        = $ToolKitStatus
                                                        }
                                                    }
                                                    Write-Warning ($Package_DB_ToolName+' package tool is duplicated.')
                                                }                                                
                                                else{
                                                    $Packages_DB_ToolKit += [PSCustomObject]@{
                                                        Id            = $Package_DB_ToolId
                                                        CommandMethod = $Package_DB_ToolCommandMethod
                                                        ProviderName  = $Package_DB_ToolProviderName
                                                        Name          = $Package_DB_ToolName
                                                        Version       = $Package_DB_ToolVersion
                                                        Source        = $Package_DB_ToolSource
                                                        Status        = 'is-not-installed'
                                                    }
                                                    $PackageToolConditionList += $False
                                                    Write-Warning ($Package_DB_ToolName+' package tool is not installed.')                                                
                                                }
                                            }
                                            elseif($Package_DB_ToolCommandMethod -eq 'Get-Command'){
                                                $Package_DB_ToolCommandType = $Package_DB_ToolItem.CommandType
                                                $GetToolItem                = Get-Command ($Package_DB_ToolName+'*') -ErrorAction SilentlyContinue
                                                $GetToolItemCount           = $GetToolItem.Count
                                                if($GetToolItemCount -eq 1){
                                                    $GetToolName        = $GetToolItem.Name
                                                    $GetToolCommandType = $GetToolItem.CommandType
                                                    $GetToolVersion     = $GetToolItem.Version
                                                    $GetToolSource      = $GetToolItem.Source
                                                    $ToolKitCondition   = $True
                                                    if($Package_DB_ToolCommandType -eq 'Uknown'){
                                                        $ToolKitCommandType = $GetToolCommandType
                                                    }
                                                    elseif($Package_DB_ToolCommandType -eq $GetToolCommandType){
                                                        $ToolKitCommandType = $GetToolCommandType
                                                    }
                                                    else{
                                                        $ToolKitCondition   = $False
                                                        $ToolKitCommandType = 'Uknown'
                                                    }
                                                    if($Package_DB_ToolVersion -eq 'Uknown'){
                                                        $ToolKitVersion = $GetToolVersion
                                                    }
                                                    elseif($Package_DB_ToolVersion -eq $GetToolVersion){
                                                        $ToolKitVersion = $GetToolVersion
                                                    }
                                                    else{
                                                        $ToolKitCondition = $False
                                                        $ToolKitVersion   = 'Uknown'
                                                    }
                                                    if($Package_DB_ToolSource -eq 'Uknown'){
                                                        $ToolKitSource = $GetToolSource
                                                    }
                                                    elseif($Package_DB_ToolSource -eq $GetToolSource){
                                                        $ToolKitSource = $GetToolSource
                                                    }
                                                    else{
                                                        $ToolKitCondition = $False
                                                        $ToolKitSource    = 'Uknown'
                                                    }
                                                    if($ToolKitCondition){
                                                        $PackageToolConditionList += $True
                                                        $ToolKitStatus = 'is-installed'
                                                        Write-Host ([string]$GetToolName+' package tool is installed.')
                                                    }
                                                    else{
                                                        $PackageToolConditionList += $False
                                                        $ToolKitStatus = 'is-not-installed'
                                                        Write-Warning ([string]$GetToolName+' package tool parameters is not valid.')
                                                    }
                                                    $Packages_DB_ToolKit += [PSCustomObject]@{
                                                        Id            = $Package_DB_ToolId
                                                        CommandMethod = $Package_DB_ToolCommandMethod
                                                        CommandType   = $ToolKitCommandType
                                                        Name          = $GetToolName
                                                        Version       = $ToolKitVersion
                                                        Source        = $ToolKitSource
                                                        Status        = $ToolKitStatus
                                                    }
                                                }
                                                elseif($GetToolItemCount -gt 1){
                                                    foreach ($DuplicatedItem in $GetToolItem) {
                                                        $GetToolName        = $DuplicatedItem.Name
                                                        $GetToolCommandType = $DuplicatedItem.CommandType
                                                        $GetToolVersion     = $DuplicatedItem.Version
                                                        $GetToolSource      = $DuplicatedItem.Source
                                                        $ToolKitCondition   = $True
                                                        if($Package_DB_ToolCommandType -eq 'Uknown'){
                                                            $ToolKitCommandType = $GetToolCommandType
                                                        }
                                                        elseif($Package_DB_ToolCommandType -eq $GetToolCommandType){
                                                            $ToolKitCommandType = $GetToolCommandType
                                                        }
                                                        else{
                                                            $ToolKitCondition   = $False
                                                            $ToolKitCommandType = 'Uknown'
                                                        }
                                                        if($Package_DB_ToolVersion -eq 'Uknown'){
                                                            $ToolKitVersion = $GetToolVersion
                                                        }
                                                        elseif($Package_DB_ToolVersion -eq $GetToolVersion){
                                                            $ToolKitVersion = $GetToolVersion
                                                        }
                                                        else{
                                                            $ToolKitCondition = $False
                                                            $ToolKitVersion   = 'Uknown'
                                                        }
                                                        if($Package_DB_ToolSource -eq 'Uknown'){
                                                            $ToolKitSource = $GetToolSource
                                                        }
                                                        elseif($Package_DB_ToolSource -eq $GetToolSource){
                                                            $ToolKitSource = $GetToolSource
                                                        }
                                                        else{
                                                            $ToolKitCondition = $False
                                                            $ToolKitSource    = 'Uknown'
                                                        }
                                                        if($ToolKitCondition){
                                                            $PackageToolConditionList += $True
                                                            $ToolKitStatus = 'is-duplicated'
                                                            Write-Host ([string]$GetToolName+' package tool is duplicated.')
                                                        }
                                                        else{
                                                            $PackageToolConditionList += $False
                                                            $ToolKitStatus = 'is-not-installed'
                                                            Write-Warning ([string]$GetToolName+' package tool parameters is not valid.')
                                                        }
                                                        $Packages_DB_ToolKit += [PSCustomObject]@{
                                                            Id            = $Package_DB_ToolId
                                                            CommandMethod = $Package_DB_ToolCommandMethod
                                                            CommandType   = $ToolKitCommandType
                                                            Name          = $GetToolName
                                                            Version       = $ToolKitVersion
                                                            Source        = $ToolKitSource
                                                            Status        = $ToolKitStatus
                                                        }
                                                    }
                                                    Write-Warning ($Package_DB_ToolName+' package tool is duplicated.')
                                                }                                            
                                                else{
                                                    $Packages_DB_ToolKit += [PSCustomObject]@{
                                                        Id            = $Package_DB_ToolId
                                                        CommandMethod = $Package_DB_ToolCommandMethod
                                                        CommandType   = $Package_DB_ToolCommandType
                                                        Name          = $Package_DB_ToolName
                                                        Version       = $Package_DB_ToolVersion
                                                        Source        = $Package_DB_ToolSource
                                                        Status        = 'is-not-installed'
                                                    }
                                                    $PackageToolConditionList += $False
                                                    Write-Warning ($Package_DB_ToolName+' package tool is not installed.')   
                                                }
                                            }
                                            else{
                                                $VariableMember   = ($PackageTool | Get-Member -MemberType NoteProperty | Select -ExpandProperty Name)[2]
                                                $VariableValue    = ($PackageToolpsobject.properties.value)[2]
                                                $Packages_DB_ToolKit += [PSCustomObject]@{
                                                    Id            = $Package_DB_ToolId
                                                    CommandMethod = $Package_DB_ToolCommandMethod
                                                    Name          = $Package_DB_ToolName
                                                    Version       = $Package_DB_ToolVersion
                                                    Source        = $Package_DB_ToolSource
                                                    Status        = 'is-not-supported'
                                                } | Add-Member -MemberType NoteProperty -Name $VariableMember -Value $VariableValue
                                                $PackageListConditionList += [PSCustomObject]@{
                                                    Permeable   = $False
                                                    Impermeable = $False
                                                }
                                                $PackageToolConditionList += $False
                                                Write-Warning ($GetToolName+' package tool method "'+$Package_DB_ToolCommandMethod+'" is not supported.')
                                            }
                                        }
                                        $PackageToolIndex++
                                    }
                                }
                                # Package verify conditions
                                if($PackageToolConditionList.Count -eq 1 -and $PackageToolConditionList){
                                    $PackageToolCondition = $True
                                }
                                elseif($PackageToolConditionList.Count -gt 1 -and $null -eq $($PackageToolConditionList -match $False)){
                                    $PackageToolCondition = $True
                                }
                                else{
                                    $PackageToolCondition = $False
                                }
    
                                if($PackageToolCondition -and $Package_Config_ToolList.Count -eq $Package_DB_ToolList.Count){
                                    $PackagesConditionList += $True
                                    (($Configuration.ListOfPackages)[$PackageIndex]).Status = 'is-installed'
                                }
                                elseif($PackageToolCondition -and $Package_Config_ToolList.Count -gt $Package_DB_ToolList.Count){
                                    $PackagesConditionList += $True
                                    (($Configuration.ListOfPackages)[$PackageIndex]).Status = 'is-duplicated'
                                }                            
                                else{
                                    $PackagesConditionList += $False
                                    (($Configuration.ListOfPackages)[$PackageIndex]).Status = 'is-not-installed'
                                }
                                (($Configuration.ListOfPackages)[$PackageIndex]).ToolList = $Packages_DB_ToolKit
                            }
                        }
                        if($FindPackageCondition){
                            $PackageListConditionList += [PSCustomObject]@{
                                Permeable   = $PackagesConditionList
                                Impermeable = $True
                            }
                        }
                        else{
                            $PackageListConditionList += [PSCustomObject]@{
                                Permeable   = $PackagesConditionList
                                Impermeable = $False
                            }                        
                        }
                        $PackageIndex++
                    }  
                }            
            }        
            else{
                BREAK
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($ListOfPackagesCount -ge 1){
                $PermeableConditionList   = $PackageListConditionList.Permeable
                $ImpermeableConditionList = $PackageListConditionList.Impermeable
                # Verify permeable conditions 
                if($PermeableConditionList.Count -eq 1 -and $PermeableConditionList){
                    $PermeableCondition = $True
                }
                elseif($PermeableConditionList.Count -gt 1 -and $null -eq $($PermeableConditionList -match $False)){
                    $PermeableCondition = $True
                }
                else{
                    $PermeableCondition = $False
                }
                # Verify impermeable conditions
                if($ImpermeableConditionList.Count -eq 1 -and $ImpermeableConditionList){
                    $ImpermeableCondition = $True
                }
                elseif($ImpermeableConditionList.Count -gt 1 -and $null -eq $($ImpermeableConditionList -match $False)){
                    $ImpermeableCondition = $True
                }
                else{
                    $ImpermeableCondition = $False
                }        
                if($ImpermeableCondition){
                    if($PermeableCondition){
                        Write-Host "Packages include all applicable terms and conditions."
                        $PackagesValidation = $True
                    }
                    else{
                        Write-Warning "Packages contain an permeable condition."
                        $PackagesValidation = $True
                    }
                }
                else{
                    Write-Warning "Packages contain an impermeable condition!"
                    $PackagesValidation = $False
                }
            }
            else{
                Write-Warning "List of packages is empty."
                $PackagesValidation = $True
            }
        }
    }
    end{
        if($MeasureDuration){
            $DurationTotal = $DurationBegin+$DurationProcess
            Write-Host ('DurationBegin:      '+$DurationBegin)
            Write-Host ('DurationProcess:    '+$DurationProcess)
            Write-Host ('DurationTotal:      '+$DurationTotal)
            Write-Host ''
        }
        return $PackagesValidation
    }
}

function Get-PowerShell_Version_Recognition {
<#
.SYNOPSIS
    Powershell version verification.

.DESCRIPTION
    Powershell version verification according to the condition in the configuration file.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER Configuration
    PSCustomObject - The configuration parameter specifies all the necessary information to successfully
     run and complete the function.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.EXAMPLE
    Get-PowerShell_Version_Recognition -OperatingSystem $OS_TYPE -Configuration $ConfigData -MeasureDuration $False -ErrorAction Stop

.INPUTS
    PSCustomObject

.OUTPUTS
    Boolean

.NOTES
    Author: Jan Setunsky
    GitHub: https://GitHub.com/JanSetunsky
#>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [PSCustomObject]$OperatingSystem,
        [Parameter(Position=1,Mandatory=$True)]
        [PSCustomObject]$Configuration,
        [Parameter(Position=2,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            if($OperatingSystem -eq 'Linux'){
                $VersionValidation = $True
                # Command for Linux
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $VersionValidation = $True
                # Command for MacOS
            }
            elseif($OperatingSystem -eq 'Windows'){
                # Command for Windows
                Write-Host ('[ VERIFICATION - VERSION RECOGNITION ]')
                $VersionConditionList = @()
                $PwshVersion    = $Configuration.PowerShellVersion
                $PSVersionMajor = $PSVersionTable.PSVersion.Major
                $PSVersionMinor = $PSVersionTable.PSVersion.Minor
                $PSVersionPatch = $PSVersionTable.PSVersion.Patch
                $PSVersionFull  = [string]$PSVersionMajor+'.'+[string]$PSVersionMinor+'.'+[string]$PSVersionPatch
                $PSCondition    = $PSVersionMajor -ge $PwshVersion
                if($PSCondition){
                    $VersionConditionList += $True
                    Write-Host ("PowerShell version is "+$PSVersionFull)
                }
                else{
                    $VersionConditionList += $False
                    Write-Warning "This script requires PowerShell version "+[string]$PwshVersion+" or higher."
                }
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($VersionConditionList.Count -eq 1 -and $VersionConditionList){
                Write-Host ("Version validation succeeded.")
                $VersionValidation = $True
            }
            elseif($VersionConditionList.Count -gt 1 -and $null -eq $($VersionConditionList -match $False)){
                Write-Host ("Version validation succeeded.")
                $VersionValidation = $True
            }
            else{
                Write-Warning "Version validation failed!"
                $VersionValidation = $False            
            }
        }
    }
    end{
        if($MeasureDuration){
            $DurationTotal = $DurationBegin+$DurationProcess
            Write-Host ('DurationBegin:      '+$DurationBegin)
            Write-Host ('DurationProcess:    '+$DurationProcess)
            Write-Host ('DurationTotal:      '+$DurationTotal)
            Write-Host ''
        }
        return $VersionValidation
    }
}

function Get-PowerShell_Rights_Management {
<#
.SYNOPSIS
    Verifying PowerShell Administrator Rights.

.DESCRIPTION
    PowerShell must be run with the execution policy set to "Bypass" , "AllSigned" or "RemoteSigned".

.PARAMETER OperatingSystem
    The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER Configuration
    PSCustomObject - The configuration parameter specifies all the necessary information to successfully
     run and complete the function.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.EXAMPLE
    Get-PowerShell_Rights_Management -OperatingSystem $OS_TYPE -Configuration $ConfigData -MeasureDuration $False -ErrorAction Stop

.INPUTS
    PSCustomObject

.OUTPUTS
    Boolean

.NOTES
    Author: Jan Setunsky
    GitHub: https://GitHub.com/JanSetunsky
#>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [PSCustomObject]$OperatingSystem,
        [Parameter(Position=1,Mandatory=$True)]
        [PSCustomObject]$Configuration,
        [Parameter(Position=2,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            if($OperatingSystem -eq 'Linux'){
                $RightsValidation = $True
                # Command for Linux
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $RightsValidation = $True
                # Command for MacOS
            }
            elseif($OperatingSystem -eq 'Windows'){
                # Command for Windows
                Write-Host ('[ VERIFICATION - RIGHTS MANAGEMENT ]')
                if(-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
                    Write-Warning 'PowerShell must be run with administrator rights.'
                    $RightsValidation = $False
                }
                else{
                    $ExecutionPolicy = Get-ExecutionPolicy
                    if($ExecutionPolicy -eq 'Bypass' -or $ExecutionPolicy -eq 'AllSigned' -or $ExecutionPolicy -eq 'RemoteSigned'){
                        Write-Host ('PowerShell uses administrator rights "'+$ExecutionPolicy+'".')
                    }
                    else{
                        Write-Warning 'PowerShell must be run with the execution policy set to "Bypass" , "AllSigned" or "RemoteSigned".'
                        $SetExecutionPolicy = Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -ErrorAction Stop
                    }
                    $RightsValidation = $True
                }
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            # empty
        }
    }
    end{
        if($MeasureDuration){
            $DurationTotal = $DurationBegin+$DurationProcess
            Write-Host ('DurationBegin:      '+$DurationBegin)
            Write-Host ('DurationProcess:    '+$DurationProcess)
            Write-Host ('DurationTotal:      '+$DurationTotal)
            Write-Host ''
        }
        if($RightsValidation){
            return $True
        }
        else{
            BREAK
        }
    }
}

function Get-Operating_System_Recognition {
<#
.SYNOPSIS
    Recognition of the operating system.

.DESCRIPTION
    Recognition of the operating system and subsequent distribution of the result for all 
    functions and scripts.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.EXAMPLE
    Get-Operating_System_Recognition -MeasureDuration $false

.INPUTS
    PSCustomObject

.OUTPUTS
    Boolean

.NOTES
    Author: Jan Setunsky
    GitHub: https://GitHub.com/JanSetunsky
#>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            $OS = $PSVersionTable.OS
            $PLATFORM = $PSVersionTable.Platform
            if($IsLinux){
                $OS_TYPE = 'Linux'
                $OsValidation = $True
            }
            elseif($IsMacOS){
                $OS_TYPE = 'MacOS'
                $OsValidation = $True
            }
            elseif($IsWindows){
                $OS_TYPE = 'Windows'
                $OsValidation = $True
            }
            else{
                $OS_TYPE = 'Uknown'
                $OsValidation = $False
            }
            <# ALTERNATIVE METHOD
                if($env:OS -match 'Windows'){
                    # Command for Windows
                    $OS_TYPE = 'Windows'
                }
                else{
                    # Command for Linux/macOS
                    $PlatformName = $(uname)
                    if($PlatformName -match 'Linux'){
                        $OS_TYPE = 'Linux'
                    }
                    elseif($PlatformName -match 'Darwin'){
                        $OS_TYPE = 'MacOS'
                    }
                    else{
                        $OS_TYPE = 'None'
                    }
                }        
            #>
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            # empty
        }
    }
    end{
        if($MeasureDuration){
            $DurationTotal = $DurationBegin+$DurationProcess
            Write-Host ('DurationBegin:      '+$DurationBegin)
            Write-Host ('DurationProcess:    '+$DurationProcess)
            Write-Host ('DurationTotal:      '+$DurationTotal)
            Write-Host ''
        }
        if($OsValidation){
            $OS_DATA = [PSCustomObject]@{
                OS       = $OS
                OS_TYPE  = $OS_TYPE
                PLATFORM = $PLATFORM
            }
            return $OS_DATA
        }
        else{
            BREAK
        }
    }
}



# OTHERS
function Encode-Command {
<#
.SYNOPSIS
    Function to encode the command into Base64.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER Command
    String Option to enter individual commands or the entire scriptblock.

.EXAMPLE
    Encode-Command -OperatingSystem 'Windows' -Command {Write-Host 'Test command'}

.INPUTS
    PSCustomObject

.OUTPUTS
    Base64String

.NOTES
    Author: Jan Setunsky
    GitHub: https://GitHub.com/JanSetunsky
#>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [PSCustomObject]$OperatingSystem,
        [Parameter(Position=1,Mandatory=$True)]
        [PSCustomObject]$Command
    )
    begin{
        $DurationBegin = Measure-Command -Expression {}
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($OperatingSystem -eq 'Linux'){
                $Encoded = $null
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Encoded = $null
            }
            elseif($OperatingSystem -eq 'Windows'){
                if($Command.Length -ge 1){
                    $Bytes   = [System.Text.Encoding]::Unicode.GetBytes($Command)
                    $Encoded = [Convert]::ToBase64String($Bytes)
                }
                else{
                    $Encoded = $null
                }
            }
            else{
                
            }
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
        Write-Host ('[ ENCODE COMMAND ]')
        Write-Host ('DurationBegin:      '+$DurationBegin)
        Write-Host ('DurationProcess:    '+$DurationProcess)
        Write-Host ('DurationTotal:      '+$DurationTotal)
        Write-Host ''
        return $Encoded        
    }
}

function Decode-Command {
<#
.SYNOPSIS
    Function to decode the command from Base64 string into string.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER Command
    Base64String Option to enter individual commands or the entire scriptblock.

.EXAMPLE
    Decode-Command -OperatingSystem 'Windows' -Command {VwByAGkAdABlAC0ASABvAHMAdAAgACcAVABlAHMAdAAgAGMAbwBtAG0AYQBuAGQAJwA=}

.INPUTS
    PSCustomObject

.OUTPUTS
    String

.NOTES
    Author: Jan Setunsky
    GitHub: https://GitHub.com/JanSetunsky
#>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [PSCustomObject]$OperatingSystem,
        [Parameter(Position=1,Mandatory=$True)]
        [PSCustomObject]$Command
    )
    begin{
        $DurationBegin = Measure-Command -Expression {}
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($OperatingSystem -eq 'Linux'){
                $Decoded = $null
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Decoded = $null
            }
            elseif($OperatingSystem -eq 'Windows'){
                if($Command.Length -ge 1){
                    $Decoded = [System.Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($Command))
                }
                else{
                    $Decoded = $null
                }                
            }
            else{
                $Decoded = $null
            }
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
        Write-Host ('[ DECODE COMMAND ]')
        Write-Host ('DurationBegin:      '+$DurationBegin)
        Write-Host ('DurationProcess:    '+$DurationProcess)
        Write-Host ('DurationTotal:      '+$DurationTotal)
        Write-Host ''
        return $Decoded
    }
}

function New-Runspace {
<#
.SYNOPSIS
    This function allows the invoke scriptblock to run within a new runspace.

.DESCRIPTION
    Within the new runtime, encoded and decoded script blocks can be called, 
    and the WindowStyle can also be set. The -NoExit parameter is set automatically. 
    -Verb "runas" is set here so changes can be declared manually and not fully 
    automatically without the user's knowledge.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER Name
    String runspace script name declaration.

.PARAMETER ScriptBlock
    Base64String or String for runspace script block declaration.

.PARAMETER CommandType
    String runspace command type 'Encode-Command' or 'Decode-Command'.

.PARAMETER WindowStyle
    String runspace window style 'Hidden','Normal','Minimized','Maximized'.

.EXAMPLE
    Get-GitHub_Availability -OperatingSystem $OS_TYPE -Configuration $ConfigData -GitHubDatabase $GitHubData -MeasureDuration $False -ErrorAction Stop

.INPUTS
    PSCustomObject

.OUTPUTS
    Boolean

.NOTES
    Author: Jan Setunsky
    GitHub: https://github.com/JanSetunsky
#>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [PSCustomObject]$OperatingSystem,
        [Parameter(Position=1,Mandatory=$True)]
        [PSCustomObject]$Name,
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ScriptBlock,        
        [Parameter(Position=3,Mandatory=$True)]
        [PSCustomObject]$CommandType,
        [Parameter(Position=4,Mandatory=$True)]
        [PSCustomObject]$WindowStyle        
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            [string]$GUID = [guid]::NewGuid().Guid
            if($CommandType -eq 'Encode-Command'){
                $Condition = $True
                $Arguments = "-NoExit", "-WindowStyle $WindowStyle", "-encodedCommand $ScriptBlock"
            }
            elseif($CommandType -eq 'Decode-Command'){
                $Condition = $True
                $Arguments = "-NoExit", "-WindowStyle $WindowStyle", "-Command $ScriptBlock"
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $EndTime    = ''
                $Status     = 'Running'
                $Process    = Start-Process "pwsh.exe" -argumentlist $Arguments -PassThru -Verbose -Verb "runas"
                $ProcessPID = $Process.Id
                $RunspaceId = $GUID
                $RunspaceProcess = {
                    $Items = Get-CimInstance -ClassName win32_process -filter "ProcessId = `'$ProcessPID`'" 
                    if($Items.Count -ge 1){
                        foreach ($Item in $Items) {
                            #get owner
                            $Owner = Invoke-CimMethod -InputObject $Item -MethodName GetOwner
                            $Parent = Get-Process -Id $Item.ParentprocessID
                            $RunspaceProcessDetail = [PSCustomObject]@{
                                PSTypename      = "PowerShellProcess"
                                ProcessID       = $Item.ProcessID
                                Name            = $Item.Name
                                ScriptName      = $Name
                                Status          = $Status
                                Handles         = $Item.HandleCount
                                WorkingSet      = $Item.WorkingSetSize
                                ParentProcessID = $Item.ParentProcessID
                                ParentProcess   = $Parent.Name
                                ParentPath      = $Parent.Path
                                Started         = $Item.CreationDate
                                Ended           = $EndTime
                                Owner           = "$($Owner.Domain)\$($Owner.user)"
                                CommandLine     = $Item.Commandline
                            }
                        }
                        sleep 2
                        $RunspaceProcess |iex -ErrorAction SilentlyContinue
                    }
                    else{
                        $RunspaceProcessDetail.Status = 'Done'
                        $RunspaceProcessDetail.Ended  = Get-Date
                        $Condition = $True
                    }
                }
                $RunspaceProcess | iex -ErrorAction SilentlyContinue
            }
            else{
                $Condition = $False
            }
        }
    }
    end{
        Write-Host ('[ PROJECT INSTALLER - RUNSPACE PROCESS ]')
        Write-Host ('ConditionResult:    '+$Condition)
        Write-Host ('DurationBegin:      '+$DurationBegin)
        Write-Host ('DurationProcess:    '+$DurationProcess)
        Write-Host ('DurationTotal:      '+$DurationTotal)
        Write-Host ''        
        return $Condition
    }
}



# PROCEDURES INVOKER
function Invoke-Project_Procedures  {
<#
.SYNOPSIS
    Invoke project Procedures function is used to automatically invoke a procedure 
    from the list of procedures stored in the configuration file.

.DESCRIPTION
    On startup, it gets the name of the procedure group from the configuration file
     automatically, and then gets the list of tasks for that procedure and calls 
     the tasks from the list in the functions.ps1 file.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject output from Build-Project_Environment.

.PARAMETER Procedures
    PSCustomObject Procedure group names that identify themselves with the list of groups in the configuration file. This will trigger a specific task list.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.EXAMPLE
    Invoke-Project_Procedures -OperatingSystem $OS_TYPE -BuildData $BuildData -Procedures ('Helm_Install_Prometheus_Grafana') -MeasureDuration $True -ErrorAction Stop

.INPUTS
    PSCustomObject

.OUTPUTS
    Boolean

.NOTES
    Author: Jan Setunsky
    GitHub: https://github.com/JanSetunsky
#>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$True)]
        [PSCustomObject]$OperatingSystem,        
        [Parameter(Position=1,Mandatory=$True)]
        [PSCustomObject]$BuildData,
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$Procedures,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            $Autor                  = $BuildData.Autor
            $ProjectId              = $BuildData.ProjectId
            $ProjectName            = $BuildData.ProjectName
            $InstallPath            = $BuildData.InstallPath
            $RunspacePath           = $BuildData.RunspacePath
            $ProjectsPath           = $BuildData.ProjectsPath
            $OS                     = $BuildData.OS
            $Platform               = $BuildData.Platform
            $Architecture           = $BuildData.Architecture
            $EnviromentProvider     = $BuildData.EnviromentProvider
            $EnviromentType         = $BuildData.EnviromentType
            $Virtualization         = $BuildData.Virtualization
            $InstallingGitHub       = $BuildData.InstallingGitHub
            $InstallingGitLab       = $BuildData.InstallingGitLab            
            $InstallingModules      = $BuildData.InstallingModules
            $InstallingPackages     = $BuildData.InstallingPackages
            $ListOfProcedures       = $BuildData.ListOfProcedures
            $ListOfGitHub           = $BuildData.ListOfGitHub
            $ListOfGitLab           = $BuildData.ListOfGitLab
            $ListOfModules          = $BuildData.ListOfModules
            $ListOfPackages         = $BuildData.ListOfPackages

            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                # Validation condition
                if($Architecture -eq 'AMD64' -and $EnviromentProvider -eq 'Localhost' -and $EnviromentType -eq 'On-premises' -and $Virtualization -eq 'None'){
                    $Condition = $True
                    $ProcedureScriptBlock = {
                        $Step = 0
                        foreach($Procedure in $ListOfProcedures.$ProcedureName){
                            $Step++
                            $Name             = $Procedure.Name
                            $MeasureDuration  = $Procedure.MD
                            $Extra            = $Procedure.Extra
                            $FunctionName     = 'PROCEDURE_'+$Name
                            if($Extra){
                                $ExtraData = $Procedure.Data
                                $FunctionFullName = $FunctionName+' -OperatingSystem $OperatingSystem -BuildData $BuildData -MeasureDuration $MeasureDuration -ExtraData $ExtraData'
                            }
                            else{
                                $FunctionFullName = $FunctionName+' -OperatingSystem $OperatingSystem -BuildData $BuildData -MeasureDuration $MeasureDuration'
                            }
                            Write-Host ('[ '+$Step+' ][ '+$ProcedureName+' ]--------------------------------')
                            Write-Host ('Name: '+$FunctionName)
                            Write-Host ('[Output] >>>')
                            if(Get-Command -Name $FunctionName -ErrorAction SilentlyContinue){
                                $FunctionFullName | iex -ErrorAction SilentlyContinue
                            }
                            else{
                                Write-Host 'Procedure function is not found.'
                            }
                            
                        }
                    }
                }
                else{
                    $Condition = $False
                }
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            Write-Host ''
            Write-Host ('[ PROJECT PROCEDURES - LAUNCHER ]')
            foreach ($ProcedureName in $Procedures) {
                # Procedure process
                if($Condition){
                    $Result = 'Procedures were successfully initiated!'
                    $ProcedureScriptBlock | iex -ErrorAction SilentlyContinue
                }
                else{
                    $Result = 'Procedures were unsuccessfully initiated!'
                }
            }
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
        Write-Host ('ProcessResult: '+$Result)
        if($MeasureDuration){
            $DurationTotal = $DurationBegin+$DurationProcess
            Write-Host ('DurationBegin:      '+$DurationBegin)
            Write-Host ('DurationProcess:    '+$DurationProcess)
            Write-Host ('DurationTotal:      '+$DurationTotal)
            Write-Host ''
        }
        return $Condition
    }
}




#region >> [ PROJECT BUILDER ]
$PROJECT_BUILDER_SC = {
    $BuildData = Build-Project_Environment -OperatingSystem $OS_TYPE -Configuration $ConfigData -GitHubDatabase $GitHubData -GitLabDatabase $GitLabData -ModuleDatabase $ModulesData -PackageDatabase $PackagesData -MeasureDuration $False -ErrorAction Stop
    $Install   = Install-Project_Environment -OperatingSystem $OS_TYPE -BuildData $BuildData -MeasureDuration $False -ErrorAction Stop    
    $Save      = Save-Project_Environment -OperatingSystem $OS_TYPE -BuildData $BuildData -MeasureDuration $False -ErrorAction Stop
}
#endregion [ PROJECT BUILDER ]

#region >> [ PROJECT PROCEDURES ]
$PROJECT_PROCEDURES_SC = {
    $InvokeProcedure = Invoke-Project_Procedures -OperatingSystem $OS_TYPE -BuildData $BuildData -Procedures ('LOCALHOST_MINIKUBE_START_LOCAL_CLUSTER','LOCALHOST_MINIKUBE_OBSERVABILITY_STACK_Helm_Install_Prometheus_Grafana','LOCALHOST_MINIKUBE_DEPLOY_JENKINS_IMAGE','LOCALHOST_MINIKUBE_DEPLOY_NGINX_IMAGE') -MeasureDuration $True -ErrorAction Stop
}
#endregion [ PROJECT PROCEDURES ]

#region >> [ TRIGGER SWITCH ]
$TRIGGER_SWITCH_SC = {
    switch (1..4) {
        1 { $PROJECT_INSTALL_DEFINITION_SC | iex -ErrorAction SilentlyContinue }
        2 { $PROJECT_INSTALL_VERIFICATION_SC | iex -ErrorAction SilentlyContinue }
        3 { $PROJECT_BUILDER_SC | iex -ErrorAction SilentlyContinue }
        4 { $PROJECT_PROCEDURES_SC | iex -ErrorAction SilentlyContinue }
    }
}
#endregion [ DEFAULT SWITCH ]

$ScriptRoot       = $PSScriptRoot
$DefaultRoot      = Split-Path $ScriptRoot -Parent
$InterfacesPath   = Join-Path -Path $DefaultRoot -ChildPath 'interfaces' -Verbose
$CorePath         = Join-Path -Path $InterfacesPath -ChildPath 'core.ps1' -Verbose
$ProceduresPath   = Join-Path -Path $InterfacesPath -ChildPath 'kubernetes_procedures.ps1' -Verbose
$DefinitionPath   = Join-Path -Path $InterfacesPath -ChildPath 'installation_definition.ps1' -Verbose
$VerificationPath = Join-Path -Path $InterfacesPath -ChildPath 'installation_verification.ps1' -Verbose
$FULL_AUTOMATION  = $True
Import-Module $CorePath
Import-Module $ProceduresPath
Import-Module $DefinitionPath
Import-Module $VerificationPath
$MeasureCommand = Measure-Command -Expression {
    $TRIGGER_SWITCH_SC | iex -ErrorAction SilentlyContinue
}
Write-Host ('OverallTime: '+$MeasureCommand)
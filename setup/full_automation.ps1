#region >> [ PROJECT AUTORUN ]
$PROJECT_AUTORUN_SC = {
    $FULL_AUTOMATION = $True
    .$InstallEnvironmentPath
    .$StartLocalClusterPath
    .$InstallMonitoringStackPath
    .$DeployImagePath
}
#endregion [ PROJECT AUTORUN ]

#region >> [ TRIGGER SWITCH ]
$TRIGGER_SWITCH_SC = {
    switch (1) {
        1 { $PROJECT_AUTORUN_SC | iex -ErrorAction SilentlyContinue }
    }
}
#endregion [ DEFAULT SWITCH ]

# Installation paths
$ScriptRoot                 = $PSScriptRoot
$DefaultRoot                = Split-Path $ScriptRoot -Parent
$LibrariesPath              = Join-Path -Path $DefaultRoot -ChildPath 'libraries' -Verbose
$KubernetesPath             = Join-Path -Path $LibrariesPath -ChildPath 'kubernetes' -Verbose
$InstallEnvironmentPath     = Join-Path -Path $ScriptRoot -ChildPath 'install_environment.ps1' -Verbose
$StartLocalClusterPath      = Join-Path -Path $KubernetesPath -ChildPath 'start_local_cluster.ps1' -Verbose
$InstallMonitoringStackPath = Join-Path -Path $KubernetesPath -ChildPath 'install_prometheus-grafana.ps1' -Verbose
$DeployImagePath            = Join-Path -Path $KubernetesPath -ChildPath 'deploy_image.ps1' -Verbose

$MeasureCommand = Measure-Command -Expression {
    $TRIGGER_SWITCH_SC | iex -ErrorAction SilentlyContinue
}
Write-Host ('OverallTime: '+$MeasureCommand)
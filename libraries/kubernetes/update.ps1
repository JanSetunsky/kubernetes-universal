#region >> [ PROJECT PROCEDURES ]
$PROJECT_PROCEDURES_SC = {
    $InvokeProcedure = Invoke-Project_Procedures -OperatingSystem $OS_TYPE -BuildData $BuildData -Procedures ('Update') -MeasureDuration $True -ErrorAction Stop
}
#endregion [ PROJECT PROCEDURES ]

#region >> [ TRIGGER SWITCH ]
$TRIGGER_SWITCH_SC = {
    switch (1..3) {
        1 { $PROJECT_KUBERNETES_DEFINITION_SC | iex -ErrorAction SilentlyContinue }
        2 { $PROJECT_GLOBAL_VERIFICATION_SC | iex -ErrorAction SilentlyContinue }
        3 { $PROJECT_PROCEDURES_SC   | iex -ErrorAction SilentlyContinue }
    }
}
#endregion [ DEFAULT SWITCH ]

$ScriptRoot       = $PSScriptRoot
$LibrariesRoot    = Split-Path $ScriptRoot -Parent
$DefaultRoot      = Split-Path $LibrariesRoot -Parent
$InterfacesPath   = Join-Path -Path $DefaultRoot -ChildPath 'interfaces' -Verbose
$CorePath         = Join-Path -Path $InterfacesPath -ChildPath 'core.ps1' -Verbose
$ProceduresPath   = Join-Path -Path $InterfacesPath -ChildPath 'procedures.ps1' -Verbose
$DefinitionPath   = Join-Path -Path $InterfacesPath -ChildPath 'project_kubernetes_definition.ps1' -Verbose
$VerificationPath = Join-Path -Path $InterfacesPath -ChildPath 'project_global_verification.ps1' -Verbose
Import-Module $CorePath
Import-Module $ProceduresPath
Import-Module $DefinitionPath
Import-Module $VerificationPath
$MeasureCommand = Measure-Command -Expression {
    $TRIGGER_SWITCH_SC | iex -ErrorAction SilentlyContinue
}
Write-Host ('OverallTime: '+$MeasureCommand)

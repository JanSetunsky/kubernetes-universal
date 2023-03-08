# KUBERNETES CLUSTER MANAGEMENT
function LOCALHOST_PROCEDURE_MINIKUBE-Start_Local_Cluster {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Start_Local_Cluster

.DESCRIPTION
    First, the status of the cluster is determined, if it is available, and then 
    the start of the cluster itself is started, otherwise the cluster is already running or is suspended.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

.INPUTS
    PSCustomObject

.OUTPUTS
    Success or Failed

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue

                # MiniKube start
                if($MiniKubeStatus -eq 'is-not-exist'){
                    Write-Host 'MiniKube cluster will now be created.'
                    $MiniKubeStart = minikube start

                    # Write output
                    foreach($Output in $MiniKubeStart){
                        Write-Host $Output
                    }
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    Write-Host 'MiniKube cluster is already running.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster has started running.'
                    $MiniKubeStart = minikube start

                    # Write output
                    foreach($Output in $MiniKubeStart){
                        Write-Host $Output
                    }
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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

function LOCALHOST_PROCEDURE_MINIKUBE-Stop_Local_Cluster {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Stop_Local_Cluster

.DESCRIPTION
    First, the status of the cluster is determined as to whether it is available, and then
    initiates a cluster shutdown. If exit does not run, the cluster is already shut down or suspended.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

.INPUTS
    PSCustomObject

.OUTPUTS
    Success or Failed

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
                # MiniKube stop
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    Write-Host 'MiniKube cluster will be shut down.'
                    $MiniKubeStop = minikube stop
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                # Write output
                foreach($Output in $MiniKubeStop){
                    Write-Host $Output
                }
                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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

function LOCALHOST_PROCEDURE_MINIKUBE-Pause_Local_Cluster {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Pause_Local_Cluster

.DESCRIPTION
    First, the status of the cluster is determined as to whether it is available.
    If the cluster is on, it will pause. If the cluster is stopped or suspended, nothing happens.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

.INPUTS
    PSCustomObject

.OUTPUTS
    Success or Failed

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
                # MiniKube stop
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    Write-Host 'MiniKube cluster is running and will be suspended.'
                    $MiniKubeStop = minikube pause
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                # Write output
                foreach($Output in $MiniKubeStop){
                    Write-Host $Output
                }
                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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

function LOCALHOST_PROCEDURE_MINIKUBE-UnPause_Local_Cluster {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-UnPause_Local_Cluster

.DESCRIPTION
    First, the status of the cluster is determined as to whether it is available.
    If the cluster is suspended, it will start again. If the cluster is stopped or started, nothing happens.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

.INPUTS
    PSCustomObject

.OUTPUTS
    Success or Failed

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
                # MiniKube stop
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    Write-Host 'MiniKube cluster is already running.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended and will be started again.'
                    $MiniKubeStop = minikube unpause
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                # Write output
                foreach($Output in $MiniKubeStop){
                    Write-Host $Output
                }
                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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

function LOCALHOST_PROCEDURE_MINIKUBE-Delete_Local_Cluster {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Delete_Local_Cluster

.DESCRIPTION
    First, the state of the cluster is determined, according to the state of the cluster, it is shut down and deleted.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

.INPUTS
    PSCustomObject

.OUTPUTS
    Success or Failed

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
                # MiniKube stop
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    Write-Host 'MiniKube cluster will be shut down.'
                    $MiniKubeStop = minikube stop
                    Write-Host 'MiniKube cluster will be deleted.'
                    $MiniKubeDelete = minikube delete
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                    Write-Host 'MiniKube cluster will be deleted.'
                    $MiniKubeDelete = minikube delete
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                    Write-Host 'MiniKube cluster will be deleted.'
                    $MiniKubeDelete = minikube delete
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                # Write output
                foreach($Output in $MiniKubeStop){
                    Write-Host $Output
                }
                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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

function LOCALHOST_PROCEDURE_MINIKUBE-Delete_All_Clusters {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Delete_All_Clusters

.DESCRIPTION
    First, the state of the cluster is determined, according to the state of the cluster, it is shut down and deleted.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

.INPUTS
    PSCustomObject

.OUTPUTS
    Success or Failed

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
                # MiniKube stop
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    Write-Host 'MiniKube cluster will be shut down.'
                    $MiniKubeStop = minikube stop
                    Write-Host 'MiniKube all clusters will be deleted.'
                    $MiniKubeDelete = minikube delete --all
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                    Write-Host 'MiniKube all clusters will be deleted.'
                    $MiniKubeDelete = minikube delete --all
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                    Write-Host 'MiniKube all clusters will be deleted.'
                    $MiniKubeDelete = minikube delete --all
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                # Write output
                foreach($Output in $MiniKubeStop){
                    Write-Host $Output
                }
                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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

function LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status

.DESCRIPTION
    This function determines the state of the cluster and then returns a ps custom object
    $MiniKubeOutput = [PSCustomObject]@{
                            Type = $MiniCubeType
                            Host = $MiniKubeHost
                            CubeFly = $MiniKubeFly
                            ApiServer = $MiniKubeApiServer
                            Config = $MiniKubeKubeConfig
                            IsRunning = $False
                        }

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

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
        [PSCustomObject]$BuildData,
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube status
                $MiniKubeStatus = minikube status

                if($MiniKubeStatus -match '\* Profile "minikube" not found.'){
                    # MiniKube cluster is not exist
                    $MiniKubeOutput = 'is-not-exist'
                }
                else{
                    $MiniKubeType       = $MiniKubeStatus[1]
                    $MiniKubeHost       = $MiniKubeStatus[2]
                    $MiniKubeKubeLet    = $MiniKubeStatus[3]
                    $MiniKubeApiServer  = $MiniKubeStatus[4]
                    $MiniKubeKubeConfig = $MiniKubeStatus[5]
    
                    if($MiniKubeType -match 'Control Plane'){
                        $MiniKubeType = 'Control Plane'
                    }
                    else{
                        $MiniKubeType = 'Uknown'
                    }
                
                    if($MiniKubeHost -match 'Stopped'){
                        $MiniKubeHost = 'Stopped'
                    }
                    elseif($MiniKubeHost -match 'Running'){
                        $MiniKubeHost = 'Running'
                    }
                    else{
                        $MiniKubeHost = 'Uknown'
                    }
                
                    if($MiniKubeKubeLet -match 'Stopped'){
                        $MiniKubeKubeLet = 'Stopped'
                    }
                    elseif($MiniKubeKubeLet -match 'Running'){
                        $MiniKubeKubeLet = 'Running'
                    }    
                    else{
                        $MiniKubeKubeLet = 'Uknown'
                    }
                
                    if($MiniKubeApiServer -match 'Stopped'){
                        $MiniKubeApiServer = 'Stopped'
                    }
                    elseif($MiniKubeApiServer -match 'Running'){
                        $MiniKubeApiServer = 'Running'
                    }
                    elseif($MiniKubeApiServer -match 'Running'){
                        $MiniKubeApiServer = 'Paused'
                    }
                    else{
                        $MiniKubeApiServer = 'Uknown'
                    }
                
                    if($MiniKubeKubeConfig -match 'Stopped'){
                        $MiniKubeKubeConfig = 'Stopped'
                    }
                    elseif($MiniKubeKubeConfig -match 'Configured'){
                        $MiniKubeKubeConfig = 'Configured'
                    }
                    else{
                        $MiniKubeKubeConfig = 'Uknown'
                    }
                
                    # MiniKube start
                    if(
                        $MiniKubeType -eq 'Control Plane' -and
                        $MiniKubeHost -eq 'Running' -and
                        $MiniKubeKubeLet -eq 'Running' -and
                        $MiniKubeApiServer -eq 'Running' -and
                        $MiniKubeKubeConfig -eq 'Configured'
                    ){
                        Write-Host 'MiniKube cluster is already running.'
                        # Create Output
                        $MiniKubeOutput = [PSCustomObject]@{
                            Type       = $MiniKubeType
                            Host       = $MiniKubeHost
                            KubeLet    = $MiniKubeKubeLet
                            ApiServer  = $MiniKubeApiServer
                            Config     = $MiniKubeKubeConfig
                            IsRunning  = $True
                        }
                    }
                    elseif(
                        $MiniKubeType -eq 'Control Plane' -and
                        $MiniKubeHost -eq 'Running' -and
                        $MiniKubeKubeLet -eq 'Stopped' -and
                        $MiniKubeApiServer -eq 'Paused' -and
                        $MiniKubeKubeConfig -eq 'Stopped'        
                    ){
                        Write-Host 'MiniKube cluster is suspended.'
                        # Create Output
                        $MiniKubeOutput = [PSCustomObject]@{
                            Type       = $MiniKubeType
                            Host       = $MiniKubeHost
                            KubeLet    = $MiniKubeKubeLet
                            ApiServer  = $MiniKubeApiServer
                            Config     = $MiniKubeKubeConfig
                            IsRunning  = $False
                        }
                    }
                    elseif(
                        $MiniKubeType -eq 'Control Plane' -and
                        $MiniKubeHost -eq 'Stopped' -and
                        $MiniKubeKubeLet -eq 'Stopped' -and
                        $MiniKubeApiServer -eq 'Stopped' -and
                        $MiniKubeKubeConfig -eq 'Stopped'        
                    ){
                        Write-Host 'MiniKube cluster is down.'
                        # Create Output
                        $MiniKubeOutput = [PSCustomObject]@{
                            Type       = $MiniKubeType
                            Host       = $MiniKubeHost
                            KubeLet    = $MiniKubeKubeLet
                            ApiServer  = $MiniKubeApiServer
                            Config     = $MiniKubeKubeConfig
                            IsRunning  = $False
                        }
                    }    
                    else{
                        Write-Warning 'MiniKube cluster result does not match the conditions.'
                        # Create Output
                        $MiniKubeOutput = [PSCustomObject]@{
                            Type       = $MiniKubeType
                            Host       = $MiniKubeHost
                            KubeLet    = $MiniKubeKubeLet
                            ApiServer  = $MiniKubeApiServer
                            Config     = $MiniKubeKubeConfig
                            IsRunning  = $False
                        }
                    }
                }

                # Write output
                foreach($Output in $MiniKubeStart){
                    Write-Host $Output
                }
                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
        if($MeasureDuration){
            $DurationTotal = $DurationBegin+$DurationProcess
            Write-Host ('DurationBegin:      '+$DurationBegin)
            Write-Host ('DurationProcess:    '+$DurationProcess)
            Write-Host ('DurationTotal:      '+$DurationTotal)
            Write-Host ''
        }
        return $MiniKubeOutput
    }
}



# KUBERNETES NGINX WEB SERVER
function LOCALHOST_PROCEDURE_MINIKUBE-Deploy_Nginx_Image {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Deploy_Nginx_Image

.DESCRIPTION
    This function deploys NGINX IMAGE to kubernetes.
    External data from the configuration file is used for deployment.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

.INPUTS
    PSCustomObject

.OUTPUTS
    Success or Failed

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
                # MiniKube deployment
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    $ProjectPath = Join-Path -Path $ProjectsPath -ChildPath  $ProjectName
                    if(Test-Path $ProjectPath){
                        # Navigate to project repository 
                        cd $ProjectPath

                        # Procedure data
                        $DeploymentName  = $ProcedureData.DeploymentName
                        $DeploymentImage = $ProcedureData.DeploymentImage
                        $DeploymentType  = $ProcedureData.DeploymentType
                        $DeploymentPort  = $ProcedureData.DeploymentPort

                        # Get deployments
                        $KubeCtlDeployments = kubectl get deployments $DeploymentName

                        # Validation of deployment condition
                        if($KubeCtlDeployments.Count -ge 1){
                            $DeploymentCondition = 'is-ready'
                        }
                        else{
                            $DeploymentCondition = 'is-not-ready'
                        }

                        # Validation of deployment
                        if($DeploymentCondition -eq 'is-ready'){
                            Write-Warning ('MiniKube cluster already contains deployments named: '+$DeploymentName)
                        }
                        elseif($DeploymentCondition -eq 'is-not-ready'){
                            # Create deployment
                            $KubeCtlCreate = kubectl create deployment $DeploymentName --image=$DeploymentImage
                            $KubeCtlExpose = kubectl expose deployment $DeploymentName --type=$DeploymentType --port=$DeploymentPort

                            # Write output
                            foreach($Output in $KubeCtlCreate){
                                Write-Host $Output
                            }

                            # Write output
                            foreach($Output in $KubeCtlExpose){
                                Write-Host $Output
                            }                            
                        }
                        else{
                            Write-Warning 'MiniKube cluster triggered an invalid condition'
                        }
                    }
                    else{
                        Write-Warning 'Project: '+$ProjectPath+'is not exist.'
                    }
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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

function LOCALHOST_PROCEDURE_MINIKUBE-Update_Nginx_Image {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Update_Nginx_Image

.DESCRIPTION
    This function updated NGINX IMAGE to kubernetes.
    External data from the configuration file is used for deployment.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

.INPUTS
    PSCustomObject

.OUTPUTS
    Success or Failed

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
                # MiniKube deployment
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    $ProjectPath = Join-Path -Path $ProjectsPath -ChildPath  $ProjectName
                    if(Test-Path $ProjectPath){
                        # Navigate to project repository 
                        cd $ProjectPath

                        # Procedure data
                        $DeploymentName = $ProcedureData.DeploymentName

                        # Get deployments
                        $KubeCtlDeployments = kubectl get deployments $DeploymentName

                        # Validation of deployment condition
                        if($KubeCtlDeployments.Count -ge 1){
                            $DeploymentCondition = 'is-ready'
                        }
                        else{
                            $DeploymentCondition = 'is-not-ready'
                        }

                        # Validation of deployment
                        if($DeploymentCondition -eq 'is-ready'){
                            Write-Warning ('MiniKube cluster already contains deployments named: '+$DeploymentName)
                        }
                        elseif($DeploymentCondition -eq 'is-not-ready'){
                            # Update deployment
                            $KubeCtlUpdate = kubectl set image deployment/$DeploymentName 

                            # Write output
                            foreach($Output in $KubeCtlCreate){
                                Write-Host $Output
                            }

                            # Write output
                            foreach($Output in $KubeCtlExpose){
                                Write-Host $Output
                            }                            
                        }
                        else{
                            Write-Warning 'MiniKube cluster triggered an invalid condition'
                        }
                    }
                    else{
                        Write-Warning 'Project: '+$ProjectPath+'is not exist.'
                    }
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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

function LOCALHOST_PROCEDURE_MINIKUBE-Delete_Nginx_Image {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Delete_Nginx_Image

.DESCRIPTION
    After deploying NGINX IMAGE, this function will uninstall the nginx demo deployment including the service.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

.INPUTS
    PSCustomObject

.OUTPUTS
    Success or Failed

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
                # MiniKube deployment
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    $ProjectPath = Join-Path -Path $ProjectsPath -ChildPath  $ProjectName
                    if(Test-Path $ProjectPath){
                        cd $ProjectPath

                        # Procedure data
                        $DeploymentName = $ProcedureData.DeploymentName

                        # Get deployments
                        $KubeCtlDeployments = kubectl get deployments $DeploymentName

                        # Validation of deployment condition
                        if($KubeCtlDeployments.Count -ge 1){
                            $DeploymentCondition = 'is-ready'
                        }
                        else{
                            $DeploymentCondition = 'is-not-ready'
                        }

                        # Validation of deployment
                        if($DeploymentCondition -eq 'is-ready'){
                            # Delete deployment
                            $KubeCtlDeleteDeployment = kubectl delete deployment $DeploymentName
                            $KubeCtlDeleteService    = kubectl delete service $DeploymentName

                            # Write output
                            foreach($Output in $KubeCtlDeleteDeployment){
                                Write-Host $Output
                            }

                            # Write output
                            foreach($Output in $KubeCtlDeleteService){
                                Write-Host $Output
                            }           
                        }
                        elseif($DeploymentCondition -eq 'is-not-ready'){
                            # pass
                        }
                        else{
                            # pass
                        }
                    }
                    else{
                        Write-Warning 'Project: '+$ProjectPath+'is not exist.'
                    }
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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

function LOCALHOST_PROCEDURE_MINIKUBE-Get_Nginx_Service {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Get_Nginx_Service

.DESCRIPTION
    After deploying NGINX IMAGE to kubernetes, this function checks if the nginx image deployment and service are available.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

.INPUTS
    PSCustomObject

.OUTPUTS
    Success or Failed

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
                # MiniKube deployment
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    $ProjectPath = Join-Path -Path $ProjectsPath -ChildPath  $ProjectName
                    if(Test-Path $ProjectPath){
                        cd $ProjectPath

                        # Procedure data
                        $DeploymentName = $ProcedureData.DeploymentName

                        # Get deployments
                        $KubeCtlDeployments = kubectl get deployments $DeploymentName

                        # Validation of deployment condition
                        if($KubeCtlDeployments.Count -ge 1){
                            $DeploymentCondition = 'is-ready'
                        }
                        else{
                            $DeploymentCondition = 'is-not-ready'
                        }

                        # Validation of deployment
                        if($DeploymentCondition -eq 'is-ready'){
                            # Get Services
                            $KubeCtlGetServices = kubectl get services $DeploymentName

                            # Write output
                            foreach($Output in $KubeCtlGetServices){
                                Write-Host $Output
                            }
                        }
                        elseif($DeploymentCondition -eq 'is-not-ready'){
                            # pass                            
                        }
                        else{
                            # pass
                        }
                    }
                    else{
                
                    }
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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



# KUBERNETES OBSERVABILITY STACK INSTALLATION
function LOCALHOST_PROCEDURE_MINIKUBE-Helm_Install_Prometheus {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Helm_Install_Prometheus

.DESCRIPTION
    Installing the Prometheus dependency using the Helm installer package.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $null -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
                # MiniKube deployment
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    $ProjectPath = Join-Path -Path $ProjectsPath -ChildPath  $ProjectName
                    if(Test-Path $ProjectPath){
                        cd $ProjectPath

                        $HelmInstallPrometheusList = @()

                        # Re-Verify helm list
                        $HelmList = helm list
                        if($HelmList -match "prometheus"){
                            Write-Host "Prometheus is already installed."
                        }
                        else{
                            # Procedure data
                            $StackName     = $ProcedureData.StackName
                            $StackFullName = $ProcedureData.StackFullName
                            $StackUri      = $ProcedureData.StackUri

                            # Installation
                            $HelmInstallPrometheusList += helm repo add $StackFullName $StackUri
                            $HelmInstallPrometheusList += helm repo update
                            $HelmInstallPrometheusList += helm install $StackName $StackFullName/$StackName

                            # Write output
                            foreach($Output in $HelmInstallPrometheusList){
                                Write-Host $Output
                            }
                        }

                        # Re-Verify helm list
                        $HelmList = helm list
                        if($HelmList -match "prometheus"){
                            Write-Host "Prometheus is installed."
                        }
                        else{
                            Write-Warning "Prometheus is not installed!"
                        }

                        # Write output
                        foreach($Output in $HelmList){
                            Write-Host $Output
                        }
                    }
                    else{
                        Write-Warning 'Project: '+$ProjectPath+'is not exist.'
                    }
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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

function LOCALHOST_PROCEDURE_MINIKUBE-Helm_Install_Grafana {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Helm_Install_Grafana

.DESCRIPTION
    Installing the Grafana dependency using the Helm installer package.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
                # MiniKube deployment
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    $ProjectPath = Join-Path -Path $ProjectsPath -ChildPath  $ProjectName
                    if(Test-Path $ProjectPath){
                        cd $ProjectPath

                        $HelmInstallGrafanaList = @()

                        # Re-Verify helm list
                        $HelmList = helm list
                        if($HelmList -match "grafana"){
                            Write-Host "Grafana is already installed."
                        }
                        else{
                            # Procedure data
                            $StackName     = $ProcedureData.StackName
                            $StackFullName = $ProcedureData.StackFullName
                            $StackUri      = $ProcedureData.StackUri

                            # Installation
                            $HelmInstallGrafanaList += helm repo add $StackFullName $StackUri
                            $HelmInstallGrafanaList += helm repo update
                            $HelmInstallGrafanaList += helm install $StackName $StackFullName/$StackName

                            # Write output
                            foreach($Output in $HelmInstallGrafanaList){
                                Write-Host $Output
                            }
                        }

                        # Re-Verify helm list
                        $HelmList = helm list
                        if($HelmList -match "grafana"){
                            Write-Host "Grafana is installed."
                        }
                        else{
                            Write-Warning "Grafana is not installed!"
                        }

                        # Write output
                        foreach($Output in $HelmList){
                            Write-Host $Output
                        }
                    }
                    else{
                        Write-Warning 'Project: '+$ProjectPath+'is not exist.'
                    }
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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

function LOCALHOST_PROCEDURE_MINIKUBE-Create_Kubernetes_Dashboard {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Create_Kubernetes_Dashboard

.DESCRIPTION
    Creating a kubernetes dashboard according to external data sources from the configuration file.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
                # MiniKube deployment
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    $ProjectPath = Join-Path -Path $ProjectsPath -ChildPath  $ProjectName
                    if(Test-Path $ProjectPath){
                        cd $ProjectPath

                        $CreateKubernetesDashboard = @()

                        # Re-Verify helm list
                        $HelmList = helm list
                        if($HelmList -match "prometheus"){
                            $PrometheusCondition = $True
                        }
                        else{
                            $PrometheusCondition = $False
                            Write-Warning "Prometheus is not installed."
                        }

                        if($HelmList -match "grafana"){
                            $GrafanaCondition = $True
                        }
                        else{
                            $GrafanaCondition = $False
                            Write-Warning "Grafana is not installed."
                        }

                        if($PrometheusCondition -and $GrafanaCondition){
                            # Data
                            $KubernetesDashboard  = $ProcedureData.KubernetesDashboard

                            # Create
                            $CreateKubernetesDashboard += kubectl create -f $KubernetesDashboard --validate=false

                            # Write output
                            foreach($Output in $CreateKubernetesDashboard){
                                Write-Host $Output
                            }
                        }
                        else{
                            Write-Warning "Helm deploy monitoring is not completed."
                        }
                    }
                    else{
                        Write-Warning 'Project: '+$ProjectPath+'is not exist.'
                    }
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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

function LOCALHOST_PROCEDURE_MINIKUBE-Create_Monitoring_Standalone {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Create_Monitoring_Standalone

.DESCRIPTION
    Creating a kubernetes monitoring standalone according to external data sources from the configuration file.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
                # MiniKube deployment
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    $ProjectPath = Join-Path -Path $ProjectsPath -ChildPath  $ProjectName
                    if(Test-Path $ProjectPath){
                        cd $ProjectPath

                        $CreateMonitoringStandalone = @()

                        # Re-Verify helm list
                        $HelmList = helm list
                        if($HelmList -match "prometheus"){
                            $PrometheusCondition = $True
                        }
                        else{
                            $PrometheusCondition = $False
                            Write-Warning "Prometheus is not installed."
                        }

                        if($HelmList -match "grafana"){
                            $GrafanaCondition = $True
                        }
                        else{
                            $GrafanaCondition = $False
                            Write-Warning "Grafana is not installed."
                        }

                        if($PrometheusCondition -and $GrafanaCondition){
                            # Data
                            $MonitoringStandalone = $ProcedureData.MonitoringStandalone

                            # Create
                            $CreateMonitoringStandalone += kubectl create -f $MonitoringStandalone --validate=false

                            # Write output
                            foreach($Output in $CreateMonitoringStandalone){
                                Write-Host $Output
                            }
                        }
                        else{
                            Write-Warning "Helm deploy monitoring is not completed."
                        }
                    }
                    else{
                        Write-Warning 'Project: '+$ProjectPath+'is not exist.'
                    }
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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

function LOCALHOST_PROCEDURE_MINIKUBE-Create_Service_Account_Prometheus {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Create_Service_Account_Prometheus

.DESCRIPTION
    Creating a service account named prometheus that is deployed to kubernetes to communicate with kubernetes.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
                # MiniKube deployment
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    $ProjectPath = Join-Path -Path $ProjectsPath -ChildPath  $ProjectName
                    if(Test-Path $ProjectPath){
                        cd $ProjectPath

                        $KubeCtlGetServiceAccounts   = @()
                        $KubeCtlCreateServiceAccount = @()
                        $ServiceAccountCondition     = @()

                        $KubeCtlGetServiceAccounts += kubectl get serviceaccounts

                        # Write output
                        foreach($Output in $KubeCtlGetServiceAccounts){
                            Write-Host $Output
                        }

                        # Find current service account
                        foreach($ServiceAccount in $KubeCtlGetServiceAccounts){
                            if($ServiceAccount -notmatch 'prometheus-' -and $ServiceAccount -match 'prometheus'){
                                $ServiceAccountCondition += $True
                            }
                            else{
                                $ServiceAccountCondition += $False
                            }
                        }

                        # Compare service accounts condition
                        if($ServiceAccountCondition.Count -gt 1){
                            if($ServiceAccountCondition -match $True){
                                Write-Warning 'Service deployment for prometheus already exists.'
                            }
                            else{
                                Write-Host 'Service observability stack deployment for prometheus is now running.'
                                $KubeCtlCreateServiceAccount = kubectl create serviceaccount prometheus
                            }
                        }
                        elseif($ServiceAccountCondition.Count -eq 1){
                            if($ServiceAccountCondition -eq $True){
                                Write-Warning 'Service deployment for prometheus already exists.'
                            }
                            else{
                                Write-Host 'Service observability stack deployment for prometheus is now running.'
                                $KubeCtlCreateServiceAccount = kubectl create serviceaccount prometheus
                            }
                        }
                        else{
                            Write-Warning 'The result for comparing service accounts is not valid.'
                        }

                        # Write output
                        foreach($Output in $KubeCtlCreateServiceAccount){
                            Write-Host $Output
                        }

                    }
                    else{
                        Write-Warning 'Project: '+$ProjectPath+'is not exist.'
                    }
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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

function LOCALHOST_PROCEDURE_MINIKUBE-Create_Cluster_Prometheus_Role {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Create_Cluster_Prometheus_Role

.DESCRIPTION
    Creating a cluster prometheus role, and saving the role in the project folder.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
                # MiniKube deployment
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    $ProjectPath = Join-Path -Path $ProjectsPath -ChildPath  $ProjectName
                    if(Test-Path $ProjectPath){
                        cd $ProjectPath

                        # Create paths
                        $ProjectPrometheusPath         = Join-Path -Path $ProjectPath -ChildPath 'prometheus'
                        $ProjectClusterRolePath        = Join-Path -Path $ProjectPrometheusPath -ChildPath 'cluster_role'
                        $PrometheusRoleYamlPath        = Join-Path -Path $ProjectClusterRolePath -ChildPath 'prometheus-role.yaml'
                        $PrometheusRoleBindingYamlPath = Join-Path -Path $ProjectClusterRolePath -ChildPath 'prometheus-role-binding.yaml'
                        $PrometheusRoleYamlContent = (
@"
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/proxy
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
"@
                        )

                        $PrometheusRoleBindingYamlContent = (
@"
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: default
roleRef:
  kind: ClusterRole
  name: prometheus
  apiGroup: rbac.authorization.k8s.io
"@
                        )

                        # Create prometheus directory
                        if(Test-Path $ProjectPrometheusPath){
                            # pass
                        }
                        else{
                            $NewItem = New-Item -ItemType Directory -Path $ProjectPrometheusPath -Force -Verbose
                        }

                        # Create cluster role directory
                        if(Test-Path $ProjectClusterRolePath){
                            # pass
                        }
                        else{
                            $NewItem = New-Item -ItemType Directory -Path $ProjectClusterRolePath -Force -Verbose
                        }

                        # Create prometheus_role.yaml file
                        if(Test-Path $PrometheusRoleYamlPath){
                            $SetContent = Set-Content -Path $PrometheusRoleYamlPath -Value $PrometheusRoleYamlContent -Force -Verbose
                        }
                        else{
                            $NewItem    = New-Item -ItemType File -Path $PrometheusRoleYamlPath -Force -Verbose
                            $SetContent = Set-Content -Path $PrometheusRoleYamlPath -Value $PrometheusRoleYamlContent -Force -Verbose
                        }

                        # Create prometheus_role-binding.yaml file
                        if(Test-Path $PrometheusRoleBindingYamlPath){
                            $SetContent = Set-Content -Path $PrometheusRoleBindingYamlPath -Value $PrometheusRoleBindingYamlContent -Force -Verbose
                        }
                        else{
                            $NewItem    = New-Item -ItemType File -Path $PrometheusRoleBindingYamlPath -Force -Verbose
                            $SetContent = Set-Content -Path $PrometheusRoleBindingYamlPath -Value $PrometheusRoleBindingYamlContent -Force -Verbose
                        }

                        $ServiceAccountCondition    = @()
                        $KubeCtlGetServiceAccounts  = @()
                        $KubeCtlApplyPrometheusRole = @()

                        # Get service account list
                        $KubeCtlGetServiceAccounts += kubectl get serviceaccounts

                        # Write output
                        foreach($Output in $KubeCtlGetServiceAccounts){
                            Write-Host $Output
                        }

                        # Find current service account
                        foreach($ServiceAccount in $KubeCtlGetServiceAccounts){
                            if($ServiceAccount -notmatch 'prometheus-' -and $ServiceAccount -match 'prometheus'){
                                $ServiceAccountCondition += $True
                            }
                            else{
                                $ServiceAccountCondition += $False
                            }
                        }

                        # Compare service accounts condition
                        if($ServiceAccountCondition.Count -gt 1){
                            if($ServiceAccountCondition -match $True){
                                Write-Host 'Service observability stack now creates the prometheus role'
                                cd $ProjectClusterRolePath
                                $KubeCtlApplyPrometheusRole += kubectl apply -f prometheus-role.yaml
                                $KubeCtlApplyPrometheusRole += kubectl apply -f prometheus-role-binding.yaml
                            }
                            else{
                                Write-Warning 'Service deployment for prometheus is not exists.'
                            }
                        }
                        elseif($ServiceAccountCondition.Count -eq 1){
                            if($ServiceAccountCondition -match $True){
                                Write-Host 'Service observability stack now creates the prometheus role'
                                cd $ProjectClusterRolePath
                                $KubeCtlApplyPrometheusRole += kubectl apply -f prometheus-role.yaml
                                $KubeCtlApplyPrometheusRole += kubectl apply -f prometheus-role-binding.yaml
                            }
                            else{
                                Write-Warning 'Service deployment for prometheus is not exists.'
                            }
                        }
                        else{
                            Write-Warning 'The result for comparing service accounts is not valid.'
                        }

                        # Write output
                        foreach($Output in $KubeCtlApplyPrometheusRole){
                            Write-Host $Output
                        }

                    }
                    else{
                        Write-Warning 'Project: '+$ProjectPath+'is not exist.'
                    }
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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

function LOCALHOST_PROCEDURE_MINIKUBE-Create_Prometheus_Server_Configuration {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Create_Prometheus_Server_Configuration

.DESCRIPTION
    Creation of a configuration file and configuration map for prometheus server, 
    which are saved in the project folder and deployed to kubernetes.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
                # MiniKube deployment
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    $ProjectPath = Join-Path -Path $ProjectsPath -ChildPath  $ProjectName
                    if(Test-Path $ProjectPath){
                        cd $ProjectPath

                        # Create paths
                        $ProjectPrometheusPath       = Join-Path -Path $ProjectPath -ChildPath 'prometheus'
                        $ProjectPrometheusConfigPath = Join-Path -Path $ProjectPrometheusPath -ChildPath 'config'
                        $PrometheusConfigYamlPath    = Join-Path -Path $ProjectPrometheusConfigPath -ChildPath 'prometheus-config.yaml'
                        $PrometheusConfigMapYamlPath = Join-Path -Path $ProjectPrometheusConfigPath -ChildPath 'prometheus-configmap.yaml'
                        $PrometheusConfigYamlContent = (
@'
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-server-conf
  labels:
    app: prometheus
data:
  prometheus.yml: |-
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'kubernetes-apiservers'
        kubernetes_sd_configs:
        - role: endpoints
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        relabel_configs:
        - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
          action: keep
          regex: default;kubernetes;https
      - job_name: 'kubernetes-nodes'
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        kubernetes_sd_configs:
        - role: node
        relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
        - target_label: __address__
          replacement: kubernetes.default.svc:443
        - source_labels: [__meta_kubernetes_node_name]
          regex: (.+)
          target_label: __metrics_path__
          replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
        - role: pod
        relabel_configs:
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
          action: replace
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_pod_name]
          action: replace
          target_label: kubernetes_pod_name

'@
                        )

                        $PrometheusConfigMapYamlContent = (
@'
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-server-conf
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'kubernetes-apiservers'
        kubernetes_sd_configs:
          - role: 'endpoints'
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: true
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        relabel_configs:
          - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
            action: keep
            regex: default;kubernetes;https
      - job_name: 'kubernetes-nodes'
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: true
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        kubernetes_sd_configs:
          - role: node
        relabel_configs:
          - action: labelmap
            regex: __meta_kubernetes_node_label_(.+)
          - target_label: __address__
            replacement: kubernetes.default.svc:443
          - source_labels: [__meta_kubernetes_node_name]
            regex: (.+)
            target_label: __metrics_path__
            replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor
      - job_name: 'kubernetes-pods'
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: true
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - action: labelmap
            regex: __meta_kubernetes_pod_label_(.+)
          - target_label: __address__
            replacement: kubernetes.default.svc:443
          - source_labels: [__meta_kubernetes_pod_name, __meta_kubernetes_namespace]
            action: keep
          - source_labels: [__meta_kubernetes_pod_container_name]
            regex: (.+)
            target_label: container_name
          - action: replace
            target_label: __address__
            replacement: kubernetes.default.svc:443
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            target_label: __address__
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
          - source_labels: [__meta_kubernetes_namespace]
            action: replace
            target_label: kubernetes_namespace
          - source_labels: [__meta_kubernetes_pod_name]
            action: replace
            target_label: kubernetes_pod_name

'@
                        )

                        # Create prometheus directory
                        if(Test-Path $ProjectPrometheusPath){
                            # pass
                        }
                        else{
                            $NewItem = New-Item -ItemType Directory -Path $ProjectPrometheusPath -Force -Verbose
                        }

                        # Create prometheus config directory
                        if(Test-Path $ProjectPrometheusConfigPath){
                            # pass
                        }
                        else{
                            $NewItem = New-Item -ItemType Directory -Path $ProjectPrometheusConfigPath -Force -Verbose
                        }

                        # Create prometheus-config.yaml file
                        if(Test-Path $PrometheusConfigYamlPath){
                            $SetContent = Set-Content -Path $PrometheusConfigYamlPath -Value $PrometheusConfigYamlContent -Force -Verbose
                        }
                        else{
                            $NewItem    = New-Item -ItemType File -Path $PrometheusConfigYamlPath -Force -Verbose
                            $SetContent = Set-Content -Path $PrometheusConfigYamlPath -Value $PrometheusConfigYamlContent -Force -Verbose
                        }

                        # Create prometheus-configmap.yaml file
                        if(Test-Path $PrometheusConfigMapYamlPath){
                            $SetContent = Set-Content -Path $PrometheusConfigMapYamlPath -Value $PrometheusConfigMapYamlContent -Force -Verbose
                        }
                        else{
                            $NewItem    = New-Item -ItemType File -Path $PrometheusConfigMapYamlPath -Force -Verbose
                            $SetContent = Set-Content -Path $PrometheusConfigMapYamlPath -Value $PrometheusConfigMapYamlContent -Force -Verbose
                        }

                        $ServiceAccountCondition         = @()
                        $KubeCtlGetServiceAccounts       = @()
                        $KubeCtlCreatePrometheusConfig   = @()
                        $KubeCtlApplyPrometheusConfigMap = @()

                        # Get service account list
                        $KubeCtlGetServiceAccounts += kubectl get serviceaccounts

                        # Write output
                        foreach($Output in $KubeCtlGetServiceAccounts){
                            Write-Host $Output
                        }

                        # Find current service account
                        foreach($ServiceAccount in $KubeCtlGetServiceAccounts){
                            if($ServiceAccount -match 'prometheus-server'){
                                $ServiceAccountCondition += $True
                            }
                            else{
                                $ServiceAccountCondition += $False
                            }
                        }

                        # Compare service accounts condition
                        if($ServiceAccountCondition.Count -gt 1){
                            if($ServiceAccountCondition -match $True){
                                Write-Host 'Service observability stack now creates the prometheus configuration.'
                                cd $ProjectPrometheusConfigPath
                                $KubeCtlCreatePrometheusConfig += kubectl create -f prometheus-config.yaml
                                $KubeCtlApplyPrometheusConfigMap += kubectl apply -f prometheus-configmap.yaml
                            }
                            else{
                                Write-Warning 'Service deployment for prometheus-server is not exists.'
                            }
                        }
                        elseif($ServiceAccountCondition.Count -eq 1){
                            if($ServiceAccountCondition -match $True){
                                Write-Host 'Service observability stack now creates the prometheus configuration.'
                                cd $ProjectPrometheusConfigPath
                                $KubeCtlCreatePrometheusConfig += kubectl create -f prometheus-config.yaml
                                $KubeCtlApplyPrometheusConfigMap += kubectl apply -f prometheus-configmap.yaml
                            }
                            else{
                                Write-Warning 'Service deployment for prometheus-server is not exists.'
                            }
                        }
                        else{
                            Write-Warning 'The result for comparing service accounts is not valid.'
                        }

                        # Write output
                        foreach($Output in $KubeCtlCreatePrometheusConfig){
                            Write-Host $Output
                        }

                        # Write output
                        foreach($Output in $KubeCtlApplyPrometheusConfigMap){
                            Write-Host $Output
                        }

                    }
                    else{
                        Write-Warning 'Project: '+$ProjectPath+'is not exist.'
                    }
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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



# KUBERNETES OBSERVABILITY STACK GET METRIC DATA
function LOCALHOST_PROCEDURE_MINIKUBE-Get_Prometheus_Server_Metrics {
<#
.SYNOPSIS
    Procedure definition:
    LOCALHOST_PROCEDURE_MINIKUBE-Create_Prometheus_Server_Tunnel

.DESCRIPTION
    In the new session, we create a tunnel between the session and the prometheus-server.
    With this we establish a hard connection and call metrics from prometheus.

.PARAMETER OperatingSystem
    String - The operating system parameter specifies which operating system is initialized when the function
    is run, and the function can respond with a specific command format for that operating system.

.PARAMETER BuildData
    PSCustomObject shared output from Build-Project_Environment.

.PARAMETER MeasureDuration
    Condition boolean for generating the function speed measurement result to the console as write-host.

.PARAMETER ExtraData
    PSCustomObject - The extra data parameter specifies whether extra data is available for the implementation, 
    otherwise it is null. This parameter is only used for specific functions for better automation using a configuration file.

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
        [AllowNull()]
        [Parameter(Position=2,Mandatory=$True)]
        [PSCustomObject]$ProcedureData,
        [Parameter(Position=3,Mandatory=$True)]
        [Boolean]$MeasureDuration
    )
    begin{
        $DurationBegin = Measure-Command -Expression {
            # Preparation and validation
            if($OperatingSystem -eq 'Linux'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'MacOS'){
                $Condition = $True
            }
            elseif($OperatingSystem -eq 'Windows'){
                $Condition = $True

                # MiniKube cluster availability verification
                $MiniKubeStatus = LOCALHOST_PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
                
                # MiniKube deployment
                if(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Running' -and
                    $MiniKubeStatus.ApiServer -eq 'Running' -and
                    $MiniKubeStatus.Config -eq 'Configured'
                ){
                    $ProjectPath = Join-Path -Path $ProjectsPath -ChildPath $ProjectName
                    if(Test-Path $ProjectPath){
                        cd $ProjectPath
                        
                        # Procedure variables
                        $CommandType   = 'Decode-Command'
                        $AppName       = $ProcedureData.AppName
                        $Namespace     = $ProcedureData.Namespace
                        $ContainerName = $ProcedureData.ContainerName
                        $Ports         = $ProcedureData.Ports
                        $Url           = $ProcedureData.Url
                        $WindowStyle   = $ProcedureData.WindowStyle

                        # Create paths
                        $ProjectPrometheusPath              = Join-Path -Path $ProjectPath -ChildPath 'prometheus'
                        $ProjectPrometheusMetricsPath       = Join-Path -Path $ProjectPrometheusPath -ChildPath 'metrics'
                        $ProjectPrometheusContainerNamePath = Join-Path -Path $ProjectPrometheusMetricsPath -ChildPath $ContainerName

                        # Create prometheus directory
                        if(Test-Path $ProjectPrometheusPath){
                            # pass
                        }
                        else{
                            $NewItem = New-Item -ItemType Directory -Path $ProjectPrometheusPath -Force -Verbose
                        }

                        # Create prometheus metrics directory
                        if(Test-Path $ProjectPrometheusMetricsPath){
                            # pass
                        }
                        else{
                            $NewItem = New-Item -ItemType Directory -Path $ProjectPrometheusMetricsPath -Force -Verbose
                        }

                        # Create prometheus pod name metrics directory
                        if(Test-Path $ProjectPrometheusContainerNamePath){
                            # pass
                        }
                        else{
                            $NewItem = New-Item -ItemType Directory -Path $ProjectPrometheusContainerNamePath -Force -Verbose
                        }
                       
                        $ServiceAccountCondition   = @()
                        $KubeCtlGetServiceAccounts = @()
                        $PodCondition   = @()
                        $KubeCtlGetPods = @()

                        # Get service account list
                        $KubeCtlGetServiceAccounts += kubectl get serviceaccounts

                        # Write output
                        foreach($Output in $KubeCtlGetServiceAccounts){
                            Write-Host $Output
                        }

                        # Find current service account
                        foreach($ServiceAccount in $KubeCtlGetServiceAccounts){
                            if($ServiceAccount -match $PodName){
                                $ServiceAccountCondition += $True
                            }
                            else{
                                $ServiceAccountCondition += $False
                            }
                        }

                        # Get pods list
                        $KubeCtlGetPods += kubectl get pods

                        # Write output
                        foreach($Output in $KubeCtlGetPods){
                            Write-Host $Output
                        }

                        # Find current service account
                        foreach($Pod in $KubeCtlGetPods){
                            if($Pod -match $ContainerName){
                                $PodCondition += $True
                                $Regex = ($ContainerName+"-\w+-\w+")
                                $Match = [regex]::Match($Pod, $Regex)
                                $PodName = $Match.Value
                            }
                            else{
                                $PodCondition += $False
                            }
                        }
                        Write-Host $PodName
                        # Compare service account condition and pod condition
                        if($ServiceAccountCondition -match $True){
                            if($PodCondition -match $True){
                                # Runspace firt start
                                $RunspaceFirstStart = $True

                                # Prepare prometheus query from List Of Metric
                                foreach ($Metric in $ProcedureData.ListOfMetric){
                                    # Metric variables
                                    $MetricName = $Metric.Name
                                    $MetricType = $Metric.Type

                                    if($RunspaceProcessDetail.Condition){
                                        # pass
                                    }
                                    elseif($RunspaceFirstStart){
                                        # Create tunnel job
                                        $ScriptBlock = {
                                            $Job = Start-Job -ScriptBlock {
                                                kubectl port-forward -n importnamespace importpodname importports
                                            }
                                        } -replace 'importnamespace',$Namespace -replace 'importpodname',$PodName -replace 'importports',$Ports

                                        # Start new runspace
                                        $RunspaceProcessDetail = New-Runspace_Procedure -OperatingSystem $OperatingSystem -Name $PodName -ScriptBlock $ScriptBlock -CommandType $CommandType -WindowStyle $WindowStyle -ErrorAction SilentlyContinue
                                        $RunspaceFirstStart    = $False
                                    }
                                    else{
                                        Write-Warning 'Runspace process detail condition is false.'
                                    }
                                    
                                    # Metric path
                                    $CurrentMetricPath = Join-Path -Path $ProjectPrometheusContainerNamePath -ChildPath $MetricName

                                    # Create prometheus current metric directory
                                    if(Test-Path $CurrentMetricPath){
                                        # pass
                                    }
                                    else{
                                        $NewItem = New-Item -ItemType Directory -Path $CurrentMetricPath -Force -Verbose
                                    }

                                    $MetricConditionList = @()
                                    $RequestOutputList   = @()
                                    $QueryList           = @()

                                    # Metric methods by name
                                    if($MetricName -eq 'Cpu'){
                                        # Create metric query
                                        switch ($MetricType) {
                                            1 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'total-cpu-all-containers-in-cluster'
                                                $MetricDesc     = 'Query the total CPU usage of all containers in the cluster.'
                                                $MetricQuery    = 'container_cpu_usage_seconds_total'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            2 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'cpu-specific-container'
                                                $MetricDesc     = 'Query the CPU usage of one specific container.'
                                                $MetricQuery    = 'container_cpu_usage_seconds_total{container_name="importcontainername"}' -replace 'importcontainername',$ContainerName
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            3 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'average-cpu-all-containers-in-app'
                                                $MetricDesc     = 'Query the average CPU usage of all containers of the given application.'
                                                $MetricQuery    = 'avg(container_cpu_usage_seconds_total{namespace="importnamespace", app="importappname"})' -replace 'importnamespace',$Namespace -replace 'importappname',$AppName
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            4 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'maximum-cpu-all-containers-in-cluster'
                                                $MetricDesc     = 'Query the maximum CPU usage of containers in the cluster.'
                                                $MetricQuery    = 'max(container_cpu_usage_seconds_total)'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            5 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'total-cpu-all-containers-in-node'
                                                $MetricDesc     = 'Query the total CPU usage of all containers on a given node.'
                                                $MetricQuery    = 'sum(container_cpu_usage_seconds_total) by (node)'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            6 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'cpu-consumed-in-1h-interval'
                                                $MetricDesc     = 'Query the amount of CPU used in a given time interval.'
                                                $MetricQuery    = 'increase(container_cpu_usage_seconds_total[1h])'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            7 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'average-cpu-all-containers-in-app-in-5m-interval'
                                                $MetricDesc     = 'Query the average CPU usage of all containers of the given application in a certain time window.'
                                                $MetricQuery    = 'avg_over_time(container_cpu_usage_seconds_total{namespace="importnamespace", app="importappname"}[5m])' -replace 'importnamespace',$Namespace -replace 'importappname',$AppName
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            8 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'total-cpu-usage-in-pod-and-namespace'
                                                $MetricDesc     = 'Query the total CPU consumption of a container in a pod in a specific namespace.'
                                                $MetricQuery    = 'sum(container_cpu_usage_seconds_total{pod="importpod", namespace="importnamespace"}) by (namespace, pod, container)' -replace 'importpod',$PodName -replace 'importnamespace',$Namespace
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                        }
                                    }
                                    elseif($MetricName -eq 'Memory'){
                                        # Create metric query
                                        switch ($MetricType) {
                                            1 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'total-memory-all-containers-in-cluster'
                                                $MetricDesc     = 'Query the total memory consumption of all containers in the cluster.'
                                                $MetricQuery    = 'container_memory_usage_bytes'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            2 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'memory-specific-container'
                                                $MetricDesc     = 'Query the memory consumption of one specific container.'
                                                $MetricQuery    = 'container_memory_usage_bytes{container_name="importcontainername"}' -replace 'importcontainername',$ContainerName
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            3 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'average-memory-all-containers-in-app'
                                                $MetricDesc     = 'Query the average memory consumption of all containers of the given application.'
                                                $MetricQuery    = 'avg(container_memory_usage_bytes{namespace="importnamespace", app="importappname"})' -replace 'importnamespace',$Namespace -replace 'importappname',$AppName
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            4 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'maximum-memory-all-containers-in-cluster'
                                                $MetricDesc     = 'Query the maximum consumption of containers in the cluster.'
                                                $MetricQuery    = 'max(container_memory_usage_bytes)'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            5 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'total-memory-all-containers-in-node'
                                                $MetricDesc     = 'Query the total consumption of all containers on a given node.'
                                                $MetricQuery    = 'sum(container_memory_usage_bytes) by (node)'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            6 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'memory-consumed-in-1h-interval'
                                                $MetricDesc     = 'Query the amount of memory consumed in a given time interval.'
                                                $MetricQuery    = 'increase(container_memory_usage_bytes[1h])'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            7 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'average-memory-all-containers-in-app-in-5m-interval'
                                                $MetricDesc     = 'Query the average memory consumption of all containers of the given application in a certain time window.'
                                                $MetricQuery    = 'avg_over_time(container_memory_usage_bytes{namespace="importnamespace", app="importappname"}[5m])' -replace 'importnamespace',$Namespace -replace 'importappname',$AppName
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            8 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'total-memory-usage-in-pod-and-namespace'
                                                $MetricDesc     = 'Query the total memory consumption of a container in a pod in a specific namespace.'
                                                $MetricQuery    = 'sum(container_memory_usage_bytes{pod="importpod", namespace="importnamespace"}) by (namespace, pod, container)' -replace 'importpod',$PodName -replace 'importnamespace',$Namespace
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                        }
                                    }
                                    elseif($MetricName -eq 'HardDisk'){
                                        # Create metric query
                                        switch ($MetricType) {
                                            1 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'total-size-all-disks-in-cluster'
                                                $MetricDesc     = 'Query the total size of all disks in the cluster.'
                                                $MetricQuery    = 'node_filesystem_size_bytes'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            2 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'available-disk-space-in-specific-node'
                                                $MetricDesc     = 'Query available disk space on a given node.'
                                                $MetricQuery    = 'node_filesystem_avail_bytes{mountpoint="/mnt/disk1"}'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            3 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'total-disk-usage-in-specific-node'
                                                $MetricDesc     = 'Query the total disk usage on the given node.'
                                                $MetricQuery    = 'node_filesystem_size_bytes{mountpoint="/mnt/disk1"} - node_filesystem_avail_bytes{mountpoint="/mnt/disk1"}'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            4 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'maximum-disk-usage-in-specific-node'
                                                $MetricDesc     = 'Query the maximum disk usage on a given node.'
                                                $MetricQuery    = 'avg(node_filesystem_size_bytes{job="node-exporter", cluster="importclustername"})' -replace 'importjobname',$Namespace -replace 'importclustername',$Namespace
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            5 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'amount-disk-space-in-1h-interval'
                                                $MetricDesc     = 'Query the amount of disk space used in a given time interval.'
                                                $MetricQuery    = 'max(node_filesystem_used_bytes{mountpoint="/mnt/disk1"})'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            6 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'amount-used-disk-space-in-1h-interval'
                                                $MetricDesc     = 'Query for the amount of used disk space in a given time interval.'
                                                $MetricQuery    = 'increase(node_filesystem_size_bytes{mountpoint="/mnt/disk1"}[1h])'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            7 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'average-disk-size-in-group-nodes-in-5m-interval'
                                                $MetricDesc     = 'Query the average disk size in a given group of nodes in a specific time window.'
                                                $MetricQuery    = 'avg_over_time(node_filesystem_size_bytes{job="node-exporter", cluster="importclustername"}[5 m])' -replace 'importjobname',$Namespace -replace 'importclustername',$Namespace
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                        }
                                    }
                                    elseif($MetricName -eq 'Network'){
                                        # Create metric query
                                        switch ($MetricType) {
                                            1 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'incoming-network-traffic-in-specific-interface'
                                                $MetricDesc     = 'Query incoming network traffic on a given network interface.'
                                                $MetricQuery    = 'irate(node_network_receive_bytes_total{device="eth0"}[5m])'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            2 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'outgoing-network-traffic-in-specific-interface'
                                                $MetricDesc     = 'Query outgoing network traffic on a given network interface.'
                                                $MetricQuery    = 'irate(node_network_transmit_bytes_total{device="eth0"}[5m])'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            3 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'total-network-traffic-in-5m-interval'
                                                $MetricDesc     = 'Query the total network traffic on a given node.'
                                                $MetricQuery    = 'sum(increase(node_network_receive_bytes_total[5m]))%20%2B%20sum(increase(node_network_transmit_bytes_total[5m]))'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            4 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'average-speed-network-traffic-in-5m-interval'
                                                $MetricDesc     = 'Query the average speed of network traffic in a given time interval.'
                                                $MetricQuery    = 'avg_over_time(rate(node_network_receive_bytes_total[5m])[5m:])%20%2B%20avg_over_time(rate(node_network_transmit_bytes_total[5m])[5m:])'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            5 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'number-connections-in-node'
                                                $MetricDesc     = 'Query the number of connections on a given node.'
                                                $MetricQuery    = 'node_netstat_Tcp_established'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            6 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'average-number-connections-in-group-node'
                                                $MetricDesc     = 'Query the average number of connections in a given group of nodes.'
                                                $MetricQuery    = 'avg(node_netstat_Tcp_established{job="node-exporter", cluster="importclustername"})' -replace 'importjobname',$Namespace -replace 'importclustername',$Namespace
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                            7 {
                                                $MetricConditionList += $True
                                                $MetricTypeName = 'number-connections-in-1h-interval'
                                                $MetricDesc     = 'Query the number of connections in a given time interval.'
                                                $MetricQuery    = 'increase(node_netstat_Tcp_established[1h])'
                                                $QueryUri       = "$Url/api/v1/query?query=$MetricQuery"
                                                $QueryPSCO      = [PSCustomObject]@{
                                                    Type = $MetricTypeName
                                                    Desc = $MetricDesc
                                                    Uri  = $QueryUri
                                                }
                                                $QueryList += $QueryPSCO
                                            }
                                        }
                                    }
                                    else{
                                        $MetricConditionList += $False
                                    }
                                    Write-Host $QueryUriList
                                    # Metric methods condition
                                    if($MetricConditionList.Count -gt 1){
                                        if($null -eq $($MetricConditionList -match $False)){
                                            $MetricCondition = $True
                                        }
                                        else{
                                            $MetricCondition = $False
                                        }
                                    }
                                    elseif($MetricConditionList.Count -eq 1){
                                        if($MetricConditionList){
                                            $MetricCondition = $True
                                        }
                                        else{
                                            $MetricCondition = $False
                                        }
                                    }
                                    else{
                                        $MetricCondition = $False
                                    }
                                    
                                    # Metric methods condition
                                    if($MetricCondition){
                                        foreach($QueryItem in $QueryList){
                                            # Get Query items
                                            $QueryItemTypeName = $QueryItem.Type
                                            $QueryItemDesc     = $QueryItem.Desc
                                            $QueryItemUri      = $QueryItem.Uri
                                            
                                            Write-Host $QueryItemTypeName
                                            Write-Host $QueryItemDesc

                                            # Get metrics
                                            $RequestOutput = Invoke-RestMethod -Method GET -Uri $QueryItemUri -Verbose
                                            $RequestOutputList += $RequestOutput

                                            # Metric method type path
                                            $MetricMethodTypePath = $CurrentMetricItemPath = Join-Path -Path $CurrentMetricPath -ChildPath $QueryItemTypeName

                                            # Create prometheus specific method type metric directory
                                            if(Test-Path $MetricMethodTypePath){
                                                # pass
                                            }
                                            else{
                                                $NewItem = New-Item -ItemType Directory -Path $MetricMethodTypePath -Force -Verbose
                                            }

                                            # Get ticks
                                            [string]$Ticks = (Get-Date).Ticks

                                            # Create file name
                                            $MetricFileName = $Ticks+'.json'

                                            # Metric item path
                                            $CurrentMetricItemPath = Join-Path -Path $MetricMethodTypePath -ChildPath $MetricFileName

                                            # Query processor 
                                            if($RequestOutput.Status -eq 'Success'){
                                                # Convert metric data to json
                                                $RequestJson = $RequestOutput | ConvertTo-Json -Depth 100

                                                # Create Metric item file
                                                if(Test-Path $CurrentMetricItemPath){
                                                    $SetContent = Set-Content -Path $CurrentMetricItemPath -Value $RequestJson -Force -Verbose
                                                }
                                                else{
                                                    $NewItem    = New-Item -ItemType File -Path $CurrentMetricItemPath -Force -Verbose
                                                    $SetContent = Set-Content -Path $CurrentMetricItemPath -Value $RequestJson -Force -Verbose
                                                }
                                            }
                                            else{
                                                Write-Warning ('The query could not be retrieved.')
                                            }
                                        }
                                    }
                                    else{
                                        Write-Warning ('Metric condition is not valid.')
                                    }
                                }

                                # Kill runspace process
                                KILL $RunspaceProcessDetail.ProcessID
                            }
                            else{
                                Write-Warning 'Pod for '+$PodName+' is not exists.'
                            }
                        }
                        else{
                            Write-Warning 'Service deployment for '+$PodName+' is not exists.'
                        }

                    }
                    else{
                        Write-Warning 'Project: '+$ProjectPath+'is not exist.'
                    }
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Running' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Paused' -and
                    $MiniKubeStatus.Config -eq 'Configured'        
                ){
                    Write-Host 'MiniKube cluster is suspended.'
                }
                elseif(
                    $MiniKubeStatus.Type -eq 'Control Plane' -and
                    $MiniKubeStatus.Host -eq 'Stopped' -and
                    $MiniKubeStatus.KubeLet -eq 'Stopped' -and
                    $MiniKubeStatus.ApiServer -eq 'Stopped' -and
                    $MiniKubeStatus.Config -eq 'Stopped'        
                ){
                    Write-Host 'MiniKube cluster is already shut down.'
                }    
                else{
                    Write-Warning 'MiniKube cluster result does not match the conditions.'
                }

                Write-Host ''
            }
            else{
                $Condition = $False
            }
        }
    }
    process{
        $DurationProcess = Measure-Command -Expression {
            if($Condition){
                $Result = 'Success'
            }
            else{
                $Result = 'Failed'
            }
            Write-Host ('[Result] >>>')
            Write-Host $Result
        }
    }
    end{
        $DurationTotal = $DurationBegin+$DurationProcess
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


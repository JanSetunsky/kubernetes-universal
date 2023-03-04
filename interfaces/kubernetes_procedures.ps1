# KUBERNETES CLUSTER MANAGEMENT
function PROCEDURE_MINIKUBE-Start_Local_Cluster {
<#
.SYNOPSIS
    Procedure definition:
    PROCEDURE_Start-MiniKube_cluster

.DESCRIPTION
    First, the status of the cluster is determined, if it is available, and then 
    the start of the cluster itself is started, otherwise the cluster is already running.

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
                $MiniKubeStatus = PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
                Write-Host $MiniKubeStatus

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
                    Write-Host 'MiniKube cluster cannot be started.'
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

function PROCEDURE_MINIKUBE-Stop_Local_Cluster {
<#
.SYNOPSIS
    Procedure definition:
    PROCEDURE_Stop-MiniKube_cluster

.DESCRIPTION
    First, the status of the cluster is determined, whether it is available, and then 
    the termination of the cluster itself is triggered, otherwise the cluster is shut down.

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
                $MiniKubeStatus = PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
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

function PROCEDURE_MINIKUBE-Delete_Local_Cluster {
<#
.SYNOPSIS
    Procedure definition:
    PROCEDURE_Stop-MiniKube_cluster

.DESCRIPTION
    First, the status of the cluster is determined, whether it is available, and then 
    the termination of the cluster itself is triggered, otherwise the cluster is shut down.

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
                $MiniKubeStatus = PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
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

function PROCEDURE_MINIKUBE-Get_Local_Cluster_Status {
<#
.SYNOPSIS
    Procedure definition:
    PROCEDURE_Get-MiniKube_cluster_Status

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
function PROCEDURE_MINIKUBE-Deploy_Nginx_Image {
<#
.SYNOPSIS
    Procedure definition:
    PROCEDURE_Deploy-MiniKube_NGINX_DEMO

.DESCRIPTION
    This function deploys NGINX DEMO to kubernetes.
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
                $MiniKubeStatus = PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
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

function PROCEDURE_MINIKUBE-Update_Nginx_Image {
<#
.SYNOPSIS
    Procedure definition:
    PROCEDURE_Deploy-MiniKube_NGINX_DEMO

.DESCRIPTION
    This function deploys NGINX DEMO to kubernetes.
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
                $MiniKubeStatus = PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
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

function PROCEDURE_MINIKUBE-Delete_Nginx_Image {
<#
.SYNOPSIS
    Procedure definition:
    PROCEDURE_Delete-MiniKube_NGINX_DEMO

.DESCRIPTION
    After deploying NGINX DEMO, this function will uninstall the nginx demo deployment including the service.

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
                $MiniKubeStatus = PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
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

function PROCEDURE_MINIKUBE-Get_Nginx_Service {
<#
.SYNOPSIS
    Procedure definition:
    PROCEDURE_Get-Services_MiniKube_NGINX_DEMO

.DESCRIPTION
    After deploying NGINX DEMO to kubernetes, this function checks if the nginx demo deployment and service are available.

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
                $MiniKubeStatus = PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
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



# KUBERNETES MONITORING STACK
function PROCEDURE_MINIKUBE-Helm_Install_Prometheus {
<#
.SYNOPSIS
    Procedure definition:
    PROCEDURE_Helm-Install_Prometheus

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
                $MiniKubeStatus = PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
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
                            $StackFullName = $ProcedureData.FullName
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

function PROCEDURE_MINIKUBE-Helm_Install_Grafana {
<#
.SYNOPSIS
    Procedure definition:
    PROCEDURE_Helm-Install_Prometheus

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
                $MiniKubeStatus = PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
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
                            $StackFullName = $ProcedureData.FullName
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

function PROCEDURE_MINIKUBE-Helm_Deploy_Prometheus_Grafana {
<#
.SYNOPSIS
    Procedure definition:
    PROCEDURE_Helm-Deploy_Prometheus_And_Grafana

.DESCRIPTION
    Deploying prometheus and grafana to the minicube.

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
                $MiniKubeStatus = PROCEDURE_MINIKUBE-Get_Local_Cluster_Status -OperatingSystem $OperatingSystem -BuildData $BuildData -ProcedureData $ProcedureData -MeasureDuration $MeasureDuration -ErrorAction SilentlyContinue
            
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

                        $HelmDeployMonitoring = @()

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
                            # Procedure data
                            $KubernetesDashboard  = $ProcedureData.KubernetesDashboard
                            $MonitoringStandalone = $ProcedureData.MonitoringStandalone

                            # Installation
                            $HelmDeployMonitoring += kubectl create -f $KubernetesDashboard --validate=false
                            $HelmDeployMonitoring += kubectl create -f $MonitoringStandalone --validate=false

                            # Write output
                            foreach($Output in $HelmDeployMonitoring){
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

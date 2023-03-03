#region >> [ CONFIRM MINIKUBE SERVER STATUS PROCESS ]
$CONFIRM_MINIKUBE_SERVER_STATUS_SC = {
    $MiniKubeStatus        = minikube status
    $MiniKubeType          = $MiniKubeStatus[1]
    $MiniKubeHost          = $MiniKubeStatus[2]
    $MiniKubeKubeLet       = $MiniKubeStatus[3]
    $MiniKubeApiServer     = $MiniKubeStatus[4]
    $MiniKubeKubeConfig    = $MiniKubeStatus[5]
    $MiniKubeConditionList = @()

    if($MiniKubeType -match 'Control Plane'){
        $MiniKubeType = 'Control Plane'
        $MiniKubeConditionList += $True
    }
    else{
        $MiniKubeType = 'Uknown'
        $MiniKubeConditionList += $False
    }

    if($MiniKubeHost -match 'Stopped'){
        $MiniKubeHost = 'Stopped'
        $MiniKubeConditionList += $False
    }
    elseif($MiniKubeHost -match 'Running'){
        $MiniKubeHost = 'Running'
        $MiniKubeConditionList += $True
    }
    else{
        $MiniKubeHost = 'Uknown'
        $MiniKubeConditionList += $False
    }

    if($MiniKubeKubeLet -match 'Stopped'){
        $MiniKubeKubeLet = 'Stopped'
        $MiniKubeConditionList += $False
    }
    elseif($MiniKubeKubeLet -match 'Running'){
        $MiniKubeKubeLet = 'Running'
        $MiniKubeConditionList += $True
    }    
    else{
        $MiniKubeKubeLet = 'Uknown'
        $MiniKubeConditionList += $False
    }

    if($MiniKubeApiServer -match 'Stopped'){
        $MiniKubeApiServer = 'Stopped'
        $MiniKubeConditionList += $False
    }
    elseif($MiniKubeApiServer -match 'Running'){
        $MiniKubeApiServer = 'Running'
        $MiniKubeConditionList += $True
    }
    else{
        $MiniKubeApiServer = 'Uknown'
        $MiniKubeConditionList += $False
    }

    if($MiniKubeKubeConfig -match 'Stopped'){
        $MiniKubeKubeConfig = 'Stopped'
        $MiniKubeConditionList += $False
    }
    elseif($MiniKubeKubeConfig -match 'Configured'){
        $MiniKubeKubeConfig = 'Configured'
        $MiniKubeConditionList += $True
    }
    else{
        $MiniKubeKubeConfig = 'Uknown'
        $MiniKubeConditionList += $False
    }

    if($null -eq $($MiniKubeConditionList -eq $False)){
        $CONFIRM_MINIKUBE_SERVER_STATUS_OUTPUT = [PSCustomObject]@{
            Type       = $MiniKubeType
            Host       = $MiniKubeHost
            KubeLet    = $MiniKubeKubeLet
            ApiServer  = $MiniKubeApiServer
            KubeConfig = $MiniKubeKubeConfig
            Condition  = $True
        }
    }
    else{
        $CONFIRM_MINIKUBE_SERVER_STATUS_OUTPUT = [PSCustomObject]@{
            Type       = $MiniKubeType
            Host       = $MiniKubeHost
            KubeLet    = $MiniKubeKubeLet
            ApiServer  = $MiniKubeApiServer
            KubeConfig = $MiniKubeKubeConfig
            Condition  = $False
        }
    }

    Write-Host ('IsRunning: '+$CONFIRM_MINIKUBE_SERVER_STATUS_OUTPUT.Condition)
    Write-Host ''
}
#endregion [ CONFIRM MINIKUBE SERVER STATUS PROCESS ]

#region >> [ CONFIRM MINIKUBE SERVER STATUS SWITCH ]
$CONFIRM_MINIKUBE_SERVER_STATUS_SWITCH_SC = {
    switch (1) {
        1 { $CONFIRM_MINIKUBE_SERVER_STATUS_SC | iex -ErrorAction SilentlyContinue }
    }
}
#endregion [ CONFIRM MINIKUBE SERVER STATUS SWITCH ]
$CONFIRM_MINIKUBE_SERVER_STATUS_SWITCH_SC | iex -ErrorAction SilentlyContinue


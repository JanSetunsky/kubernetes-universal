#region >> [ GET MINIKUBE SERVER STATUS PROCESS ]
$GET_MINIKUBE_SERVER_STATUS_SC = {
    $MiniKubeStatus     = minikube status
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

    foreach($Output in $MiniKubeStatus){
        Write-Host $Output
    }

    $GET_MINIKUBE_SERVER_STATUS_OUTPUT = [PSCustomObject]@{
        Type       = $MiniKubeType
        Host       = $MiniKubeHost
        KubeLet    = $MiniKubeKubeLet
        ApiServer  = $MiniKubeApiServer
        KubeConfig = $MiniKubeKubeConfig
    }
}
#endregion [ GET MINIKUBE SERVER STATUS PROCESS ]

#region >> [ GET MINIKUBE SERVER STATUS SWITCH ]
$GET_MINIKUBE_SERVER_STATUS_SWITCH_SC = {
    switch (1) {
        1 { $GET_MINIKUBE_SERVER_STATUS_SC | iex -ErrorAction SilentlyContinue }
    }
}
#endregion [ GET MINIKUBE SERVER STATUS SWITCH ]
$GET_MINIKUBE_SERVER_STATUS_SWITCH_SC | iex -ErrorAction SilentlyContinue


#region >> [ START MINIKUBE SERVER PROCESS ]
$START_MINIKUBE_SERVER_SC = {
    if(
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.Type -eq 'Control Plane' -and
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.Host -eq 'Running' -and
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.KubeLet -eq 'Running' -and
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.ApiServer -eq 'Running' -and
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.KubeConfig -eq 'Configured'
    ){
        Write-Host 'MiniKube server is already running.'
    }
    elseif(
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.Type -eq 'Control Plane' -and
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.Host -eq 'Stopped' -and
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.KubeLet -eq 'Stopped' -and
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.ApiServer -eq 'Stopped' -and
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.KubeConfig -eq 'Stopped'        
    ){
        Write-Host 'MiniKube server has started running.'
        $MiniKubeStart = minikube start
    }    
    else{
        Write-Host 'MiniKube server result does not match the conditions.'
    }
    foreach($Output in $MiniKubeStart){
        Write-Host $Output
    }
    Write-Host ''
}
#endregion [ START MINIKUBE SERVER PROCESS ]

#region >> [ START MINIKUBE SERVER SWITCH ]
$START_MINKUBE_SERVER_SWITCH_SC = {
    switch (1) {
        1 { $START_MINIKUBE_SERVER_SC | iex -ErrorAction SilentlyContinue }
    }
}
#endregion [ START MINIKUBE SERVER SWITCH ]
$START_MINKUBE_SERVER_SWITCH_SC | iex -ErrorAction SilentlyContinue
#region >> [ STOP MINIKUBE SERVER PROCESS ]
$STOP_MINIKUBE_SERVER_SC = {
    if(
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.Type -eq 'Control Plane' -and
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.Host -eq 'Running' -and
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.KubeLet -eq 'Running' -and
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.ApiServer -eq 'Running' -and
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.KubeConfig -eq 'Configured'
    ){
        Write-Host 'MiniKube server will be shut down.'
        $MiniKubeStop = minikube stop
    }
    elseif(
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.Type -eq 'Control Plane' -and
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.Host -eq 'Stopped' -and
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.KubeLet -eq 'Stopped' -and
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.ApiServer -eq 'Stopped' -and
        $GET_MINIKUBE_SERVER_STATUS_OUTPUT.KubeConfig -eq 'Stopped'        
    ){
        Write-Host 'MiniKube server is already shut down.'
    }    
    else{
        Write-Host 'MiniKube server result does not match the conditions.'
    }
    foreach($Output in $MiniKubeStop){
        Write-Host $Output
    }
}
#endregion [ STOP MINIKUBE SERVER PROCESS ]

#region >> [ STOP MINIKUBE SERVER SWITCH ]
$STOP_MINKUBE_SERVER_SWITCH_SC = {
    switch (1) {
        1 { $STOP_MINIKUBE_SERVER_SC | iex -ErrorAction SilentlyContinue }
    }
}
#endregion [ STOP MINIKUBE SERVER SWITCH ]
$STOP_MINKUBE_SERVER_SWITCH_SC | iex -ErrorAction SilentlyContinue
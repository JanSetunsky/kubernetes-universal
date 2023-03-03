#region >> [ DEPLOY NGINX DEMO FOR MINIKUBE PROCESS ]
$DEPLOY_NGINX_DEMO_FOR_MINIKUBE_SC = {
    $ProjectPath = Join-Path -Path $ProjectsPath -ChildPath  $ProjectName
    if(Test-Path $ProjectPath){
        cd $ProjectPath
        # Create deployment
        kubectl create deployment nginxdemos --image=docker.io/nginxdemos/nginx-hello:plain-text
        kubectl expose deployment nginxdemos --type=NodePort --port=80
        
    }
    else{

    }

    foreach($Output in $MiniKubeStatus){
        Write-Host $Output
    }
}
#endregion [ DEPLOY NGINX DEMO FOR MINIKUBE PROCESS ]

#region >> [ DEPLOY NGINX DEMO FOR MINIKUBE SWITCH ]
$DEPLOY_NGINX_DEMO_FOR_MINIKUBE_SWITCH_SC = {
    switch (1) {
        1 { $DEPLOY_NGINX_DEMO_FOR_MINIKUBE_SC | iex -ErrorAction SilentlyContinue }
    }
}
#endregion [ DEPLOY NGINX DEMO FOR MINIKUBE SWITCH ]
$DEPLOY_NGINX_DEMO_FOR_MINIKUBE_SWITCH_SC | iex -ErrorAction SilentlyContinue


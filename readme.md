# kubernetes-universal

This is a demonstration of how to build a universal environment for deploying, for example, 
Kubernetes, or others, and managing automation operations with the DevOps CI/CD method.
All automation processes can be automated from A to Z using procedures. 

## The lifecycle of an application build

### Environment configuration file

First of all, we need to fill in a configuration file that represents the local or shared 
system environment where the entire application development cycle takes place.

You can see an example of this in the `environment/config.json` file.

### Dependency environment database

Next, we need to populate the database configuration files that represent local and/or shared configuration dependencies.
They are `.db/modules.json` , `.db/packages.json` , `.db/github.json` and `.db/gitlab.json` files

#### GitHub and GitLab

These files, in turn, represent the names of the repositories on the GitHub and GitLab cloud infrastructure, and when they are filled in, they will be initialized, installed, or downloaded. It's still in development and not all traffic ependencies are programmed yet, but I'm working hard on it.

#### Modules 

Modules represent PowerShell module manifests. If you fill in the modules, you will be prompted to confirm the installation of the modules when you run this installation.

#### Packages 

Packages represent application names and their installation scheme. If you fill in the packages, you will be prompted to confirm the installation of the packages when you run this installation.

### Installation

There are two installation options, which can be found in the setup folder. There is either `.setup/install_environment.ps1` or `.setup/fullautomation.ps1`.

If we choose `.setup/install_environment.ps1`, the basic dependencies will be installed and then it is possible to manually test the functions found in all `.libraries/kubernetes/*`. You just need to invoke these functions with the `pwsh 'file path' method, for example.

If we choose `.setup/ifullautomation.ps1`, all dependencies will be installed, prometheus and grafana will be deployed, and the nginx web server will be deployed.

Part of the installation is the creation of the runspace folder, where the projects folder is created automatically and where your project is created under the name ProjectName, which is part of the configuration file.

A new `.runspace/projects/project_name/config.json` file will be created with your project to store the project data, including the necessary dependency data. Log files and all current dependencies that are written to local disk will also be stored here.

### Functions

Functions that are part of kubernetes-universal are located centrally in folder`.interfaces/*`.
The main functions for creating and controlling the environment are located in the file `.interfaces/core.ps1`. Functions include SYNOPSIS, DESCRIPTION, PARAMETER, EXAMPLE, INPUTS, and OUTPUTS.

Here we find files with the names:
`.interfaces/installation_definition.ps1`
`.interfaces/installation_verification.ps1`
These script blocks are used for routine data definition, file paths and installation verification.
They are separated in this way to shorten the routine installation code, since the same processes are repeated over and over again.

Here we find files with the names:
`.interfaces/kubernetes_verification.ps1`
`.interfaces/kubernetes_definition.ps1`
These files represent the routine definition and verification of the built project/project environment in the game `.runspace/project_name/config.json` and are no longer installed.

### Procedures

The `.interfaces/kubernetes_procedures.ps1` file contains automation routines that are called from the project configuration file.
This makes it possible to share additional data in the configuration file, for example as follows:
`
{
    "Name": "LOCALHOST_PROCEDURE_MINIKUBE-Helm_Install_Prometheus",
    "MD": false,
    "Data":[{
        "StackName": "prometheus",
        "StackFullName": "prometheus-community",
        "StackUri": "https://prometheus-community.github.io/helm-charts"
    }]
}
`
This means that we can pass data to procedures using date and other variables. Thanks to this, we can pass variables directly to procedures and thus create universal functions.

The `.environment/config.json` file contains a section called ListOfProcedures where the given input syntax must be followed and where the procedures for automating the DevOps CI/CD operation are specified.

These procedures trigger specific functions where we can create specific routine processes for a given automation of DevOps development activities.


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

After creating the environment, we can start the installation. If you use the configuration file that is included in the `.Environment/...` folder, the environment will be installed on the local disk and your computer will be ready to run kubernetes using the MiniKube application that I chose for testing.

Part of the installation is the creation of the runspace folder, where the projects folder is created automatically and where your project is created under the name ProjectName, which is part of the configuration file.

A new `./config.json` file will be created with your project, where the data between the configuration file from `.environment/config.json` and the database files will be validated.

This is a test version and always before starting MiniKube, it is necessary to run the file `.install.ps1` which initializes and updates the environment so that a file such as `.start.ps1` can be run

### Functions

The `.functions.ps1` file contains all the functions that are part of the environment installation automation. All features have a brief SYNOPSIS,DESCRIPTION,PARAMETER,EXAMPLE,INPUTS and OUTPUTS.

### Procedures

The `.environment/config.json` file includes a section named ListOfProcedures where the given input syntax must be followed and where the DevOps CI/CD operation automation procedures are specified.

The `.environment/config.json` file contains a section called ListOfProcedures where the given input syntax must be followed and where the procedures for automating the DevOps CI/CD operation are specified.

These procedures run specific functions from the `.procedures.ps1` file, where we can create specific functions for a given automation of routine activities for DevOps operation.

### Start,Stop,Deploy,Delete

The environment includes 4 basic launchers for starting MiniKube, stopping MiniKube, deploying nginx-demo, deleting nginx-demo.
Over time I will create more universal functions and move the configuration elements to the `.environment/config.json side of the configuration file.
# Build Steps for Creating Immutable VM Images

## Overview

The AppDynamics Cloud Kickstart project enables an IT Administrator, Software Developer, or DevOps engineer to 
automate the building of immutable VM images using open source tools from [HashiCorp](https://www.hashicorp.com/). 
Currently, the VMs consist of these types:

-	__APM-Platform VM__: An APM Platform stand-alone VM designed for Application Performance Monitoring. It consists of the AppDynamics Enterprise Console, Controller, and Events Service.
-	__CWOM-Platform VM__: A Cisco Workload Optimization Manager (CWOM) stand-alone VM designed for Intelligent Workload Management. It consists of the CWOM Platform server.
-	__LPAD VM__: An AWS EC2 'Launchpad' VM with pre-configured tooling for Kubernetes and Serverless CLI Operations.

## Installation Instructions - macOS

To build the AppD Cloud Kickstart VM images, the following open source software needs to be installed on the host macOS machine:

-	Homebrew 3.0.11
-	Git 2.31.1
-	Packer 1.7.2
-	Terraform 0.14.10
-	jq 1.6

Perform the following steps to install the needed software:

1.	Install the [Homebrew 3.0.11](https://brew.sh/) package manager for macOS 64-bit. Paste the following into a macOS Terminal prompt:  
    ```bash
    $ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    ```

2.	Install [Git 2.31.1](https://git-scm.com/downloads) for macOS 64-bit.  
    ```bash
    $ brew install git
    ```

3.	Install [Packer 1.7.2](https://www.packer.io/downloads.html) for macOS 64-bit.  
    ```bash
    $ brew tap hashicorp/tap
    $ brew install hashicorp/tap/packer
    ```

4.	Install [Terraform 0.14.10](https://www.terraform.io/downloads.html) for macOS 64-bit.  
    ```bash
    $ brew tap hashicorp/tap
    $ brew install hashicorp/tap/terraform
    ```

5.	Install [jq 1.6](https://stedolan.github.io/jq/) for macOS 64-bit.  
    `$ brew install jq`  

### Configuration and Validation - macOS

1.	Validate installed command-line tools:

    ```bash
    $ brew --version
    Homebrew 3.0.11
    $ brew doctor
    Your system is ready to brew.

    $ git --version
    git version 2.31.1

    $ packer --version
    1.7.2

    $ terraform --version
    Terraform v0.14.10

    $ jq --version
    jq-1.6
    ```

2.	Configure Git for local user:

    ```bash
    $ git config --global user.name "<first_name> <last_name>"
    $ git config --global user.email "<your_email>"
    $ git config --global --list
    ```

## Installation Instructions - Windows 64-Bit

To build the AppD Cloud Kickstart immutable VM images, the following open source software needs to be installed on the host Windows machine:

-	Git 2.31.1 for Win64
-	Packer 1.7.2
-	Terraform 0.14.10
-	jq 1.6

Perform the following steps to install the needed software:

1.	Install [Git 2.31.1](https://github.com/git-for-windows/git/releases/download/v2.31.1.windows.1/Git-2.31.1-64-bit.exe) for Windows 64-bit.

2.	Install [Packer 1.7.2](https://releases.hashicorp.com/packer/1.7.2/packer_1.7.2_windows_amd64.zip) for Windows 64-bit.  
    Create suggested install folder and extract contents of ZIP file to:  
    `C:\HashiCorp\bin`  

3.	Install [Terraform 0.14.10](https://releases.hashicorp.com/terraform/0.14.10/terraform_0.14.10_windows_amd64.zip) for Windows 64-bit.  
    Create suggested install folder and extract contents of ZIP file to:  
    `C:\HashiCorp\bin`  

4.	Install [jq 1.6](https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe) for Windows 64-bit.  
    Create suggested install folder and rename binary to:  
    `C:\Program Files\Git\usr\local\bin\jq.exe`

### Configuration and Validation - Windows 64-Bit

1.	Set Windows Environment `PATH` to:

    ```bash
    PATH=C:\HashiCorp\bin;C:\Program Files\Git\usr\local\bin;%PATH%
    ```

2.	Reboot Windows.

3.	Launch Git Bash.  
    Start Menu -- > All apps -- > Git -- > Git Bash

4.	Validate installed command-line tools:

    ```bash
    $ git --version
    git version 2.31.1.windows.1

    $ packer --version
    1.7.2

    $ terraform --version
    Terraform v0.14.10

    $ jq --version
    jq-1.6
    ```

5.	Configure Git for local user:

    ```bash
    $ git config --global user.name "<first_name> <last_name>"
    $ git config --global user.email "<your_email>"
    $ git config --global --list
    ```

## Get the Code

1.	Create a folder for your AppD Cloud Kickstart project:

    ```bash
    $ mkdir -p /<drive>/projects
    $ cd /<drive>/projects
    ```

2.	Get the code from GitHub:

    ```bash
    $ git clone https://github.com/Appdynamics/AppD-Cloud-Kickstart.git
    $ cd AppD-Cloud-Kickstart
    ```

## Build the Immutable VM Images with Packer

The AppDynamics Cloud Kickstart project currently supports immutable VM image builds for Amazon AWS and 
Google Cloud Platform (GCP). In the future, we will be adding support for Microsoft Azure. Click on a 
link below for platform-specific instructions and Bill-of-Materials.

-	[AWS CentOS 7.9 VMs](AWS_VM_BUILD_INSTRUCTIONS.md): Instructions
-	[GCP CentOS 7.9 VMs](GCP_VM_BUILD_INSTRUCTIONS.md): Instructions

# Build Steps for Preparing the Workshop

## Overview

When delivering AppDynamics Cloud workshops, the provisioning and configuration of these lab environments 
can be an extremely tedious and time-consuming challenge for SE's. To solve that problem, the AppDynamics 
Cloud Kickstart project delivers a set of artifacts to automate the build, deployment, and configuration 
portion of these pre-workshop activities using open source tooling.

## Build and Deployment Tools

Although there are many tools available to accomplish the project's automation goals, it was decided to 
standardize on [Packer](https://www.packer.io/) and [Terraform](https://www.terraform.io/) from HashiCorp.
This is primarily due to their capability for building and deploying software platforms to multi-cloud 
environments, as well as having a high level of adoption within the developer community.

### Packer

[Packer](https://packer.io/) is an open source tool for creating identical machine images for multiple platforms
from a single source configuration. Packer is lightweight, runs on every major operating system, and is highly
performant. A machine image (or immutable VM image) is a single static unit that contains a pre-configured
operating system and installed software which is used to quickly create new running machines.  

As part of this project, Packer is used to create immutable VM images consisting of a standardized installation 
of CentOS 7.9 with a set of common software. These static images are later used by Terraform when standing-up 
the infrastructure and compute resources needed by workshop participants. Currently, these VMs consist of the 
following types:

-	__LPAD VM__: A 'Launchpad' VM with pre-configured tooling for Kubernetes and Serverless CLI Operations.
-	__APM-Platform VM__: An APM Platform stand-alone VM designed for Application Performance Monitoring. It consists of the AppDynamics Enterprise Console, Controller, and Events Service.

For SE-lead workshops, these VM images are built and maintained by AppDynamics. However, all of the artifacts 
used to build the images are present in this project, so customers are free to customize and build their own VM
images if desired.  

### Terraform

[Terraform](https://terraform.io/) is a tool for building, changing, and versioning infrastructure safely and
efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.
The infrastructure Terraform can manage includes low-level components such as compute instances, storage, and
networking, as well as high-level components such as DNS entries, SaaS features, etc.  

In this project, Terraform is used to automate the deployment of the Lab infrastructure, including VPCs, subnets, 
security groups, load balancers, and VMs using templates. The SE can also specify the number of environments 
needed (one for each participant) as well as the lab sequence start number, such as Lab01, Lab02, Lab03, etc.

## Get Started

To configure the AppDynamics Cloud workshop environments, the first step is to set-up your local environment 
by installing the needed software.

### Prerequisites
You install Packer and Terraform on a control node, usually your local laptop, which then uses the cloud CLI and/or
SSH to communicate with your cloud resources and managed nodes.

## Installation Instructions - macOS

The following open source software needs to be installed on the host macOS machine:

-	Homebrew 4.3.17
-	Git 2.46.0
-	Packer 1.11.2
-	Terraform 1.9.5
-	jq 1.7.1

Perform the following steps to install the needed software:

1.	Install the [Homebrew 4.3.17](https://brew.sh/) package manager for macOS 64-bit. Paste the following into a macOS Terminal prompt:  
    ```bash
    $ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    ```

2.	Install [Git 2.46.0](https://git-scm.com/downloads) for macOS 64-bit.  
    ```bash
    $ brew install git
    ```

3.	Install [Packer 1.11.2](https://developer.hashicorp.com/packer/install) for macOS 64-bit.  
    ```bash
    $ brew tap hashicorp/tap
    $ brew install hashicorp/tap/packer
    ```

4.	Install [Terraform 1.9.5](https://developer.hashicorp.com/terraform/install) for macOS 64-bit.  
    ```bash
    $ brew tap hashicorp/tap
    $ brew install hashicorp/tap/terraform
    ```

5.	Install [jq 1.7.1](https://jqlang.github.io/jq/) for macOS 64-bit.  
    `$ brew install jq`  

### Configuration and Validation - macOS

1.	Validate installed command-line tools:

    ```bash
    $ brew --version
    Homebrew 4.3.17
    $ brew doctor
    Your system is ready to brew.

    $ git --version
    git version 2.46.0

    $ packer --version
    1.11.2

    $ terraform --version
    Terraform v1.9.5

    $ jq --version
    jq-1.7.1
    ```

2.	Configure Git for local user:

    ```bash
    $ git config --global user.name "<first_name> <last_name>"
    $ git config --global user.email "<your_email>"
    $ git config --global --list
    ```

## Installation Instructions - Windows 64-Bit

To build the AppD Cloud Kickstart immutable VM images, the following open source software needs to be installed on the host Windows machine:

-	Git 2.46.0 for Win64
-	Packer 1.11.2
-	Terraform 1.9.5
-	jq 1.7.1

Perform the following steps to install the needed software:

1.	Install [Git 2.46.0](https://github.com/git-for-windows/git/releases/download/v2.46.0.windows.1/Git-2.46.0-64-bit.exe) for Windows 64-bit.

2.	Install [Packer 1.11.2](https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_windows_amd64.zip) for Windows 64-bit.  
    Create suggested install folder and extract contents of ZIP file to:  
    `C:\HashiCorp\bin`  

3.	Install [Terraform 1.9.5](https://releases.hashicorp.com/terraform/1.9.5/terraform_1.9.5_windows_amd64.zip) for Windows 64-bit.  
    Create suggested install folder and extract contents of ZIP file to:  
    `C:\HashiCorp\bin`  

4.	Install [jq 1.7.1](https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-win64.exe) for Windows 64-bit.  
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
    git version 2.46.0.windows.1

    $ packer --version
    1.11.2

    $ terraform --version
    Terraform v1.9.5

    $ jq --version
    jq-1.7.1
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
    $ git clone https://github.com/CiscoDevNet/AppD-Cloud-Kickstart.git
    $ cd AppD-Cloud-Kickstart
    ```

## Build the VM Images and Deploy the Lab Infrastructure

The AppDynamics Cloud Kickstart project currently supports VM image builds for Amazon AWS, Microsoft Azure, 
and Google Cloud Platform (GCP). Click on a link below for platform-specific instructions and a Bill-of-Materials.

-	[AWS Build and Deploy](AWS_VM_BUILD_INSTRUCTIONS.md): Instructions
-	[Azure Build and Deploy](AZURE_VM_BUILD_INSTRUCTIONS.md): Instructions
-	[GCP Build and Deploy](GCP_VM_BUILD_INSTRUCTIONS.md): Instructions

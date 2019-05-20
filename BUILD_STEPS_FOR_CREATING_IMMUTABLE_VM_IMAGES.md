# Build Steps for Creating Immutable VM Images

## Overview

The AppDynamics Cloud Kickstart project enables an IT Administrator, Software Developer, or DevOps engineer to automate the building of immutable VM images using open source tools from [Hashicorp](https://www.hashicorp.com/). Currently, these VMs consist of two types:

-	__APM-Platform VM__: An APM Platform stand-alone VM designed for Application Performance Monitoring. It consists of the AppDynamics Enterprise Console, Controller, and Events Service.
-	__LPAD-EKS VM__: 'Launchpad' VM with pre-configured tooling for Cloud and Kubernetes CLI Operations.

## Installation Instructions - macOS

To build the AppD Cloud Kickstart VM images, the following open source software needs to be installed on the host macOS machine:

-	Homebrew 2.1.3
	-	Command Line Tools (CLT) for Xcode
-	Packer 1.4.1
-	Git 2.21.0
-	jq 1.6

Perform the following steps to install the needed software:

1.	Install [Command Line Tools (CLT) for Xcode](https://developer.apple.com/downloads).  
    `$ xcode-select --install`  

    **NOTE:** Most Homebrew formulae require a compiler. A handful require a full Xcode installation. You can install [Xcode](https://itunes.apple.com/us/app/xcode/id497799835), the [CLT](https://developer.apple.com/downloads), or both; Homebrew supports all three configurations. Downloading Xcode may require an Apple Developer account on older versions of Mac OS X. Sign up for free [here](https://developer.apple.com/register/index.action).  

2.	Install the [Homebrew 2.1.3](https://brew.sh/) package manager for macOS 64-bit. Paste the following into a macOS Terminal prompt:  
    `$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

3.	Install [Packer 1.4.1](https://packer.io/) for macOS 64-bit.  
    `$ brew install packer`  

4.	Install [Git 2.21.0](https://git-scm.com/downloads) for macOS 64-bit.  
    `$ brew install git`  

5.	Install [jq 1.6](https://stedolan.github.io/jq/) for macOS 64-bit.  
    `$ brew install jq`  

### Configuration and Validation - macOS

1.	Validate installed command-line tools:

    ```
    $ brew --version
    Homebrew 2.1.3
    $ brew doctor
    Your system is ready to brew.

    $ packer --version
    1.4.1

    $ git --version
    git version 2.21.0

    $ jq --version
    jq-1.6
    ```

2.	Configure Git for local user:

    ```
    $ git config --global user.name "<your_name>"
    $ git config --global user.email "<your_email>"
    $ git config --global --list
    ```

## Installation Instructions - Windows 64-Bit

To build the AppD Cloud Kickstart immutable VM images, the following open source software needs to be installed on the host Windows machine:

-	Packer 1.4.1
-	Git 2.21.0 for Win64
-	jq 1.6

Perform the following steps to install the needed software:

1.	Install [Packer 1.4.1](https://releases.hashicorp.com/packer/1.4.1/packer_1.4.1_windows_amd64.zip) for Windows 64-bit.  
    Create suggested install folder and extract contents of ZIP file to:  
    `C:\HashiCorp\Packer\bin`  

2.	Install [Git 2.21.0](https://github.com/git-for-windows/git/releases/download/v2.21.0.windows.1/Git-2.21.0-64-bit.exe) for Windows 64-bit.

3.	Install [jq 1.6](https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe) for Windows 64-bit.  
    Create suggested install folder and rename binary to:  
    `C:\Program Files\Git\usr\local\bin\jq.exe`

### Configuration and Validation - Windows 64-Bit

1.	Set Windows Environment `PATH` to:

    ```
    PATH=C:\HashiCorp\Packer\bin;C:\Program Files\Git\usr\local\bin;%PATH%
    ```

2.	Reboot Windows.

3.	Launch Git Bash.  
    Start Menu -- > All apps -- > Git -- > Git Bash

4.	Validate installed command-line tools:

    ```
    $ packer --version
    1.4.1

    $ git --version
    git version 2.21.0.windows.1

    $ jq --version
    jq-1.6
    ```

5.	Configure Git for local user:

    ```
    $ git config --global user.name "<your_name>"
    $ git config --global user.email "<your_email>"
    $ git config --global --list
    ```

## Get the Code

1.	Create a folder for your AppD Cloud Kickstart project:

    ```
    $ mkdir -p /<drive>/projects
    $ cd /<drive>/projects
    ```

2.	Get the code from GitHub:

    ```
    $ git clone https://github.com/Appdynamics/AppD-Cloud-Kickstart.git
    $ cd AppD-Cloud-Kickstart
    ```

## Build the Immutable VM Images with Packer

The AppDynamics Cloud Kickstart project currently supports immutable VM image builds for Amazon AWS. In the future, we will be adding support for Microsoft Azure and Google Cloud Platform (GCP). Click on a link below for platform-specific instructions and Bill-of-Materials.

-	[AWS Amazon Linux 2 VMs](AWS_VM_BUILD_INSTRUCTIONS.md): Instructions

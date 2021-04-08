# Google Compute Engine (GCP) CentOS 7.9 Image Build Instructions

Follow these instructions to build the GCE CentOS 7.9 images:

-	__APM-Platform VM__: An APM Platform stand-alone VM with an AppDynamics Controller.
-	__LPAD VM__: A GCP GCE 'Launchpad' VM needed for Kubernetes and Serverless CLI Operations and running the sample apps.

Before building the AppD Cloud Kickstart VM images for GCP, it is recommended that you install the Google 
Cloud SDK, which includes the `gcloud` CLI tool. The gcloud CLI manages authentication, local configuration, 
developer workflow, and interactions with the Google Cloud Platform APIs. It is the primary tool used to 
create and manage Google Cloud resources.  

The gcloud CLI will also allow you to cleanup and delete any resources created by the DevOps tooling when 
you are finished, such as purging old GCE images created by Packer.

## GCP-Specific Installation Instructions - macOS

Here is a list of the recommended open source software to be installed on the host macOS machine:

-	Google Cloud SDK 335.0.0 (command-line interface)

Perform the following steps to install the needed software:

1.	Install [Google Cloud SDK 335.0.0](https://cloud.google.com/sdk/docs/quickstart#mac).  
    `$ brew install --cask google-cloud-sdk`  

    Depending on your shell, follow the on-screen instructions to add the SDK binaries to your `PATH`.

2.	Validate installed command-line tool:

    ```bash
    $ gcloud --version
    Google Cloud SDK 335.0.0
    bq 2.0.66
    core 2021.04.02
    gsutil 4.60
    ```

## GCP-Specific Installation Instructions - Windows 64-Bit

For Windows, users have a wide variety of choice in command-line tools and shells for running the gcloud CLI, 
such as the Windows Command Prompt, [PowerShell](https://docs.microsoft.com/en-us/powershell/), 
[Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/get-started), 
[Git Bash](https://git-scm.com/download/win), [Cygwin](https://www.cygwin.com/), and 
[The Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/about).  

Although you are free to use any of these tools, the installation steps described below will be based on 
the usage of **Git Bash** for consistency.  

Here is a list of the recommended open source software to be installed on the host Windows machine:

-	Google Cloud SDK 335.0.0 (command-line interface)

Perform the following steps to install the needed software:

1.	Install [Google Cloud SDK 335.0.0](https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe) for Windows 64-bit.  
    Run the downloaded EXE installer and follow the on-screen instructions.  

    **NOTE:** For Windows users, the EXE installation package offers a familiar and convenient way to 
    install the Google Cloud SDK without installing any other prerequisites. For more information, please visit 
    [Installing Google Cloud SDK](https://cloud.google.com/sdk/docs/install#windows) for Windows.

2.	Fix Python path errors in the `gcloud` shell script.  

    **NOTE:** As of the current release, the directory paths to the Python binary are invalid. Run the 
    following commands to correct the error:

    ```bash
    $ cd ~/AppData/Local/Google/Cloud\ SDK/google-cloud-sdk/bin
    $ cp -p gcloud gcloud.orig
    $ sed -i -e "s/bundledpythonunix\/bin\/python3/bundledpython\/python.exe/g" gcloud
    ```

3.	Validate installed command-line tool:

    ```bash
    $ gcloud --version
    Google Cloud SDK 335.0.0
    bq 2.0.66
    core 2021.04.02
    gsutil 4.60
    ```

### Configuration and Validation - Windows 64-Bit
C:\Users\win10admin\AppData\Local\Google\Cloud SDK

## Prepare for the Build

All user credentials and installation inputs are driven by environment variables and can be configured within the `set_appd_cloud_kickstart_env.sh` script you will create in `./bin`. There are LOTS of options, but most have acceptable defaults. You only need to concentrate on a handful that are uncommented in the template file.

In particular, you will need to supply your AppDynamics login credentials to the [download site](https://download.appdynamics.com/download/). You will also need to provide an AWS Access Key ID and Secret Access Key from a valid AWS account.

The build will __fail__ if they are not set.

To prepare for the build, perform the following steps:

1.	Customize your AppD Cloud Kickstart project environment:

    Copy the template file and edit `set_appd_cloud_kickstart_env.sh` located in `./bin` to customize the environment variables for your environment.

    ```bash
    $ cd /<drive>/projects/AppD-Cloud-Kickstart/bin
    $ cp -p set_appd_cloud_kickstart_env.sh.template set_appd_cloud_kickstart_env.sh
    $ vi set_appd_cloud_kickstart_env.sh
    ```

    The following environment variables are the most common to be overridden. They are grouped by sections in the file, so you will have to search to locate the exact line. For example, the AWS-related variables are at the end of the file.

    The first 4 are mandatory and the others are optional, but helpful. If you are building the AMI images in the `us-east-1` region (N. Virginia), the region-related variables can be left alone.

    ```bash
    appd_username="<Your_AppDynamics_Download_Site_Email>"
    appd_password="<Your_AppDynamics_Download_Site_Password>"

    AWS_ACCESS_KEY_ID="<Your_AWS_ACCESS_KEY_ID>"
    AWS_SECRET_ACCESS_KEY="<Your_AWS_SECRET_ACCESS_KEY>"

    aws_ami_owner="<Your Firstname> <Your Lastname>"
    aws_cli_default_region_name="us-east-1"         # example for N. Virginia.
    aws_ami_region="us-east-1"                      # example for N. Virginia.
    ```

    Save and source the environment variables file in order to define the variables in your shell.

    ```bash
    $ source ./set_appd_cloud_kickstart_env.sh
    ```

    Validate the newly-defined environment variables via the following commands:

    ```bash
    $ env | grep -i ^aws | sort
    $ env | grep -i ^appd | sort
    ```

2.	Supply a valid AppDynamics Controller license file:

	-	This license can be supplied by any AppDynamics SE
		-	It is recommended to have at least 10 APM, 10 server, 10 network, 5 DB, 1 unit of each Analytics and 1 unit of each RUM within the license key.
		-	Copy your AppDynamics Controller `license.lic` and rename it to `provisioners/scripts/centos/tools/appd-controller-license.lic`.


## Build the Amazon Machine Images (AMIs) with Packer

1.	Build the __APM-Platform VM__ CentOS 7.9 AMI image:

    This will take several minutes to run.

    ```bash
    $ cd /<drive>/projects/AppD-Cloud-Kickstart/builders/packer/aws
    $ packer build apm-platform-centos79.json
    ```

    If the build fails, check to ensure the accuracy of all variables edited above--including items such as spaces between access keys and the ending parentheses.

2.	Build the __LPAD VM__ CentOS 7.9 AMI image:

    This will take several minutes to run. However, this build will be shorter
    because the size of the root volume for the AMI image is much smaller.

    ```bash
    $ packer build lpad-centos79.json
    ```

3. The steps for creating the AMI's are completed. 

## AWS CentOS 7.9 Bill-of-Materials

__APM-Platform VM__ - The following utilities and application performance management applications are pre-installed:

-	Amazon AWS CLI 2.1.35 (command-line interface)
-	Amazon AWS GCE Instance Metadata Query Tool (command-line interface)
-	Ansible 2.9.19
-	AppDynamics Enterprise Console 21.4.0 Build 24567
	-	AppDynamics Controller 21.4.0 Build 1244
	-	AppDynamics Events Service 4.5.2.0 Build 20651
-	Docker 20.10.5 CE
	-	Docker Bash Completion
	-	Docker Compose 1.29.0
	-	Docker Compose Bash Completion
-	Java SE JDK 8 Update 282 (Amazon Corretto 8)
-	jq 1.6 (command-line JSON processor)
-	MySQL Shell 8.0.23
-	Python 2.7.5
	-	Pip 21.0.1
-	Python 3.6.8
	-	Pip 21.0.1
-	VIM - Vi IMproved 8.2

__LPAD VM__ - The following AWS CLI command-line tools and utilities are pre-installed:

-	Amazon AWS CLI 2.1.35 (command-line interface)
-	Amazon AWS GCE Instance Metadata Query Tool (command-line interface)
-	Amazon AWS EKS CLI [eksctl] 0.44.0 (command-line interface)
-	Amazon AWS IAM Authenticator 1.19.6 for AWS EKS CLI and kubectl.
-	Amazon AWS Kubernetes Control CLI [kubectl] 1.19.6 (command-line interface)
-	Ansible 2.9.19
-	AppDynamics Node.js Serverless Tracer 21.3.278
-	Docker 20.10.5 CE
	-	Docker Bash Completion
	-	Docker Compose 1.29.0
	-	Docker Compose Bash Completion
-	Git 2.31.1
	-	Git Bash Completion
	-	Git-Flow 1.12.3 (AVH Edition)
	-	Git-Flow Bash Completion
-	Helm CLI 3.5.3 (Package Manager for Kubernetes)
-	Java SE JDK 8 Update 282 (Amazon Corretto 8)
-	Java SE JDK 11.0.10 (Amazon Corretto 11)
-	Java SE JDK 15.0.2 (Amazon Corretto 15)
-	Java SE JDK 16 (Amazon Corretto 16)
-	jq 1.6 (command-line JSON processor)
-	Node.js JavaScript runtime v14.16.1 (Latest LTS Version)
-	npm JavaScript Package Manager for Node.js 7.8.0
-	nvm (Node Version Manager) bash script 0.38.0
-	Python 2.7.5
	-	Pip 21.0.1
-	Python 3.6.8
	-	Pip 21.0.1
-	Serverless Framework CLI 2.34.0
-	VIM - Vi IMproved 8.2

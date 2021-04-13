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

Here is a list of the additional recommended software to be installed on the host macOS machine:

-	Google Cloud SDK 335.0.0 (command-line interface)

Perform the following steps to install the needed software:

1.	Install [Google Cloud SDK 335.0.0](https://cloud.google.com/sdk/docs/quickstart#mac).  
    `$ brew install --cask google-cloud-sdk`  

    Depending on your shell, follow the on-screen instructions to source the SDK binaries to your `PATH`.  

    For example, for Bash shell users, add the following to your `~/.bashrc` file:  

    ```bash
    source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
    source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"
    ```

2.	Validate installed command-line tool:

    ```bash
    $ gcloud --version
    Google Cloud SDK 335.0.0
    bq 2.0.66
    core 2021.04.02
    gsutil 4.60
    ```

## GCP-Specific Installation Instructions - Windows 64-Bit

Windows users have a wide variety of choice in command-line tools and shells for running the gcloud CLI, 
such as the Windows Command Prompt, [PowerShell](https://docs.microsoft.com/en-us/powershell/), 
[Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/get-started), 
[Git Bash](https://git-scm.com/download/win), and 
[The Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/about).  

Although you are free to use any of these tools, the installation steps described below will be based on 
the usage of the **Git Bash** terminal for consistency.  

Here is a list of the additional recommended software to be installed on the host Windows machine:

-	Google Cloud SDK 335.0.0 (command-line interface)

Perform the following steps to install the needed software:

1.	Install [Google Cloud SDK 335.0.0](https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe) for Windows 64-bit.  
    Run the downloaded EXE installer, follow the on-screen instructions, and accept the defaults until you get to the last step.  

    **NOTE:** For Windows users, the EXE installation package offers a familiar and convenient way to 
    install the Google Cloud SDK without installing any other prerequisites. For more information, please visit 
    [Installing Google Cloud SDK](https://cloud.google.com/sdk/docs/install#windows) for Windows.  

    On the last step of the installer, uncheck the **Start Google Cloud SDK Shell** checkbox, which will 
    also grayout the **Run 'gcloud init' to configure the Cloud SDK** checkbox. We will perform these steps 
    later using the Git Bash terminal instead.  

    ![gcloud Windows 10 Installer](./images/gcloud-windows-10-installer-01.png)

2.	Open the **Git Bash** terminal and fix Python path errors in the `gcloud` shell script.  

    **NOTE:** As of this writing, the `gcloud` shell script contains invalid directory paths to the Python binary. Run the 
    following commands to correct the error:

    ```bash
    $ cd ~/AppData/Local/Google/Cloud\ SDK/google-cloud-sdk/bin
    $ cp -p gcloud gcloud.orig
    $ sed -i -e "s/bundledpythonunix\/bin\/python3/bundledpython\/python.exe/g" gcloud
    $ cd ~
    ```

3.	Using the **Git Bash** Terminal, validate the installed command-line tool:

    ```bash
    $ gcloud --version
    Google Cloud SDK 335.0.0
    bq 2.0.66
    core 2021.04.02
    gsutil 4.60
    ```

## Configuration and Validation

The configuration and validation steps are essentially identical for macOS and Windows 64-Bit systems. Perform the following steps to complete these tasks:  

1.	Configure the Google Cloud SDK from the command-line.  

    Run the 'gcloud init' command to launch an interactive Getting Started workflow for the command-line tool.  

    ```bash
    $ gcloud init
    ```

    You should see output similar to the following. When prompted, answer '**Y**' to log in:  

    ```bash
    Welcome! This command will take you through the configuration of gcloud.

    Your current configuration has been set to: [default]

    You can skip diagnostics next time by using the following flag:
      gcloud init --skip-diagnostics

    Network diagnostic detects and fixes local network connection issues.
    Checking network connection...done.
    Reachability Check passed.
    Network diagnostic passed (1/1 checks passed).

    You must log in to continue. Would you like to log in (Y/n)? Y
    ```

    You should see output similar to the following which will then launch your browser:  

    ```bash
    Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?...
    ```

2.	Authorize gcloud and other SDK tools to access the Google Cloud Platform using your user account credentials.

    Sign-in to your Google account and click "Next":  

    ![gcloud init Auth 01](./images/gcloud-init-browser-auth-01.png)

    <br>

    Enter your password if needed and then continue to the next screen.  

    <br>

    Click the "Allow" button to configure the Google Cloud SDK to authenticate using your Google account:  

    ![gcloud init Auth 02](./images/gcloud-init-browser-auth-02.png)

    <br>

    You should now see a message like the one below:  

    ![gcloud init Auth 03](./images/gcloud-init-browser-auth-03.png)

    <br>

    In your terminal, you should also receive a login message as follows:  

    ```bash
    You are logged in as: [yourusername@cisco.com].
    ```

3.	You will be prompted to select the GCP Cloud Project to use. For AppDynamics SEs, select '**gcp-appdcloudplatfo-nprd-68190**', which as of this writing is number '**2**'.

    ```bash
    Pick cloud project to use:
     [1] csbimages-prod-poy1
     [2] gcp-appdcloudplatfo-nprd-68190
     [3] Create a new project
    Please enter numeric choice or text value (must exactly match list
    item): 2
    ```

    You should see output similar to the following. When prompted, answer '**n**' to configure a default Compute Region and Zone. We will do that in a later step:  

    ```bash
    Your current project has been set to: [gcp-appdcloudplatfo-nprd-68190].

    Do you want to configure a default Compute Region and Zone? (Y/n)? n
    ```

    You should see output similar to the following:  

    ```bash
    Your Google Cloud SDK is configured and ready to use!

    * Commands that require authentication will use yourusername@cisco.com by default
    * Commands will reference project `gcp-appdcloudplatfo-nprd-68190` by default
    Run `gcloud help config` to learn how to change individual settings

    This gcloud configuration is called [default]. You can create additional configurations if you work with multiple accounts and/or projects.
    Run `gcloud topic configurations` to learn more.

    Some things to try next:

    * Run `gcloud --help` to see the Cloud Platform services you can interact with. And run `gcloud help COMMAND` to get help on any gcloud command.
    * Run `gcloud topic --help` to learn about advanced features of the SDK like arg files and output formatting
    ```

4.	Next, select the default GCP Cloud Region and Zone to use. For AppDynamics SEs, use Region '**us-central1**' and Zone '**us-central1-a**'.  

    ```bash
    $ gcloud config set compute/region us-central1
    $ gcloud config set compute/zone us-central1-a
    ```

5.	Finally, validate your Cloud SDK configuration:  

    ```bash
    $ gcloud config list
    ```

    You should see output similar to the following.  

    ```bash
    [compute]
    region = us-central1
    zone = us-central1-a
    [core]
    account = youruserame@cisco.com
    disable_usage_reporting = True
    project = gcp-appdcloudplatfo-nprd-68190

    Your active configuration is: [default]
    ```

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

-	Amazon AWS CLI 2.1.36 (command-line interface)
-	Amazon AWS GCE Instance Metadata Query Tool (command-line interface)
-	Ansible 2.9.20
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

-	Amazon AWS CLI 2.1.36 (command-line interface)
-	Amazon AWS GCE Instance Metadata Query Tool (command-line interface)
-	Amazon AWS EKS CLI [eksctl] 0.44.0 (command-line interface)
-	Amazon AWS IAM Authenticator 1.19.6 for AWS EKS CLI and kubectl.
-	Amazon AWS Kubernetes Control CLI [kubectl] 1.19.6 (command-line interface)
-	Ansible 2.9.20
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
-	npm JavaScript Package Manager for Node.js 7.9.0
-	nvm (Node Version Manager) bash script 0.38.0
-	Python 2.7.5
	-	Pip 21.0.1
-	Python 3.6.8
	-	Pip 21.0.1
-	Serverless Framework CLI 2.35.0
-	VIM - Vi IMproved 8.2

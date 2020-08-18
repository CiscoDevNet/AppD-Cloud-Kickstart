# AWS CentOS 7.8 AMI Build Instructions

Follow these instructions to build the AWS CentOS 7.8 AMI images:

-	__APM-Platform VM__: An APM Platform stand-alone VM with an AppDynamics Controller.
-	__CWOM-Platform VM__: A Cisco Workload Optimization Manager (CWOM) stand-alone VM with a CWOM Platform server.
-	__LPAD VM__: An AWS EC2 'Launchpad' VM needed for Kubernetes and Serverless CLI Operations and running the sample apps.

Before building the AppD Cloud Kickstart VM images for AWS, it is recommended that you install the AWS CLI v2. This will allow you to cleanup and delete any resources created by the Packer builds when you are finished. It will also provide the ability to easily purge old AMI images while keeping the latest. Note that in AWS CLI version 2, the required Python 3 libraries are now embedded in the installer and no longer need to be installed separately.

## AWS-Specific Installation Instructions - macOS

Here is a list of the recommended open source software to be installed on the host macOS machine:

-	Amazon AWS CLI 2.0.40 (command-line interface)

Perform the following steps to install the needed software:

1.	Install [AWS CLI 2.0.40](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html).  
    `$ brew install awscli@2`  

2.	Validate installed command-line tools:

    ```
    $ aws --version
    aws-cli/2.0.40 Python/3.8.5 Darwin/19.6.0 source/x86_64
    ```

## AWS-Specific Installation Instructions - Windows 64-Bit

Here is a list of the recommended open source software to be installed on the host Windows machine:

-	Amazon AWS CLI 2.0.40 (command-line interface)

Perform the following steps to install the needed software:

1.	Install [AWS CLI 2.0.40](https://awscli.amazonaws.com/AWSCLIV2.msi) for Windows 64-bit.  
    Run the downloaded MSI installer and follow the on-screen instructions.  

    **NOTE:** For Windows users, the MSI installation package offers a familiar and convenient way to install the AWS CLI without installing any other prerequisites. However, when updates are released, you must repeat the installation process to get the latest version of the AWS CLI. If you prefer more frequent updates, consider using `pip` as described in the AWS CLI [install guide](https://docs.aws.amazon.com/cli/latest/userguide/install-windows.html).

2.	Validate installed command-line tool:

    ```
    $ aws --version
    aws-cli/2.0.40 Python/3.7.7 Windows/10 botocore/2.0.0dev44
    ```

## Prepare for the Build

All user credentials and installation inputs are driven by environment variables and can be configured within the `set_appd_cloud_kickstart_env.sh` script you will create in `./bin`. There are LOTS of options, but most have acceptable defaults. You only need to concentrate on a handful that are uncommented in the template file.

In particular, you will need to supply your AppDynamics login credentials to the [download site](https://download.appdynamics.com/download/). You will also need to provide an AWS Access Key ID and Secret Access Key from a valid AWS account.

The build will __fail__ if they are not set.

To prepare for the build, perform the following steps:

1.	Customize your AppD Cloud Kickstart project environment:

    Copy the template file and edit `set_appd_cloud_kickstart_env.sh` located in `./bin` to customize the environment variables for your environment.

    ```
    $ cd /<drive>/projects/AppD-Cloud-Kickstart/bin
    $ cp -p set_appd_cloud_kickstart_env.sh.template set_appd_cloud_kickstart_env.sh
    $ vi set_appd_cloud_kickstart_env.sh
    ```

    The following environment variables are the most common to be overridden. They are grouped by sections in the file, so you will have to search to locate the exact line. For example, the AWS-related variables are at the end of the file.

    The first 4 are mandatory and the others are optional, but helpful. If you are building the AMI images in the `us-east-1` region (N. Virginia), the region-related variables can be left alone.

    ```
    appd_username="<Your_AppDynamics_Download_Site_Email>"
    appd_password="<Your_AppDynamics_Download_Site_Password>"

    AWS_ACCESS_KEY_ID="<Your_AWS_ACCESS_KEY_ID>"
    AWS_SECRET_ACCESS_KEY="<Your_AWS_SECRET_ACCESS_KEY>"

    aws_ami_owner="<Your Firstname> <Your Lastname>"
    aws_cli_default_region_name="us-east-1"         # example for N. Virginia.
    aws_ami_region="us-east-1"                      # example for N. Virginia.
    ```

    Save and source the environment variables file in order to define the variables in your shell.

    ```
    $ source ./set_appd_cloud_kickstart_env.sh
    ```

    Validate the newly-defined environment variables via the following commands:

    ```
    $ env | grep -i ^aws | sort
    $ env | grep -i ^appd | sort
    ```

2.	Supply a valid AppDynamics Controller license file:

	-	This license can be supplied by any AppDynamics SE
		-	It is recommended to have at least 10 APM, 10 server, 10 network, 5 DB, 1 unit of each Analytics and 1 unit of each RUM within the license key.
		-	Copy your AppDynamics Controller `license.lic` and rename it to `provisioners/scripts/centos/tools/appd-controller-license.lic`.


## Build the Amazon Machine Images (AMIs) with Packer

1.	Build the __APM-Platform VM__ CentOS 7.8 AMI image:

    This will take several minutes to run.

    ```
    $ cd /<drive>/projects/AppD-Cloud-Kickstart/builders/packer/aws
    $ packer build apm-platform-centos78.json
    ```

    If the build fails, check to ensure the accuracy of all variables edited above--including items such as spaces between access keys and the ending parentheses.

2.	Build the __CWOM-Platform VM__ CentOS 7.8 AMI image:

    This will take several minutes to run.

    ```
    $ cd /<drive>/projects/AppD-Cloud-Kickstart/builders/packer/aws
    $ packer build cwom-platform-centos78.json
    ```

    If the build fails, check to ensure the accuracy of all variables edited above--including items such as spaces between access keys and the ending parentheses.

3.	Build the __LPAD VM__ CentOS 7.8 AMI image:

    This will take several minutes to run. However, this build will be shorter
    because the size of the root volume for the AMI image is much smaller.

    ```
    $ packer build lpad-centos78.json
    ```

4. The steps for creating the AMI's are completed. 

## AWS CentOS 7.8 Bill-of-Materials

__APM-Platform VM__ - The following utilities and application performance management applications are pre-installed:

-	Amazon AWS CLI 2.0.40 (command-line interface)
-	Amazon AWS EC2 Instance Metadata Query Tool (command-line interface)
-	Ansible 2.9.12
-	AppDynamics Enterprise Console 20.7.4 Build 22931
	-	AppDynamics Controller 20.7.4 Build 2948
	-	AppDynamics Events Service 4.5.2.0 Build 20640
-	Docker 19.03.12 CE
	-	Docker Bash Completion
	-	Docker Compose 1.26.2
	-	Docker Compose Bash Completion
-	Java SE JDK 8 Update 265 (Amazon Corretto 8)
-	jq 1.6 (command-line JSON processor)
-	MySQL Shell 8.0.21
-	Python 2.7.5
	-	Pip 20.2.2
-	Python 3.6.8
	-	Pip 20.2.2
-	VIM - Vi IMproved 8.2

__CWOM-Platform VM__ - The following utilities and workload optimization management applications are pre-installed:

-	Amazon AWS CLI 2.0.40 (command-line interface)
-	Amazon AWS EC2 Instance Metadata Query Tool (command-line interface)
-	Ansible 2.9.12
-	Cisco Workload Optimization Manager (CWOM) 2.3.20
-	Docker 19.03.12 CE
	-	Docker Bash Completion
	-	Docker Compose 1.26.2
	-	Docker Compose Bash Completion
-	Java SE JDK 8 Update 265 (Amazon Corretto 8)
-	jq 1.6 (command-line JSON processor)
-	MySQL Shell 8.0.21
-	Python 2.7.5
	-	Pip 20.2.2
-	Python 3.6.8
	-	Pip 20.2.2
-	VIM - Vi IMproved 8.2

__LPAD VM__ - The following AWS CLI command-line tools and utilities are pre-installed:

-	Amazon AWS CLI 2.0.40 (command-line interface)
-	Amazon AWS EC2 Instance Metadata Query Tool (command-line interface)
-	Amazon AWS EKS CLI [eksctl] 0.25.0 (command-line interface)
-	Amazon AWS IAM Authenticator 1.17.9 for AWS EKS CLI and kubectl.
-	Amazon AWS Kubernetes Control CLI [kubectl] 1.17.9 (command-line interface)
-	Ansible 2.9.12
-	AppDynamics Node.js Serverless Tracer 20.3.178
-	Docker 19.03.12 CE
	-	Docker Bash Completion
	-	Docker Compose 1.26.2
	-	Docker Compose Bash Completion
-	Git 2.28.0
	-	Git Bash Completion
	-	Git-Flow 1.12.3 (AVH Edition)
	-	Git-Flow Bash Completion
-	Helm CLI 3.3.0 (Package Manager for Kubernetes)
-	Java SE JDK 8 Update 265 (Amazon Corretto 8)
-	Java SE JDK 11.0.8 (Amazon Corretto 11)
-	Java SE JDK 14.0.2 (Oracle)
-	jq 1.6 (command-line JSON processor)
-	Node.js JavaScript runtime v12.18.3 (Latest LTS Version)
-	npm JavaScript Package Manager for Node.js 6.14.8
-	nvm (Node Version Manager) bash script 0.35.3
-	Python 2.7.5
	-	Pip 20.2.2
-	Python 3.6.8
	-	Pip 20.2.2
-	Serverless Framework CLI 1.78.1
-	VIM - Vi IMproved 8.2

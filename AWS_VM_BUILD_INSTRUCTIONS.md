# AWS CentOS 7.7 AMI Build Instructions

Follow these instructions to build the AWS CentOS 7.7 AMI images:

-	__APM-Platform VM__: An APM Platform stand-alone VM with an AppDynamics Controller.
-	__CWOM-Platform VM__: A Cisco Workload Optimization Manager (CWOM) stand-alone VM with a CWOM Platform server.
-	__LPAD VM__: An AWS EC2 'Launchpad' VM needed for Kubernetes and Serverless CLI Operations and running the sample apps.

Before building the AppD Cloud Kickstart VM images for AWS, it is recommended that you install the AWS CLI and Python3. This will allow you to cleanup and delete any resources created by the Packer builds when you are finished. It will also provide the ability to easily purge old AMI images while keeping the latest.

## AWS-Specific Installation Instructions - macOS

Here is a list of the recommended open source software to be installed on the host macOS machine:

-	Amazon AWS CLI 1.17.9 (command-line interface)
-	Python 3.7.6
	-	Pip 20.0.2

Perform the following steps to install the needed software:

1.	Install [Python 3.7.6](https://www.python.org/downloads/release/python-376/) for macOS 64-bit.  
    `$ brew install python3`  

2.	Upgrade [Pip 20.0.2](https://pypi.org/project/pip/) for macOS 64-bit.  
    `$ pip3 install pip --upgrade --user`  

3.	Install [AWS CLI 1.17.9](https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html#awscli-install-osx-pip).  
    `$ pip3 install awscli --upgrade --user`  

4.	Add AWS CLI to shell environment `PATH`:

    ```
    vi $HOME/.bashrc

    # add aws cli to path. -------------------------------------------------
    PATH=$HOME/Library/Python/3.7/bin:$PATH
    export PATH
    # ----------------------------------------------------------------------

    source $HOME/.bashrc
    ```

5.	Validate installed command-line tools:

    ```
    $ python3 --version
    Python 3.7.6

    $ pip3 --version
    pip 20.0.2 from /usr/local/lib/python3.7/site-packages/pip (python 3.7)

    $ aws --version
    aws-cli/1.17.9 Python/3.7.6 Darwin/18.7.0 botocore/1.14.9
    ```

## AWS-Specific Installation Instructions - Windows 64-Bit

Here is a list of the recommended open source software to be installed on the host Windows machine:

-	Amazon AWS CLI 1.17.9 (command-line interface)

Perform the following steps to install the needed software:

1.	Install [AWS CLI 1.17.9](https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi) for Windows 64-bit.  
    Run the downloaded MSI installer and follow the on-screen instructions.  

    **NOTE:** For Windows users, the MSI installation package offers a familiar and convenient way to install the AWS CLI without installing any other prerequisites. However, when updates are released, you must repeat the installation process to get the latest version of the AWS CLI. If you prefer more frequent updates, consider using `pip` as described in the AWS CLI [install guide](https://docs.aws.amazon.com/cli/latest/userguide/install-windows.html).

2.	Validate installed command-line tool:

    ```
    $ aws --version
    aws-cli/1.17.9 Python/3.6.0 Windows/10 botocore/1.14.9
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

    The first 4 are mandatory and the others are optional, but helpful. If you are building the AMI images in the `eu-west-3` region (Paris), the region-related variables can be left alone.

    ```
    appd_username="<Your_AppDynamics_Download_Site_Email>"
    appd_password="<Your_AppDynamics_Download_Site_Password>"

    AWS_ACCESS_KEY_ID="<Your_AWS_ACCESS_KEY_ID>"
    AWS_SECRET_ACCESS_KEY="<Your_AWS_SECRET_ACCESS_KEY>"

    aws_ami_owner="<Your Firstname> <Your Lastname>"
    aws_cli_default_region_name="eu-west-3"         # example for Paris.
    aws_ami_region="eu-west-3"                      # example for Paris.
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

1.	Build the __APM-Platform VM__ CentOS 7.7 AMI image:

    This will take several minutes to run.

    ```
    $ cd /<drive>/projects/AppD-Cloud-Kickstart/builders/packer/aws
    $ packer build apm-platform-centos77.json
    ```

    If the build fails, check to ensure the accuracy of all variables edited above--including items such as spaces between access keys and the ending parentheses.

2.	Build the __CWOM-Platform VM__ CentOS 7.7 AMI image:

    This will take several minutes to run.

    ```
    $ cd /<drive>/projects/AppD-Cloud-Kickstart/builders/packer/aws
    $ packer build cwom-platform-centos77.json
    ```

    If the build fails, check to ensure the accuracy of all variables edited above--including items such as spaces between access keys and the ending parentheses.

3.	Build the __LPAD VM__ CentOS 7.7 AMI image:

    This will take several minutes to run. However, this build will be shorter
    because the size of the root volume for the AMI image is much smaller.

    ```
    $ packer build lpad-centos77.json
    ```

4. The steps for creating the AMI's are completed. 

## AWS CentOS 7.7 Bill-of-Materials

__APM-Platform VM__ - The following utilities and application performance management applications are pre-installed:

-	AppDynamics Enterprise Console 4.5.16.0 Build 21295
	-	AppDynamics Controller 4.5.16.1 Build 2272
	-	AppDynamics Event Service 4.5.2.0 Build 20561
-	Docker 19.03.5 CE
	-	Docker Bash Completion
	-	Docker Compose 1.25.3
	-	Docker Compose Bash Completion
-	Java SE JDK 8 Update 242 (Amazon Corretto 8)
-	jq 1.6 (command-line JSON processor)
-	MySQL Shell 8.0.19
-	Python 2.7.5
	-	Pip 20.0.2

__CWOM-Platform VM__ - The following utilities and workload optimization management applications are pre-installed:

-	Cisco Workload Optimization Manager (CWOM) 2.3.6
-	Docker 19.03.5 CE
	-	Docker Bash Completion
	-	Docker Compose 1.25.3
	-	Docker Compose Bash Completion
-	Java SE JDK 8 Update 242 (Amazon Corretto 8)
-	jq 1.6 (command-line JSON processor)
-	MySQL Shell 8.0.19
-	Python 2.7.5
	-	Pip 20.0.2
-	Python 3.6.3
	-	Pip 20.0.2

__LPAD VM__ - The following AWS CLI command-line tools and utilities are pre-installed:

-	Amazon AWS CLI 1.17.9 (command-line interface)
-	Amazon AWS EKS CLI [eksctl] 0.13.0 (command-line interface)
-	Amazon AWS IAM Authenticator 1.14.6 for AWS EKS CLI and kubectl.
-	Amazon AWS Kubernetes Control CLI [kubectl] 1.14.6 (command-line interface)
-	AppDynamics Node.js Serverless Tracer 1.0.1
-	Docker 19.03.5 CE
	-	Docker Bash Completion
	-	Docker Compose 1.25.3
	-	Docker Compose Bash Completion
-	Git 2.25.0
	-	Git Bash Completion
	-	Git-Flow 1.12.3 (AVH Edition)
	-	Git-Flow Bash Completion
-	Helm CLI 3.0.2 (Package Manager for Kubernetes)
-	Java SE JDK 8 Update 242 (Amazon Corretto 8)
-	Java SE JDK 11.0.6 (Amazon Corretto 11)
-	Java SE JDK 13.0.2 (Oracle)
-	jq 1.6 (command-line JSON processor)
-	Node.js JavaScript runtime v12.14.1 (Latest LTS Version)
-	npm JavaScript Package Manager for Node.js 6.13.7
-	nvm (Node Version Manager) bash script 0.35.2
-	Python 2.7.5
	-	Pip 20.0.2
-	Python 3.6.3
	-	Pip 20.0.2
-	Serverless Framework CLI 1.61.3

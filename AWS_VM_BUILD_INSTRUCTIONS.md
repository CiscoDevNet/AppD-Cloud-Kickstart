# AWS Amazon Linux 2 AMI Build Instructions

Follow these instructions to build the AWS Amazon Linux 2 AMI images:

-	__APM-Platform VM__: An APM Platform stand-alone VM with an AppDynamics Controller.
-	__LPAD-EKS VM__: An AWS EKS 'Launchpad' VM needed for Kubernetes CLI Operations and running the sample apps.

Before building the AppD Cloud Kickstart VM images for AWS, it is recommended that you install the AWS CLI and Python3. This will allow you to cleanup and delete any resources created by the Packer builds when you are finished. It will also provide the ability to easily purge old AMI images while keeping the latest.

## AWS-Specific Installation Instructions - macOS

Here is a list of the recommended open source software to be installed on the host macOS machine:

-	Amazon AWS CLI 1.16.153 (command-line interface)
-	Python 3.7.3
	-	Pip 19.1.1

Perform the following steps to install the needed software:

1.	Install [Python 3.7.3](https://www.python.org/downloads/release/python-372/) for macOS 64-bit.  
    `$ brew install python3`  

2.	Upgrade [Pip 19.1.1](https://pypi.org/project/pip/) for macOS 64-bit.  
    `$ pip3 install --upgrade pip`  

3.	Install [AWS CLI 1.16.153](https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html#awscli-install-osx-pip).  
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
    Python 3.7.3

    $ pip3 --version
    pip 19.1 from /usr/local/lib/python3.7/site-packages/pip (python 3.7)

    $ aws --version
    aws-cli/1.16.153 Python/3.7.3 Darwin/18.5.0 botocore/1.12.143
    ```

## AWS-Specific Installation Instructions - Windows 64-Bit

Here is a list of the recommended open source software to be installed on the host Windows machine:

-	Amazon AWS CLI 1.16.153 (command-line interface)

Perform the following steps to install the needed software:

1.	Install [AWS CLI 1.16.153](https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi) for Windows 64-bit.  
    Run the downloaded MSI installer and follow the on-screen instructions.  

    **NOTE:** For Windows users, the MSI installation package offers a familiar and convenient way to install the AWS CLI without installing any other prerequisites. However, when updates are released, you must repeat the installation process to get the latest version of the AWS CLI. If you prefer more frequent updates, consider using `pip` as described in the AWS CLI [install guide](https://docs.aws.amazon.com/cli/latest/userguide/install-windows.html).

2.	Validate installed command-line tool:

    ```
    $ aws --version
    aws-cli/1.16.153 Python/3.6.0 Windows/10 botocore/1.12.143
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

    The first 4 are mandatory and the others are optional, but helpful. If you are building the AMI images in the `us-west-2`region (Oregon), the region-related variables can be left alone.

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

1.	Build the __APM-Platform VM__ Amazon Linux 2 AMI image:

    This will take several minutes to run.

    ```
    $ cd /<drive>/projects/AppD-Cloud-Kickstart/builders/packer/aws
    $ packer build apm-platform-al2.json
    ```

    If the build fails, check to ensure the accuracy of all variables edited above--including items such as spaces between access keys and the ending parentheses.

2.	Build the __LPAD-EKS VM__ Amazon Linux 2 AMI image:

    This will take several minutes to run. However, this build will be shorter
    because the size of the root volume for the AMI image is much smaller.

    ```
    $ packer build lpad-eks-al2.json
    ```

3. The steps for creating the AMI's are completed. 

## AWS Amazon Linux 2 Bill-of-Materials

The following utilities and application performance management applications are pre-installed in the __APM-Platform VM__:

-	AppDynamics Enterprise Console 4.5.9.0 Build 19152
	-	AppDynamics Controller 4.5.9.2 Build 5729
	-	AppDynamics Event Service 4.5.2.0 Build 20201
-	Docker 18.06.1-ce
	-	Docker Bash Completion
	-	Docker Compose 1.24.0
	-	Docker Compose Bash Completion
-	Java SE JDK 8 Update 212 (Amazon Corretto 8)
-	jq 1.6 (command-line JSON processor)
-	MySQL Shell 8.0.16
-	Python 2.7.14
	-	Pip 19.1.1

The following AWS CLI command-line tools and utilities are pre-installed in the __LPAD-EKS VM__:

-	Amazon AWS CLI 1.16.153 (command-line interface)
-	Amazon AWS EKS CLI [eksctl] 0.1.31 (command-line interface)
-	Amazon AWS IAM Authenticator 1.12.7 for AWS EKS CLI and kubectl.
-	Amazon AWS Kubernetes Control CLI [kubectl] 1.12.7 (command-line interface)
-	Docker 18.06.1-ce
	-	Docker Bash Completion
	-	Docker Compose 1.24.0
	-	Docker Compose Bash Completion
-	Git 2.21.0
	-	Git Bash Completion
	-	Git-Flow 1.12.1 (AVH Edition)
	-	Git-Flow Bash Completion
-	Helm CLI [helm/tiller] 2.13.1 (Package Manager for Kubernetes)
-	Java SE JDK 8 Update 212 (Amazon Corretto 8)
-	Java SE JDK 11.0.3 (Amazon Corretto 11)
-	Java SE JDK 12.0.1 (Oracle)
-	jq 1.6 (command-line JSON processor)
-	Python 2.7.14
	-	Pip 19.1.1
-	Python 3.7.1
	-	Pip 19.1.1

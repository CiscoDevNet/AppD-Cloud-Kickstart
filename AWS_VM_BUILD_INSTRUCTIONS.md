# AWS Amazon Linux 2 AMI Build Instructions

Follow these instructions to build the AWS Amazon Linux 2 AMI images.

The fist images purpose is: An AppDynamics Controller

The second images purpose is: The AWS EKS LaunchPad to run sample apps

## Prepare for the Build

All user credentials and installation inputs are driven by environment variables and can
be configured in the `set_appd_cloud_kickstart_env.sh` script located in `./bin`. There
are LOTS of options, but most have acceptable defaults. You only need to concentrate
on a handful that are uncommented in the environment template file.

In particular, you will need to supply your AppDynamics login credentials to the
[download site](https://download.appdynamics.com/download/). You will also need to
provide an AWS Access Key ID and Secret Access Key from a valid AWS account.

The build will __fail__ if they are not set.

To prepare for the build, perform the following steps:

1.	Customize your AppD Cloud Kickstart project environment:

    Copy and edit the `set_appd_cloud_kickstart_env.sh` file located in `./bin`.

    ```
    $ cd /<drive>/projects/AppD-Cloud-Kickstart/bin
    $ cp -p set_appd_cloud_kickstart_env.sh.template set_appd_cloud_kickstart_env.sh
    $ vi set_appd_cloud_kickstart_env.sh
    ```

    The following environment variables are the most common to be overridden. They are
    grouped by sections in the file, so you will have to search to locate the exact line.
    For example, the AWS-related variables are at the end of the file.

    The first 4 are manditory and the others are optional, but helpful. If you are
    building the AMI images in the `us-west-2` region, the region-related variables
    can be left alone.

    ```
    appd_username="<Your_AppDynamics_Download_Site_Email>"
    appd_password="<Your_AppDynamics_Download_Site_Password>"

    AWS_ACCESS_KEY_ID="<Your_AWS_ACCESS_KEY_ID>"
    AWS_SECRET_ACCESS_KEY="<Your_AWS_SECRET_ACCESS_KEY>"

    aws_cli_default_region_name="us-east-2"
    aws_ami_owner="<Your Firstname> <Your Lastname>"
    aws_ami_region="us-east-2"
    ```

    Save and source the environment variables file in order to define the variables in your shell.

    ```
    $ source ./set_appd_cloud_kickstart_env.sh
    ```

    Validate the sourcing of the file was successful via the following command which should return environment variances:

    ```
    $ env | grep -i "appd"
    ```

2.	Supply a valid AppDynamics Controller license file:

  -	This license can be supplied by any AppDynamics SE
  -	It is recommended to have at least 10 APM, 10 server, 10 network, 5 DB, 1 unit of each Analytics and 1 unit of each RUM within the license key
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

-	AppDynamics Enterprise Console 4.5.7.0 Build 17784
	-	AppDynamics Controller 4.5.7.1 Build 17076
	-	AppDynamics Event Service 4.5.2.0 Build 20201
-	Docker 18.06.1-ce
	-	Docker Bash Completion
	-	Docker Compose 1.23.2
	-	Docker Compose Bash Completion
-	Java SE JDK 8 Update 202
-	jq 1.6 (command-line JSON processor)
-	MySQL Shell 8.0.15
-	Python 2.7.14
	-	Pip 19.0.3

The following AWS CLI command-line tools and utilities are pre-installed in the __LPAD-EKS VM__:

-	Amazon AWS CLI 1.16.117 (command-line interface)
-	Amazon AWS EKS CLI [eksctl] 0.1.23 (command-line interface)
-	Amazon AWS IAM Authenticator 1.11.5 for AWS EKS CLI and kubectl.
-	Amazon AWS Kubernetes Control CLI [kubectl] 1.11.5 (command-line interface)
-	Docker 18.06.1-ce
	-	Docker Bash Completion
	-	Docker Compose 1.23.2
	-	Docker Compose Bash Completion
-	Git 2.21.0
	-	Git Bash Completion
	-	Git-Flow 1.12.1 (AVH Edition)
	-	Git-Flow Bash Completion
-	Java SE JDK 8 Update 202
-	jq 1.6 (command-line JSON processor)
-	Python 2.7.14
	-	Pip 19.0.3
-	Python 3.7.1
	-	Pip 19.0.3

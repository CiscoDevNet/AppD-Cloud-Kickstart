# Lab Exercise 1
## Launch the First EC2 Instance (e.g. Launch Pad).

The Launch Pad EC2 instance is used to execute all the steps needed for the creation and management of the Kubernetes (AWS EKS) cluster. It comes pre-installed with utilities like AWS CLI, kubectl, eksctl, etc.

In this exercise you will use the [AWS Management Console](https://aws.amazon.com/console/) to launch the first EC2 instance that will be used to clone two GitHub repositories and create the EKS cluster in the next lab exercise.

This EC2 instance will be referenced in the lab steps as the 'Launch Pad EC2'.

You will need to use an existing AMI image named **LPAD-CentOS77-AMI** located in the AWS region that you are working in:

**NOTE:** Though any region can be utilized, this workshop creates a VPC, Elastic IP address, and NAT Gateway. You may run into issues with default limits for these resources. In the AppDynamics AWS environment, these limits have been increased in several regions. In general, please be aware that these limits may impact your ability to create a EKS Cluster.

- The AMI image for the **us-east-1** region can be found [here](https://us-east-1.console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:sort=tag:Name).
- The AMI image for the **us-east-2** region can be found [here](https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:sort=tag:Name).
- The AMI image for the **us-west-2** region can be found [here](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:sort=tag:Name).

<br>

Once you have identified the appropriate AMI, launch an instance of it via:

#### 1. Select the **LPAD-CentOS77-AMI** and click the **Launch** button.
#### 2. Select General Purpose: **t2.micro**.
#### 3. Click '**Next: Configure Instance Details**' in the bottom right.
#### 4. Keep all default values; scroll to the bottom and expand '**Advanced Details**'.

Once 'Advance Details' is expanded, enter the following '**User data**' commands '**As text**'.

This allows you to customize configuration of the EC2 instance during launch.

Copy and paste the following script code in the the 'User data' text box:

```
#!/bin/sh
cd /opt/appd-cloud-kickstart/provisioners/scripts/aws
chmod 755 ./initialize_al2_lpad_cloud_init.sh

AWS_ACCESS_KEY_ID="<Your_AWS_Access_Key_Here>"
export AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY="<Your_AWS_Secret_Access_Key_Here>"
export AWS_SECRET_ACCESS_KEY
aws_cli_default_region_name="<Your_AWS_Region_Here>"
export aws_cli_default_region_name

./initialize_al2_lpad_cloud_init.sh
```

Before continuing, you need to substitute the values for the actual **AWS_ACCESS_KEY_ID** and **AWS_SECRET_ACCESS_KEY**
environment variables with valid credentials for your environment.
Also set the **aws_cli_default_region_name** environment variable. Valid values are: 'us-east-1', 'us-east-2', and 'us-west-2'.
Please note the variables are case sensitive:

If the above section is not completed correctly at VM creation, the Launch Pad EC2 instance will not function as intended.

#### 5. Click '**Next: Add Storage**' in the bottom right.

Leave the defaults.

#### 6. Click '**Next: Add Tags**' in the bottom right.

Add one tag as shown below. For example, if your user name is 'John Smith', enter the following:

Key: **Name**  
Value: **User-LPAD-John-Smith**

#### 7. Click '**Next: Configure Security Group**' in the bottom right.

Select the following group from the drop down:

![Security Group](./images/security-group-01.png)

#### 8. Click '**Review and Launch**' to launch your VM. When prompted for a key pair:  

     a. Select the **AppD-Cloud-Kickstart-AWS** pem if you have access to it. You can request this key from the workshop creators.  
     b. Otherwise: Select **Create a new key pair** and give it a name. Remember to download it and save it locally.  

**NOTE:** Once the VM is launched, take note of the Public IP Address (FQDN) of the server. You will be leveraging this server in the remainder of the lab.

<br>

[Overview](aws-eks-monitoring.md) | 1, [2](lab-exercise-02.md), [3](lab-exercise-03.md), [4](lab-exercise-04.md), [5](lab-exercise-05.md), [6](lab-exercise-06.md) | [Back](aws-eks-monitoring.md) | [Next](lab-exercise-02.md)

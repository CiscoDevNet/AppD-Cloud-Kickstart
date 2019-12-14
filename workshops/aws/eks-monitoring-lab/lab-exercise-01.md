# Lab Exercise 1
## Launch the First EC2 Instance (e.g. Launch Pad EC2).

The Launch Pad EC2 instance is used to execute all the steps needed for creation and management of the Kubernetes (AWS EKS) cluster. It comes pre-installed with utilities like AWS CLI, kubectl, eksctl, etc.

In this exercise you will use the [AWS Management Console](https://aws.amazon.com/console/) to launch the first EC2 instance that will be used to clone two Github repositories and create the EKS cluster in the next lab step.

This EC2 instance will be referenced in the lab steps as the 'Launch Pad EC2'.

You will need to use an existing AMI image named **LPAD-CentOS77-AMI** located in the AWS region that you are working in:

**NOTE:** Though any region can be utilized, this workshop creates a VPC and utilizes an elastic IP address. You may run into issues with default limits for these resources. In the AppDynamics AWS environment, these limits have been increased in **us-east-1**. If you are internal to AppD, it is recommended to utilize this region. For clients, know these limits may impact your ability to create a EKS Cluster later on.

- The AMI image for the **us-east-1** region can be found [here](https://us-east-1.console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:sort=tag:Name).
- The AMI image for the **us-east-2** region can be found [here](https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:sort=tag:Name).
- The AMI image for the **us-west-1** region can be found [here](https://us-west-1.console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:sort=tag:Name).
- The AMI image for the **us-west-2** region can be found [here](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:sort=tag:Name).

<br>

Once you have identified the appropriate AMI, launch an instance of it via:

  1. Select the AMI > Launch
  2. Select General Purpose: **t2.micro**
  3. Click 'Configure Instance Details' in the bottom right
  4. Keep all default values
  5. Scroll to the bottom and expand 'Advanced Details'

Once 'Advance Details' is expanded, enter the following 'User data' commands 'As text'.

This allows you to configure the EC2 instance during launch.

Before continuing, you need to define the **AWS_ACCESS_KEY_ID** and **AWS_SECRET_ACCESS_KEY** environment
variables with valid credentials for your environment. Also set **user_name** and **aws_cli_default_region_name**
environment variables as needed (defaults are shown). Please note the variables are case sensitive:

```
#!/bin/sh
cd /opt/appd-cloud-kickstart/provisioners/scripts/aws
chmod 755 ./initialize_al2_lpad_cloud_init.sh

user_name="centos"                      # Modify username as needed.
export user_name
AWS_ACCESS_KEY_ID=""                    # Set AWS Access Key ID.
export AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=""                # Set AWS Secret Access Key.
export AWS_SECRET_ACCESS_KEY
aws_cli_default_region_name="us-east-1" # Modify region name as needed.
export aws_cli_default_region_name

./initialize_al2_lpad_cloud_init.sh
```

If the above section is not completed at VM creation, the Launch Pad instance will not function as intended.

  6. Select on 'Add Storage' tab and chose default options.
  7. Next, select the 'Add Tags' tab. Add one tag. [Key = Name , Value = User-Lpad-Initials].
     For example, if your user name is 'John Calvin Smith', enter the following:

     Key: Name  
     Value: User-Lpad-JCS

  8. Next Select the 'Configure Security Group' tab. Select the following group from the drop down.

![Security Group](./images/security-group-01.png)

  9. Review and Launch your VM. When prompted for a key pair:  

     a. If you are internal to AppD: Select the **AppD-Cloud-Kickstart-AWS** pem if you have access to it. You can request this key from the workshop creators.  
     b. If you are external: Select **Create a new key pair** and give it a name. Remember to download it and save it locally.  

**NOTE:** Once the VM is launched, take note of the FQDN of the server. You will be leveraging this server in the remainder of the lab.

<br>

[Overview](aws-eks-monitoring.md) | 1, [2](lab-exercise-02.md), [3](lab-exercise-03.md), [4](lab-exercise-04.md), [5](lab-exercise-05.md), [6](lab-exercise-06.md) | [Back](aws-eks-monitoring.md) | [Next](lab-exercise-02.md)

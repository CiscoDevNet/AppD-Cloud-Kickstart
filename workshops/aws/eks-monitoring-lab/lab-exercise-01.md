# Lab Exercise 1
## Launch the First EC2 Instance (e.g. Launch Pad EC2). This is going to be used to execute all the steps needed for installation.



In this exercise you will use the [AWS Management Console](https://aws.amazon.com/console/) to launch the first EC2 instance that will be used to clone two Github repositories and create the EKS cluster in the next lab step.

This EC2 instance will be referenced in the lab steps as the 'Launch Pad EC2'.

You will need to use an existing AMI image named **LPAD-EKS-AL2-AMI** and located in the AWS region that you are working in:

- The AMI image for the **us-west-2** region can be found [here](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:sort=tag:Name).
- The AMI image for the **us-east-2** region can be found [here](https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:sort=tag:Name).

<br>

.......

Click on the 'Advanced' link on the bottom left of the console screen to enter the following 'User data' commands.
This allows you to configure the EC2 instance during launch.

Before continuing, you will need to define the **AWS_ACCESS_KEY_ID** and **AWS_SECRET_ACCESS_KEY** environment
variables with valid credentials for your environment. If you are NOT working in the 'us-west-2' region, also
uncomment and set the **aws_cli_default_region_name**. Please note the variables are case sensitive:

```
#!/bin/sh
cd /opt/appd-cloud-kickstart/provisioners/scripts/aws
chmod 755 ./initialize_al2_lpad_eks_cloud_init.sh

# Set unique AWS CLI config parameters.
AWS_ACCESS_KEY_ID=""
export AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=""
export AWS_SECRET_ACCESS_KEY
#aws_cli_default_region_name="us-east-2"    # Default is 'us-west-2'. Uncomment if in 'us-east-2'.
#export aws_cli_default_region_name

./initialize_al2_lpad_eks_cloud_init.sh
```

<br>

[Overview](aws-eks-monitoring.md) | [1](lab-exercise-01.md), [2](lab-exercise-02.md), [3](lab-exercise-03.md), [4](lab-exercise-04.md), [5](lab-exercise-05.md), [6](lab-exercise-06.md) | [Back](aws-eks-monitoring.md) | [Next](lab-exercise-02.md)

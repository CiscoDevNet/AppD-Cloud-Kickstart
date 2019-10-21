# Lab Exercise 3
## Launch the Second EC2 Instance (e.g. Controller EC2)

The AppDynamics Controller is the central management server where all data is stored and analyzed. All AppDynamics Agents connect to the Controller to report data, and the Controller provides a browser-based user interface for monitoring and troubleshooting application performance.

In this exercise you will use the [AWS Management Console](https://aws.amazon.com/console/) to launch the second EC2 instance that will have the AppDynamics Enterprise Console, Controller, and Events Service running on it.

This EC2 instance will be referenced in the lab steps as the 'Controller EC2'.

You will need to use an existing AMI image named **APM-Platform-4514-CentOS77-AMI** and located in the AWS region that you are working in:

- The AMI image for the **us-west-1** region can be found [here](https://us-west-1.console.aws.amazon.com/ec2/v2/home?region=us-west-1#Images:sort=tag:Name).
- The AMI image for the **us-west-2** region can be found [here](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:sort=tag:Name).
- The AMI image for the **us-east-1** region can be found [here](https://us-east-1.console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:sort=tag:Name).
- The AMI image for the **us-east-2** region can be found [here](https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:sort=tag:Name).

<br>

Once you have identified the appropriate AMI, launch an instance of it via:

  1. Select the AMI > Launch
  2. Select Memory optimized 'r5a.large' or 'r5.large' with 2 vCPUs and 16 GiB RAM
  3. Click 'Configure Instance Details' in the bottom right
  4. Keep all default values
  5. Scroll to the bottom and Expand Advanced

Click on the 'Advanced' link on the bottom left of the console screen to enter the following 'User data' commands.
This allows you to configure the EC2 instance during launch:

```
#!/bin/sh
cd /opt/appd-cloud-kickstart/provisioners/scripts/aws
chmod 755 ./initialize_al2_apm_platform_cloud_init.sh

user_name="centos"                          # Default is 'centos'. Modify if using another username.
export user_name

./initialize_al2_apm_platform_cloud_init.sh
```

  6. Select on 'Add Storage' tab and chose default options.
  7. Next Select on 'Add Tags' tab. Add one tag. [Key = Name , Value = User_Ctlr_Initials].

    Example of Value field:
    User Name: John Calvin Smith
    
    Key = Name
    Value=User-Ctlr-JCS

  8. Next Select the 'Configure Security Group' tab. Select the following group from the drop down.

![Security Group](./images/security-group-01.png)

  9. Review and Launch your VM. When prompted for a key pair:  

     a. If you are internal to AppD: Select the **AppD-Cloud-Kickstart-AWS** pem if you have access to it. You can request this key from the workshop creators.  
     b. If you are external: Use the same key pair that you created in [Lab Exercise 1](lab-exercise-01.md). Remember to substitute the name of your downloaded '.pem' file for 'AppD-Cloud-Kickstart-AWS.pem' in all of the remaining lab exercises.

**NOTE:** Once the VM is launched, take note of the FQDN of the server. You will be leveraging this server in the remainder of the lab.

Your controller address will be:

http://FQDN_OF_MACHINE:8090/controller

<br>

[Overview](aws-eks-monitoring.md) | [1](lab-exercise-01.md), [2](lab-exercise-02.md), 3, [4](lab-exercise-04.md), [5](lab-exercise-05.md), [6](lab-exercise-06.md) | [Back](lab-exercise-02.md) | [Next](lab-exercise-04.md)

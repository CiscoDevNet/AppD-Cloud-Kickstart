# AWS EKS Monitoring

AWS EKS Monitoring Lab Guide.

## Overview

This is a work-in-progress.

### Launch EC2 Instance for Controller

In this step you will use the [AWS Management Console](https://aws.amazon.com/console/) to launch a new EC2 instance that will have the AppDynamics Enterprise Console, Controller, and Events Service running on it.

based on an existing AMI which can be found here...???


```
#!/bin/sh
cd /opt/appd-cloud-kickstart/provisioners/scripts/aws
chmod 755 ./initialize_al2_apm_platform_cloud_init.sh
./initialize_al2_apm_platform_cloud_init.sh

```

### Launch EC2 Instance for Launch Pad


```
#!/bin/sh
cd /opt/appd-cloud-kickstart/provisioners/scripts/aws
chmod 755 ./initialize_al2_lpad_eks_cloud_init.sh
./initialize_al2_lpad_eks_cloud_init.sh

```

### SSH into Launch Pad 

TODO...


### Clone Github Repositories

Once you have an SSH command terminal open to the EC2 instance for the launch pad, you need to clone two Github repositories by issuing the commands below:

```
cd /home/ec2-user
git clone https://github.com/Appdynamics/AppD-Cloud-Kickstart.git
git clone https://github.com/Appdynamics/AD-Capital-Kube.git
```

### Create EKS Cluster

TODO...

```
cd /home/ec2-user/AppD-Cloud-Kickstart/applications/aws/AD-Capital-Kube
chmod -R 775 .
```

TODO... Explain usage of user name and region

```
export appd_aws_eks_user_name=User-0X
export appd_aws_eks_region=us-west-2
```

TODO...

```
./create_eks_cluster.sh
```


![Installation Options](./images/2.png)

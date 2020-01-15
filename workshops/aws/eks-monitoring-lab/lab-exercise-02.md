# Lab Exercise 2
## Clone Github Repositories & Create EKS Cluster

This workshop takes previously configured docker-compose applications (AD-Capital-Kube) and makes them deployable to a kubernetes cluster. If you are curious about any of the repositiories; either the original java application code itself or the dockerized version, they are publicly available with detailed explanations as to what they contain. For the purpose of this walkthrough, it will be focused solely on Kubernetes.

In this exercise you will need to do the following:

- SSH into the Launch Pad EC2 instance
- Clone two Github repositories
- Run a script to create a new EKS cluster

### **1.** SSH Into the Launch Pad EC2 Instance
You will need a copy of the `AppD-Cloud-Kickstart-AWS.pem` file in order to SSH into your Launch Pad EC2 instance. You can obtain a copy of the `AppD-Cloud-Kickstart-AWS.pem` file from your lab instructor.  

Otherwise: Use the key pair that you created in [Lab Exercise 1](lab-exercise-01.md). Remember to substitute the name of your downloaded '.pem' file for 'AppD-Cloud-Kickstart-AWS.pem' in all of the remaining lab exercise steps.  
<br>
You will use the user name '**centos**' with no password to SSH into the Launch Pad EC2 instance.
<br><br>

***For Mac Users:***

Run the command below from a terminal window, with the path to your copy of the `AppD-Cloud-Kickstart-AWS.pem` file and the host name or IP Address of your Launch Pad EC2 instance
```
chmod 400 <path-to-file>/AppD-Cloud-Kickstart-AWS.pem
ssh -i <path-to-file>/AppD-Cloud-Kickstart-AWS.pem <hostname-of-your-launch-pad-ec2-instance>
```

Example:
```
ssh -i AppD-Cloud-Kickstart-AWS.pem centos@ec2-54-214-99-204.us-east-1.compute.amazonaws.com
```

<br>

***For Windows Users:***

You will need [PuTTY](https://www.putty.org/) or another SSH client installed to SSH into the Launch Pad EC2 instance
<br>

If you are using PuTTY, you can find the instructions to convert the pem file to a ppk file in the link provided below:

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html#putty-private-key

<br>

***After Logging In:***

**NOTE** If you created your own SSH key, you will need to set the value of the '**appd_aws_eks_ssh_public_key**' environment variable with the name of your key. The default is '**AppD-Cloud-Kickstart-AWS.pem**.

```
export appd_aws_eks_ssh_public_key=your-unique-ssh-key
```
<br>

### **2.** Clone Github Repositories

Once you have an SSH command terminal open to the EC2 instance for the launch pad, you need to clone two Github repositories by running the commands below:

```
cd /home/centos

git clone https://github.com/Appdynamics/AppD-Cloud-Kickstart.git

cd /home/centos

git clone https://github.com/Appdynamics/AD-Capital-Kube.git
```

After you run the commands, you should have two new folders in your home directory

*/home/centos/AD-Capital-Kube*
*/home/centos/AppD-Cloud-Kickstart*

![Git Repos Pulled](./images/2.png)

<br>

### **3.** Create EKS Cluster

Change to the directory where you will set permissions on the scripts used in the next steps by running the commands below:

```
cd /home/centos/AppD-Cloud-Kickstart/applications/aws/AD-Capital-Kube
```
<br>
Next, you will need to set two environment variables before you run the script to create the EKS cluster. The first variable, **appd_aws_eks_user_name**, needs special instructions, so please read carefully.  
<br>
**It is VERY IMPORTANT that the 'appd_aws_eks_user_name' variable BE UNIQUE TO YOU !!!**  

This variable is used as the name of the EKS cluster and the cluster creation will fail if there is any existing cluster with the same name. It could also interfere with another persons cluster with the same name if they are running the script to create the cluster when you are.

It is advisable to set the '**appd_aws_eks_user_name**' variable to a value that is a combination of your name or initials combined with a date number sequence to ensure a unique cluster name.

Example:
<br>

Users Name: **John Smith**

Date Number Sequence: **2020-01-15**

The example command based on users name and date number sequence show above:

*export appd_aws_eks_user_name=User-John-Smith-2020-01-15*

<br>

Run the command below, replacing 'your-unique-user-id' with the unique user id you created based on the instructions above:
```
export appd_aws_eks_user_name=your-unique-user-id
```
<br>

The second variable ('**appd_aws_eks_region**') needs to specify the AWS region that you are working in.  Currently, only the three regions below are supported.

- us-east-1
- us-east-2
- us-west-2

<br>

If you are working in the **us-east-1** region, run the command below:
```
export appd_aws_eks_region=us-east-1
```

If you are working in the **us-east-2** region, run the command below:
```
export appd_aws_eks_region=us-east-2
```

If you are working in the **us-west-2** region, run the command below:
```
export appd_aws_eks_region=us-west-2
```


<br>

Once both variables have been set, run the commands below to create the EKS cluster.

```
cd /home/centos/AppD-Cloud-Kickstart/applications/aws/AD-Capital-Kube

./create_eks_cluster.sh
```

<br>

You should start to see output from the command that is similar to the image seen below:

- Leave the exiting SSH terminal window open and running
- The cluster creation command will take roughly 15 minutes to finish
- You can proceed to [Lab Exercise 3](lab-exercise-03.md) at this point

<br>

![EKS Cluster Created](./images/3.png)

**NOTE:** If you run into any CloudFormation rollback errors, it could be due to a VPC/Elastic IP/NAT Gateway limit. See [CloudFormation Rollback Error](cloud-formation-rollback-error.md) for more information and instructions on how to resolve.

[Overview](aws-eks-monitoring.md) | [1](lab-exercise-01.md), 2, [3](lab-exercise-03.md), [4](lab-exercise-04.md), [5](lab-exercise-05.md), [6](lab-exercise-06.md) | [Back](lab-exercise-01.md) | [Next](lab-exercise-03.md)

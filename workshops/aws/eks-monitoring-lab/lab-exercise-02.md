# Lab Exercise 2
## Clone GitHub Repositories & Create EKS Cluster

This workshop takes previously configured docker-compose applications (AD-Capital-Kube) and makes them deployable to a kubernetes cluster. If you are curious about any of the repositiories; either the original java application code itself or the dockerized version, they are publicly available with detailed explanations as to what they contain. For the purpose of this walkthrough, it will be focused solely on Kubernetes.

In this exercise you will need to do the following:

- SSH into the Launch Pad EC2 instance
- Clone two GitHub repositories
- Run a command to connect to an EKS cluster

### **1.** SSH Into the Launch Pad EC2 Instance
You will need a copy of the `AppD-Cloud-Kickstart-AWS.pem` file in order to SSH into your Launch Pad EC2 instance. You can obtain a copy of the `AppD-Cloud-Kickstart-AWS.pem` file from your lab instructor.  

Otherwise: If you created a new SSH key pair in [Lab Exercise 1](lab-exercise-01.md), remember to substitute the name of your downloaded '.pem' file for 'AppD-Cloud-Kickstart-AWS.pem' in all of the remaining lab exercise steps.  
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
ssh -i AppD-Cloud-Kickstart-AWS.pem centos@ec2-54-214-99-204.eu-west-3.compute.amazonaws.com
```

<br>

***For Windows Users:***

You will need [PuTTY](https://www.putty.org/) or another SSH client installed to SSH into the Launch Pad EC2 instance
<br>

If you are using PuTTY, you can find the instructions to convert the pem file to a ppk file in the link provided below:

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html#putty-private-key

<br>

### **2.** Clone GitHub Repositories

Once you have an SSH command terminal open to the EC2 instance for the launch pad, you need to clone two GitHub repositories by running the commands below:

```
cd /home/centos

git clone https://github.com/Appdynamics/AppD-Cloud-Kickstart.git
cd AppD-Cloud-Kickstart
git fetch origin
git checkout -b cleur20-lab origin/cleur20-lab

cd /home/centos

git clone https://github.com/Appdynamics/AD-Capital-Kube.git
```

After you run the commands, you should have two new folders in your home directory

*/home/centos/AD-Capital-Kube*

*/home/centos/AppD-Cloud-Kickstart*

![Git Repos Pulled](./images/2.png)

<br>

### **3.** Connect to the EKS Cluster

Change to the directory where you will prepare to connect to your AWS EKS cluster and create a local `kubeconfig`:

```
cd /home/centos/AppD-Cloud-Kickstart/applications/aws/AD-Capital-Kube
```
<br>

Next, you will need to set two environment variables. The first variable, '**appd_aws_eks_user_name**', needs special instructions, so please read carefully.  

<br>

**It is VERY IMPORTANT that the 'appd_aws_eks_user_name' variable BE UNIQUE TO YOU !!!**  

This variable is used as the name of the EKS cluster and the cluster configuration will fail if do not follow this step properly. It could also interfere with another persons cluster with the same name if they are running commands to configure the cluster when you are.

It is advisable to set the '**appd_aws_eks_user_name**' variable to a value that was assigned to your by your lab instructor to ensure a unique cluster name.

Example:
<br>

Lab User Name: **Lab-User-01**

The example command based on the lab user name and number sequence show above:

*export appd_aws_eks_user_name=Lab-User-01*

<br>

Run the command below, replacing 'your-unique-lab-user-id' with the unique lab user id you were assigned based on the instructions above:
```
export appd_aws_eks_user_name=your-unique-lab-user-id
```
<br>

The second variable ('**appd_aws_eks_region**') needs to specify the AWS region that you were assigned to work in.  Currently, only the three regions below are supported.

- eu-central-1
- eu-west-2
- eu-west-3

<br>

If you were assigned to work in the **eu-central-1** region, run the command below:
```
export appd_aws_eks_region=eu-central-1
```

If you were assigned to work in the **eu-west-2** region, run the command below:
```
export appd_aws_eks_region=eu-west-2
```

If you were assigned to work in the **eu-west-3** region, run the command below:
```
export appd_aws_eks_region=eu-west-3
```


<br>

Once both variables have been set, run the commands below to connect to your AWS EKS cluster and create a local `kubeconfig`:

```
cd /home/centos/AppD-Cloud-Kickstart/applications/aws/AD-Capital-Kube

./create_kubeconfig_for_eks.sh

```

<br>

Check to see if the output from the command is similar to the image seen below:

<br>

![EKS Kubeconfig Updated](./images/create-kubeconfig.png)

[Overview](aws-eks-monitoring.md) | [1](lab-exercise-01.md), 2, [3](lab-exercise-03.md), [4](lab-exercise-04.md), [5](lab-exercise-05.md), [6](lab-exercise-06.md) | [Back](lab-exercise-01.md) | [Next](lab-exercise-03.md)

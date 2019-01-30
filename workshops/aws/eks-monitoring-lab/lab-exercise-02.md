# Lab Exercise 2
## Clone Github Repositories & Create EKS Cluster

In this step you will need to do the following:

- SSH into the Launch Pad EC2 instance
- Clone two Github repositories
- Run commands to create a new EKS cluster



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


<br>

[Overview](aws-eks-monitoring.md) | [1](lab-exercise-01.md), [2](lab-exercise-02.md), [3](lab-exercise-03.md), [4](lab-exercise-04.md), [5](lab-exercise-05.md), [6](lab-exercise-06.md) | [Back](lab-exercise-01.md) | [Next](lab-exercise-03.md)
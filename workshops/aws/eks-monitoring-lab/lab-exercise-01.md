# Lab Exercise 1
## Launch the First EC2 Instance (e.g. Launch Pad EC2)



In this exercise you will use the [AWS Management Console](https://aws.amazon.com/console/) to launch the first EC2 instance that will be used to clone two Github repositories and create the EKS cluster in the next lab step.

This EC2 instance will be referenced in the lab steps as the 'Launch Pad EC2'. 

You will need to use an existing AMI image located in the AWS region that you are working in:

- The AMI image for the **us-west-2** region can be found [here ???](???)
- The AMI image for the **us-east-2** region can be found [here ???](???)

<br>

.......

Click on the 'Advanced' link on the bottom left of the console screen to enter the following commands:

```
#!/bin/sh
cd /opt/appd-cloud-kickstart/provisioners/scripts/aws
chmod 755 ./initialize_al2_lpad_eks_cloud_init.sh
./initialize_al2_lpad_eks_cloud_init.sh

```

<br>

[Overview](aws-eks-monitoring.md) | [1](lab-exercise-01.md), [2](lab-exercise-02.md), [3](lab-exercise-03.md), [4](lab-exercise-04.md), [5](lab-exercise-05.md), [6](lab-exercise-06.md) | [Back](aws-eks-monitoring.md) | [Next](lab-exercise-02.md)
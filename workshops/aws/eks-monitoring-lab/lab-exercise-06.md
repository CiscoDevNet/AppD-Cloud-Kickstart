# Lab Exercise 6
## Delpoy the Kubernetes Extension to EKS



In this exercise you will need to do the following:

- Deploy the Kubernetes Extension to the EKS cluster
- Monitor the results of delpoying the Kubernetes Extension
- Create a new custom dashboard for Kubernetes events

<br>

### **1.** Deploy the Kubernetes Extension to EKS

Using the SSH terminal for the Launch Pad EC2 instance, change to the directory to deploy the Kubernetes Extension by running the command below:

```
cd /home/ec2-user/AppD-Cloud-Kickstart/applications/aws/AD-Capital-Kube/KubeExtMachineAgent
```
Depending on what AWS region you deployed the AD-Capital application to in the previous exercise, **run only one** of the following commands below which correspond to your AWS region to deploy the Kubernetes Extension:

```
kubectl create -f us-west-2/
```

```
kubectl create -f us-east-2/
```

You should see output from the command similar to the image seen below:

![Create KubeExt](./images/20.png)

<br>

### **2.** Monitor the Results of Deploying the Kubernetes Extension to EKS

Now wait two minutes and run the command below to validate that the extension has been deployed to the cluster:

```
kubectl get pods -n default
```
You should then see output similar to the image seen below:

![EKS Pods](./images/21.png)

After 12 minutes, you will see a new dashboard created like the image seen below.  You can find it by navigating to the Dashboards & Reports tab at the top menu in the AppDynamics UI:

![Kubernetes Ext Dashboard](./images/22.png)

<br>

[Overview](aws-eks-monitoring.md) | [1](lab-exercise-01.md), [2](lab-exercise-02.md), [3](lab-exercise-03.md), [4](lab-exercise-04.md), [5](lab-exercise-05.md), [6](lab-exercise-06.md) | [Back](lab-exercise-05.md)
# Lab Exercise 1
## Clone GitHub Repository & Configure GKE Kubernetes Cluster

This workshop takes previously configured docker-compose applications (AD-Capital-Kube) and makes them deployable to a kubernetes cluster. If you are curious about any of the repositiories; either the original java application code itself or the dockerized version, they are publicly available with detailed explanations as to what they contain. For the purpose of this walkthrough, it will be focused solely on Kubernetes.

In this exercise you will need to do the following:

- SSH into the Launch Pad GCE instance
- Clone GitHub repository
- Run a command to connect to a GKE Kubernetes cluster

### **1.** SSH Into the Launch Pad GCE Instance
You will need a copy of the `AppD-Cloud-Kickstart.pem` file in order to SSH into your Launch Pad GCE instance. You can obtain a copy of the `AppD-Cloud-Kickstart.pem` file from your lab instructor.  

You will use the user name '**centos**' with no password to SSH into the Launch Pad GCE instance.
<br><br>

***For Mac Users:***

Run the command below from a terminal window, with the path to your copy of the `AppD-Cloud-Kickstart.pem` file and the IP Address of your Launch Pad GCE instance:
```bash
chmod 400 <path-to-file>/AppD-Cloud-Kickstart.pem
ssh -i <path-to-file>/AppD-Cloud-Kickstart.pem <ip-address-of-your-launch-pad-gce-instance>
```

Example:
```bash
ssh -i AppD-Cloud-Kickstart.pem centos@35.206.71.70
```

<br>

***For Windows Users:***

You will need [PuTTY](https://www.putty.org/) or another SSH client installed to SSH into the Launch Pad GCE instance.
<br>

If you are using PuTTY, you can obtain a copy of the `AppD-Cloud-Kickstart.ppk` file from your lab instructor.

Configure PuTTY to SSH into the Launch Pad GCE instance using the steps below:

1. Enter the public IP address of your LPAD instance
2. Enter a name for your session to your LPAD instance
3. Click on the Auth option under SSH
4. Click on the Browse button to select your PPK file
5. Click on the Session option at the top of the tree on the left
6. Click on the Save button and your session will be added to the list
7. Click on the Open button to start your session


![Git Repos Pulled](./images/putty-config-01.png)

![Git Repos Pulled](./images/gcp-putty-config-02.png)

![Git Repos Pulled](./images/putty-config-03.png)

When your session opens you will be prompted for your user name. Enter '**centos**' for the user name, no password is required.

![Git Repos Pulled](./images/gcp-putty-config-04.png)

<br>

### **2.** Clone GitHub Repository

Once you have an SSH command terminal open to the GCE instance for the launch pad, you need to clone the GitHub repository by running the commands below:

```bash
cd ~

git clone https://github.com/Appdynamics/AppD-Cloud-Kickstart.git
```

After you run the command, you should have this folder in your home directory.

*~/AppD-Cloud-Kickstart*

![Git Repos Pulled](./images/gcp-gke-monitoring-lab-01.png)

<br>

### **3.** Connect to the GKE Kubernetes Cluster

The gcloud command-line interface is the primary CLI tool to create and manage Google Cloud resources.  

Verify your gcloud CLI configuration:

```bash
gcloud config list
```

After you run the command, verify that your **account** settings begin with '**devops@**':

![Git Repos Pulled](./images/gcp-gke-monitoring-lab-02.png)

<br>

Next, verify the name of your GKE Cluster and retrieve the compute zone of the cluster:

```bash
echo $gcp_gke_cluster_name

gcloud container clusters list --filter="name:${gcp_gke_cluster_name}" --format="value(location)"
```

After you run the command, take note of your **GKE Cluster name** and '**Compute Zone (location)**':

![Git Repos Pulled](./images/gcp-gke-monitoring-lab-03.png)

<br>

Finally, update the local kubeconfig file with appropriate credentials and endpoint information for your GKE Cluster. By default, 
the credentials are written to `$HOME/.kube/config`. You can provide an alternate path by setting the `KUBECONFIG` environment variable.

Fetch the credentials for your GKE Cluster, making sure to update the zone with the location returned from the previous step.  

Then, validate the configuration by displaying a list of cluster services:

```bash
gcloud container clusters get-credentials ${gcp_gke_cluster_name} --zone us-central1-a

kubectl get services
```

Check to see if the output from the command is similar to the image seen below:

![Git Repos Pulled](./images/gcp-gke-monitoring-lab-04.png)

[Overview](gcp-gke-monitoring.md) | 1, [2](lab-exercise-02.md), [3](lab-exercise-03.md), [4](lab-exercise-04.md), [5](lab-exercise-05.md) | [Back](gcp-gke-monitoring.md) | [Next](lab-exercise-02.md)

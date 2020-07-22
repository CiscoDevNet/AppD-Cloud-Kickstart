## Kubernetes and AppD

For a detailed tutorial on how to install and configure this application for a Kubernetes cluster navigate to the [walkthrough](https://github.com/Appdynamics/AD-Capital-Kube/blob/master/KubernetesWalkthrough/1.md).


## Our Story

We had a multi-service application wrapped in docker that we wanted to move from on-prem to AWS w/ Kubernetes. In moving the parts to Kubernetes, we wanted to test locally before using production grade Kubernetes. The available options were Minikube and docker-for-mac (edge version with Kubernetes). While they aren't broken, then behavior was never consistent. This led to more time being spent restarting and investigating if it was us or Minikube. We also looked at a docker-compose converting function to move all of our docker-compose files to yaml files made for Kubernetes. This led to some unexpected conversions, and rather lack of general knowledge about all of the individual fields for Pods, Deployments, and Services. Long story short, don't try and cut corners by using minikube or kompose. You'll save a lot of time tinkering.

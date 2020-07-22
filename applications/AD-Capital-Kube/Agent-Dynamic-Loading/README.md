# Agents in this project

## Using the docker store image
This project takes advantage of two main docker images. There is a docker image
appdemo/adcapital-tomcat which is responsible for building the app with the java-agent.
If you take a look at the ADCapital-Tomcat folder in this directory, you can see
we are leveraging the docker store image (store/appdynamics/java:4.4_tomcat9-jre8-alpine). This is arguably the cleanest
as it requires just pairing together your dockerfile to pull from ours.

## Loading physical agents in docker
The DaemonSet in this project requires a machine agent to run. If you look at the
second folder appd-machine, you can see this Dockerfile takes advantage of using a
physical agent in the directory to build into the image. What's unique about this
method, is that you can add your cloud extensions here making it much easier to manage
ahead of time. In this scenario, we are loading the kubernetes extension (https://github.com/Appdynamics/kubernetes-events-extension)
with the necessary kubelet and controller config ahead of time. This is a great way
to deploy the machine agent on your cloud vendors with your cloud specific
extensions. For example, you could package the dockerfile with all aws extensions
if you deploy to aws.

## SideCar Agent
You also have the opportunity to load the agents via a shared volume or the sidecar method.
This is a popular method of running two containers in the same pod that share resources. In
this scenario we are loading the resources into a shared volume that the pod running
the application uses. If you look at adcapital-project, our startup.sh file is
loading source code and gradle into a shared volume. This project runs as an
init container, so that the application has the source code and packages it needs
before it's launched. You could download the agent to a shared directory that
the application then uses.

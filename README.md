# AppD-Cloud-Kickstart

The Cloud Kickstart is an enablement workshop demonstrating AppDynamics ability to monitor cloud native workloads. AWS support is currently available, with Azure and GCP to follow.

## Overview

End-to-end monitoring of cloud applications remains a challenge for most cloud consumers. Over the last few years, AppDynamics has released significant capabilities to meet this challenge.

Cloud Kickstart showcases these capabilities. The project consists of a collection of build, deploy, and provisioning assets; sample application; and instructions to aid in the delivery of the workshop.

Customers, partners, and sellers are free to leverage these materials and gain valuable hands-on experience monitoring cloud native applications using AppDynamics.

## Workshop Delivery Approach

Immutable infrastructure is an approach to managing services and software deployments on IT resources where components are replaced rather than changed. An application or service is effectively redeployed each time a change occurs.

This capability is deemed absolutely critical to achieve repeatability and scale. The workshop leverages this approach by automating the build and deployment of workshop VM images.

## Get Started

The first step is to set-up the environment by building the workshop images:

-	[Build Steps for Creating Immutable VM Images](BUILD_STEPS_FOR_CREATING_IMMUTABLE_VM_IMAGES.md)

Once the images are built, click on the following link to get started with the lab:

-	[AWS EKS Monitoring Lab Guide](workshops/aws/eks-monitoring-lab/aws-eks-monitoring.md)

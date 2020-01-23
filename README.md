# AppDynamics Cloud Adoption: Hands on Workshop
## Session ID: LTRCLD-2321

The AppDynamics Cloud Adoption: Hands on Workshop or Cloud Kickstart is an enablement workshop demonstrating AppDynamics ability to monitor cloud native workloads. AWS support is currently available, with Azure and GCP to follow. The idea is to deliver different chapters within each cloud provider bucket. The first chapter available within the AWS bucket is "AWS EKS Monitoring". More chapters will be added soon.

## Overview

End-to-end monitoring of cloud applications remains a challenge for most cloud consumers. Over the last few years, AppDynamics has released significant capabilities to meet this challenge.

Cloud Kickstart showcases these capabilities. The project consists of a collection of build, deploy, and provisioning assets; sample application; lab guides; and instructions to aid in the delivery of the workshop.

Customers, partners, and sellers are free to leverage these materials and gain valuable hands-on experience monitoring cloud native applications using AppDynamics.

This same content can also be delivered as community or corporate webinars.

## Workshop Delivery Approach

Immutable infrastructure is an approach to managing services and deployments of IT resources (applications and infrastructure) where components are replaced rather than changed. This capability is deemed absolutely critical to support reproducibility and scale.

The workshop leverages this approach by automating the build and deployment of workshop VM images.

## Get Started

The first step is to set-up the environment by building the workshop images:

-	[Build Steps for Creating Immutable VM Images](BUILD_STEPS_FOR_CREATING_IMMUTABLE_VM_IMAGES.md)

Once the images are built, click on the following link to get started with the lab:

-	[AWS EKS Monitoring Lab Guide](workshops/aws/eks-monitoring-lab/aws-eks-monitoring.md)

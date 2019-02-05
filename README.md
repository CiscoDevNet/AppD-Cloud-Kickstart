# AppD-Cloud-Kickstart

AppDynamics Cloud Kickstart repository for building and deploying cloud monitoring
enablement workshops featuring AWS, Azure, and GCP workloads. 

## Overview

Monitoring cloud applications is an area that remains challenging for many cloud
consumers. Over the past few years, AppDynamics has released a significant number
of new capabilities to address this cloud monitoring challenge.

To showcase these new capabilities, the **AppD-Cloud-Kickstart** project
provides a collection of build and deploy tooling, provisioning assets, and
training materials to aid in the delivery of small enablement workshops which
demonstrate AppDynamics' ability to monitor cloud native workloads.

The purpose of these workshops is to have our customers, partners, and sellers
gain hands-on experience around monitoring cloud native applications using
AppDynamics. The vision of this project is to cover a variety of monitoring
use cases across AWS, Azure and GCP.

## Workshop Delivery Approach

An important goal of the project is to automate the building and deploying of
immutable Workshop VM images using immutable infrastructure.

Immutable infrastructure is an approach to managing services and software
deployments on IT resources where components are replaced rather than changed.
An application or service is effectively redeployed each time a change occurs.

This capability was deemed absolutely critical to achieve repeatability and scale.
Otherwise, every workshop becomes a one-off and any changes (new software version,
new cloud service offerings, etc.) would impact our ability to deliver.

## Benefits

This delivery approach yields a number of benefits:

-	Speed of delivery. Workshop VM instances can be created and destroyed dynamically.
-	Our partners have the ability to take advantage of the workshop assets outside of a formal classroom environment.
-	Our partners can always take advantage of the latest and greatest versions of the product and workshop assets.

## Get Started

To get started building the immutable workshop VM images, click on the following link:

-	[Build Steps for Creating Immutable VM Images](BUILD_STEPS_FOR_CREATING_IMMUTABLE_VM_IMAGES.md)

To get started with the enablement workshop, click on the link below:

-	[AWS EKS Monitoring Lab Guide](workshops/aws/eks-monitoring-lab/aws-eks-monitoring.md)

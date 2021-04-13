# AppD Cloud Kickstart

**NEW!!** Announcing support for Google Kubernetes Engine (GKE).  

The Cloud Kickstart is an enablement workshop demonstrating AppDynamics ability to monitor cloud native 
workloads. AWS and GCP support is currently available, with Azure support to follow. The idea is to deliver 
different chapters within each cloud provider bucket. The first chapter available within the AWS bucket 
is **AWS EKS Monitoring**. Likewise, the first chapter available within the GCP bucket is **GCP GKE Monitoring**. 
More chapters will be added soon.

## Overview

End-to-end monitoring of cloud applications remains a challenge for most cloud consumers. Over the last 
few years, AppDynamics has released significant capabilities to meet this challenge.

Cloud Kickstart showcases these capabilities. The project consists of a collection of build, deploy, and 
provisioning assets; sample application; lab guides; and instructions to aid in the delivery of the workshop.

Customers, partners, and sellers are free to leverage these materials and gain valuable hands-on experience 
monitoring cloud native applications using AppDynamics.

This same content can also be delivered as community or corporate webinars.

## Workshop Delivery Approach

Immutable infrastructure is an approach to managing services and deployments of IT resources (applications 
and infrastructure) where components are replaced rather than changed. This capability is deemed absolutely 
critical to support reproducibility and scale.

The workshop leverages this approach by automating the build and deployment of workshop VM images.

## Get Started

To get started, AppDynamics SEs, partners, or others tasked with delivering the Workshop need to build and 
deploy the necessary cloud resources required for each cloud provider:

**NOTE:** Lab participants should skip to the next section.

-	[Build Steps for Preparing the Workshop](docs/BUILD_STEPS_FOR_PREPARING_THE_WORKSHOP.md)

Once the cloud environment is prepared, click on one of the following links to get started with the workshop:

-	[AWS EKS Monitoring Lab Guide](workshops/aws/eks-monitoring-lab/aws-eks-monitoring.md)
-	[GCP GKE Monitoring Lab Guide](workshops/gcp/gke-monitoring-lab/gcp-gke-monitoring.md)

## Overview

Amazon Elastic Container Service for Kubernetes (EKS) makes it easier to operate Kubernetes clusters, but performance monitoring remains a top challenge. AppDynamics seamlessly integrates into EKS environments, providing insights into the performance of every microservice deployed and bring container and K8 visibility, all through a single pane of glass. On the heels of announcing the general availability of AppDynamics for Kubernetes at KubeCon Europe, we’ve partnered with Amazon Web Services (AWS) to bring Amazon EKS to the broader Kubernetes community. AppDynamics provides enterprise-grade, end-to-end performance monitoring for applications orchestrated by Kubernetes.

## Monitoring Amazon EKS with AppDynamics

EKS makes it easier to operate Kubernetes clusters; however, performance monitoring remains one of the top challenges in Kubernetes adoption. In fact, according to a recent CNCF survey, 46% of enterprises reported monitoring as their biggest challenge. Specifically, organizations deploying containers on the public cloud, cite monitoring as a big challenge. Perhaps because cloud providers monitoring tools may not play well with organization’s existing tools which are used to monitor on-premises resources.

# How Does it Work?

AppDynamics seamlessly integrates into EKS environments. The machine agent runs as a DaemonSet on EKS worker nodes, and application agents are deployed alongside your application binaries within the application pods. Out-of-the-box integration gives you the deepest visibility into EKS cluster health, AWS resources and Docker containers, and provides insights into the performance of every microservice deployed—all through a single pane of glass. (./images/1.png)

# CloudFormation Rollback Error
## VPC / Elastic IP Limit Issue

If you run into an error similar to the below, check CloudFormation on AWS and see why the rollback occurred. This may be a VPC / Elastic IP limit or due to some other reason.  

unexpected status "ROLLBACK_IN_PROGRESS" while waiting for CloudFormation stack "eksctl-AD-Capital-partain2019a1-cluster" to reach "CREATE_COMPLETE" status
<br>

If the error is related to the # of VPC's or the # of Elastic IP addresses you may either delete existing VPC's / Elastic IP addresses, or ask Amazon to increase your limit.

**To View**
1. For VPC's, chose the URL appropriate to your region:  
    a. [us-east-1](https://console.aws.amazon.com/vpc/home?region=us-east-1#vpcs:sort=VpcId)  
    b. [us-east-2](https://console.aws.amazon.com/vpc/home?region=us-east-2#vpcs:sort=VpcId)  
    c. [us-west-1](https://console.aws.amazon.com/vpc/home?region=us-west-1#vpcs:sort=VpcId)  
    d. [us-west-2](https://console.aws.amazon.com/vpc/home?region=us-west-2#vpcs:sort=VpcId)  

2. For Elastic IPC's, chose the URL appropriate to your region:  
    a. [us-east-1](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Addresses:sort=InstanceId)  
    b. [us-east-2](https://console.aws.amazon.com/ec2/v2/home?region=us-east-2#Addresses:sort=InstanceId)  
    c. [us-west-1](https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#Addresses:sort=InstanceId)  
    d. [us-west-2](https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#Addresses:sort=InstanceId)  

**To Delete** -- DO NOT do this unless you know what impact (if any) your actions will cause
1. Navigate to the correct region for either VPC or EIP's above
2. Select the VPC you want removed
3. Select Action > Delete VPC for VPC's, or Disassociate Address for Elastic IP's
4. If prompted, there may be other areas you need to go and remediate first. Follow the instructions / information provided in the prompt.

**To Request Additional VPC's or EIP's**
1. Navitate to the AWS Request Form located here: https://console.aws.amazon.com/support/cases#/create?issueType=service-limit-increase&limitType=service-code-elastic-ips
2. Select a Limit Type 'Elastic IP' or 'VPC'
3. Select a severity -- your call, select something appropriate.
4. Select the Region you want the request associated with
5. Select the new limit you are requesting
6. Fill in a description of why you are requesting the limit
7. Submit the request
8. Wait

[Overview](aws-eks-monitoring.md) | [1](lab-exercise-01.md), [2](lab-exercise-02.md), [3](lab-exercise-03.md), [4](lab-exercise-04.md), [5](lab-exercise-05.md), [6](lab-exercise-06.md) | [Return](lab-exercise-02.md)

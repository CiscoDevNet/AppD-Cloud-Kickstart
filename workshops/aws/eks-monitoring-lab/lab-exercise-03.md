# Lab Exercise 3
## Launch the Second EC2 Instance (e.g. Controller EC2)

The AppDynamics Controller is the central management server where all data is stored and analyzed. All AppDynamics Agents connect to the Controller to report data, and the Controller provides a browser-based user interface for monitoring and troubleshooting application performance.

In this exercise you will use the [AWS Management Console](https://aws.amazon.com/console/) to launch the second EC2 instance that will have the AppDynamics Enterprise Console, Controller, and Events Service running on it.

This EC2 instance will be referenced in the lab steps as the 'Controller EC2'.

You will need to use an existing AMI image named **APM-Platform-21417-CentOS79-AMI** and located in the AWS region that you are working in:

- The AMI image for the **ap-south-1** region can be found [here](https://ap-south-1.console.aws.amazon.com/ec2/v2/home?region=ap-south-1#Images:sort=tag:Name).
- The AMI image for the **us-east-1** region can be found [here](https://us-east-1.console.aws.amazon.com/ec2/v2/home?region=us-east-1#Images:sort=tag:Name).
- The AMI image for the **us-east-2** region can be found [here](https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:sort=tag:Name).
- The AMI image for the **us-west-2** region can be found [here](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:sort=tag:Name).
- The AMI image for the **eu-west-2** region can be found [here](https://eu-west-2.console.aws.amazon.com/ec2/v2/home?region=eu-west-2#Images:sort=tag:Name).
- The AMI image for the **eu-west-3** region can be found [here](https://eu-west-3.console.aws.amazon.com/ec2/v2/home?region=eu-west-3#Images:sort=tag:Name).

<br>

Once you have identified the appropriate AMI, launch an instance of it via:

  1. Select the **APM-Platform-21417-CentOS79-AMI** and click the **Launch** button.
  2. Select Memory optimized: **m5a.xlarge** with 4 vCPUs and 16 GiB RAM.
  3. Click '**Next: Configure Instance Details**' in the bottom right.
  4. Keep all default values; scroll to the bottom and expand '**Advanced Details**'.

Once 'Advance Details' is expanded, enter the following '**User data**' commands '**As text**'.

This allows you to customize configuration of the EC2 instance during launch.

Copy and paste the following script code in the the 'User data' text box:

```bash
#!/bin/sh
cd /opt/appd-cloud-kickstart/provisioners/scripts/aws
chmod 755 ./initialize_al2_apm_platform_cloud_init.sh

./initialize_al2_apm_platform_cloud_init.sh
```

If the above section is not completed correctly at VM creation, the Controller EC2 instance will not function as intended.

  5. Click '**Next: Add Storage**' in the bottom right and leave the defaults.
  6. Click '**Next: Add Tags**' in the bottom right and add one tag as shown below:
     For example, if your user name is 'John Smith', enter the following:

     Key: **Name**  
     Value: **User-CTLR-John-Smith**

  7. Click '**Next: Configure Security Group**' in the bottom right. Select the following group from the drop down.

![Security Group](./images/security-group-01.png)

  8. Click '**Review and Launch**' to launch your VM. When prompted for a key pair:  

     a. Select the **AppD-Cloud-Kickstart** pem if you have access to it. You can request this key from the workshop creators.  
     b. Otherwise: Select **Create a new key pair** and give it a name. Remember to download it and save it locally.  
     b. Otherwise: Use the same key pair that you created in [Lab Exercise 1](lab-exercise-01.md). Remember to substitute the name of your downloaded '.pem' file for 'AppD-Cloud-Kickstart.pem' in all of the remaining lab exercises.

**NOTE:** Once the VM is launched, it will take ~5-10 minutes for the Controller to completely initialize and accept login requests.
Make sure you take note of the Public IP Address (FQDN) of the server. You will be leveraging this server in the remainder of the lab.

You can test that the Controller is ready via the REST API. Run the command below from a terminal window:
```bash
curl http://<FQDN>:8090/controller/rest/serverstatus
```

If the Controller has successfully started, an XML document such as the following will be returned:
```bash
<?xml version="1.0" encoding="UTF-8"?>
<serverstatus vendorid="" version="1">
  <available>true</available>
  <serverid></serverid>
  <serverinfo>
    <vendorname>AppDynamics</vendorname>
    <productname>AppDynamics Application Performance Management</productname>
    <serverversion>021-004-017-000</serverversion>
    <implementationVersion>Controller v21.4.17.0 Build 21.4.17-1609 Commit afe86b529c8c27a9fd1b8ab287422b8e2185e22a</implementationVersion>
  </serverinfo>
  <startupTimeInSeconds>8</startupTimeInSeconds>
</serverstatus>
```

If you see `null` or an HTML document containing a 404 error, the Controller is not quite ready. Just wait a few minutes longer.  

When ready, your controller address will be:

**http://FQDN:8090/controller**

Use the usename "**admin**" to login. And use "**welcome1**" as the password.
<br>

[Overview](aws-eks-monitoring.md) | [1](lab-exercise-01.md), [2](lab-exercise-02.md), 3, [4](lab-exercise-04.md), [5](lab-exercise-05.md), [6](lab-exercise-06.md) | [Back](lab-exercise-02.md) | [Next](lab-exercise-04.md)

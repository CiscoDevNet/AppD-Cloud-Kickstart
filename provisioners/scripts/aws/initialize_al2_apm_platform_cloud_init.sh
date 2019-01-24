#!/bin/sh -eux
# appdynamics apm cloud-init script to initialize amazon linux 2 vm imported from ami.

# add public keys for ec2-user user. ---------------------------------------------------------------
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCBsZpmGJhDGK7OHT7Q5oALQqQaniIiacJgr8EM8rQ6Sv6B2te1G5UTdX45IKFDl54FDrwJ479RDaFRYcvd4QWWzIJ8dhUERESyQRSyb9MXd8R+MDc4iL+2/R23vWLNsFSA01D79Z50Q1ujvDJxzXGY86zJCsRRbkn8ODayUeNJZ5s+f4ACnti6OdjEIZGawZ3Y8ERRb1ZTVG/SbG2KZQxLWQpJSTT4mOB7M/i+RqTl8vB5Gd5j2fQSvLvzhX1sgUvacD6YpIv5YqLPRurnE0Hi/PtcshmJo50/PC0Qypg5q5VJYN5IP5x62iRpnbDBUOe9rpNpp1YqbGXGFQ3TuYPJ AppD-Cloud-Kickstart-AWS" >> /home/ec2-user/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCeG1qPuiVxXkhlawv3F/PtG2IB3UnGrecCN/0Y4GzIqrNwCcA6MDH5UH1IeBGaCgkm8jXZaOimwkwK4eROSJgJYNtXkYqooVC7SqoIgAbQGKykY9dpgi+ngi9uqALj1l7oUMqAkz6JRO5pueYtoiqo+me8Wbz9Kq6345flqQUh2vDjPfA2xBRGHfUYePQL3nvrc6jX5ad1i8lPuKrp5lXcYUdSP4FBDbEv1zJwi/d6M9irhlptOSGYqQH/zVvZnb1lrYSRv79Gz/WQnce4hKG5GCo5fohbfzlwsqgyFpm6uEu/yjpq/fkPxneNbH1VuljWFsDOjY9xqx8g331cJmbr ADFinancialAWS" >> /home/ec2-user/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUdqQb2fMOX8XzTtqMORY674lELuv2e01EtkoI6enfmB6dqd7mG/Njcko/kznGoWu/6R7nPQnZ8RGXH+Tq0Z+BfBeuR78dPYyBr0r/tORxCGqIgl1NOOuslp3opl4Hz+ec71MlzoQf/k8rVPpGtSHXeaiKEGBuW9niFVboM1oA+eo3Hmpn10IZK2SQ6LcfHqEPURWr7tJ9HkdJ4K7MRoO/HQ6WC1KJI8b4M8U3jGpbG2CjtI3hZ6s58I+53cHULx00T5xbp3+42A49ldwSAF0NUKjWJMH33KRDt4ZN74C36DkXcLzms28k19DGtsqo/reh4ss3mh57QgHDSoxizB7V EdBarberis" >> /home/ec2-user/.ssh/authorized_keys
chmod 600 /home/ec2-user/.ssh/authorized_keys

# set default values for input environment variables if not set. -----------------------------------
aws_hostname="apm"

# set the system hostname. -------------------------------------------------------------------------
hostnamectl set-hostname "${aws_hostname}.localdomain" --static
hostnamectl set-hostname "${aws_hostname}.localdomain"

# verify configuration.
hostnamectl status

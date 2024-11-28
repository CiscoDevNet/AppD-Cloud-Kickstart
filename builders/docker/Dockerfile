FROM centos:7 as builder
MAINTAINER Matt Johnson <matjohn2+dockerappd@cisco.com>

# Install Dependancies for build
RUN yum install -y wget which unzip

# Install useful tools
RUN yum install -y iproute vim

# Environment variables for build scripts from Packer CentOS provision scripts

ENV appd_platform_name="testplatformname"
ENV appd_platform_description="Test Platform Description"

# These break some provisioning scripts from the provison/packer dirs if not "centos"
ENV user_name="centos"
ENV user_group="centos"
ENV HOME_DIR="/home/centos"
ENV HOME_DIR="/home/centos"

## We need appd_username and appd_password during the build.
## These authenticate you to the AppD download site.
## Passing in as build-args, testing the multi-stage build doesnt keep the args.
ARG appd_username
ARG appd_password

# Unused ENV variables for this build.
#ENV appd_platform_admin_username="platformadmin"
#ENV appd_platform_admin_password="platformtest"
#ENV appd_platform_db_password="dbtest"
#ENV appd_platform_db_root_password="dbroottest"
#ENV appd_controller_admin_username="controlleruser"
#ENV appd_controller_admin_password="controllerpassword"
#ENV appd_controller_root_password="controllerrootpassword"
#ENV appd_controller_mysql_password="controllermysqlpassword"
#ENV user_docker_profile=""
#ENV d_completion_release=""
#ENV kickstart_home=""
#ENV user_docker_profile=""
#ENV d_completion_release=""
#ENV kickstart_home=""

# Critical so the docker build image hostname(s) dont end up breaking the API on final image.
# Need to build with --add-host=platformadmin:127.0.0.1 in the `docker build` command.
ENV appd_platform_server_host="platformadmin"
RUN cat /etc/hosts
RUN ping -c 3 platformadmin
## Set a couple of the other vars for consistency just incase.
ENV appd_platform_hosts="platformadmin"
ENV appd_events_service_hosts="platformadmin"

# Make systemctl not end scripts (unecessary for the dockerized process)
RUN export export systemctl_loc=`which systemctl` ; \
    mv ${systemctl_loc} ${systemctl_loc}.bak; \ 
    ln -s /bin/true ${systemctl_loc}

# Scripts from the Packer provisioning repo
COPY provisioners/scripts /provision

# Things expected from the Kickstart we're not running
RUN useradd centos

## These two are needed for /provision/common/install_root_user_env.sh to run
ENV kickstart_home="/"
RUN mkdir /provisioners ; ln -s /provision /provisioners/scripts

# Touch licence file so cp doesnt fail (even if licence is empty, it will kill the setup scripts)
RUN touch /provision/centos/tools/appd-controller-license.lic

# Run provisioning scripts
RUN /provision/centos/install_centos7_kickstart_tools.sh
RUN /provision/common/install_aws_corretto_java_jdk_8.sh
#RUN /provision/centos/install_centos7_docker.sh
#RUN /provision/common/install_docker_compose.sh
RUN /provision/centos/install_centos7_python3.sh
RUN /provision/centos/install_centos7_python3_scl.sh
RUN /provision/common/install_root_user_env.sh
RUN /provision/common/install_user_env.sh
RUN /provision/common/install_jq_json_processor.sh
RUN /provision/centos/install_centos7_oracle_mysql_shell_8.sh
RUN /provision/centos/install_centos7_appdynamics_enterprise_console.sh || true
RUN /provision/centos/install_centos7_appdynamics_platform_services.sh || true

# INIT SYSTEM SETUP
## Make SystemD work in a containerized environment.
## Replicating our CentOS7 Packer VM Image as much as possible.
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

#Put systemctl back into place
RUN export systemctl=`which systemctl` ; rm -fv ${systemctl} ; mv -v ${systemctl}.bak ${systemctl}

## Enable appdynamics SystemD service
RUN ln -s /etc/systemd/system/appdynamics*.service /etc/systemd/system/default.target.wants/.

## Script to Kickoff systemd on container runtime.
COPY ./builders/docker/start.sh /opt/start.sh
RUN chmod +x /opt/start.sh

# Licence on install expected at : /provisioners/scripts/centos/tools/appd-controller-license.lic
## Install dependancies - AWS CLIv2
RUN /provision/common/install_aws_cli_2.sh
## Add a script which, on systemD startup, uses AWS S3 creds via ENV vars (to `docker run -v envfile.env:/opt/get_apm_platform_licence.env` ) to fetch and install an eval licence.
RUN cp /provision/common/config_aws_cli_2.sh /opt/config_aws_cli_2.sh
RUN cp /provision/utils/get_apm_platform_license.sh /opt/get_apm_platform_license.sh
RUN chmod +x /opt/config_aws_cli_2.sh
RUN chmod +x /opt/get_apm_platform_license.sh
COPY ./builders/docker/appdynamics-fetch-demo-licence.service /etc/systemd/system/appdynamics-fetch-demo-licence.service



# CLEANUP 
RUN rm -rf /provision
RUN rm -rf /provisioners

## Get rid of the layers, we're already big enough!
FROM scratch as controller
COPY --from=builder / /

# SystemD needs to run with cgroup and /run access
## docker run --mount type=bind,source=/run,target=/run --mount type=bind,source=/sys/fs/cgroup,target=/sys/fs/cgroup <image>
VOLUME [ "/sys/fs/cgroup" ]
VOLUME [ "/run" ]

# Ports
EXPOSE 9191 
EXPOSE 8090
EXPOSE 8181
EXPOSE 9080

CMD ["/opt/start.sh"]


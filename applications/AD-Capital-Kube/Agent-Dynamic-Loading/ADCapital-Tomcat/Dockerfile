FROM store/appdynamics/java:4.5_tomcat9-jre8-alpine
#FROM store/appdynamics/java:4.4_tomcat9-jre8-alpine
#FROM store/appdynamics/java:4.3.7.1_tomcat9-jre8

#UBUNTU Specific, 4.4 went to APK
#RUN apt-get update
#RUN apt-get install -y yum

RUN apk update && apk upgrade


ENV DOCKERIZE_VERSION v0.5.0

RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# Shared directory mounted as docker volume
ENV PROJECT /project

ENV GRADLE_HOME $PROJECT/gradle-2.1
ENV PATH $PATH:$GRADLE_HOME/bin
ENV NETVIS_HOME /

ADD startup.sh /
RUN chmod 744 /startup.sh

#ADD appd-netviz-x64-linux-4.5.0.1000 /opt/appdynamics/ver4.4.3.22593/external-services

#RUN ./opt/appdynamics/ver4.4.3.22593/external-services/install.sh

ADD setenv.sh ${CATALINA_HOME}/bin
RUN chmod 744 ${CATALINA_HOME}/bin/setenv.sh

# Note: This command should not return or the container will exit
CMD "/startup.sh"

EXPOSE 80
EXPOSE 8080
EXPOSE 8009

#!/bin/bash

#https://docs.appdynamics.com/display/PRO44/Installing+Agent-Side+Components#InstallingAgent-SideComponents-ConfiguretheAnalyticsAgentforaRemoteHost
export APPD_ANALYTICS_AGENT="-Dappdynamics.analytics.agent.url=http://monitor:9090/v2/sinks/bt"
export APPD_JAVAAGENT="-javaagent:/opt/appdynamics/javaagent.jar"
export NETWORK_AGENT="-Dappdynamics.socket.collection.bci.enable=true"


# Specialize container behavior based on ROLE env var
# Uses https://github.com/jwilder/dockerize to check service dependencies
# Binaries and Gradle scripts are sourced from ${PROJECT} docker shared volume
case ${ROLE} in
rest)
  dockerize -wait tcp://adcapitaldb:3306 \
            -wait-retry-interval ${RETRY} -timeout ${TIMEOUT} || exit $?

  cd ${PROJECT}/AD-Capital; gradle createDB

  cp  ${PROJECT}/AD-Capital/Rest/build/libs/Rest.war ${CATALINA_HOME}/webapps;
  cd ${CATALINA_HOME}/bin;


  /usr/lib/jvm/java-1.8-openjdk/jre/bin/java ${APPD_ANALYTICS_AGENT} ${NETWORK_AGENT} -Djava.util.logging.config.file=/usr/local/tomcat/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -javaagent:/opt/appdynamics/javaagent.jar -classpath /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar -Dcatalina.base=/usr/local/tomcat -Dcatalina.home=/usr/local/tomcat -Djava.io.tmpdir=/usr/local/tomcat/temp org.apache.catalina.startup.Bootstrap start
  ;;
portal)
  dockerize -wait tcp://rabbitmq:5672 \
            -wait tcp://rest:8080 \
            -wait-retry-interval ${RETRY} -timeout ${TIMEOUT} || exit $?

  cp /${PROJECT}/AD-Capital/Portal/build/libs/portal.war ${CATALINA_HOME}/webapps;
  cd ${CATALINA_HOME}/bin;
  /usr/lib/jvm/java-1.8-openjdk/jre/bin/java ${APPD_ANALYTICS_AGENT} ${NETWORK_AGENT} -Djava.util.logging.config.file=/usr/local/tomcat/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -javaagent:/opt/appdynamics/javaagent.jar -classpath /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar -Dcatalina.base=/usr/local/tomcat -Dcatalina.home=/usr/local/tomcat -Djava.io.tmpdir=/usr/local/tomcat/temp org.apache.catalina.startup.Bootstrap start
  ;;
processor)
  dockerize -wait tcp://adcapitaldb:3306 \
            -wait tcp://rabbitmq:5672 \
            -wait tcp://rest:8080 \
            -wait-retry-interval ${RETRY} -timeout ${TIMEOUT} || exit $?

  cp /${PROJECT}/AD-Capital/Processor/build/libs/processor.war ${CATALINA_HOME}/webapps;


  /usr/lib/jvm/java-1.8-openjdk/jre/bin/java ${APPD_ANALYTICS_AGENT} ${NETWORK_AGENT} -Djava.util.logging.config.file=/usr/local/tomcat/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -javaagent:/opt/appdynamics/javaagent.jar -classpath /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar -Dcatalina.base=/usr/local/tomcat -Dcatalina.home=/usr/local/tomcat -Djava.io.tmpdir=/usr/local/tomcat/temp org.apache.catalina.startup.Bootstrap start
  ;;
approval)
  dockerize -wait tcp://rabbitmq:5672 \
            -wait tcp://rest:8080 \
            -wait-retry-interval ${RETRY} -timeout ${TIMEOUT} || exit $?

  /usr/lib/jvm/java-1.8-openjdk/jre/bin/java ${APPD_JAVAAGENT} ${APPD_ANALYTICS_AGENT} ${NETWORK_AGENT} -jar ${PROJECT}/AD-Capital/QueueReader/build/libs/QueueReader.jar
  ;;
verification)
  dockerize -wait tcp://adcapitaldb:3306 \
            -wait tcp://rabbitmq:5672 \
            -wait tcp://rest:8080 \
            -wait-retry-interval ${RETRY} -timeout ${TIMEOUT} || exit $?

  cd ${CATALINA_HOME}/bin;
  /usr/lib/jvm/java-1.8-openjdk/jre/bin/java ${APPD_JAVAAGENT} ${APPD_ANALYTICS_AGENT} ${NETWORK_AGENT} -jar ${PROJECT}/AD-Capital/Verification/build/libs/Verification.jar
  ;;
*)
  echo "ROLE missing: container will exit"; exit 1
  ;;

esac

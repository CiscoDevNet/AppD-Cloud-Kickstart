
# Set AppDynamics Java Agent environment variables using docker run -e, --env or --env-file
# https://docs.appdynamics.com/display/PRO43/Use+Environment+Variables+for+Java+Agent+Settings
export CATALINA_OPTS="$CATALINA_OPTS LD_PRELOAD=/usr/appd/agents/netviz/lib/appd-netlib.so -javaagent:/usr/appd/agents/apm/javaagent.jar -Dappdynamics.socket.collection.bci.enable=true -javaagent:/opt/appdynamics/javaagent.jar ${APPDYNAMICS_NODE_PREFIX:+-Dappdynamics.agent.reuse.nodeName=true -Dappdynamics.agent.reuse.nodeName.prefix=${APPDYNAMICS_NODE_PREFIX}} -Dappdynamics.analytics.agent.url=http://analytics-agent:9090/v2/sinks/bt"
#export APPD_JAVAAGENT=" -javaagent:${APPD_DIR}/java-agent/javaagent.jar"
#

#!/bin/sh

if [ "${SCRIPT_DEBUG}" = "true" ] ; then
    set -x
    echo "Script debugging is enabled, allowing bash commands and their arguments to be printed as they are executed"
fi

# Inditex: Avoid configure activemq.xml. It is in ConfigMap
# source $AMQ_HOME/bin/configure.sh
source /opt/partition/partitionPV.sh
source /usr/local/dynamic-resources/dynamic_resources.sh

ACTIVEMQ_OPTS="$(adjust_java_options ${ACTIVEMQ_OPTS})"

ACTIVEMQ_OPTS="${ACTIVEMQ_OPTS} $(/opt/jolokia/jolokia-opts)"

# Make sure that we use /dev/urandom
ACTIVEMQ_OPTS="${ACTIVEMQ_OPTS} -Djava.security.egd=file:/dev/./urandom"

# Add jmxtrans agent
if [ "$AMQ_JMXTRANX_AGENT" = "true" ]; then
  echo "Using jmxtrans agent to collect metrics. Configuration loaded from /opt/amq/conf/jmxtrans-agent-kafka-influxdb.xml"
  ACTIVEMQ_OPTS="${ACTIVEMQ_OPTS} -Xbootclasspath/p:/opt/amq/conf:/opt/amq/lib/slf4j-api-1.7.10.jar:/opt/amq/lib/optional/slf4j-log4j12-1.7.10.jar:/opt/amq/lib/optional/log4j-1.2.17.redhat-1.jar -javaagent:/opt/amq/lib/jmxtrans-agent.jar=/opt/amq/conf/jmxtrans-agent-kafka-influxdb.xml"
fi

# White list packages for use in ObjectMessages: CLOUD-703
if [ -n "$MQ_SERIALIZABLE_PACKAGES" ]; then
  ACTIVEMQ_OPTS="${ACTIVEMQ_OPTS} -Dorg.apache.activemq.SERIALIZABLE_PACKAGES=${MQ_SERIALIZABLE_PACKAGES}"
fi

# Inditex: Optimization to vertical scale
# http://activemq.apache.org/how-do-i-configure-10s-of-1000s-of-queues-in-a-single-broker-.html
# http://activemq.2283324.n4.nabble.com/Large-number-of-queues-HowTo-td2364929.html
ACTIVEMQ_OPTS="${ACTIVEMQ_OPTS} -Dorg.apache.activemq.UseDedicatedTaskRunner=false"

# Inditex: General Optimizations
# http://blog.christianposta.com/activemq/speeding-up-activemq-persistent-messaging-performance-by-25x/
# http://sigreen.github.io/2016/02/10/amq-tuning.html
ACTIVEMQ_OPTS="${ACTIVEMQ_OPTS} -Dorg.apache.activemq.kahaDB.files.skipMetadataUpdate=true"

# Add proxy command line options
source /opt/run-java/proxy-options
options="$(proxy_options)"
options="$(echo $options | sed 's|"|\\"|g')"
ACTIVEMQ_OPTS="$ACTIVEMQ_OPTS $options"

# Add jolokia command line options
cat <<EOF > $AMQ_HOME/bin/env
ACTIVEMQ_OPTS="${ACTIVEMQ_OPTS} ${JAVA_OPTS_APPEND}"
EOF

echo "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

# Parameters are
# - instance directory
function runServer() {
  # Fix log file
  local instanceDir=$1
  local log_file="$AMQ_HOME/conf/log4j.properties"
  sed -i "s+activemq\.base}/data+activemq.data}+" "$log_file"

  export ACTIVEMQ_DATA="$instanceDir"
  exec "$AMQ_HOME/bin/activemq" console
}

function init_data_dir() {
  # No init needed for AMQ
  return
}

if [ "$AMQ_SPLIT" = "true" ]; then
  DATA_DIR="${AMQ_HOME}/data"
  mkdir -p "${DATA_DIR}"

  partitionPV "${DATA_DIR}" "${AMQ_LOCK_TIMEOUT:-30}"
else
    exec $AMQ_HOME/bin/activemq console
fi

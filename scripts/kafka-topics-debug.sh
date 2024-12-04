#!/bin/bash

#execute script against a single pod:
#oc exec -i POD_NAME -- bash -s -- --log-level=WARN --topic=MYTOPIC < kafka-topics-debug.sh

readonly USAGE="
Usage: kafka-topics-debug.sh [options]

Required:
  --log-level=<string>          log level for client
  --topic=<string>              the name of the topic for kafka-topics --describe

"
OPTSPEC=":-:"
while getopts "$OPTSPEC" optchar; do
  case "${optchar}" in
    -)
      case "${OPTARG}" in
        log-level=*)
          TOOLS_LOG_LEVEL=${OPTARG#*=}
          ;;
        topic=*)
          TOOLS_TOPIC=${OPTARG#*=}
          ;;
        *)
          error "$USAGE"
          ;;
      esac;;
  esac
done

error() {
  echo "$@" 1>&2 && exit 1
}

shift $((OPTIND-1))

if [[ -z $TOOLS_LOG_LEVEL || -z $TOOLS_TOPIC ]]; then
  error "$USAGE"
fi

echo "topic: $TOOLS_TOPIC"
echo "log: $TOOLS_LOG_LEVEL"
cat /tmp/strimzi.properties  | egrep "controlplane-9090.ssl" | sed 's/listener.name.controlplane-9090.//g' > /tmp/tools.properties
echo "ssl.endpoint.identification.algorithm=" >> /tmp/tools.properties
echo "security.protocol=SSL" >> /tmp/tools.properties
cat /opt/kafka/config/tools-log4j.properties  | sed "s/WARN/$TOOLS_LOG_LEVEL/g" > /tmp/tools-log4j.properties
export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:/tmp/tools-log4j.properties"
./bin/kafka-topics.sh --list --command-config /tmp/tools.properties --bootstrap-server 127.0.0.1:9090
./bin/kafka-topics.sh --describe --topic $TOOLS_TOPIC --command-config /tmp/tools.properties --bootstrap-server 127.0.0.1:9090

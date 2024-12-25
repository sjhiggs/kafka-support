#!/bin/bash

#
# Example Usage
# 
# One-way SSL, no authentication:
#   ./kafka-ssl-client.sh  --log-level=INFO --java-debug-ssl=true --topic=FOO --kafka-version=3.8.0 --truststore-location=/tmp/ca.pem --tls-verify-name=false --bootstrap-server=my-bootstrap-server.local:443
#
# Two-way SSL:
#   ./kafka-ssl-client.sh  --log-level=INFO --java-debug-ssl=true --topic=my-topic --kafka-version=3.8.0 --truststore-location=/tmp/ca.pem --keystore-location=/tmp/client.pem --tls-verify-name=false --bootstrap-server=my-bootstrap-server.local:443
# 

readonly USAGE="
Usage: kafka-ssl-client.sh [options]

Required:
  --log-level=<string>          	log level for client
  --java-debug-ssl			log java ssl debugging info
  --topic=<string>            	  	the name of the topic for kafka-topics --describe
  --kafka-version=<string>		the upstream kafka version to use for the client
  --bootstrap-server=<string>		the kafka bootstrap server
  --truststore-location=<string>	location of the PEM file contain the trusted CA(s) (concatenated CA chain)
  --keystore-location=<string>		location of the PEM file contain the client private key and certificate
  --tls-verify-name=<string>		true/false - should the client verify the server's TLS hostname?

  

"
OPTSPEC=":-:"
while getopts "$OPTSPEC" optchar; do
  case "${optchar}" in
    -)
      case "${OPTARG}" in
        log-level=*)
          TOOLS_LOG_LEVEL=${OPTARG#*=}
          ;;
        java-debug-ssl=*)
          JAVA_DEBUG_SSL=${OPTARG#*=}
          ;;
        topic=*)
          TOOLS_TOPIC=${OPTARG#*=}
          ;;
        kafka-version=*)
          KAFKA_VERSION=${OPTARG#*=}
          ;;
        bootstrap-server=*)
          BOOTSTRAP_SERVER=${OPTARG#*=}
          ;;
        truststore-location=*)
          TRUSTSTORE_LOCATION=${OPTARG#*=}
          ;;
        keystore-location=*)
          KEYSTORE_LOCATION=${OPTARG#*=}
          ;;
        tls-verify-name=*)
          TLS_VERIFY_NAME=${OPTARG#*=}
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

echo "topic: $TOOLS_TOPIC"
echo "log: $TOOLS_LOG_LEVEL"
echo "java debug: $JAVA_DEBUG_SSL"
echo "kafka version:  $KAFKA_VERSION"
echo "bootstrap server: $BOOTSTRAP_SERVER"
echo "truststore location: $TRUSTSTORE_LOCATION"
echo "keystore location: $KEYSTORE_LOCATION"
echo "tls verification: $TLS_VERIFY_NAME"

if [[ -z $TOOLS_LOG_LEVEL || -z $TOOLS_TOPIC || -z $JAVA_DEBUG_SSL || -z $KAFKA_VERSION || -z $BOOTSTRAP_SERVER || -z $TRUSTSTORE_LOCATION || -z $TLS_VERIFY_NAME ]]; then
  error "$USAGE"
fi

echo "start of script..."

# from https://github.com/fvaleri/strimzi-debugging/blob/main/init.sh
for x in curl xz java; do
  if ! command -v "$x" &>/dev/null; then
    echo "Missing required utility: $x"; exit 1
  fi
done

# get Kafka
KAFKA_HOME="/tmp/kafka-$KAFKA_VERSION" && export KAFKA_HOME
if [[ ! -d $KAFKA_HOME ]]; then
  echo "Downloading Kafka to $KAFKA_HOME"
  mkdir -p "$KAFKA_HOME"
  curl -sLk "https://archive.apache.org/dist/kafka/$KAFKA_VERSION/kafka_2.13-$KAFKA_VERSION.tgz" | tar xz -C "$KAFKA_HOME" --strip-components 1
fi

cat > $KAFKA_HOME/kafka-tools.properties <<EOF
security.protocol=SSL
ssl.truststore.type=PEM
ssl.truststore.location=$TRUSTSTORE_LOCATION
EOF

if [ -n "$KEYSTORE_LOCATION" ]; then
cat >> $KAFKA_HOME/kafka-tools.properties <<EOF
ssl.keystore.type=PEM
ssl.keystore.location=$KEYSTORE_LOCATION
EOF
fi


if [ "$TLS_VERIFY_NAME" = false ]; then
  echo "skipping hostname checks..."
  echo "ssl.endpoint.identification.algorithm=" >> $KAFKA_HOME/kafka-tools.properties
fi

cat > $KAFKA_HOME/kafka-tools-log4j.properties <<EOF
log4j.rootLogger=$TOOLS_LOG_LEVEL, stderr
log4j.appender.stderr=org.apache.log4j.ConsoleAppender
log4j.appender.stderr.layout=org.apache.log4j.PatternLayout
log4j.appender.stderr.layout.ConversionPattern=[%d] %p %m (%c)%n
log4j.appender.stderr.Target=System.err
log4j.logger.org.reflections=ERROR
EOF

if [ "$JAVA_DEBUG_SSL" = true ]; then
	echo "debug java ssl"
	export KAFKA_JMX_OPTS="-Djavax.net.debug=all -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
else
	unset KAFKA_JMX_OPTS
fi

export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:$KAFKA_HOME/kafka-tools-log4j.properties"

#$KAFKA_HOME/bin/kafka-topics.sh --bootstrap-server $BOOTSTRAP_SERVER --command-config $KAFKA_HOME/kafka-tools.properties --list

$KAFKA_HOME/bin/kafka-producer-perf-test.sh --producer-props bootstrap.servers=$BOOTSTRAP_SERVER --producer.config $KAFKA_HOME/kafka-tools.properties --num-records 1 --throughput 100  --topic $TOOLS_TOPIC --record-size 100 


echo "end of script"

#!/bin/bash

KAFKA_VERSION="3.8.0"
SSL_PEM_LOCATION=/tmp/ca.pem
BOOTSTRAP_SERVER=mybootstrap-myproject.apps.higgskafka.lab.upshift.rdu2.redhat.com:443
TLS_VERIFY_NAME=false
export KAFKA_JMX_OPTS=" -Djavax.net.debug=all-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"

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
ssl.truststore.location=/$SSL_PEM_LOCATION
EOF

if [ "$TLS_VERIFY_NAME" = false ]; then
  echo "skipping hostname checks..."
  echo "ssl.endpoint.identification.algorithm=" >> $KAFKA_HOME/kafka-tools.properties
fi

cat > $KAFKA_HOME/kafka-tools-log4j.properties <<EOF
log4j.rootLogger=DEBUG, stderr
log4j.appender.stderr=org.apache.log4j.ConsoleAppender
log4j.appender.stderr.layout=org.apache.log4j.PatternLayout
log4j.appender.stderr.layout.ConversionPattern=[%d] %p %m (%c)%n
log4j.appender.stderr.Target=System.err
log4j.logger.org.reflections=ERROR
EOF

export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:$KAFKA_HOME/kafka-tools-log4j.properties"

$KAFKA_HOME/bin/kafka-topics.sh --bootstrap-server $BOOTSTRAP_SERVER --command-config $KAFKA_HOME/kafka-tools.properties --list

$KAFKA_HOME/bin/kafka-producer-perf-test.sh --producer-props bootstrap.servers=$BOOTSTRAP_SERVER --producer.config $KAFKA_HOME/kafka-tools.properties --num-records 1 --throughput 100  --topic FOO --record-size 100 


echo "end of script"

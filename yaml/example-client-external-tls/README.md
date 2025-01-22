# Introduction

Meets the following requirements:

* TLS Listener (Route) with externally issued server certificate for external clients
* Operator-managed Cluster CA for internal TLS
* Externally issued client certificates for client cerficiate authentication for external clients

# Initialization

From base (git project) directory.  Note - customize env file.

```
oc new-project myproject
oc create -f yaml/subscription
cp custom-ca/env.bak custom-ca/env
```

# Create CAs, server cert, client cert

Creates:

   * Root CA
   * Issuing CA (for listener certificate)
   * A second Issuing CA (for client certificates)
   * Server certificate for the Kafka listener
   * Client certificate for CN=myuser, client certificate authentication to Broker

```
./custom-ca/init.sh
./custom-ca/ca.sh
./custom-ca/ca-issuing.sh
./custom-ca/ca-issuing-clients.sh
./custom-ca/cert-listener.sh
```

Note: may use wildcard like *.apps-crc.testing for CN

```
./custom-ca/cert-client.sh  
./custom-ca/create-secrets.sh
./custom-ca/export.sh
```

# Create Broker

Create a broker with the custom listener cert, custom clients-ca certificate for client certificate authentication, and a KafkaUser with tls-external authentication configured.

```
oc create -f yaml/example-client-external-tls/kafka.yaml
oc create -f yaml/example-client-external-tls/kafka-user.yaml
```

# Test producer

Example usage (customize bootstrap server as necessary):

```
export BOOTSTRAP_SERVER=my-kafka-twowayssl2-bootstrap-myproject.apps-crc.testing:443
./scripts/kafka-ssl-client.sh  --log-level=INFO --java-debug-ssl=false --topic=my-topic --kafka-version=3.8.0 --truststore-location=/tmp/ca.pem --keystore-location=/tmp/client.pem --tls-verify-name=true --bootstrap-server=$BOOTSTRAP_SERVER
```

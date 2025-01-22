#!/bin/bash

cd "$(dirname "$0")"
source ./env

oc delete secret/my-clients-ca-cert
oc delete secret/my-clients-ca
oc delete secret/my-server-cert

oc create secret generic  my-clients-ca-cert --from-file=ca.crt=$ca_issuing_clients_dir/$ca_name.issuing.pem
#oc create secret generic  my-clients-ca --from-literal=ca.key="" 
oc create secret generic  my-clients-ca --from-file=ca.key=$ca_issuing_clients_dir/$ca_name.issuing.key

openssl rsa -in $certs_dir/server.key -out $certs_dir/server.key.decrypted
oc create secret generic  my-server-cert --from-file=cert=$certs_dir/server.pem --from-file=key=$certs_dir/server.key.decrypted

oc label secret my-clients-ca-cert strimzi.io/kind=Kafka strimzi.io/cluster="my"
oc label secret my-clients-ca strimzi.io/kind=Kafka strimzi.io/cluster="my"
oc annotate secret my-clients-ca-cert strimzi.io/ca-cert-generation="0"
oc annotate secret my-clients-ca strimzi.io/ca-key-generation="0"


#oc label secret my-cluster-ca-cert strimzi.io/kind=Kafka strimzi.io/cluster="my"
#oc label secret my-cluster-ca strimzi.io/kind=Kafka strimzi.io/cluster="my"
#oc annotate secret my-cluster-ca-cert strimzi.io/ca-cert-generation="0"
#oc annotate secret my-cluster-ca strimzi.io/ca-key-generation="0"

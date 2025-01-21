#!/bin/bash

rm -r export
mkdir export
cat ./clusterca/myca.clusterca.pem ./issuing/myca.issuing.pem ./ca/myca.pem > export/ca.crt
openssl rsa -in ./clusterca/myca.clusterca.key -out ./export/ca.key
openssl pkcs12 -export -nokeys -in ./export/ca.crt -out ./export/ca.p12 -password pass:foobar


oc delete secret my-clients-ca-cert
oc delete secret my-cluster-ca-cert
oc delete secret my-clients-ca
oc delete secret my-cluster-ca

oc create secret generic  my-clients-ca-cert --from-file=ca.crt=./export/ca.crt --from-file=ca.p12=./export/ca.p12 --from-literal=ca.password=foobar
oc create secret generic  my-cluster-ca-cert --from-file=ca.crt=./export/ca.crt --from-file=ca.p12=./export/ca.p12 --from-literal=ca.password=foobar
oc create secret generic my-clients-ca --from-file=ca.key=./export/ca.key
oc create secret generic my-cluster-ca --from-file=ca.key=./export/ca.key

oc label secret my-clients-ca-cert strimzi.io/kind=Kafka strimzi.io/cluster="my"
oc label secret my-cluster-ca-cert strimzi.io/kind=Kafka strimzi.io/cluster="my"
oc label secret my-clients-ca strimzi.io/kind=Kafka strimzi.io/cluster="my"
oc label secret my-cluster-ca strimzi.io/kind=Kafka strimzi.io/cluster="my"


oc annotate secret my-clients-ca-cert strimzi.io/ca-cert-generation="0"
oc annotate secret my-cluster-ca-cert strimzi.io/ca-cert-generation="0"
oc annotate secret my-clients-ca strimzi.io/ca-key-generation="0"
oc annotate secret my-cluster-ca strimzi.io/ca-key-generation="0"

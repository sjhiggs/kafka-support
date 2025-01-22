#!/bin/bash

cd "$(dirname "$0")"
source ./env

cat $certs_dir/client.key.decrypted $certs_dir/client.pem > /tmp/client.pem 
cat $ca_dir/$ca_name.pem $ca_issuing_dir/$ca_name.issuing.pem > /tmp/ca.pem

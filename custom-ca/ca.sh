#!/bin/bash

cd "$(dirname "$0")"
echo $PWD
source ./env

openssl genpkey -algorithm rsa -out $ca_dir/$ca_name.key -AES-256-CBC -pkeyopt rsa_keygen_bits:"$ca_key_bits"
openssl req -x509 -new -key $ca_dir/$ca_name.key -days $ca_cert_expire_days -out $ca_dir/$ca_name.pem -sha512 -subj "$ca_subject"



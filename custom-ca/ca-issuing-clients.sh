#!/bin/bash

cd "$(dirname "$0")"

source ./env

openssl genpkey -algorithm rsa -out $ca_issuing_clients_dir/$ca_name.issuing.key -AES-256-CBC -pkeyopt rsa_keygen_bits:$ca_key_bits
openssl req -new -key $ca_issuing_clients_dir/$ca_name.issuing.key -out $ca_issuing_clients_dir/$ca_name.issuing.csr -addext "basicConstraints=critical,CA:TRUE" -subj "$ca_issuing_clients_subject"
openssl x509 -req -in $ca_issuing_clients_dir/$ca_name.issuing.csr -CA $ca_dir/$ca_name.pem -CAkey $ca_dir/$ca_name.key -out $ca_issuing_clients_dir/$ca_name.issuing.pem -days 365 -sha512 -CAcreateserial  -copy_extensions copyall



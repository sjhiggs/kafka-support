#!/bin/bash

source ./env

openssl genpkey -algorithm rsa -out $certs_dir/server.key -AES-256-CBC -pkeyopt rsa_keygen_bits:"$ca_key_bits"
openssl req -new -key $certs_dir/server.key -out $certs_dir/server.csr
openssl x509 -req -in $certs_dir/server.csr -CA $ca_issuing_dir/$ca_name.issuing.pem -CAkey $ca_issuing_dir/$ca_name.issuing.key -out $certs_dir/server.pem -days 365 -sha512 -copy_extensions copyall

openssl rsa -in $certs_dir/server.key -out $certs_dir/server.key.decrypted


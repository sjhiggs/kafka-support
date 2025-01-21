#!/bin/bash

ca_name="myca"
ca_key_bits="4096"
ca_cert_expire_days="7"

rm -r clusterca
mkdir clusterca
cd clusterca

echo "### Generating clusterca private key"
openssl genpkey -algorithm rsa -out "$ca_name".clusterca.key -AES-256-CBC -pkeyopt rsa_keygen_bits:"$ca_key_bits"

echo "### Generating clusterca cert request"
openssl req -new -key "$ca_name".clusterca.key -out "$ca_name".clusterca.csr -addext "basicConstraints=critical,CA:TRUE"
#openssl req -new -key "$ca_name".clusterca.key -out "$ca_name".clusterca.csr

echo "### Sigining clusterca cert request with issuing CA"
openssl x509 -req -in "$ca_name".clusterca.csr -CA ../issuing/"$ca_name".issuing.pem -CAkey ../issuing/"$ca_name".issuing.key -out "$ca_name".clusterca.pem -days 365 -sha512 -CAcreateserial -copy_extensions copyall



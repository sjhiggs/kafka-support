#!/bin/bash

cd "$(dirname "$0")"

cp env.bak env
source ./env

mkdir $ca_dir
mkdir $ca_issuing_dir
mkdir $ca_issuing_clients_dir
mkdir $certs_dir

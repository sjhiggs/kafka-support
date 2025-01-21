# Description

Create a CA, issuing CA, issuing (clients) CA, and secrets for Kafka cluster:

~~~
./init.sh - initialize directories
./ca.sh - create the root CA
./ca-issuing.sh - create the issuing CA
./ca-issuing-clients.sh - create another issuing CA for client certs
./cert-listener.sh - create a certificate for a custom listener
./cert-client.sh - create a client certificate for authentication/authorization
./create-secrets.sh - generate openshift secrets for demo kafka yaml
./export.sh - copy certs to the /tmp directory for usage with demo scripts
./clean.sh - delete all ca's, certs, keys, etc.
~~~

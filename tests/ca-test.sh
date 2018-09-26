#!/bin/sh

# Simple shell tests using fairly standard tools:
# curl, openssl, jq


if [ -f test-ca-cert.pem ] || [ -f test.crt ] || [ -f test.csr ] || [ -f test.key ] ; then
    echo "Previous test certificates found."
    echo "Please remove and try again: test-ca-cert.pem test.crt test.csr test.key"
    exit 1
fi


# $1 - hostname and port (defaults to localhost:8888)
# $2 - profile (defaults to server)

if [ -n "${1}" ] ; then
    SERVER_PORT=${1}
else
    SERVER_PORT=localhost:8888
fi

if [ -n "${2}" ] ; then
    SERVICE=${2}
else
    SERVICE=server
fi

RANDOM_CN=$RANDOM-$RANDOM


echo "Downloading CA cert from ${SERVER_PORT} to test-ca-cert.pem"
curl -s -d '{"label": "primary"}' http://${SERVER_PORT}/api/v1/cfssl/info | jq -r ".result.certificate" > test-ca-cert.pem


echo "Generating private key (test.key) and CSR (test.csr) with RANDOM CN of $RANDOM_CN"
openssl genrsa -out test.key 4096
openssl req -subj "/C=DE/ST=BE/L=Berlin/O=Engineering/OU=SRE/CN=$RANDOM_CN" -new -key test.key -out test.csr


echo "Requesting signed cert (test.crt)"
curl -s -d "{\"certificate_request\": \"$(awk '{printf "%s\\n", $0}' test.csr)\", \"profile\": \"$SERVICE\"}" "http://${SERVER_PORT}/api/v1/cfssl/sign" | jq -r '.result."certificate"' > test.crt


echo "Validating signed cert (test.crt) with CA cert (test-ca-cert.pem)"
openssl verify -CAfile test-ca-cert.pem test.crt


echo "Inspecting signed cert (test.crt) for previously generated RANDOM CN of $RANDOM_CN"
openssl x509 -in test.crt -noout -text | grep "CN=${RANDOM_CN}"
if [ "$?" == 0 ] ; then
    echo "CN: FOUND"
else
    echo "CN: NOT FOUND"
fi

#!/bin/sh

echo "Create prod database"

/root/go/bin/goose -env production -path /root/go/src/github.com/cloudflare/cfssl/certdb/sqlite up

if [ -f /cfssl-server/root_ca.csr ] && [ -f root_ca.pem ] && [ -f root_ca-key.pem ] ; then
    echo "CSR, private key, and certificate files exist"
else
    /root/go/bin/cfssl gencert -initca configs/ca_csr.json | /root/go/bin/cfssljson -bare root_ca
fi

echo "Starting cfssl API server"

/root/go/bin/cfssl serve \
    -address=0.0.0.0 \
    -ca=/cfssl-server/root_ca.pem \
    -ca-key=/cfssl-server/root_ca-key.pem \
    -config=/cfssl-server/configs/ca-config.json \
    -db-config=/cfssl-server/configs/certdb.json

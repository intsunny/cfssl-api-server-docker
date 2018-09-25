FROM alpine:3.8

# ca_csr.json
# settings for generating the CSR and keys for the cfssl server
ENV CA_CN 'cfssl api CA'
ENV CA_KEY_ALGO rsa
ENV CA_KEY_SIZE 4096
ENV CA_NAMES_C 'DE'
ENV CA_NAMES_L 'Berlin'
ENV CA_NAMES_O 'Engineering'
ENV CA_NAMES_OU 'SRE'
ENV CA_EXPIRY '87600h'

# ca-config.json
# settings for configuring cfssl ca signing options
ENV CA_SIGNING_EXPIRY_DEFAULT 720h
ENV CA_SIGNING_EXPIRY_INTERMEDIATE 720h
ENV CA_SIGNING_EXPIRY_SERVER 720h
ENV CA_SIGNING_EXPIRY_CLIENT 720h
# The regex below is Google RE2 standard
ENV CA_SIGNING_SERVER_NAME_WHITELIST '.*\\.foo$|.*\\.bar$'
ENV CA_SIGNING_CLIENT_NAME_WHITELIST '.*\\.foo$|.*\\.bar$'

WORKDIR /cfssl-server

COPY configs /cfssl-server/configs
COPY run-cfssl.sh /cfssl-server

RUN apk update && apk add go git musl-dev gettext
RUN go get -u github.com/cloudflare/cfssl/cmd/cfssl
RUN go get -u github.com/cloudflare/cfssl/cmd/cfssljson
RUN go get bitbucket.org/liamstask/goose/cmd/goose

EXPOSE 8888/tcp

ENTRYPOINT ["/bin/sh", "run-cfssl.sh"]
CMD ["/bin/sh"]

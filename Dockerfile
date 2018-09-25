FROM alpine:3.8

WORKDIR /cfssl-server

COPY configs /cfssl-server/configs
COPY run-cfssl.sh /cfssl-server

RUN apk update && apk add go git musl-dev
RUN go get -u github.com/cloudflare/cfssl/cmd/cfssl
RUN go get -u github.com/cloudflare/cfssl/cmd/cfssljson
RUN go get bitbucket.org/liamstask/goose/cmd/goose

EXPOSE 8888/tcp

ENTRYPOINT ["sh", "run-cfssl.sh"]

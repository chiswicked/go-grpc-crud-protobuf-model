FROM golang:1.11.2-alpine3.8

RUN apk update && apk add protobuf protobuf-dev make git 

ADD Makefile .
ADD *.proto .

ENTRYPOINT ["make"]
BASE_PATH			:= $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

GRPC_GW_REPO		:= github.com/grpc-ecosystem/grpc-gateway
GRPC_GW_PROTO_PATH	:= $(GOPATH)/src/$(GRPC_GW_REPO)/third_party/googleapis

PROTOC_IMPORTS		:= -I/usr/include -I$(GRPC_GW_PROTO_PATH) -I$(BASE_PATH)

.PHONY: clean install build docker-build

all: clean install build

clean:
	@echo "[clean] removing $(BASE_PATH)/*.pb.go"
	@rm -rf $(BASE_PATH)/*.pb.go
	@echo "[clean] removing $(BASE_PATH)/*.pb.gw.go"
	@rm -rf $(BASE_PATH)/*.pb.gw.go
	@echo "[clean] removing $(BASE_PATH)/*.swagger.json"
	@rm -rf $(BASE_PATH)/*.swagger.json

install:
	@echo [install] installing dependencies
	@[ -x $(GOPATH)/bin/protoc-gen-grpc-gateway ] || go get -u $(GRPC_GW_REPO)/protoc-gen-grpc-gateway
	@[ -x $(GOPATH)/bin/protoc-gen-swagger ] || go get -u $(GRPC_GW_REPO)/protoc-gen-swagger
	@[ -x $(GOPATH)/bin/protoc-gen-go ] || go get -u github.com/golang/protobuf/protoc-gen-go
build:
	@echo [build] Building protobufs
	@protoc $(PROTOC_IMPORTS) --go_out=plugins=grpc:$(BASE_PATH) $(BASE_PATH)/*.proto

	@echo [build] Building gRPC gateway
	@protoc $(PROTOC_IMPORTS) --grpc-gateway_out=logtostderr=true:$(BASE_PATH) $(BASE_PATH)/*.proto

	@echo [build] Generating swagger definitions
	@protoc $(PROTOC_IMPORTS) --swagger_out=logtostderr=true:$(BASE_PATH) $(BASE_PATH)/*.proto 

docker-build:
	docker build -t proto-build:local .

ci-docker-build: docker-build

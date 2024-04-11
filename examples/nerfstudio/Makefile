REPO_NAME=harbor.lins.lab/library/nerfstudio
TAG=cu118-ubuntu2204-torch2.1.2
DATE=$(shell date +%y%m%d)
BASE_VERSION=base-$(TAG)-$(DATE)
NERF_VERSION=v1.0.1-$(TAG)
BASE=$(REPO_NAME):$(BASE_VERSION)
NERF=$(REPO_NAME):$(NERF_VERSION)

MY_HTTP_PROXY=http://192.168.123.169:18889
BUILD_ARGS=--build-arg http_proxy=$(MY_HTTP_PROXY) --build-arg https_proxy=$(MY_HTTP_PROXY)

build: push_base push_nerf

build_base:
	docker build -t $(BASE) --target base $(BUILD_ARGS) .

push_base: build_base
	docker push $(BASE)

build_nerf:
	docker build -t $(NERF) --target nerfstudio $(BUILD_ARGS) .

push_nerf: build_nerf
	docker push $(NERF)

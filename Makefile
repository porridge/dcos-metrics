IMAGE_NAME=dcos-metrics-dev

.PHONY: all
all: clean build test

.PHONY: build
build: docker
	$(call buildIt,collector)
	$(call buildIt,statsd-emitter)
	$(call buildIt,collector-emitter)

.PHONY: plugins
plugins: docker clean
	$(call buildIt,plugins)

.PHONY: test
test: docker clean build
	$(call testIt,collector unit)

.PHONY: module
module:
	docker run \
		--rm \
		-it \
		-v $(PWD):/workspace/dcos-metrics \
		-v $(PWD)/build_module.sh:/workspace/build_module.sh \
		-w /workspace \
		rusxg/ubuntu-cmake \
		bash build_module.sh

.PHONY: run-module
run-module:
	bash run_module.sh

.PHONY: clean
clean:
        # Clean from within the docker container to avoid issues with file permissions:
        $(call buildIt,clean)

.PHONY: docker
docker:
	docker build -t $(IMAGE_NAME) .

define testIt
	$(call containerIt,bash -c "./scripts/test.sh $1")
endef

define buildIt
	$(call containerIt,bash -c "./scripts/build.sh $1")
endef

define containerIt
	docker run \
	--rm \
	-v $(shell pwd):/go/src/github.com/dcos/dcos-metrics \
	-w /go/src/github.com/dcos/dcos-metrics \
	$(IMAGE_NAME) \
	$1
endef


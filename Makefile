CODE_PATHS := pylabrobot_sila_bridge

GITLAB_USERNAME				?=
GITLAB_TOKEN				?=

PYTHON_VERSION				?= 3.9## default python build to 3.9

# Originally CI_PROJECT_NAME came from the CI, but it is safer if this comes directly from pyproject.toml
CI_PROJECT_NAME				:= $(shell grep -i name pyproject.toml | head -1 | awk -F'"' '{print $$2}' | tr "[A-Z]" "[a-z]" | tr "_" "-")
CI_COMMIT_REF_NAME			?= $(shell git symbolic-ref --short -q HEAD)
CI_COMMIT_REF_NAME			:= $(subst /,-,$(CI_COMMIT_REF_NAME))
CI_COMMIT_BEFORE_SHA		:= $(shell git rev-parse HEAD^1)
CI_COMMIT_SHA				?= $(shell git rev-parse HEAD)
CI_COMMIT_SHORT_SHA			?= $(shell git rev-parse --short HEAD)
CURRENT_LOCATION			?= $(shell pwd)
CI_ENVIRONMENT_NAME			?=
CI_DOCKER_BUILD_ARGS		?=

PYPI_URL					?= https://artifactory.aws.gel.ac/artifactory/api/pypi/pypi/simple

CI_REGISTRY					?= registry.gitlab.com
CI_REGISTRY_IMAGE			?= ${CI_REGISTRY}/https://gitlab.com/opensourcelab/pylabrobot-sila-bridge
DOCKER_IMAGE_NAMESPACE		:= ${CI_REGISTRY_IMAGE}/${CI_PROJECT_NAME}
DOCKER_IMAGE_TAG			?= ${DOCKER_IMAGE_NAMESPACE}:py${PYTHON_VERSION}-${CI_COMMIT_REF_NAME}

.PHONY: build test

help:	## Prints this help/overview message
	@awk 'BEGIN {FS = ":.*?## "} /^[a-z0-9_-]+:.*?## / {printf "\033[36m%-17s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

_CMD_DOCKER_BUILD := \
	docker build \
		${CI_DOCKER_BUILD_ARGS} \

## construct the docker image with the git branch inc. into the tag
.build_${PYTHON_VERSION}: Dockerfile pylabrobot_sila_bridge clean__py
	${_CMD_DOCKER_BUILD} \
		--platform linux/amd64 \
		--build-arg PYTHON_BASE=${PYTHON_VERSION} \
		--build-arg PYPI_URL=${PYPI_URL} \
		--cache-from ${DOCKER_IMAGE_TAG} \
		--tag ${DOCKER_IMAGE_TAG} \
		--target test \
		.
	touch $@

build: .build_${PYTHON_VERSION} ## build local python3.9 image. Define PYTHON_VERSION to select other python version.

push: build
	docker push ${DOCKER_IMAGE_TAG}

pull:
	docker pull ${DOCKER_IMAGE_TAG} || echo "No pre-made image available"

test:	## run pytest on mounted-in tests (change tests, no rebuild!)
	mkdir -p $(shell pwd)/bin && \
	docker run \
			--platform linux/amd64 \
			--volume $(shell pwd)/bin/:/pylabrobot_sila_bridge/bin/ \
			--volume $(shell pwd):/pylabrobot_sila_bridge:rw \
			${DOCKER_IMAGE_TAG} \
			pytest --cov-report xml:/pylabrobot_sila_bridge/bin/coverage.xml tests/

test_shell:	## enter test docker image Bash
	mkdir -p $(shell pwd)/bin && \
		docker run -it \
				--platform linux/amd64 \
				--volume $(shell pwd)/bin/:/pylabrobot_sila_bridge/bin/ \
				--volume $(shell pwd):/pylabrobot_sila_bridge:rw \
				${DOCKER_IMAGE_TAG} \
				/bin/bash

# cleaning up --------------------------------------------------------
clean: clean__docker clean__py clean__reports

clean__py:	## clean python temp files
	find . -iname *.pyc -delete
	find . -iname __pycache__ -delete
	find . -iname .cache -delete

clean__docker:	## Clean up all docker images generated by this repo
	rm -rf .*sentinel
	for image in \
		$$(docker images --format "{\{.Repository}\}:{\{.Tag}\}\t{\{.ID}\}" | grep -e "${DOCKER_IMAGE_NAMESPACE}" | awk '{print $$2}'); do \
		docker rmi -f $$image; \
	done

clean__reports:
	rm -rf ${PATH_REPORTS}

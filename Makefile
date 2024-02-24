SHELL = /bin/bash

PROJECT_NAME    := python-stack

DEBIAN_VERSION  := `cat ./version/debian`
POETRY_VERSION  := `cat ./version/poetry`
PYTHON_VERSION  := `cat ./version/python`

IMAGE_NAME      := $(or ${IMAGE_NAME}, ${IMAGE_NAME}, $(PROJECT_NAME)-image)
IMAGE_VERSION   := $(or ${IMAGE_VERSION}, ${IMAGE_VERSION}, latest)
IMAGE_TAG       := $(IMAGE_NAME):$(IMAGE_VERSION)
IMAGE_ARCHIVE   := $(IMAGE_NAME)-$(IMAGE_VERSION).tar.gz

CONTAINER_NAME  := $(PROJECT_NAME)-container
CONTAINER_ID    := $(or ${CONTAINER_ID}, ${CONTAINER_ID}, `date +%s`)

USER_NAME       := user
USER_UID        := 10000


help:
	@echo
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/\(.*\):.*##[ \t]*/    \1 ## /' | column -t -s '##'
	@echo


## Main commands

bash: ## - bash shell
	@docker container run \
	$(call as_interactive) \
	$(call as_user) \
	$(call with_labels) \
	$(call with_volume) \
	--name $(CONTAINER_NAME)-$(CONTAINER_ID) \
	$(IMAGE_TAG) bash


## Docker commands

build: prune rebuild ## - build image

rebuild:
	@docker image build \
	$(call with_build_args) \
	$(call with_labels) \
	$(call force_rebuild) \
	--tag $(IMAGE_TAG) .

images: ## - list images
	@docker image ls $(call filter_project)

containers: ## - list containers
	@docker container ls $(call filter_project)

prune: prune-containers prune-images ## - cleans up

prune-containers:
	-@docker container prune $(call filter_project) --force
	-@docker container ls $(call filter_project) --quiet | xargs docker container rm --force

prune-images:
	-@docker image prune $(call filter_project) --force
	-@docker image ls $(call filter_project) --quiet | xargs docker image rm --force

save-image:
	@docker image save $(IMAGE_TAG) | pigz --fast --processes `nproc` > /tmp/$(IMAGE_ARCHIVE)

load-image:
	@docker image load < /tmp/$(IMAGE_ARCHIVE)


define with_build_args
	--build-arg DEBIAN_VERSION=$(DEBIAN_VERSION) \
	--build-arg POETRY_VERSION=$(POETRY_VERSION) \
	--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
	--build-arg USER_NAME=$(USER_NAME) \
	--build-arg USER_UID=$(USER_UID)
endef

define with_labels
	--label project.name=$(PROJECT_NAME) \
	--label image.name=$(PROJECT_NAME)
endef

define force_rebuild
	--no-cache --pull
endef

define as_interactive
	--interactive --rm --tty
endef

define as_user
	--user $(USER_NAME)
endef

define with_volume
	--volume ./:/home/user/workdir
endef

define filter_project
	--filter label=project.name=$(PROJECT_NAME)
endef
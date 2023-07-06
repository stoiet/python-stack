PROJECT_NAME	:= python-stack

DEBIAN_VERSION	:= `cat ./version/debian`
POETRY_VERSION	:= `cat ./version/poetry`
PYTHON_VERSION	:= `cat ./version/python`

IMAGE_NAME		:= $(PROJECT_NAME)-image
CONTAINER_NAME	:= $(PROJECT_NAME)-container
CONTAINER_ID	:= $(or ${CONTAINER_ID}, ${CONTAINER_ID}, `date +%s`)


## Commands

help:
	@echo
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/\(.*\):.*##[ \t]*/    \1 ## /' | column -t -s '##'
	@echo

build: ## - build image
	docker image build $(call build_args) $(call labels) --tag $(IMAGE_NAME):latest .

bash: ## - open bash shell
	docker container run --interactive --rm --tty --user user --name $(CONTAINER_NAME)-$(CONTAINER_ID) $(IMAGE_NAME):latest bash


define build_args
	--build-arg DEBIAN_VERSION=$(DEBIAN_VERSION) \
	--build-arg POETRY_VERSION=$(POETRY_VERSION) \
	--build-arg PYTHON_VERSION=$(PYTHON_VERSION)
endef

define labels
	--label PROJECT_NAME=$(PROJECT_NAME) \
	--label DEBIAN_VERSION=$(DEBIAN_VERSION) \
	--label POETRY_VERSION=$(POETRY_VERSION) \
	--label PYTHON_VERSION=$(PYTHON_VERSION)
endef
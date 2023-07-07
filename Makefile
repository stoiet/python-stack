PROJECT_NAME    := python-stack

DEBIAN_VERSION  := `cat ./version/debian`
POETRY_VERSION  := `cat ./version/poetry`
PYTHON_VERSION  := `cat ./version/python`

IMAGE_NAME      := $(PROJECT_NAME)-image
CONTAINER_NAME  := $(PROJECT_NAME)-container
CONTAINER_ID    := $(or ${CONTAINER_ID}, ${CONTAINER_ID}, `date +%s`)

USER_NAME       := user
USER_UID        := 10000


## Commands

help:
	@echo
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/\(.*\):.*##[ \t]*/    \1 ## /' | column -t -s '##'
	@echo

build: ## - build image
	docker image build \
	$(call build_args) \
	$(call build_labels) \
	$(call build_secure) \
	--tag $(IMAGE_NAME):latest .

bash: ## - open bash shell
	docker container run --interactive --rm --tty --user $(USER_NAME) --name $(CONTAINER_NAME)-$(CONTAINER_ID) --volume ./:/home/user/workdir $(IMAGE_NAME):latest bash


define build_args
	--build-arg DEBIAN_VERSION=$(DEBIAN_VERSION) \
	--build-arg POETRY_VERSION=$(POETRY_VERSION) \
	--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
	--build-arg USER_NAME=$(USER_NAME) \
	--build-arg USER_UID=$(USER_UID)
endef

define build_labels
	--label PROJECT_NAME=$(PROJECT_NAME) \
	--label DEBIAN_VERSION=$(DEBIAN_VERSION) \
	--label POETRY_VERSION=$(POETRY_VERSION) \
	--label PYTHON_VERSION=$(PYTHON_VERSION)
endef

define build_secure
	--no-cache \
	--pull
endef
.PHONY: test

DEBIAN_VERSION				:= `cat ./configs/versions/debian-version`
PYTHON_VERSION				:= `cat ./configs/versions/python-version`
POETRY_VERSION				:= `cat ./configs/versions/poetry-version`

DOCKER_COMPOSE_FILE			:= ./configs/docker/docker-compose.yaml

IMAGE_NAME 					:= python-stack
IMAGE_TAG					:= $(or ${IMAGE_TAG}, ${IMAGE_TAG}, latest)
CONTAINER_ID				:= $(or ${CONTAINER_ID}, ${CONTAINER_ID}, `date +%s`)

help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/\(.*\):.*##[ \t]*/    \1 ## /' | column -t -s '##'
	@echo


## Docker commands:

build: ## Build project image
	$(call docker_compose) build $(IMAGE_NAME)

destroy: ## Destroy project containers and image
	$(call docker_compose) down --rmi all --remove-orphans

images: ## List project images
	$(call docker_compose) images $(IMAGE_NAME)

containers: ## List project containers
	$(call docker_compose) ps --all

bash: ## Run bash shell
	$(call docker_compose_run) bash


define docker_compose
	$(call docker_compose_file_variables) docker-compose --file $(DOCKER_COMPOSE_FILE) --project-name $(IMAGE_NAME)
endef

define docker_compose_run
	$(call docker_compose) run --name $(IMAGE_NAME)-$(CONTAINER_ID) --user=user --use-aliases --no-deps --rm $(IMAGE_NAME)
endef

define docker_compose_file_variables
	IMAGE_NAME=$(IMAGE_NAME) \
	IMAGE_TAG=$(IMAGE_TAG) \
	CONTAINER_ID=$(CONTAINER_ID) \
	DEBIAN_VERSION=$(DEBIAN_VERSION) \
	PYTHON_VERSION=$(PYTHON_VERSION) \
	POETRY_VERSION=$(POETRY_VERSION)
endef

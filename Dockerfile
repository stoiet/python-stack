ARG PYTHON_VERSION
ARG DEBIAN_VERSION
FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION} AS base

ARG USER_NAME
ENV USER_HOME /home/${USER_NAME}
ENV USER_CONFIG ${USER_HOME}/.config
ENV USER_WORKDIR ${USER_HOME}/workdir

ARG POETRY_VERSION
RUN set -eux && \
    apt-get update && \
    apt-get upgrade --assume-yes && \
    apt-get install --assume-yes --no-install-recommends --no-install-suggests curl && \
    curl -sSL https://install.python-poetry.org | POETRY_HOME=/usr/local POETRY_VERSION=${POETRY_VERSION} python - && \
    apt-get remove --assume-yes --purge curl && \
    apt-get autoremove --assume-yes --purge && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

ARG USER_NAME
ARG USER_UID
RUN useradd -c ${USER_NAME} -d ${USER_HOME} -l -m -s /bin/false -u ${USER_UID} -U ${USER_NAME}

ARG USER_NAME
USER ${USER_NAME}

RUN mkdir -p ${USER_WORKDIR} && \
    mkdir -p ${USER_CONFIG}

COPY --chown=user ./config/poetry.toml ${USER_CONFIG}/pypoetry/config.toml

WORKDIR ${USER_WORKDIR}

FROM base AS build

COPY --chown=user ./poetry.lock ${USER_WORKDIR}/poetry.lock
COPY --chown=user ./pyproject.toml ${USER_WORKDIR}/pyproject.toml

RUN poetry install --sync --no-root --all-extras --compile --no-interaction

COPY --chown=user ./src ${USER_WORKDIR}/src

RUN poetry run python -m compileall ${USER_WORKDIR}/src

ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}-alpine AS production

ARG USER_NAME
ENV USER_HOME /home/${USER_NAME}
ENV USER_WORKDIR ${USER_HOME}/workdir

ARG USER_NAME
ARG USER_UID
RUN addgroup --gid ${USER_UID} ${USER_NAME} && \
    adduser -s /bin/false -G ${USER_NAME} -D -u ${USER_UID} ${USER_NAME}

ARG USER_NAME
USER ${USER_NAME}

RUN mkdir -p ${USER_WORKDIR}

COPY --from=build --chown=user ${USER_WORKDIR}/.venv ${USER_WORKDIR}/.venv
COPY --from=build --chown=user ${USER_WORKDIR}/src ${USER_WORKDIR}/src

WORKDIR ${USER_WORKDIR}

CMD . .venv/bin/activate && python -m uvicorn src.main:app

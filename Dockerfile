ARG PYTHON_VERSION
ARG DEBIAN_VERSION
FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION}

ARG USER_NAME
ENV USER_HOME /home/${USER_NAME}
ENV USER_CONFIG ${USER_HOME}/.config
ENV USER_WORKDIR ${USER_HOME}/workdir

ARG POETRY_VERSION
RUN set -ex && \
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
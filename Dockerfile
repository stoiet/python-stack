ARG PYTHON_VERSION
ARG DEBIAN_VERSION
FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION}

ARG USER_NAME
ENV USER_HOME /home/${USER_NAME}
ENV USER_CONFIG ${USER_HOME}/.config
ENV USER_LOCAL ${USER_HOME}/.local
ENV USER_WORKDIR ${USER_HOME}/workdir
ENV PATH ${USER_LOCAL}/bin:${PATH}

RUN apt update && \
    apt upgrade --assume-yes && \
    apt install --assume-yes --no-install-recommends curl && \
    apt autoremove

ARG USER_NAME
ARG USER_UID
RUN useradd -c ${USER_NAME} -d ${USER_HOME} -l -m -s /bin/false -u ${USER_UID} -U ${USER_NAME}

ARG USER_NAME
USER ${USER_NAME}

RUN mkdir -p ${USER_WORKDIR} && \
    mkdir -p ${USER_CONFIG} && \
    mkdir -p ${USER_LOCAL}
    
WORKDIR ${USER_WORKDIR}

COPY --chown=user ./config/poetry.toml ${USER_CONFIG}/pypoetry/config.toml

ARG POETRY_VERSION
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=${USER_LOCAL} POETRY_VERSION=${POETRY_VERSION} python -
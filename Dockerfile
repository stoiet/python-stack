ARG PYTHON_VERSION
ARG DEBIAN_VERSION
FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION}

ARG USER_NAME
ENV HOME /home/${USER_NAME}
ENV WORKDIR ${HOME}/workdir
ENV CONFIG ${HOME}/.config
ENV PATH ${HOME}/.local/bin/:${PATH}

ARG USER_NAME
ARG USER_UID
RUN useradd -c ${USER_NAME} -d ${HOME} -l -m -s /bin/false -u ${USER_UID} -U ${USER_NAME}

ARG USER_NAME
USER ${USER_NAME}

RUN mkdir -p ${WORKDIR} && \
    mkdir -p ${CONFIG}
    
WORKDIR ${WORKDIR}

COPY --chown=user ./config/poetry.toml ${CONFIG}/pypoetry/config.toml

ARG POETRY_VERSION
RUN pip --python $(which python) --no-input --no-cache-dir \
    install --no-warn-script-location --no-warn-conflicts --prefer-binary --user \
    poetry==${POETRY_VERSION}
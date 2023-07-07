ARG PYTHON_VERSION
ARG DEBIAN_VERSION
FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION}

ENV HOME /home/user
ENV USER user
ENV UID 10000
ENV WORKDIR ${HOME}/workdir
ENV CONFIG ${HOME}/.config
ENV PATH ${HOME}/.local/bin/:${PATH}

RUN useradd -c ${USER} -d ${HOME} -l -m -s /bin/false -u ${UID} -U ${USER}

USER ${USER}

RUN mkdir -p ${WORKDIR} && \
    mkdir -p ${CONFIG}
    
WORKDIR ${WORKDIR}

COPY --chown=user ./config/poetry.toml ${CONFIG}/pypoetry/config.toml

ARG POETRY_VERSION
RUN pip --python $(which python) --no-input --no-cache-dir \
    install --no-warn-script-location --no-warn-conflicts --prefer-binary --user \
    poetry==${POETRY_VERSION}
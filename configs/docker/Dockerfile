ARG PYTHON_VERSION
ARG DEBIAN_VERSION
FROM python:${PYTHON_VERSION}-${DEBIAN_VERSION} AS python-stack-image

ENV USER user
ENV WORKDIR /usr/user/workdir
ENV HOME /usr/user
ENV BIN_PATH /usr/bin
ENV XDG_CONFIG_HOME ${HOME}/.config
ENV PATH ${HOME}/.local/bin:${PATH}
ENV PYTHONDONTWRITEBYTECODE 1

RUN useradd -d ${HOME} -m -s /bin/bash -r ${USER}

USER ${USER}

RUN mkdir ${WORKDIR} && \
    mkdir -p ${XDG_CONFIG_HOME}/pypoetry

COPY --chown=user ./configs/poetry/* ${XDG_CONFIG_HOME}/pypoetry/

ARG POETRY_VERSION
RUN python -m pip install --user --upgrade pip && \
    python -m pip install --user --prefer-binary --no-warn-script-location poetry==${POETRY_VERSION}

WORKDIR ${WORKDIR}

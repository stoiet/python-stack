ARG PYTHON_VERSION
ARG DEBIAN_VERSION
FROM python:${PYTHON_VERSION}-${DEBIAN_VERSION} AS python-stack-image

ENV USER user
ENV WORKDIR /usr/user/workdir
ENV HOME /usr/user
ENV BIN_PATH /usr/bin

RUN useradd -d ${HOME} -m -s /bin/bash -r ${USER}

USER ${USER}

RUN mkdir ${WORKDIR}

ARG POETRY_VERSION
RUN python3 -m pip install --user --upgrade pip && \
    python3 -m pip install --user --prefer-binary --no-warn-script-location poetry==${POETRY_VERSION}

WORKDIR ${WORKDIR}

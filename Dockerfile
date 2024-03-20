# parameters
ARG ARCH
ARG NAME
ARG ORGANIZATION
ARG DESCRIPTION
ARG MAINTAINER

# ==================================================>
# ==> Do not change the code below this line
ARG BASE_REGISTRY=docker.io
ARG BASE_ORGANIZATION=ripl
ARG BASE_REPOSITORY=ubuntu
ARG BASE_TAG=22.04

# define base image
FROM ${BASE_REGISTRY}/${BASE_ORGANIZATION}/${BASE_REPOSITORY}:${BASE_TAG}-${ARCH} as BASE

# recall all arguments
# - current project
ARG NAME
ARG ORGANIZATION
ARG DESCRIPTION
ARG MAINTAINER
# - base project
ARG BASE_REGISTRY
ARG BASE_ORGANIZATION
ARG BASE_REPOSITORY
ARG BASE_TAG
# - defaults
ARG LAUNCHER=default

# define/create project paths
ARG PROJECT_PATH="${CPK_SOURCE_DIR}/${NAME}"
ARG PROJECT_LAUNCHERS_PATH="${CPK_LAUNCHERS_DIR}/${NAME}"
RUN mkdir -p "${PROJECT_PATH}"
RUN mkdir -p "${PROJECT_LAUNCHERS_PATH}"
WORKDIR "${PROJECT_PATH}"

# keep some arguments as environment variables
ENV \
    CPK_PROJECT_NAME="${NAME}" \
    CPK_PROJECT_DESCRIPTION="${DESCRIPTION}" \
    CPK_PROJECT_MAINTAINER="${MAINTAINER}" \
    CPK_PROJECT_PATH="${PROJECT_PATH}" \
    CPK_PROJECT_LAUNCHERS_PATH="${PROJECT_LAUNCHERS_PATH}" \
    CPK_LAUNCHER="${LAUNCHER}"

RUN apt update && apt install -y gnupg2 && rm -rf /var/lib/apt/lists/*
RUN wget -qO - https://repo.ultraleap.com/keys/apt/gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/ultraleap.gpg
RUN echo 'deb [arch=amd64] https://repo.ultraleap.com/apt stable main' | tee /etc/apt/sources.list.d/ultraleap.list

# install apt dependencies
COPY ./dependencies-apt.txt "${PROJECT_PATH}/"
RUN cpk-apt-install ${PROJECT_PATH}/dependencies-apt.txt

RUN wget -qO Miniforge3.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh \
    && bash Miniforge3.sh -b -p /opt/miniforge3 \
    && rm Miniforge3.sh

# install launcher scripts
COPY ./launchers/. "${PROJECT_LAUNCHERS_PATH}/"
COPY ./launchers/default.sh "${PROJECT_LAUNCHERS_PATH}/"
RUN cpk-install-launchers "${PROJECT_LAUNCHERS_PATH}"

# copy project root
COPY ./*.cpk ./*.sh ${PROJECT_PATH}/

# install python dependencies and packages
SHELL ["/bin/bash", "-c"]
COPY ./dependencies-py3.txt "${PROJECT_PATH}/"
COPY ./packages "${CPK_PROJECT_PATH}/packages"
RUN . /opt/miniforge3/etc/profile.d/conda.sh \
    && . /opt/miniforge3/etc/profile.d/mamba.sh \
    && mamba create -n ros \
    && mamba activate ros \
    && pip install -U pip \
    && conda config --env --add channels robostack-staging \
    && mamba install -y ros-noetic-desktop-full \
    && git clone --depth 1 https://github.com/ultraleap/leapc-python-bindings.git /opt/leapc-python-bindings \
    && cd /opt/leapc-python-bindings/ \
    && pip install -r requirements.txt \
    && python -m build leapc-cffi \
    && pip install leapc-cffi/dist/leapc_cffi-0.0.1.tar.gz \
    && pip install -e leapc-python-api \
    && cpk-pip3-install ${PROJECT_PATH}/dependencies-py3.txt \
    && catkin build --workspace ${CPK_CODE_DIR} \
    && cpk-install-packages-dependencies

# define default command
CMD ["bash", "-c", "launcher-${CPK_LAUNCHER}"]

# store module metadata
LABEL \
    cpk.label.current="${ORGANIZATION}.${NAME}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.description="${DESCRIPTION}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.code.location="${PROJECT_PATH}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.base.registry="${BASE_REGISTRY}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.base.organization="${BASE_ORGANIZATION}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.base.project="${BASE_REPOSITORY}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.base.tag="${BASE_TAG}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.maintainer="${MAINTAINER}"
# <== Do not change the code above this line
# <==================================================

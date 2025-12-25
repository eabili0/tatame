ARG UBUNTU_VERSION="24.04"

FROM ubuntu:${UBUNTU_VERSION}

USER root

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y wget curl qemu-utils cloud-image-utils

ENV WORKDIR="/data"
WORKDIR ${WORKDIR}

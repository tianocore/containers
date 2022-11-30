# Dockerfile for building container images for use in the EDK2 CI.
#
# Copyright (C) 2022, Red Hat, Inc.
# SPDX-License-Identifier: BSD-2-Clause-Patent
#
# This file contains the definitions for images to be used for different
# jobs in the EDK2 CI pipeline. The set of tools and dependencies is split into
# multiple images to reduce the overall download size by providing images
# tailored to the task of the CI job. Currently there are two images: "build"
# and "test".
# The images are indented to run on x86_64.


# Build Image
# This image is intended for jobs that compile the source code and as a general
# purpose image. It contains the toolchains for all supported architectures, and
# all build dependencies.
FROM registry.fedoraproject.org/fedora-minimal:35 AS build
ENV GCC_VERSION=11.2.1-1.fc35
ENV NASM_VERSION=2.15.05-1.fc35
ENV PYTHON_VERSION=3.10
ARG GCC_LOONGARCH64_URL="https://github.com/loongson/build-tools/releases/download/2022.09.06/loongarch64-clfs-6.3-cross-tools-c-only.tar.xz"
RUN microdnf \
      --assumeyes \
      --nodocs \
      --setopt=install_weak_deps=0 \
      install \
        gcc-c++-${GCC_VERSION} \
        gcc-${GCC_VERSION} \
        gcc-aarch64-linux-gnu-${GCC_VERSION} \
        gcc-arm-linux-gnu-${GCC_VERSION} \
        gcc-riscv64-linux-gnu-${GCC_VERSION} \
        git \
        libX11-devel \
        libXext-devel \
        libuuid-devel \
        make \
        nuget \
        nasm-${NASM_VERSION} \
        python${PYTHON_VERSION} \
        python3-distutils-extra \
        python3-pip \
        python3-setuptools \
        nodejs \
        npm \
        tar \
        sudo
RUN alternatives --install /usr/bin/python python /usr/bin/python3 1
RUN pip install pip --upgrade

RUN mkdir -p /cross-tools/ && \
      curl -L "${GCC_LOONGARCH64_URL}" | \
      tar --extract -z --strip-components=1 -C /cross-tools

ENV GCC5_AARCH64_PREFIX /usr/bin/aarch64-linux-gnu-
ENV GCC5_ARM_PREFIX     /usr/bin/arm-linux-gnu-
ENV GCC5_RISCV64_PREFIX /usr/bin/riscv64-linux-gnu-
ENV GCC5_LOONGARCH64_PREFIX /cross-tools/bin/loongarch64-unknown-linux-gnu-

# Tools used by build extensions.
RUN npm install -g npm markdownlint-cli cspell

# Test Image
# This image is indented for jobs that run tests (and possibly also build)
# firmware images. It is based on the build image and adds Qemu for the
# architectures under test.

#Building qemu from source:
FROM build AS test
ARG QEMU_URL="https://download.qemu.org/qemu-7.1.0.tar.xz"
RUN microdnf \
      --assumeyes \
      --nodocs \
      --setopt=install_weak_deps=0 \
      install \
        bzip2 \
        findutils \
        git \
        glib2-devel \
        libfdt-devel \
        ninja-build \
        pixman-devel \
        python3 \
        tar \
        zlib-devel && \
    mkdir -p qemu-build && cd qemu-build && \
    curl "${QEMU_URL}" | \
    tar --extract --strip-components=1 -J && \
    ./configure --target-list=x86_64-softmmu,arm-softmmu,aarch64-softmmu,loongarch64-softmmu && \
    make install -j $(nproc) && \
    rm -rf qemu-build && \
    microdnf \
      --assumeyes \
      remove \
        ninja-build

# Dev Image
# This image is indented for local use. This builds on the test image but adds
# tools for local developers.
FROM test AS dev
ENV GCM_LINK=https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.785/gcm-linux_amd64.2.0.785.tar.gz
RUN microdnf \
      --assumeyes \
      --nodocs \
      --setopt=install_weak_deps=0 \
      install \
        libicu \
        wget \
        tar

# Setup the git credential manager for developer credentials.
RUN wget ${GCM_LINK} -O gcm.tar.gz && tar -xvf gcm.tar.gz -C /usr/local/bin && rm gcm.tar.gz
RUN git-credential-manager-core configure
RUN git config --global credential.credentialStore cache

# Dockerfile for building container images for use in the EDK2 CI.
#
# Copyright (C) 2022, Red Hat, Inc.
# Copyright (c) 2023 Loongson Technology Corporation Limited. All rights reserved.
# SPDX-License-Identifier: BSD-2-Clause-Patent
#
# This file contains the definitions for images to be used for different
# jobs in the EDK2 CI pipeline. The set of tools and dependencies is split into
# multiple images to reduce the overall download size by providing images
# tailored to the task of the CI job. Currently there are two images: "build"
# and "test".
# The images are intended to run on x86_64.


# Build Image
# This image is intended for jobs that compile the source code and as a general
# purpose image. It contains the toolchains for all supported architectures, and
# all build dependencies.
FROM registry.fedoraproject.org/fedora:39 AS build
ARG GCC_VERSION=13.2.1-4.fc39
ARG GCC_VERSION_CROSS=13.2.1-1.fc39
ARG NASM_VERSION=2.16.01-4.fc39
ARG PYTHON_VERSION=3.12
ARG CSPELL_VERSION=8.0.0
ARG MARKDOWNLINT_VERSION=0.37.0
ARG POWERSHELL_VERSION=7.4.0
ARG DOTNET_VERSION=6.0
RUN dnf \
      --assumeyes \
      --nodocs \
      --setopt=install_weak_deps=0 \
      install \
        acpica-tools \
        dotnet-runtime-${DOTNET_VERSION} \
        curl \
        gcc-c++-${GCC_VERSION} \
        gcc-${GCC_VERSION} \
        gcc-aarch64-linux-gnu-${GCC_VERSION_CROSS} \
        gcc-arm-linux-gnu-${GCC_VERSION_CROSS} \
        gcc-riscv64-linux-gnu-${GCC_VERSION_CROSS} \
        gcc-loongarch64-linux-gnu-${GCC_VERSION_CROSS} \
        git \
        lcov \
        libX11-devel \
        libXext-devel \
        libuuid-devel \
        make \
        nuget \
        nasm-${NASM_VERSION} \
        https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-1.rh.x86_64.rpm \
        python${PYTHON_VERSION} \
        python3-distutils-extra \
        python3-pip \
        python3-devel \
        python3-setuptools \
        nodejs \
        npm \
        tar \
        sudo
RUN alternatives --install /usr/bin/python python /usr/bin/python3 1
RUN pip install pip lcov_cobertura setuptools --upgrade

ENV GCC5_AARCH64_PREFIX /usr/bin/aarch64-linux-gnu-
ENV GCC5_ARM_PREFIX     /usr/bin/arm-linux-gnu-
ENV GCC5_RISCV64_PREFIX /usr/bin/riscv64-linux-gnu-
ENV GCC5_LOONGARCH64_PREFIX /usr/bin/loongarch64-linux-gnu-

# Tools used by build extensions.
RUN npm install -g npm \
      cspell@${CSPELL_VERSION} \
      markdownlint-cli@${MARKDOWNLINT_VERSION}

# Test Image
# This image is intended for jobs that run tests (and possibly also build)
# firmware images. It is based on the build image and adds Qemu for the
# architectures under test.

#Building qemu from source:
FROM build AS test
ARG QEMU_URL="https://gitlab.com/qemu-project/qemu.git"
ARG QEMU_BRANCH="v8.1.3"
RUN dnf \
      --assumeyes \
      --nodocs \
      --setopt=install_weak_deps=0 \
      install \
        bzip2 \
        findutils \
        git \
        glib2-devel \
        gtk3-devel \
        libfdt-devel \
        ninja-build \
        pixman-devel \
        python3 \
        tar \
        zlib-devel && \
    git clone "${QEMU_URL}" --branch "${QEMU_BRANCH}" --depth 1 qemu && \
    cd qemu && \
    ./configure --target-list=x86_64-softmmu,arm-softmmu,aarch64-softmmu,loongarch64-softmmu --enable-gtk && \
    make install -j $(nproc) && \
    cd .. && \
    rm -rf qemu && \
    dnf \
      --assumeyes \
      remove \
        ninja-build

# Dev Image
# This image is intended for local use. This builds on the test image but adds
# tools for local developers.
FROM test AS dev
ENV GCM_LINK=https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.785/gcm-linux_amd64.2.0.785.tar.gz
RUN dnf \
      --assumeyes \
      --nodocs \
      --setopt=install_weak_deps=0 \
      install \
        libicu \
        curl \
        tar \
        vim \
        nano

# Setup the git credential manager for developer credentials.
RUN curl -L "${GCM_LINK}" | tar -xz -C /usr/local/bin
RUN git-credential-manager-core configure
RUN git config --global credential.credentialStore cache
RUN cp /etc/skel/.bashrc /root/.bashrc

# Set the entry point
COPY fedora39_dev_entrypoint.sh /usr/libexec/entrypoint
ENTRYPOINT ["/usr/libexec/entrypoint"]

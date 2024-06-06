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
# The images are intended to run on x86_64.


# Build Image
# This image is intended for jobs that compile the source code and as a general
# purpose image. It contains the toolchains for all supported architectures, and
# all build dependencies.
FROM registry.fedoraproject.org/fedora:37 AS build

# Preinstall python + dependencies as virtual environment
RUN dnf \
      --assumeyes \
      --nodocs \
      --setopt=install_weak_deps=0 \
      install \
      python3 \
      python3-virtualenv
RUN virtualenv /opt/venv
ENV VIRTUAL_ENV /opt/venv
ENV PATH /opt/venv/bin:$PATH
RUN pip install --upgrade pip \
        -r "https://raw.githubusercontent.com/tianocore/edk2/master/pip-requirements.txt"


ARG GCC_VERSION=12.3.1-1.fc37
ARG GCC_VERSION_CROSS=12.2.1-2.fc37
ARG NASM_VERSION=2.15.05-3.fc37
ARG GCC_LOONGARCH64_URL="https://github.com/loongson/build-tools/releases/download/2022.09.06/loongarch64-clfs-6.3-cross-tools-c-only.tar.xz"
ARG CSPELL_VERSION=5.20.0
ARG MARKDOWNLINT_VERSION=0.31.0
ARG POWERSHELL_VERSION=7.3.3
ARG DOTNET_VERSION=6.0
RUN dnf \
      --assumeyes \
      --nodocs \
      --setopt=install_weak_deps=0 \
      install \
        acpica-tools \
        dotnet-runtime-${DOTNET_VERSION} \
        curl \
        diffutils \
        gcc-c++-${GCC_VERSION} \
        gcc-${GCC_VERSION} \
        gcc-aarch64-linux-gnu-${GCC_VERSION_CROSS} \
        gcc-arm-linux-gnu-${GCC_VERSION_CROSS} \
        gcc-riscv64-linux-gnu-${GCC_VERSION_CROSS} \
        git \
        lcov \
        libX11-devel \
        libXext-devel \
        libuuid-devel \
        make \
        nuget \
        nasm-${NASM_VERSION} \
        https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-1.rh.x86_64.rpm \
        nodejs \
        npm \
        tar \
        sudo

RUN mkdir -p /cross-tools/ && \
      curl -L "${GCC_LOONGARCH64_URL}" | \
      tar --extract -z --strip-components=1 -C /cross-tools

ENV GCC5_AARCH64_PREFIX /usr/bin/aarch64-linux-gnu-
ENV GCC5_ARM_PREFIX     /usr/bin/arm-linux-gnu-
ENV GCC5_RISCV64_PREFIX /usr/bin/riscv64-linux-gnu-
ENV GCC5_LOONGARCH64_PREFIX /cross-tools/bin/loongarch64-unknown-linux-gnu-

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
ARG QEMU_BRANCH="v8.0.0"
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
COPY fedora37_dev_entrypoint.sh /usr/libexec/entrypoint
ENTRYPOINT ["/usr/libexec/entrypoint"]

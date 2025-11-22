# Dockerfile for building container images for use in the EDK2 CI.
#
# Copyright (C) 2025, Red Hat, Inc.
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
FROM registry.fedoraproject.org/fedora:43 AS build

ARG CSPELL_VERSION=9.3.0
ARG MARKDOWNLINT_VERSION=0.44.0
ARG POWERSHELL_VERSION=7.5.4
ARG DOTNET_VERSION=9.0
RUN --mount=type=cache,target=/var/cache/libdnf5,sharing=locked \
    dnf \
      --assumeyes \
      --nodocs \
      --setopt=install_weak_deps=0 \
      install \
        acpica-tools \
        dotnet-runtime-${DOTNET_VERSION} \
        clang \
        curl \
        gcc-c++ \
        gcc \
        gcc-aarch64-linux-gnu \
        gcc-arm-linux-gnu \
        gcc-riscv64-linux-gnu \
        gcc-loongarch64-linux-gnu \
        git \
        lcov \
        libX11-devel \
        libXext-devel \
        libuuid-devel \
        libasan \
        libubsan \
        lld \
        llvm \
        make \
        nuget \
        nasm \
        https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-1.rh.x86_64.rpm \
        python3 \
        python3-distutils-extra \
        python3-pip \
        python3-devel \
        nodejs \
        npm \
        tar \
        sudo
RUN alternatives --install /usr/bin/python python /usr/bin/python3 1

# Preinstall python + dependencies as virtual environment
RUN --mount=type=cache,target=/var/cache/libdnf5,sharing=locked \
    dnf \
      --assumeyes \
      --nodocs \
      --setopt=install_weak_deps=0 \
      install \
      python3 \
      python3-virtualenv
RUN virtualenv=/opt/venv
ENV VIRTUAL_ENV=/opt/venv
ENV PATH=/opt/venv/bin:$PATH
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip \
        -r "https://raw.githubusercontent.com/tianocore/edk2/master/pip-requirements.txt"

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip lcov_cobertura setuptools

# Set toolchains prefix
ENV GCC_AARCH64_PREFIX=/usr/bin/aarch64-linux-gnu-
ENV GCC_ARM_PREFIX=/usr/bin/arm-linux-gnu-
ENV GCC_RISCV64_PREFIX=/usr/bin/riscv64-linux-gnu-
ENV GCC_LOONGARCH64_PREFIX=/usr/bin/loongarch64-linux-gnu-
# - Also set GCC5, which is deprecated, but still in use.
ENV GCC5_AARCH64_PREFIX=/usr/bin/aarch64-linux-gnu-
ENV GCC5_ARM_PREFIX=/usr/bin/arm-linux-gnu-
ENV GCC5_RISCV64_PREFIX=/usr/bin/riscv64-linux-gnu-
ENV GCC5_LOONGARCH64_PREFIX=/usr/bin/loongarch64-linux-gnu-

# Tools used by build extensions.
RUN --mount=type=cache,target=/root/.npm \
    npm install -g npm \
      cspell@${CSPELL_VERSION} \
      markdownlint-cli@${MARKDOWNLINT_VERSION}

# Test Image
# This image is intended for jobs that run tests (and possibly also build)
# firmware images. It is based on the build image and adds Qemu for the
# architectures under test.

FROM build AS test
RUN --mount=type=cache,target=/var/cache/libdnf5,sharing=locked \
    dnf \
      --assumeyes \
      --nodocs \
      --setopt=install_weak_deps=0 \
      install \
        qemu-system-arm \
        qemu-system-aarch64 \
        qemu-system-loongarch64 \
        qemu-system-x86 \
        qemu-system-riscv \
        qemu-ui-gtk

# Dev Image
# This image is intended for local use. This builds on the test image but adds
# tools for local developers.
FROM test AS dev
ENV GCM_LINK=https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.6.0/gcm-linux_amd64.2.6.0.tar.gz
RUN --mount=type=cache,target=/var/cache/libdnf5,sharing=locked \
    dnf \
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
RUN git-credential-manager configure
RUN git config --global credential.credentialStore cache
RUN cp /etc/skel/.bashrc /root/.bashrc

# Set the entry point
COPY fedora43_dev_entrypoint.sh /usr/libexec/entrypoint
ENTRYPOINT ["/usr/libexec/entrypoint"]

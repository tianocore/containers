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
RUN microdnf \
      --assumeyes \
      --nodocs \
      --setopt=install_weak_deps=0 \
      install \
        acpica-tools \
        gcc-c++\
        gcc \
        gcc-aarch64-linux-gnu \
        gcc-arm-linux-gnu \
        gcc-riscv64-linux-gnu \
        git \
        libX11-devel \
        libXext-devel \
        libuuid-devel \
        make \
        nuget \
        nasm \
        python \
        python3-distutils-extra \
        python3-pip \
        python3-setuptools
RUN pip install pip --upgrade
ENV GCC5_AARCH64_PREFIX /usr/bin/aarch64-linux-gnu-
ENV GCC5_ARM_PREFIX     /usr/bin/arm-linux-gnu-
ENV GCC5_RISCV64_PREFIX /usr/bin/riscv64-linux-gnu-


# Test Image
# This image is indented for jobs that run tests (and possibly also build)
# firmware images. It is based on the build image and adds Qemu for the
# architectures under test.
FROM build AS test
RUN microdnf \
      --assumeyes \
      --nodocs \
      --setopt=install_weak_deps=0 \
      install \
        qemu-system-aarch64-core \
        qemu-system-arm-core \
        qemu-system-x86-core


# Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: BSD-2-Clause-Patent

# Build ubuntu22-based container images for use when building EDK2:
# - build.  This image has the basic set of tools required to build EDK2.  It's
# appropriate for use in CI pipelines and other automation.
# - dev.  This image is the build image, plus a few developer-friendly
# additions.  It adds more packages and sets an entrypoint to run as the
# development user.


# Build Image
# This image is intended for jobs that compile the source code and as a general
# purpose image. It contains the toolchains for all supported architectures, and
# all build dependencies.
FROM ubuntu:24.04 AS build

RUN userdel -r ubuntu

# Set the EDKREPO URL (and version)
ENV EDKREPO_URL=https://github.com/tianocore/edk2-edkrepo/releases/download/edkrepo-v2.1.2/edkrepo-2.1.2.tar.gz

# Suppresses a debconf error during apt-get install.
ENV DEBIAN_FRONTEND=noninteractive

# Set timezone.
ENV TZ=UTC

ENV GCC_MAJOR_VERSION=13

# Preinstall python + dependencies as virtual environment
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
      python3 python3-venv\
      virtualenv
RUN virtualenv /opt/venv
ENV VIRTUAL_ENV /opt/venv
ENV PATH /opt/venv/bin:$PATH
RUN pip install --upgrade pip \
        -r "https://raw.githubusercontent.com/tianocore/edk2/master/pip-requirements.txt"


# Install and update the package list
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
        software-properties-common \
        apt-utils \
        cryptsetup \
        apt-transport-https \
        sudo \
        wget \
        build-essential \
        uuid-dev \
        git \
        lcov \
        nasm \
        acpica-tools \
        virtualenv \
        device-tree-compiler \
        mono-devel \
        locales \
        gnupg \
        ca-certificates && \
    apt-get install --yes --no-install-recommends \
        g++-${GCC_MAJOR_VERSION} gcc-${GCC_MAJOR_VERSION} \
        g++-${GCC_MAJOR_VERSION}-x86-64-linux-gnux32 gcc-${GCC_MAJOR_VERSION}-x86-64-linux-gnux32 \
        g++-${GCC_MAJOR_VERSION}-aarch64-linux-gnu gcc-${GCC_MAJOR_VERSION}-aarch64-linux-gnu \
        g++-${GCC_MAJOR_VERSION}-riscv64-linux-gnu gcc-${GCC_MAJOR_VERSION}-riscv64-linux-gnu \
        g++-${GCC_MAJOR_VERSION}-arm-linux-gnueabi gcc-${GCC_MAJOR_VERSION}-arm-linux-gnueabi \
        g++-${GCC_MAJOR_VERSION}-arm-linux-gnueabihf gcc-${GCC_MAJOR_VERSION}-arm-linux-gnueabihf && \
    apt-get upgrade -y && \
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

RUN \
    update-alternatives \
      --install /usr/bin/python python /usr/bin/python3.12 1 &&\
    update-alternatives \
      --install /usr/bin/python3 python3 /usr/bin/python3.12 1 &&\
    rm -rvf /etc/alternatives/cpp && \
    update-alternatives \
      --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_MAJOR_VERSION} 100 \
      --slave /usr/bin/g++ g++ /usr/bin/g++-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/gcov gcov /usr/bin/gcov-${GCC_MAJOR_VERSION} && \
    update-alternatives \
      --install /usr/bin/cpp cpp /usr/bin/cpp-${GCC_MAJOR_VERSION} 100 && \
    update-alternatives \
      --install /usr/bin/aarch64-linux-gnu-gcc aarch64-linux-gnu-gcc /usr/bin/aarch64-linux-gnu-gcc-${GCC_MAJOR_VERSION} 100 \
      --slave /usr/bin/aarch64-linux-gnu-g++ aarch64-linux-gnu-g++ /usr/bin/aarch64-linux-gnu-g++-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/aarch64-linux-gnu-gcc-ar aarch64-linux-gnu-gcc-ar /usr/bin/aarch64-linux-gnu-gcc-ar-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/aarch64-linux-gnu-gcc-nm aarch64-linux-gnu-gcc-nm /usr/bin/aarch64-linux-gnu-gcc-nm-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/aarch64-linux-gnu-gcc-ranlib aarch64-linux-gnu-gcc-ranlib /usr/bin/aarch64-linux-gnu-gcc-ranlib-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/aarch64-linux-gnu-gcov aarch64-linux-gnu-gcov /usr/bin/aarch64-linux-gnu-gcov-${GCC_MAJOR_VERSION} && \
    update-alternatives \
      --install /usr/bin/aarch64-linux-gnu-cpp aarch64-linux-gnu-cpp /usr/bin/aarch64-linux-gnu-cpp-${GCC_MAJOR_VERSION} 100 && \
    update-alternatives \
      --install /usr/bin/arm-linux-gnueabi-gcc arm-linux-gnueabi-gcc /usr/bin/arm-linux-gnueabi-gcc-${GCC_MAJOR_VERSION} 100 \
      --slave /usr/bin/arm-linux-gnueabi-g++ arm-linux-gnueabi-g++ /usr/bin/arm-linux-gnueabi-g++-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/arm-linux-gnueabi-gcc-ar arm-linux-gnueabi-gcc-ar /usr/bin/arm-linux-gnueabi-gcc-ar-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/arm-linux-gnueabi-gcc-nm arm-linux-gnueabi-gcc-nm /usr/bin/arm-linux-gnueabi-gcc-nm-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/arm-linux-gnueabi-gcc-ranlib arm-linux-gnueabi-gcc-ranlib /usr/bin/arm-linux-gnueabi-gcc-ranlib-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/arm-linux-gnueabi-gcov arm-linux-gnueabi-gcov /usr/bin/arm-linux-gnueabi-gcov-${GCC_MAJOR_VERSION} && \
    update-alternatives \
      --install /usr/bin/arm-linux-gnueabi-cpp arm-linux-gnueabi-cpp /usr/bin/arm-linux-gnueabi-cpp-${GCC_MAJOR_VERSION} 100 && \
    update-alternatives \
      --install /usr/bin/riscv64-linux-gnu-gcc riscv64-linux-gnu-gcc /usr/bin/riscv64-linux-gnu-gcc-${GCC_MAJOR_VERSION} 100 \
      --slave /usr/bin/riscv64-linux-gnu-g++ riscv64-linux-gnu-g++ /usr/bin/riscv64-linux-gnu-g++-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/riscv64-linux-gnu-gcc-ar riscv64-linux-gnu-gcc-ar /usr/bin/riscv64-linux-gnu-gcc-ar-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/riscv64-linux-gnu-gcc-nm riscv64-linux-gnu-gcc-nm /usr/bin/riscv64-linux-gnu-gcc-nm-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/riscv64-linux-gnu-gcc-ranlib riscv64-linux-gnu-gcc-ranlib /usr/bin/riscv64-linux-gnu-gcc-ranlib-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/riscv64-linux-gnu-gcov riscv64-linux-gnu-gcov /usr/bin/riscv64-linux-gnu-gcov-${GCC_MAJOR_VERSION} && \
    update-alternatives \
      --install /usr/bin/riscv64-linux-gnu-cpp riscv64-linux-gnu-cpp /usr/bin/riscv64-linux-gnu-cpp-${GCC_MAJOR_VERSION} 100

# Set toolchains prefix
ENV GCC5_AARCH64_PREFIX /usr/bin/aarch64-linux-gnu-
ENV GCC5_ARM_PREFIX     /usr/bin/arm-linux-gnueabi-
ENV GCC5_RISCV64_PREFIX /usr/bin/riscv64-linux-gnu-

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install edkrepo
RUN mkdir /edkrepo_install && \
    cd /edkrepo_install && \
    wget -O- ${EDKREPO_URL} | tar zxvf - && \
    ./install.py --no-prompt --user $(id -nu) && \
    mkdir -p /etc/edkrepo_skel && \
    cp -R /root/.edkrepo /etc/edkrepo_skel && \
    rm -rf /edkrepo_install

COPY init_edkrepo_conf.sh /usr/bin/init_edkrepo_conf

# Test Image
# This image is intended for jobs that run tests (and possibly also build)
# firmware images. It is based on the build image and adds Qemu for the
# architectures under test.

#Building qemu from source:
FROM build AS test
ARG QEMU_URL="https://download.qemu.org/qemu-9.1.1.tar.xz"
RUN apt-get update && apt-get install --yes --no-install-recommends \
        autoconf \
        automake \
        autotools-dev \
        build-essential \
        gcc \
        libpixman-1-dev \
        libglib2.0-dev \
        libsdl2-dev \
        ninja-build \
        bc \
        tar && \
    mkdir -p qemu-build && cd qemu-build && \
    wget  "${QEMU_URL}" && \
    tar -xf qemu-9.1.1.tar.xz --strip-components=1 && \
    ./configure --target-list=x86_64-softmmu,arm-softmmu,aarch64-softmmu,riscv32-softmmu,riscv32-linux-user,riscv64-linux-user,riscv64-softmmu && \
    make install -j $(nproc) && \
    cd .. && \
    rm -rf qemu-build && \
    apt remove --yes \
        ninja-build

#####################################################################
# Dev Image
#
FROM test AS dev

# Install convenience tools.  Things we like having around, but aren't
# required.
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
        bear \
        clang \
        less \
        lld \
        llvm \
        nano \
        vim \
        cmake \
        && \
    apt-get clean

# Setup the entry point
COPY ubuntu24_dev_entrypoint.sh /usr/libexec/entrypoint
ENTRYPOINT ["/usr/libexec/entrypoint"]
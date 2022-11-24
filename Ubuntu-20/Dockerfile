# Copyright (c) 2022 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: BSD-2-Clause-Patent

# Build ubuntu20-based container images for use when building EDK2:
# - build.  This image has the basic set of tools required to build EDK2.  It's
# appropriate for use in CI pipelines and other automation.
# - dev.  This image is the build image, plus a few developer-friendly
# additions.  It adds more packages and sets an entrypoint to run as the
# development user.


#####################################################################
# Build Image
#
FROM ubuntu:20.04 AS build

# Set the EDKREPO URL (and version)
ENV EDKREPO_URL=https://github.com/tianocore/edk2-edkrepo/releases/download/edkrepo-v2.1.2/edkrepo-2.1.2.tar.gz

# Suppresses a debconf error during apt-get install.
ENV DEBIAN_FRONTEND=noninteractive

# Set timezone.
ENV TZ=UTC

ENV GCC_MAJOR_VERSION=10

# Update the package list
RUN apt-get update

# Set the locale.
RUN apt-get install --yes --no-install-recommends locales && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Upgrade all packages.
RUN apt-get upgrade -y

# Install the basics
RUN apt-get install -y cryptsetup apt-transport-https apt-utils \
      software-properties-common sudo wget && \
    apt-get install --yes python3.9 python3-pip python3.9-venv && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.9 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

# Add mono's PPA.  The stuart docs direct people to install directly from the
# mono project, so we'll do the same.
# - https://github.com/tianocore/edk2-pytool-extensions/blob/master/docs/usability/using_extdep.md#a-note-on-nuget-on-linux
RUN apt-get install -y gnupg ca-certificates && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list

# Install toolchains.
RUN apt install -y \
    g++-${GCC_MAJOR_VERSION} gcc-${GCC_MAJOR_VERSION} \
    g++-${GCC_MAJOR_VERSION}-x86-64-linux-gnux32 gcc-${GCC_MAJOR_VERSION}-x86-64-linux-gnux32 \
    g++-${GCC_MAJOR_VERSION}-aarch64-linux-gnu gcc-${GCC_MAJOR_VERSION}-aarch64-linux-gnu \
    g++-${GCC_MAJOR_VERSION}-riscv64-linux-gnu gcc-${GCC_MAJOR_VERSION}-riscv64-linux-gnu \
    g++-${GCC_MAJOR_VERSION}-arm-linux-gnueabi gcc-${GCC_MAJOR_VERSION}-arm-linux-gnueabi \
    g++-${GCC_MAJOR_VERSION}-arm-linux-gnueabihf gcc-${GCC_MAJOR_VERSION}-arm-linux-gnueabihf && \
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
ENV GCC5_AARCH64_PREFIX /usr/bin/aarch64-linux-gnu-
ENV GCC5_ARM_PREFIX     /usr/bin/arm-linux-gnueabi-
ENV GCC5_RISCV64_PREFIX /usr/bin/riscv64-linux-gnu-

# Install deps.
RUN apt install -y build-essential uuid-dev git virtualenv \
    device-tree-compiler mono-devel wget

# Cleanup
RUN apt-get -y autoremove
RUN apt-get clean

# Install edkrepo
RUN mkdir /edkrepo_install && cd /edkrepo_install && \
    wget -O- ${EDKREPO_URL} | tar zxvf - && \
    ./install.py --no-prompt --user $(id -nu) && \
    mkdir -p /etc/edkrepo_skel && \
    cp -R /root/.edkrepo /etc/edkrepo_skel && \
    rm -rf /edkrepo_install
COPY init_edkrepo_conf.sh /usr/bin/init_edkrepo_conf


# Test Image
# This image is indented for jobs that run tests (and possibly also build)
# firmware images. It is based on the build image and adds Qemu for the
# architectures under test.

#Building qemu from source:
FROM build AS test
ARG QEMU_URL="https://download.qemu.org/qemu-7.1.0.tar.xz"
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
    tar -xf qemu-7.1.0.tar.xz --strip-components=1 && \
    ./configure --target-list=x86_64-softmmu,arm-softmmu,aarch64-softmmu,riscv32-softmmu,riscv32-linux-user,riscv64-linux-user,riscv64-softmmu && \
    make install -j $(nproc) && \
    rm -rf qemu-build && \
    apt remove --yes \
        ninja-build

#####################################################################
# Dev Image
#
FROM test AS dev

# Install convenience tools.  Things we like having around, but aren't
# required.
RUN apt-get install -y vim nano bear

# Setup the entry point
COPY ubuntu20_dev_entrypoint.sh /usr/libexec/entrypoint
ENTRYPOINT ["/usr/libexec/entrypoint"]

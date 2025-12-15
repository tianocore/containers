# Copyright (c) 2023-2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# Copyright (c) 2025 Yuki Kurosawa. All rights reserved.
# SPDX-License-Identifier: BSD-2-Clause-Patent

# Build ubuntu24-based container images for use when building EDK2:
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

ENV GCC_MAJOR_VERSION=13

# Install and update the package list
RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    userdel -r ubuntu && \
    dpkg --add-architecture i386 && \
    apt-get update && \
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
        ca-certificates \
        python3.12 python3-pip python3-venv python3-dev virtualenv \
        g++-${GCC_MAJOR_VERSION} gcc-${GCC_MAJOR_VERSION} \
        g++-${GCC_MAJOR_VERSION}-x86-64-linux-gnux32 gcc-${GCC_MAJOR_VERSION}-x86-64-linux-gnux32 \
        llvm-20 clang-20 lld-20 libclang-rt-20-dev && \
    apt-get install --yes --no-install-recommends \
        gcc-multilib g++-multilib libx11-dev libx11-6 libxext6 libxext-dev \
        libc6-i386 libc6-dev-i386 libxext6:i386 libxext-dev:i386 linux-libc-dev:i386 && \
    apt-get install --yes --no-install-recommends \
        g++-${GCC_MAJOR_VERSION}-aarch64-linux-gnu gcc-${GCC_MAJOR_VERSION}-aarch64-linux-gnu \
        g++-${GCC_MAJOR_VERSION}-riscv64-linux-gnu gcc-${GCC_MAJOR_VERSION}-riscv64-linux-gnu && \
    rm -rf /var/lib/apt/lists/*

RUN \
    update-alternatives \
      --install /usr/bin/python python /usr/bin/python3.12 1 && \
    update-alternatives \
      --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
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
      --slave /usr/bin/aarch64-linux-gnu-gcc-ranlib aarch64-linux-gnu-gcc-ranlib /usr/bin/aarch64-linux-gnu-gcc-ranlib-${GCC_MAJOR_VERSION} && \
    update-alternatives \
      --install /usr/bin/riscv64-linux-gnu-gcc riscv64-linux-gnu-gcc /usr/bin/riscv64-linux-gnu-gcc-${GCC_MAJOR_VERSION} 100 \
      --slave /usr/bin/riscv64-linux-gnu-g++ riscv64-linux-gnu-g++ /usr/bin/riscv64-linux-gnu-g++-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/riscv64-linux-gnu-gcc-ar riscv64-linux-gnu-gcc-ar /usr/bin/riscv64-linux-gnu-gcc-ar-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/riscv64-linux-gnu-gcc-nm riscv64-linux-gnu-gcc-nm /usr/bin/riscv64-linux-gnu-gcc-nm-${GCC_MAJOR_VERSION} \
      --slave /usr/bin/riscv64-linux-gnu-gcc-ranlib riscv64-linux-gnu-gcc-ranlib /usr/bin/riscv64-linux-gnu-gcc-ranlib-${GCC_MAJOR_VERSION}

# Add clang/llvm to PATH
ENV PATH=/usr/lib/llvm-20/bin:$PATH

# Set toolchains prefix
ENV GCC_AARCH64_PREFIX=/usr/bin/aarch64-linux-gnu-
ENV GCC_RISCV64_PREFIX=/usr/bin/riscv64-linux-gnu-
ENV GCCNOLTO_AARCH64_PREFIX=/usr/bin/aarch64-linux-gnu-
ENV GCCNOLTO_RISCV64_PREFIX=/usr/bin/riscv64-linux-gnu-

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Test Image
# This image is intended for jobs that run tests (and possibly also build)
# firmware images. It is based on the build image and adds Qemu for the
# architectures under test.

#Building qemu from source:
FROM build AS test
ARG QEMU_URL="https://download.qemu.org/qemu-9.1.1.tar.xz"
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install --yes --no-install-recommends \
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
    ./configure --target-list=x86_64-softmmu,aarch64-softmmu,riscv64-linux-user,riscv64-softmmu && \
    make install -j $(nproc) && \
    cd .. && \
    rm -rf qemu-build && \
    apt remove --yes --purge \
        ninja-build

#####################################################################
# Dev Image
#
FROM test AS dev

# Install convenience tools.  Things we like having around, but aren't
# required.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install --yes --no-install-recommends \
        bear \
        clang \
        less \
        lld \
        llvm \
        nano \
        vim \
        cmake

# Setup the entry point
COPY ubuntu24_dev_entrypoint.sh /usr/libexec/entrypoint
ENTRYPOINT ["/usr/libexec/entrypoint"]

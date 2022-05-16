FROM registry.fedoraproject.org/fedora-minimal:36

RUN microdnf \
      --assumeyes \
      --nodocs \
      --setopt=install_weak_deps=0 \
      install \
        acpica-tools \
        g++ \
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
        python3-setuptools \
        qemu-system-aarch64-core \
        qemu-system-arm-core \
        qemu-system-x86-core

RUN pip install pip --upgrade

ENV GCC5_AARCH64_PREFIX /usr/bin/aarch64-linux-gnu-
ENV GCC5_ARM_PREFIX     /usr/bin/arm-linux-gnu-
ENV GCC5_RISCV64_PREFIX /usr/bin/riscv64-linux-gnu-

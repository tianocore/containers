# Tianocore Containers

This is a Tianocore maintained project for container images used to build and
test Edk2 based UEFI firmware code projects. This repository contains the
dockerfiles and the github workflow files to generate these container images.
Container images are automatically build and uploaded to the associated github
container registry. Links to the container registry for the various images can
be found in [current status](#Current-Status).

## Current Status

| Image Name | OS SKU | Type | Build Status |
| :--------- | :----- | :--- | :----------- |
| [fedora-35-build](https://github.com/tianocore/containers/pkgs/container/containers%2Ffedora-35-build) | Fedora 35 | Build | [![Fedora 35 Images](https://github.com/tianocore/containers/actions/workflows/Fedora-35.yaml/badge.svg)](https://github.com/tianocore/containers/actions/workflows/Fedora-35.yaml) |
| [fedora-35-test](https://github.com/tianocore/containers/pkgs/container/containers%2Ffedora-35-test) | Fedora 35 | Test | [![Fedora 35 Images](https://github.com/tianocore/containers/actions/workflows/Fedora-35.yaml/badge.svg)](https://github.com/tianocore/containers/actions/workflows/Fedora-35.yaml) |
| [windows-2022-build](https://github.com/tianocore/containers/pkgs/container/containers%2Fwindows-2022-build) | Windows ServerCore 2022 | Build | [![Windows 2022 Images](https://github.com/tianocore/containers/actions/workflows/Windows-2022.yaml/badge.svg)](https://github.com/tianocore/containers/actions/workflows/Windows-2022.yaml) |

## Container Types

Containers will be broken up into the following types based on their intended
use. Additional types may be added in the future to accommodate new use cases.

### Build

Build images will only have a minimal set of tools intended to be used for
building the firmware projects. They will not contain virtualization or other
tools used for testing or development.

### Test

Usually built on top of a corresponding build image, test images will additionally
contain tools and packages used for testing the firmware. For example, test images
will contain QEMU for testing a virtualized platform.

### Dev

Intended for local use to develop for EDKII based UEFI products.

## License

All content in this repository is licensed under [BSD-2-Clause Plus Patent
License](LICENSE).

## Code of Conduct

No harassment or discrimination of any kind will be tolerated. Please ensure that
all work and communication in this project is done respectfully and fairly. For
more details, please read the [Code of Conduct](CODE_OF_CONDUCT.md).

## Contributing

This project welcomes all types of contributions. Please see the [contributing document](CONTRIBUTING.md)
to get started.

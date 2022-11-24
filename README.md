# Tianocore Containers

This is a Tianocore maintained project for container images used to build and
test Edk2 based UEFI firmware code projects. This repository contains the
dockerfiles and the github workflow files to generate these container images.
Container images are automatically build and uploaded to the associated github
container registry. Links to the container registry for the various images can
be found in [current status](#Current-Status).

## Current Status

| Image Name                                                                                                   | OS SKU                  | Type  | Build Status                                                                                                                                                                                 | Documentation                 |
| :---------                                                                                                   | :-----                  | :---  | :-----------                                                                                                                                                                                 | :----                         |
| [fedora-35-build](https://github.com/tianocore/containers/pkgs/container/containers%2Ffedora-35-build)       | Fedora 35               | Build | [![Fedora 35 Images](https://github.com/tianocore/containers/actions/workflows/Fedora-35.yaml/badge.svg)](https://github.com/tianocore/containers/actions/workflows/Fedora-35.yaml)          | [Doc](Fedora-35/Readme.md)    |
| [fedora-35-test](https://github.com/tianocore/containers/pkgs/container/containers%2Ffedora-35-test)         | Fedora 35               | Test  | [![Fedora 35 Images](https://github.com/tianocore/containers/actions/workflows/Fedora-35.yaml/badge.svg)](https://github.com/tianocore/containers/actions/workflows/Fedora-35.yaml)          | [Doc](Fedora-35/Readme.md)    |
| [fedora-35-dev](https://github.com/tianocore/containers/pkgs/container/containers%2Ffedora-35-dev)           | Fedora 35               | Dev   | [![Fedora 35 Images](https://github.com/tianocore/containers/actions/workflows/Fedora-35.yaml/badge.svg)](https://github.com/tianocore/containers/actions/workflows/Fedora-35.yaml)          | [Doc](Fedora-35/Readme.md)    |
| [windows-2022-build](https://github.com/tianocore/containers/pkgs/container/containers%2Fwindows-2022-build) | Windows ServerCore 2022 | Build | [![Windows 2022 Images](https://github.com/tianocore/containers/actions/workflows/Windows-2022.yaml/badge.svg)](https://github.com/tianocore/containers/actions/workflows/Windows-2022.yaml) | [Doc](Windows-2022/Readme.md) |
| [ubuntu-20-build](https://github.com/tianocore/containers/pkgs/container/containers%2Fubuntu-20-build)       | Ubuntu 20.04            | Build | [![Ubuntu 20 Images](https://github.com/tianocore/containers/actions/workflows/Ubuntu-20.yaml/badge.svg)](https://github.com/tianocore/containers/actions/workflows/Ubuntu-20.yaml)          | [Doc](Ubuntu-20/Readme.md)    |
| [ubuntu-20-test](https://github.com/tianocore/containers/pkgs/container/containers%2Fubuntu-20-test)       | Ubuntu 20.04            | Test | [![Ubuntu 20 Images](https://github.com/tianocore/containers/actions/workflows/Ubuntu-20.yaml/badge.svg)](https://github.com/tianocore/containers/actions/workflows/Ubuntu-20.yaml)          | [Doc](Ubuntu-20/Readme.md)    |
| [ubuntu-20-dev](https://github.com/tianocore/containers/pkgs/container/containers%2Fubuntu-20-dev)           | Ubuntu 20.04            | Dev   | [![Ubuntu 20 Images](https://github.com/tianocore/containers/actions/workflows/Ubuntu-20.yaml/badge.svg)](https://github.com/tianocore/containers/actions/workflows/Ubuntu-20.yaml)          | [Doc](Ubuntu-20/Readme.md)    |

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

## Using containers locally

Containers can provide a convenient and consistent development environment when building
EDK2 based firmware projects. This section details some tools and tips that make
using containers for local development easier. The DEV editions of the containers
are intended for this purpose. This section is not comprehensive however and it
is encouraged users experiment and consider contributing back any new useful
configurations or tools to this documentation.

__NOTE__: If your code base is cloned in Windows, it is not advised that you directly
open this repository in a Linux dev container as the file system share between Windows
and WSL 2 causes a very significant performance reduction. Instead, clone the
repo in the WSL file system and map into the container or directly clone into the
container.

### Visual Studio Code

The Visual Studio Code [Dev Container extension](https://code.visualstudio.com/docs/devcontainers/containers)
provides an easy and consistent way to use containers for local development. At
the time of writing, this extension only supports Linux based containers. This
extension provides a number of useful additions to the specified docker image on
creation.

- Configures git credential manager to pipe in git credentials.
- Makes extensions available on code inside the container.
- Abstracts management of the container for seamless use in the editor.

For a shared docker image configuration, this can be configured by creating a
.devcontainer file in the repository. Some useful configurations are details below.

| Configuration          | Purpose |
| :------------          | :------ |
| "privileged": true     | This may be needed for access to KVM for QEMU acceleration.  |
| "forwardPorts": [####] | Can be used to forward debug or serial ports to the host OS. |

It may also be desireable to run initialization commands using the "postCreateCommand"
option. Specifically running `git config --global --add safe.directory ${containerWorkspaceFolder}`
may be required if mapping the repository into the container is expected.

And example of a devcontainer used for a QEMU platform repo is included below.

```json
{
  "image": "ghcr.io/tianocore/containers/fedora-35-dev:latest",
  "postCreateCommand": "git config --global --add safe.directory ${containerWorkspaceFolder} && pip install --upgrade -r pip-requirements.txt",
  "forwardPorts": [5000],
  "privileged": true
}
```

## Notes

### Ubuntu 20

The 'dev' image of this set is suitable for development and uses a non-standard entry-point
script which changes the user inside the container to match the outside user
and expects the users home directory to be shared.
It can be run like this:

```
docker run -it \
       -v "${HOME}":"${HOME}" -e EDK2_DOCKER_USER_HOME="${HOME}" \
       ghcr.io/tianocore/containers/ubuntu-20-dev:latest /bin/bash
```

To enter the container as 'root', prepend the command to run with `su`, for example

```
docker run -it \
       -v "${HOME}":"${HOME}" -e EDK2_DOCKER_USER_HOME="${HOME}" \
       ghcr.io/tianocore/containers/ubuntu-20-dev:latest su /bin/bash
```

The images provide the ["edkrepo" tool](https://github.com/tianocore/edk2-edkrepo).

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

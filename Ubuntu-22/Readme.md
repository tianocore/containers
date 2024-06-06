# Ubuntu 22 Images

The 'dev' image of this set is suitable for development and uses a non-standard entry-point
script which changes the user inside the container to match the outside user
and expects the users home directory to be shared.
It can be run like this:
```
docker run -it \
       -v "${HOME}":"${HOME}" -e EDK2_DOCKER_USER_HOME="${HOME}" \
       -e EDK2_DOCKER_USER="$(whoami)" -e EDK2_DOCKER_UID="$(id -u)" \
       -e EDK2_DOCKER_GID="$(id -g)" \
       ghcr.io/tianocore/containers/ubuntu-22-dev:latest /bin/bash
```

To enter the container as 'root', prepend the command to run with `su`, for example
```
docker run -it \
       -v "${HOME}":"${HOME}" -e EDK2_DOCKER_USER_HOME="${HOME}" \
       -e EDK2_DOCKER_USER="$(whoami)" -e EDK2_DOCKER_UID="$(id -u)" \
       -e EDK2_DOCKER_GID="$(id -g)" \
       ghcr.io/tianocore/containers/ubuntu-22-dev:latest su /bin/bash
```

The images provide the ["edkrepo" tool](https://github.com/tianocore/edk2-edkrepo).


#!/bin/bash
#
# Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: BSD-2-Clause-Patent

#####################################################################
# Run as the same uid/gid as the developer.

set -e

#####################################################################
# Check for required env
if [ -z "${EDK2_DOCKER_USER_HOME}" ] || [ ! -d "${EDK2_DOCKER_USER_HOME}" ]; then
  echo 'Missing EDK2_DOCKER_USER_HOME'
  echo 'Please add the following to the docker command, before the image name, and run again'
  # shellcheck disable=SC2016
  echo '  -v "${HOME}":"${HOME}" -e EDK2_DOCKER_USER_HOME="${HOME}"'
  exit 1
fi


#####################################################################
# Create a user to run the command
#
# Docker would run as root, but that creates a permissions mess in a mixed
# development environment where some commands are run inside the container and
# some outside.  Instead, we'll create a user with uid/gid to match the one
# running the container.  Then, the permissions will be consistent with
# non-docker activities.
#
# - If the caller provides a username, we'll use it.  Otherwise, just use an
# arbitrary username.
EDK2_DOCKER_USER=${EDK2_DOCKER_USER:-edk2}
#
# - Get the uid and gid from the user's home directory.
user_uid=$(stat -c "%u" "${EDK2_DOCKER_USER_HOME}")
user_gid=$(stat -c "%g" "${EDK2_DOCKER_USER_HOME}")
#
# - Add the group.  We'll take a shortcut here and always name it the same as
# the username.  The name is cosmetic, though.  The important thing is that the
# gid matches.
groupadd "${EDK2_DOCKER_USER}" -f -o -g "${user_gid}"
#
# - Add the user.
useradd "${EDK2_DOCKER_USER}" -o -l -u "${user_uid}" -g "${user_gid}" \
  -G sudo -d "${EDK2_DOCKER_USER_HOME}" -M -s /bin/bash

echo "${EDK2_DOCKER_USER}":tianocore | chpasswd

#####################################################################
# Cleanup variables
unset user_uid
unset user_gid


#####################################################################
# Drop permissions and run the command
if [ "$1" = "su" ]; then
  # Special case.  Let the user come in as root, if they really want to.
  shift
  exec "$@"
else
  exec runuser -u "${EDK2_DOCKER_USER}" -- "$@"
fi
#!/usr/bin/env bash
#
# Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: BSD-2-Clause-Patent


#####################################################################
# (Re-)Initialize edkrepo for the current user.
#
# We'll install or refresh the necessary files in the user's .edkrepo
# directory.


# Require env
if [ -z "${EDK2_DOCKER_USER_HOME}" ]; then
  echo 'Missing EDK2_DOCKER_USER_HOME'
  exit 1
fi

# Copy the .edkrepo directory, but do not overwrite files.
cp -Rvn /etc/edkrepo_skel/.edkrepo "${EDK2_DOCKER_USER_HOME}"
echo "Initialized edkrepo"
#!/bin/bash
#
# Copyright (c) 2023-2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: BSD-2-Clause-Patent
#

# Utility to cleanup after an apt install or upgrade.

set -e
set -x

apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*

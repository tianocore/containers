#!/bin/sh
#
# SPDX-License-Identifier: BSD-2-Clause-Patent
#
# Simple smoke-test build of EDK2

set -e
set -x

if [ -d edk2 ]; then
  echo "Reusing existing EDK2 source tree."
  cd edk2
  echo "  Cleaning up..."
  git fetch --all
  git reset --hard origin/master
  git clean -xdf
else
  echo "Pulling fresh EDK2 source tree."
  git clone --depth=1 "https://github.com/tianocore/edk2.git"
  cd edk2
fi

# fixups / workarounds:
#   removing these files will use gcc from the image and not download it and
#   run into the python tar bug.
rm -f BaseTools/Bin/gcc_aarch64_linux_ext_dep.yaml

python -m pip install --upgrade pip
python -m pip install --upgrade -r pip-requirements.txt

stuart_setup -c .pytool/CISettings.py
stuart_update -c .pytool/CISettings.py

python BaseTools/Edk2ToolsBuild.py -t GCC5

build_step() {
  build=$1
  arch=$2
  opts="TOOL_CHAIN_TAG=GCC5"
  echo "-----------------------------------------------------------------------"
  echo "Building ${build} for ${arch}"
  echo "-----------------------------------------------------------------------"
  stuart_setup $opts -c "${build}" -a "${arch}"
  stuart_update $opts -c "${build}" -a "${arch}"
  stuart_build $opts -c "${build}" -a "${arch}"
}

build_step "OvmfPkg/PlatformCI/PlatformBuild.py"  "X64"
build_step "ArmVirtPkg/PlatformCI/QemuBuild.py"   "AARCH64"

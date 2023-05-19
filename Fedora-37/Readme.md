# Fedora 37 Images

This set of images is based on the Fedora 37 minimal image.
It has three flavors, `build`, `test`, and `dev`.
The first two are primarily intended for automated builds
and CI usage.

The `build` image contains the compilers and build tools
needed for building EDK2 under Linux (x86_64).

The `test` image extends the `build` image and adds Qemu for
testing purposes.

The `dev` image in turn extends the `test` image and adds developer
convenience tools, for example the git credential manager.

These images include:
- gcc 12.3 (x86, arm, aarch64, riscv)
- gcc 13 (LoongArch, from 2022-09-06)
- nasm 2.15.05
- Python 3.11
- Qemu 8.0.0 (x86, arm ,aarch64, loongarch)

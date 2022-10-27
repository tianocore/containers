# Fedora 35 Images

This set of images is based on the Fedora 35 minimal image.
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
- gcc 11.2.1 (x86, arm, aarch64, riscv)
- nasm 2.15.05
- Python 3.10
- Qemu 6.10 (x86, arm ,aarch64)

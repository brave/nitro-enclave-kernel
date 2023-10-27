# nitro-enclave-kernel
Tooling to reproducibly build a Linux kernel for Nitro Enclaves

When running Nitro Enclaves, the enclave executes a Linux kernel inside
its virtual machine environment. This kernel is a standard Linux kernel
with a small difference: It carries a special kernel module driver for
the Nitro Secure Module (NSM). While it's possible to build this driver
as an out of tree module, it's easier to compile the target kernel and
the nsm.ko module in a single go.

This repository provides the tooling to reproducibly create a Nitro
Enclave kernel based on arbitrary upstream stable kernel versions.

## How to build

You can generate a bzImage and nsm.ko file using [Nix](https://nixos.org/download.html)
by running the command:

```
nix-build
```

This will produce the `result/bzImage` and `result/nsm.ko` binaries.

## How to use

Once you have a `bzImage` and `nsm.ko` file, copy them to
`/usr/share/nitro_enclaves/ and overwrite the ones that come with the
nitro-cli tool.

After that, any new `build-enclave` command will pick up the new kernel
binary and use it as Linux kernel for newly generated EIF files

## How to validate

The PCR1 value of a Nitro Enclaves EIF file contains the Linux kernel,
nsm.ko file and init binary. To check whether the EIF file's PCR1 matches
this kernel build, generate your own sample EIF file and compare its PCR1
value with the target's:

```sh
$ nitro-cli build-enclave --docker-uri sample:latest --output-file sample.eif
Enclave Image successfully created.
{
  "Measurements": {
    "HashAlgorithm": "Sha384 { ... }",
    "PCR0": "...",
    "PCR1": "0123456789abcdef",
    "PCR2": "..."
  }
}
```

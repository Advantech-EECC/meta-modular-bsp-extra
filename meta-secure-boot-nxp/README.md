Advantech Secure Boot Yocto layer for NXP i.MX systems

# Overview

This layer provides Secure Boot support for boards using NXP iMX SoCs (i.MX 8 and i.MX 9 families).

Tested on Advantech hardware. NXP EVKs and other vendor boards may work too.

The approach we follow is extending bootloader and Linux recipes, adding
the signature for the bootloader and the Linux image.

Layout:

```
.
├── classes
│   ├── imx_boot_tools.bbclass
│   ├── imx_signer.bbclass
│   ├── imx_signer_common.bbclass
│   └── secure_boot.bbclass
├── conf
│   └── layer.conf
├── README.md
├── recipes-bsp
│   ├── imx-mkimage
│   │   ├── files
│   │   │   └── 0001-imx-mkimage-ahab-unhardwiring.patch
│   │   └── imx-boot_%.bbappend
│   └── u-boot
│       ├── u-boot-imx
│       │   └── common
│       │       ├── ahab_boot.cfg
│       │       └── hab4_boot.cfg
│       └── u-boot-imx_%.bbappend
├── recipes-core
│   └── images
│       ├── common.inc
│       ├── core-image-base.bbappend -> common.inc
│       ├── core-image-minimal.bbappend -> common.inc
│       ├── core-image-sato.bbappend -> common.inc
│       ├── fsl-image-machine-test.bbappend -> common.inc
│       ├── imx-image-core.bbappend -> common.inc
│       ├── imx-image-full.bbappend -> common.inc
│       └── imx-image-multimedia.bbappend -> common.inc
├── recipes-kernel
│   └── linux
│       └── linux-imx_%.bbappend
└── recipes-security
    ├── nxp-cst-signer-legacy
    │   └── nxp-cst-signer-legacy.bb
    └── nxp-imx-signer
        └── nxp-imx-signer.bb
```

# Drop-in replacement for NXP's meta-secure-boot

We designed intentionaly this layer to be simple to use it as a drop-in
replacement for NXP's ([1]) just renaming the layer. In order to facilitate
the migration and/or interoperatibility we have:

- Target `meta-secure-boot-nxp` instead of `meta-secure-boot`
- Use same input variable names (`SIG_TOOL_PATH` and `SIG_DATA_PATH`)

# References

[1] https://github.com/nxp-imx-support/meta-nxp-security-reference-design


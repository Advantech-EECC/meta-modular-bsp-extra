Advantech Yocto layer for rootfs encryption for NXP i.MX systems with Secure Boot

# Overview

This layer allows `meta-rootfs-enc-core` base layer enabling rootfs encryption on i.MX systems.

Layout:

```
.
├── classes
│   └── imx_rootfs_enc.bbclass
├── conf
│   └── layer.conf
├── files
│   └── wic
│       └── imx-imx-boot-bootpart--rootfs-enc.wks.in
├── README.md
├── recipes-bsp
│   ├── imx-mkimage
│   │   └── imx-boot_%.bbappend
│   └── u-boot
│       └── u-boot-imx_%.bbappend
├── recipes-core
│   ├── images
│   │   ├── common_imx.inc
│   │   ├── core-image-base.bbappend -> common_imx.inc
│   │   ├── core-image-minimal.bbappend -> common_imx.inc
│   │   ├── core-image-sato.bbappend -> common_imx.inc
│   │   ├── fsl-image-machine-test.bbappend -> common_imx.inc
│   │   ├── imx-image-core.bbappend -> common_imx.inc
│   │   ├── imx-image-full.bbappend -> common_imx.inc
│   │   └── imx-image-multimedia.bbappend -> common_imx.inc
│   └── initrdscripts
│       └── initramfs-module-dmcrypt-rootfs.bbappend
└── recipes-kernel
    └── linux
        ├── linux-imx
        │   └── common
        │       ├── caam.cfg
        │       ├── caam-pre-walnascar.cfg
        │       ├── dm-crypt.cfg
        │       ├── ele.cfg
        │       ├── enc-configs.inc
        │       ├── tk-caam.cfg
        │       ├── tk-common.cfg
        │       └── tk-ele.cfg
        └── linux-imx_6.%.bbappend
```

# Requirements

Layers: `meta-secure-boot-nxp` and `meta-rootfs-enc-core`

# Maintenance design targets

In addition to the targets from [../meta-rootfs-enc-core/README.md](../meta-rootfs-enc-core/README.md)

- For HABv4/AHAB-CAAM system we use the CAAM backend, for AHAB-ELE the TK-TEE backend. When Linux 6.19 becomes available we'll switch to TK-PK for NXP and for other vendors.

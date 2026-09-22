Advantech Yocto base layer for rootfs encryption for ARM systems with Secure Boot

# Overview

This layer, along with a HW-specific additional layer, e.g. `meta-rootfs-enc-nxp`, allows generating Yocto images for systems requiring rootfs encryption. We use a Linux image with initramfs for the initial setup and rootfs encrypted mounting.

Steps:

- Image generation: The Yocto build generates a WIC image with a initramfs, a ext4 root filesystem, and a computed SHA-256 digest for it.
- First boot (manufacturing/validation): In the first boot allows generating a per-device unique trusted key used for encrypting the rootfs, and then re-reads it, re-hashing the encrypted volume through the disk mapper, checking that the SHA-256 digest matches with the original digest at build time.
- Second boot: the system will mount the encrypted rootfs with the trusted key.

Layout:

```
.
├── classes
│   ├── factory_key_pair.bbclass
│   ├── rootfs_enc.bbclass
│   └── rootfs-enc-image-core.bbclass
├── conf
│   └── layer.conf
├── README.md
└── recipes-core
    ├── images
    │   └── rootfs-enc-image-initramfs.bb
    └── initrdscripts
        ├── initramfs-module-dmcrypt-rootfs
        │   └── dmcrypt_rootfs.in
        └── initramfs-module-dmcrypt-rootfs.bb
```

# Maintenance design targets

- Minimal changes to the image recipes (rootfs factory SHA-256 digest)
- Minimal changes to the Linux kernel and Secure Boot recipes
- Per-board encryption keys, with no cleartext keys/passphrases
- Using plain dm-crypt instead of LUKS for avoiding complexity in the image generation (no LUKS2 header and no first-time null encoding, avoiding mounting loop devices)
- Suitable for automated manufacturing

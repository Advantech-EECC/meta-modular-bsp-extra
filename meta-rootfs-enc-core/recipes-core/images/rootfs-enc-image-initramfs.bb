#
# meta-rootfs-enc-core/recipes-core/images/rootfs-enc-image-initramfs.bb
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit core-image factory_key_pair rootfs_enc

FACTORY_KEY_TASKS = "do_rootfs"

SUMMARY = "Initramfs for encrypted rootfs"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

do_rootfs[depends] += "initramfs-module-dmcrypt-rootfs:do_packagedata"

VIRTUAL-RUNTIME_dev_manager ?= "busybox-mdev"

INITRAMFS_IMAGE = ""
INITRAMFS_IMAGE_BUNDLE = "0"
INITRAMFS_FSTYPES = "cpio.xz"

PACKAGE_INSTALL = "\
    busybox \
    cryptsetup \
    keyutils \
    lvm2 \
    initramfs-framework-base \
    initramfs-module-dmcrypt-rootfs \
    openssl-bin \
    coreutils \
    findutils \
    util-linux-blkid \
    util-linux-fdisk \
    util-linux-blockdev \
"
PACKAGE_INSTALL:append:ee_caam = " keyctl-caam"
PACKAGE_INSTALL:append:ee_ele = " optee-client"
PACKAGE_INSTALL:remove = "\
    packagegroup-core-boot \
    kernel-image \
    kernel-devicetree \
    kernel-modules \
    e2fsprogs-mke2fs \
    udev \
    update-alternatives-opkg \
    systemd \
"

EXTRA_IMAGE_FEATURES = ""
IMAGE_FEATURES = ""
IMAGE_NAME_SUFFIX ?= ""
IMAGE_LINGUAS = ""
IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"
NO_RECOMMENDATIONS = "1"

# Same as initramfs-live-install
COMPATIBLE_HOST = "(i.86|x86_64|aarch64|arm).*-linux"

install_factory_signing_public_key() {
    install -d "${IMAGE_ROOTFS}${INITRAMFS_FACTORY_DIR}"
    install -m 0644 \
        "${FACTORY_KEYS_DIR}/${FACTORY_VALIDATION_PUB_FILE}" \
        "${IMAGE_ROOTFS}${INITRAMFS_FACTORY_DIR}/"
}

ROOTFS_POSTPROCESS_COMMAND:append = " install_factory_signing_public_key; "

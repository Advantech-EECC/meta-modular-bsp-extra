#
# meta-rootfs-enc-core/recipes-core/initrdscripts/initramfs-module-dmcrypt-rootfs.bb
#
# Initramfs module for handling the root filesystem encryption.
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit factory_key_pair rootfs_enc

SUMMARY = "Initramfs with rootfs encryption using dm-crypt + trusted keys"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

# Scarthgap compatibility
S = "${@d.getVar('UNPACKDIR') or d.getVar('WORKDIR')}"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI = " file://dmcrypt_rootfs.in"
FILES:${PN} = " /init.d/${DMR_SCRIPT_NAME}"
RDEPENDS:${PN} = " keyutils lvm2 util-linux e2fsprogs-mke2fs coreutils "

# The script needs to be run before 01-udev, i.e., as 00. Rationale: we
# need to run the script before 01-udev, in order to avoid the rootfs getting
# mounted in r/w by a systemd daemon. We've observed that the filesystems have
# mount logic also in 10-e2fs, which is something, a priori, contradictory.

DMR_INIT_NUM ??= "00"
DMR_SCRIPT_NAME = "${DMR_INIT_NUM}-dmcrypt_rootfs"

# Trusted Keys as Protected Keys ('paes' cipher) are available for since
# Linux 6.19 (2025.12). E.g. Yocto 6.0 (wrynose) for NXP is still in 6.18.
# https://cdn.kernel.org/doc/html/latest/security/keys/trusted-encrypted.html

# CAAM will support TK with Linux >= 6.19, until then, we use the
# legacy method using caam-keygen for HABv4+CAAM and AHAB+CAAM systems

ROOTFS_ENC_CONTEXT ?= "tk"

# 'paes' cipher requires Linux >= 6.19
TK_BACKEND ?= "paes"

OS_IMAGE ?= "${KERNEL_IMAGETYPE}"

do_install() {
    sed -e 's#__INITRAMFS_FACTORY_DIR__#${INITRAMFS_FACTORY_DIR}#g' \
        -e 's#__FACTORY_VALIDATION_PUB_FILE__#${FACTORY_VALIDATION_PUB_FILE}#g' \
        -e 's#__FACTORY_ROOTFS_SHA256_FILE__#${FACTORY_ROOTFS_SHA256_FILE}#g' \
        -e 's#__FACTORY_SIG_FILE_SUFFIX__#${FACTORY_SIG_FILE_SUFFIX}#g' \
        -e 's#__DMR_INIT_NUM__#${DMR_INIT_NUM}#g' \
        -e 's#__DM_TABLE_SECTOR_SIZE__#${DM_TABLE_SECTOR_SIZE}#g' \
        -e 's#__IMAGE_ROOTFS_FSTYPE__#${IMAGE_ROOTFS_FSTYPE}#g' \
        -e 's#__ROOTFS_ENC_CONTEXT__#${ROOTFS_ENC_CONTEXT}#g' \
        -e 's#__TK_BACKEND__#${TK_BACKEND}#g' \
        -e 's#__OS_IMAGE__#${OS_IMAGE}#g' \
        -e 's#__PREPART_SIZE_KIB__#${PREPART_SIZE_KIB}#g' \
        ${S}/dmcrypt_rootfs.in > ${B}/${DMR_SCRIPT_NAME}

    install -d ${D}/init.d
    install -m 0755 ${B}/${DMR_SCRIPT_NAME} ${D}/init.d/
}

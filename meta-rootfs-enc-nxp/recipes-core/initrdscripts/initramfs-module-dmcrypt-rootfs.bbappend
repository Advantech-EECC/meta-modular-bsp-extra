#
# meta-rootfs-enc-nxp/recipes-core/initrdscripts/initramfs-module-dmcrypt-rootfs.bbappend
#
# Initramfs module for handling the root filesystem encryption (i.MX)
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit imx_rootfs_enc

RDEPENDS:${PN}:append:ee_caam = " keyctl-caam"

ROOTFS_ENC_CONTEXT:ee_caam = "caam"

# 'paes' cipher requires Linux >= 6.19, so until then, for NXP AHAB+ELE
# devices we'll use the TEE TK backend
TK_BACKEND:ee_ele = "ele-tee"

OS_IMAGE:ahab = "${AHAB_OS_CNTR_SIGNED}"

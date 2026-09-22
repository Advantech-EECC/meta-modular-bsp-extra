#
# meta-rootfs-enc-nxp/recipes-bsp/imx-mkimage/imx-boot_%.bbappend
#
# Needed so KERNEL_DTB_ADDR gets reevaluated for relocating the DTB
# load after the Linux image with initramfs.
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit imx_rootfs_enc

OS_KERNEL_IMAGE = "${KERNEL_IMAGE_INITRAMFS_BIN}"

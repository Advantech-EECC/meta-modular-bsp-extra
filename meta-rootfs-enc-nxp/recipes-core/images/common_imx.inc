#
# meta-rootfs-enc-nxp/recipes-core/images/common_imx.inc
#
# Expand base BSP images for supporting rootfs encryption (i.MX)
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit imx_rootfs_enc
inherit rootfs-enc-image-core

do_generate_factory_hashes:append:hab4() {
    for dtb in ${KERNEL_DEVICETREE} ; do
        sign_files "${DEPLOY_DIR_IMAGE}/"$(basename "${dtb}")
    done
}

# AHAB: add just the Application OS image (it already has the DTBs):

IMAGE_BOOT_FILES:append:ahab = " \
    ${AHAB_OS_CNTR_SIGNED} \
"

IMAGE_BOOT_FILES:remove:ahab = " \
    ${KERNEL_IMAGETYPE} \
    ${@kernel_dtb_boot_files(d)} \
"

# HABv4: we add the DTBs and their associated .sig files:

IMAGE_BOOT_FILES:append:hab4 = " \
    ${@kernel_dtb_boot_files(d)} \
"

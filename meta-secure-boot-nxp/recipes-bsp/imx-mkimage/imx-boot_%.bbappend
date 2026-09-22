#
# meta-secure-boot-nxp/recipes-bsp/imx-mkimage/imx-boot_%.bbappend
#
# For newer HABv4 systems (i.MX8M*) and for AHAB systems, we
# address the signature in this imx-boot recipe extension.
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit imx_boot_tools imx_signer secure_boot

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://0001-imx-mkimage-ahab-unhardwiring.patch "

BOOT_VARIANT ?= ""
BOOT_NAME = "imx-boot"
UBOOT_CONFIG_EXTRA = "sd"
BOOT_IMAGE_SD = "${BOOT_NAME}${BOOT_VARIANT}-${MACHINE}-${UBOOT_CONFIG_EXTRA}.bin-${SIGNED_TARGET}"
FLASH_BIN = "flash.bin"
FLASH_OS_BIN = "flash_os.bin"
SIGNED_BOOT_IMAGE_SD = "signed-${BOOT_IMAGE_SD}"
OS_KERNEL_IMAGE ?= "${KERNEL_IMAGETYPE}"
KERNEL_IMAGE_INITRAMFS_BIN = "${KERNEL_IMAGETYPE}-initramfs-${MACHINE}.bin"
MKIMAGE_EXTRA_ARGS:append:ahab = " \
    ${@'KERNEL_DTB=${KERNEL_DTB} KERNEL_DTB_ADDR=${KERNEL_DTB_ADDR}' if d.getVar('KERNEL_DTB_ADDR') else ''} \
"
ASSEMBLE_OS_IMAGE_DEPENDS = ""
ASSEMBLE_OS_IMAGE_DEPENDS:ahab = "virtual/kernel:do_deploy"

do_compile:prepend:ahab() {
    [ "${KERNEL_DTB_ADDR}" != "" ] ||
        bbfatal "Invalid KERNEL_DTB_ADDR: please add specific CONFIG_SYS_LOAD_ADDR in secure_boot.bbclass"
}

# Sign U-Boot
do_compile:append() {
    imx_signer_sign "${S}/${BOOT_IMAGE_SD}" "${S}/${SIGNED_BOOT_IMAGE_SD}"
}

do_assemble_os_image() {
    true
}

# Regenerate the Linux kernel container image using imx-mkimage + signature
do_assemble_os_image:append:ahab() {
    cp -L "${DEPLOY_DIR_IMAGE}/${OS_KERNEL_IMAGE}" \
        "${BOOT_STAGING}/${KERNEL_IMAGETYPE}"

    # Do not include the symlinks
    for dtb in "${DEPLOY_DIR_IMAGE}/"*.dtb ; do
        [ -e "$dtb" ] || continue
        [ -L "$dtb" ] && continue
        cp "$dtb" "${BOOT_STAGING}/"
    done

    # Keep previous flash.bin
    mv -f "${BOOT_STAGING}/${FLASH_BIN}" "${BOOT_STAGING}/${FLASH_BIN}.prev"

    make SOC=${IMX_BOOT_SOC_TARGET} ${REV_OPTION} ${MKIMAGE_EXTRA_ARGS} \
        flash_kernel

    imx_signer_sign "${BOOT_STAGING}/${FLASH_BIN}" "${S}/${AHAB_OS_CNTR_SIGNED}"

    # Rename the OS image, and restore the flash.bin with the U-Boot image
    mv -f "${BOOT_STAGING}/${FLASH_BIN}" "${S}/${FLASH_OS_BIN}"
    mv -f "${BOOT_STAGING}/${FLASH_BIN}.prev" "${BOOT_STAGING}/${FLASH_BIN}"
}

do_deploy:append() {
    install -m 0644 "${S}/${SIGNED_BOOT_IMAGE_SD}" "${DEPLOYDIR}/"

    ln -srf "${DEPLOYDIR}/${SIGNED_BOOT_IMAGE_SD}" "${DEPLOYDIR}/${BOOT_NAME}"

    boot_tools_tag_file "${DEPLOYDIR}/${BOOT_NAME}"
}

do_deploy:append:ahab() {
    install -m 0755 "${S}/${AHAB_OS_CNTR_SIGNED}" "${S}/${FLASH_OS_BIN}" \
                    "${DEPLOYDIR}/"
}

do_assemble_os_image[depends] += "${ASSEMBLE_OS_IMAGE_DEPENDS}"
do_assemble_os_image[dirs] = "${B}"

addtask assemble_os_image after do_compile before do_deploy

COMPATIBLE_MACHINE = "(mx8-generic-bsp|mx9-generic-bsp)"

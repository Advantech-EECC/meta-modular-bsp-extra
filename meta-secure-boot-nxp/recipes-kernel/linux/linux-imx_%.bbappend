#
# meta-secure-boot-nxp/recipes-kernel/linux-imx_%.bbappend
#
# This recipe extension signs the Linux kernel image for the HABv4 case. For
# the case of AHAB, the imx-boot recipe will sign the AHAB image for both the
# bootloader (U-Boot) and the application OS (Linux)
#
# Padding and IVT-related information reference:
#   - https://github.com/nxp-imx-support/meta-nxp-security-reference-design/blob/walnascar-6.12.49-2.2.0/meta-secure-boot-nxp/recipes-secure-boot/linux/linux-imx-signature.bb#L82
#   - https://docs.kernel.org/arch/arm64/booting.html#call-the-kernel-image
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit deploy imx_boot_tools imx_signer secure_boot

HAB4_KERNEL_IMAGE ?= "${DEPLOYDIR}/${KERNEL_IMAGETYPE}"
HAB4_IMAGE_PADDED_IVT = "${KERNEL_IMAGETYPE}_pad_ivt.bin"
HAB4_IMAGE_PADDED_IVT_SIGNED = "signed-${KERNEL_IMAGETYPE}_pad_ivt.bin"
HAB4_SIGNED_KERNEL_IMAGE_BIN = "signed-${KERNEL_IMAGETYPE}"

st32le() {
    acci=$(printf "%u" "$1")
    for st32le_step in 1 2 3 4 ; do
        oi=$(expr $acci % 256) || true
        acci=$(expr $acci / 256) || true
        oi_oct=$(printf '%03o' "$oi") || true
            printf "\\$oi_oct"
    done
}

do_deploy:append:hab4() {
    image="${HAB4_KERNEL_IMAGE}"
    image_size=$(stat -L --printf=%s "$image")

    case "${KERNEL_IMAGETYPE}" in
    Image)
        if [ "${TARGET_ARCH}" = aarch64 ] ; then
            # load int32le from offset 16 (AArch64)
            ram_image_size=$(od -An -j 16 -N 4 -i "$image")
            [ "$ram_image_size" -ge "$image_size" ] ||
                bbfatal "Broken/cut image"
            pad_size=$(expr $ram_image_size - $image_size) || true
        else
            # Not tested
            pad_size=0
        fi
        ;;
    zImage)
        align_size=4096
        image_size_mod=$(expr $image_size % $align_size) || true
        pad_size=$(expr $align_size - $image_size_mod) || true
        ;;
    *)
        bbfatal "Unknown Linux kernel image format"
    esac

    signature=0x432000d1
    load_addr=$(printf "%u" ${CONFIG_SYS_LOAD_ADDR})
    reserved=0
    dcd_addr=0
    boot_data=0
    image_padded_size=$(expr $image_size + $pad_size)
    ivt_addr=$(expr $load_addr + $image_padded_size)
    csf_addr=$(expr $ivt_addr + 32)

    (
        cat "$image"
        head -c "$pad_size" </dev/zero
        for i in \
            "$signature" \
            "$load_addr" \
            "$reserved" \
            "$dcd_addr" \
            "$boot_data" \
            "$ivt_addr" \
            "$csf_addr" \
            "$reserved"
        do
            st32le "$i"
        done
    ) >"${SIGNDIR}/${HAB4_IMAGE_PADDED_IVT}"

    imx_signer_sign "${SIGNDIR}/${HAB4_IMAGE_PADDED_IVT}" \
            "${SIGNDIR}/${HAB4_IMAGE_PADDED_IVT_SIGNED}"

    install -m 0644 "${SIGNDIR}/${HAB4_IMAGE_PADDED_IVT_SIGNED}" \
        "${DEPLOYDIR}/${HAB4_SIGNED_KERNEL_IMAGE_BIN}"
    ln -srf "${DEPLOYDIR}/${HAB4_SIGNED_KERNEL_IMAGE_BIN}" \
        "${DEPLOYDIR}/${KERNEL_IMAGETYPE}"
}

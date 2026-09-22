#
# meta-rootfs-enc-nxp/recipes-bsp/u-boot/u-boot-imx_%.bbappend
#
# For the case of HABv4 (iMX8M*) we relocate the DTB loading address
# so we can fit a Linux image with the initramfs needed for the rootfs enc
#
# Observations:
# - This is intended mainly for the HABv4 case (modifying
#   fdt_addr/fdt_addr_r U-Boot arguments for Linux), as for the
#   AHAB case we add the address in the 'imx-mkimage' build.
# - For AHAB is needed up to Styhead, as the FDT loading mechanism
#   taking the address from the image container was not properly
#   implemented until the Walnascar release.
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit imx_rootfs_enc

XDK_FDT_ADDR ?= "0"
XDK_FDT_ADDR:mx8m-generic-bsp = "0x43000000"
XDK_FDT_ADDR:mx8x-generic-bsp = "0x83000000"
XDK_FDT_ADDR:mx8ulp-nxp-bsp = "0x83000000"
XDK_FDT_ADDR:mx91-nxp-bsp = "0x83000000"
XDK_FDT_ADDR:mx93-nxp-bsp = "0x83000000"
XDK_FDT_ADDR:mx943-nxp-bsp = "0x93000000"
XDK_FDT_ADDR:mx95-nxp-bsp = "0x93000000"

fix_fdt_addr() {
    if [ "${XDK_FDT_ADDR}" != "0" ]
    then
        bbwarn "fdt_addr reloc: ${XDK_FDT_ADDR} -> ${KERNEL_DTB_ADDR}"
        for i in fdt_addr fdt_addr_r ; do
            # In Yocto 6.0 (wrynose) 'freescale' was renamed to 'nxp':
            for t in \
                "${S}/include/configs/imx"*h \
                "${S}/board/freescale/imx"*/imx*env \
                "${S}/board/nxp/imx"*/imx*env
            do
                if [ ! -e "$t" ] ; then continue ; fi
                bbnote "$i=${XDK_FDT_ADDR} -> ${KERNEL_DTB_ADDR} · $t"
                sed -i "s#$i=${XDK_FDT_ADDR}#$i=${KERNEL_DTB_ADDR}#g" "$t"
            done
        done
    fi
}

ahab_fix_fdt_addr() {
    true
}

# In >= Walnascar is not needed (it takes the address from the image)
ahab_fix_fdt_addr:append:pre-walnascar() {
    fix_fdt_addr
}

do_configure:prepend:hab4() {
    fix_fdt_addr
}

do_configure:prepend:ahab() {
    ahab_fix_fdt_addr
}

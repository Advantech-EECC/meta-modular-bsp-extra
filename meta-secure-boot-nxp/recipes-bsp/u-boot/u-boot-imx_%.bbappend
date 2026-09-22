#
# meta-secure-boot-nxp/recipes-bsp/u-boot/u-boot-imx_%.bbappend
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit secure_boot

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:${THISDIR}/${PN}/common:"

SRC_URI:append:hab4 = " file://hab4_boot.cfg "
SRC_URI:append:ahab = " file://ahab_boot.cfg "

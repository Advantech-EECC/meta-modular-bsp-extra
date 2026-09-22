#
# meta-rootfs-enc-nxp/recipes-kernel/linux/linux-imx/common/enc-configs.inc
#
# Encryption-related additional Linux configurations. From the encryption
# engines set in the machine overrides, we add the required configurations.
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

SRC_URI:append:ee_caam = " \
    file://caam.cfg \
    file://dm-crypt.cfg \
    file://tk-common.cfg \
    file://tk-caam.cfg \
"

SRC_URI:append:ee_ele = " \
    file://dm-crypt.cfg \
    file://tk-common.cfg \
    file://tk-ele.cfg \
"

SRC_URI:append:ele = " \
    file://ele.cfg \
"

SRC_URI:append:caam:pre-walnascar = " \
    file://caam-pre-walnascar.cfg \
"

DELTA_KERNEL_DEFCONFIG:append:ee_caam:pre-whinlatter = " \
    caam.cfg \
    dm-crypt.cfg \
    tk-common.cfg \
    tk-caam.cfg \
"

DELTA_KERNEL_DEFCONFIG:append:ee_ele:pre-whinlatter = " \
    dm-crypt.cfg \
    tk-common.cfg \
    tk-ele.cfg \
"

DELTA_KERNEL_DEFCONFIG:append:ele:pre-whinlatter = " \
    ele.cfg \
"

DELTA_KERNEL_DEFCONFIG:append:caam:pre-walnascar = " \
    caam-pre-walnascar.cfg \
"

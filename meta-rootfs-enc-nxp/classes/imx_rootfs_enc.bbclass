#
# meta-rootfs-enc-nxp/classes/imx_rootfs_enc.bbclass
#
# rootfs-enc class for i.MX systems
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit rootfs_enc secure_boot

IMX_BOOTP_SIZE_MIB ??= "256"
SOC_DEFAULT_WKS_FILE ??= "not-supported"
SOC_DEFAULT_WKS_FILE:mx8-generic-bsp = "imx-imx-boot-bootpart--rootfs-enc.wks.in"
SOC_DEFAULT_WKS_FILE:mx9-generic-bsp = "imx-imx-boot-bootpart--rootfs-enc.wks.in"

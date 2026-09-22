#
# meta-secure-boot-nxp/classes/imx_boot_tools.bbclass
#
# Bootloader helper for NXP i.MX SoCs.
#
# Tagging follows the convention from:
#
# - https://github.com/Freescale/meta-freescale/blob/wrynose/classes/uuu_bootloader_tag.bbclass
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

BOOT_TOOLS ?= "imx-boot-tools"

# $1: input file
boot_tools_tag_file() {
    cp -L "$1" "$1.tagged"
    stat -L -cUUUBURNXXOEUZX7+A-XY5601QQWWZ%sEND "$1.tagged" >> "$1.tagged"
}

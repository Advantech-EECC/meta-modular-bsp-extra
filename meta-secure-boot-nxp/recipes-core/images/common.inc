#
# meta-secure-boot-nxp/recipes-core/images/common.inc
#
# Expand base BSP images for supporting Secure Boot.
#
# Observations:
# - HABv4 images need no changes, as the Linux kernel is signed keeping
#   the same file, and keeping external elements (DTBs). For the case
#   of AHAB sytems we need to add the Application OS signed container.
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit secure_boot

IMAGE_BOOT_FILES:append:ahab = " ${AHAB_OS_CNTR_SIGNED}"

#
# meta-secure-boot-nxp/recipes-security/nxp-imx-signer/nxp-imx-signer.bb
#
# Recipe for signing with the new NXP CST signer.
#
# Matching functionality from:
# https://github.com/nxp-imx-support/meta-nxp-security-reference-design/blob/walnascar-6.12.49-2.2.0/meta-secure-boot/recipes-secure-boot/nxp-imx-signer/nxp-imx-signer.bb
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit deploy imx_boot_tools imx_signer_common secure_boot

SUMMARY = "NXP IMX Signer"
DESCRIPTION = "Image signing automation tool using CST/SPSDK"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=1f6f1c0be32491a0c8d2915607a28f36"

SRC_URI = "${CST_SIGNER};branch=${SRCBRANCH}"
CST_SIGNER ?= "git://github.com/nxp-imx-support/nxp-cst-signer.git;protocol=https"
SRCBRANCH = "master"
SRCREV = "b8807075433527044b19f02f29f40fe9aa10220f"

do_deploy() {
    true
}

do_deploy:class-native() {
    install -d ${DEPLOYDIR}/${BOOT_TOOLS}
    install -m 0755 "${S}/src/imx_signer" "${DEPLOYDIR}/${BOOT_TOOLS}/"
}

addtask deploy after do_compile before do_install

BBCLASSEXTEND = "native nativesdk"

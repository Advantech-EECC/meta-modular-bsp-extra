#
# meta-secure-boot-nxp/recipes-security/nxp-cst-signer-legacy/nxp-cst-signer-legacy.bb
#
# Recipe for signing with the old NXP CST signer. Rationale: AHAB support for
# devices currently not fully supported in SPSDK, e.g. iMX8QXP
#
# Matching functionality from:
# - https://github.com/nxp-imx-support/meta-nxp-security-reference-design/tree/styhead-6.12.3-1.0.0/meta-secure-boot/recipes-secure-boot/nxp-cst-signer
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit deploy imx_boot_tools imx_signer_common secure_boot

SUMMARY = "NXP IMX Signer (legacy)"
DESCRIPTION = "Image signing automation tool using CST/SPSDK (legacy)"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=1f6f1c0be32491a0c8d2915607a28f36"

# Last version of imx-signer supporting CST for AHAB signing
SRC_URI = "${CST_SIGNER};branch=${SRCBRANCH}"
CST_SIGNER ?= "git://github.com/nxp-imx-support/nxp-imx-signer.git;protocol=https"
SRCBRANCH = "master"
SRCREV = "7f9e8fae65e6799228f70948c6f88186db3d62ef"

do_deploy() {
    true
}

do_deploy:class-native() {
    install -d ${DEPLOYDIR}/${BOOT_TOOLS}
    install -m 0755 "${S}/src/imx_signer" \
                    "${DEPLOYDIR}/${BOOT_TOOLS}/imx_signer-legacy"
}

addtask deploy after do_compile before do_install

BBCLASSEXTEND = "native nativesdk"

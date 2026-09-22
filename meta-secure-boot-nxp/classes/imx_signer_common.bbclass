#
# meta-secure-boot-nxp/classes/imx_signer_common.bbclass
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

python __anonymous() {
    # Before BitBake 2.14, Git sources are unpacked into the "git" directory
    # WORKDIRK/git for Yocto <= 5.0, and UNPACKDIR/git for Y5.1 and 5.2
    if bb.utils.vercmp_string(d.getVar("BB_VERSION"), "2.14") < 0:
        if d.getVar("UNPACKDIR"):
            d.setVar("S", "${UNPACKDIR}/git")
        else:
            d.setVar("S", "${WORKDIR}/git")
}

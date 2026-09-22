#
# meta-secure-boot-nxp/classes/imx_signer.bbclass
#
# Helper class for the IMX CST signer tool. This follows the conventions
# defined in NXP's security reference design ([1])
#
# [1] https://github.com/nxp-imx-support/meta-nxp-security-reference-design
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit secure_boot

DEPENDS += "nxp-imx-signer-native nxp-cst-signer-legacy-native"

SIGNDIR = "${B}"
CSF_CFG:ahab = "${SIG_DATA_PATH}/csf_ahab.cfg"
CSF_CFG:hab4 = "${SIG_DATA_PATH}/csf_hab4.cfg"
SPSDK_CFG:ahab = "${SIG_DATA_PATH}/spsdk_ahab.yaml"
SPSDK_CFG:hab4 = "(SPSDK is not supported for HABv4)"

imx_signer_install_conf() {
    SIG_CFGFILE="${SIGNDIR}/sign.cfg"
    IMX_SIGNER=none
    IMX_SIGNER_NEW="${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/imx_signer"
    IMX_SIGNER_LEGACY="${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/imx_signer-legacy"

    if [ -e "${CSF_CFG}" ] && [ -e "${SIG_TOOL_PATH}/linux64/bin/cst" ]
    then
        bbnote "Signature config: ${CSF_CFG} -> ${SIG_CFGFILE}"

        IMX_SIGNER=$IMX_SIGNER_LEGACY
        install -m 0755 "${CSF_CFG}" "${SIG_CFGFILE}"
    elif [ -e "${SPSDK_CFG}" ] && [ -e "${SIG_TOOL_PATH}/spsdk" ]
    then
        bbnote "Signature config: ${SPSDK_CFG} -> ${SIG_CFGFILE}"

        IMX_SIGNER=$IMX_SIGNER_NEW
        install -m 0755 "${SPSDK_CFG}" "${SIG_CFGFILE}"
        sed -i "s/^family:.*/family: ${SPSDK_FAMILY}/" "${SIG_CFGFILE}"

        [ -e "${SIG_TOOL_PATH}/spsdk" ] ||
            bbfatal "Missing SPSDK: SIG_TOOL_PATH=${SIG_TOOL_PATH}"
    else
        bbfatal "Missing: ${CSF_CFG} + ${SIG_TOOL_PATH}/linux64/bin/cst, or ${SPSDK_CFG} + ${SIG_TOOL_PATH}/spsdk"
    fi
}

# $1: file to sign
# $2: output file path (optional)
imx_signer_sign() {
    [ -e "${1:-}" ] || bbfatal "Input file (${1:-}) not found"
    [ "${2:-}" != "" ] || bbfatal "Output file (${2:-}) not given"

    imx_signer_install_conf

    src_dir=$(dirname "$1")
    signed=signed-$(basename "$1")
    out_signed=${SIGNDIR}/$signed

    bbnote "imx_signer_sign: $1 -> $out_signed"

    SIG_TOOL_PATH=${SIG_TOOL_PATH} \
    SIG_DATA_PATH=${SIG_DATA_PATH} \
        ${IMX_SIGNER} -d -i "$1" -c "${SIG_CFGFILE}"

    [ -e "$out_signed" ] ||
        bbfatal "Signature failed ($1)"

    [ "$(realpath "$2")" = "$(realpath "$out_signed")" ] ||
        mv -f "$out_signed" "$2" ||
            bbfatal "Can not move: $out_signed -> $2"
}

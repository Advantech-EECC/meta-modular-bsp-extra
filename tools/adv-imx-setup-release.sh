#!/bin/bash
#
# adv-imx-setup-release.sh
#
# This script extends NXP's imx-setup-release.sh for targeting
# manifests for Advantech boards that include support for the
# Secure Boot and root filesystem encryption layers ([1])
#
# [1] https://github.com/Advantech-EECC/imx-manifest
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

# NXP setup input vars, e.g.,
#
# SSTATE_DIR=/mnt/sstate-data
# DL_DIR=/mnt/downloads
# EULA_ACCEPTED=1

# Advantech-specific layer input vars, e.g.,
#
# 1) Secure Boot mode:
#
# For enabling Secure Boot (for NXP systems we keep using the
# same variable names for allowing layer direct replacement):
#
# E.g., when using CST tool (NXP imx-signer arguments)
# SIG_TOOL_PATH=/opt/cst
# SIG_DATA_PATH=/opt/secure/nxp/keys/hab4_rsa2048_sha256
#
# E.g., when using SPSDK tool (NXP imx-signer arguments)
# SIG_TOOL_PATH=/usr/local/bin
# SIG_DATA_PATH=/opt/secure/nxp/keys/ahab_ecc256_sha256_no_ca_flag
#
# 2) Secure Boot mode, with rootfs encryption:
#
# ENABLE_ROOTFS_ENCRYPTION=1     # (adds the meta-rootfs-enc layer)
# FACTORY_KEYS_DIR=/opt/secure/nxp/keys/factory   # Required: 'factory-signing.key.pem' and 'factory-validation.pub.pem' (use tools/gen-factory-signing-keys.sh for generating them)
#
# Additional options, default values:
#
# OPT_RM_WORK=1        # 1: add rm_work to local.conf, 0: keep tmp artifacts
# OPT_SPDX=1           # 1: enable BoM SPDX creation, 0: don't
# OPT_DEBUG=0          # 1: extra debug information, 0: don't
# OPT_NICE=0           # 1: reduce thread count usage in BitBake, 0: don't
# ADD_EXTRA_LAYERS=""  # list of layers to be added (separated by space)
#
# Check ../README.md for examples

# vars

OPT_DEBUG=${OPT_DEBUG:-0}
((OPT_DEBUG == 0)) || DT=[D] IT=[I] WT=[W] ET=[E]
C_BLACK='\e[0;30m' C_WHITE='\e[1;37m' C_GRAY='\e[1;30m' C_GRAY2='\e[0;37m'
C_RED='\e[0;31m' C_RED2='\e[1;31m' C_GREEN='\e[0;32m' C_GREEN2='\e[1;32m'
C_ORANGE='\e[0;33m' C_YELLOW='\e[1;33m' C_BLUE='\e[0;34m' C_BLUE2='\e[1;34m'
C_PURPLE='\e[0;35m' C_PURPLE2='\e[1;35m' C_CYAN='\e[0;36m' C_CYAN2='\e[1;36m'
C_BOLD="\e[1m" C_RESET='\e[0m'

BB_ENV=(
	DL_DIR SSTATE_DIR BB_HASHSERVE_DB_DIR SIG_TOOL_PATH SIG_DATA_PATH
	FACTORY_KEYS_DIR
)

# functions

logp() { echo -e "$@" >&2 ; }
logb() { logp "$1[${FUNCNAME[2]}]$2 ${@:3} $C_RESET" ; }
dbg() { ((${OPT_DEBUG:-0} == 0)) || logb "$C_CYAN2${DT:-}$C_CYAN" "$@" ; }
info() { logb "$C_RESET" "${IT:-}" "$@" ; }
warn() { logb "$C_YELLOW$C_BOLD" "${WT:-}" "$@" ; }
error() { logb "$C_RED2$C_BOLD" "${ET:-}" "$1" ; exit ${2:-1} ; }
run:s() { local c=0 ; info "$@" ; "$@" &>/dev/null || c=$? ; info "> EC=$c" ; }
local_conf() { cat >> "$BUILD_DIR/conf/local.conf" ; }

adv_setup()
{
	local i

	if [ "${SSTATE_DIR:-}" != "" ] ; then
		[ "${BB_HASHSERVE_DB_DIR:-}" != "" ] ||
			BB_HASHSERVE_DB_DIR=$SSTATE_DIR/hashserv
	fi

	if ((${OPT_NICE:-0})) ; then
		local c=$(nproc 2>/dev/null || echo 8)
		PARALLEL_MAKE=$((c / 2 + 1))
		BB_NUMBER_THREADS=$((c / 4 + 1))
		BB_ENV+=(PARALLEL_MAKE BB_NUMBER_THREADS)
	fi

	if ((${OPT_RM_WORK:-1})) ; then
		info "rm_work enabled"
		printf "INHERIT += \"rm_work\"\n"
	fi | local_conf

	if ((${OPT_SPDX:-1} > 0)) ; then
		info "Software BoM SPDX creation enabled"
		printf "INHERIT += \"create-spdx\"\n"
	fi | local_conf

	adv_modular_bsp_setup
	adv_secure_boot_setup
	adv_other_setup

	for i in ${BB_ENV[@]} ; do
		if [ "${!i:-}" = "" ] ; then continue ; fi
		BB_ENV_PASSTHROUGH_ADDITIONS+=" $i"
		info "BB_ENV_PASSTHROUGH_ADDITIONS+= $i (${!i})"
	done

	export BB_ENV_PASSTHROUGH_ADDITIONS $BB_ENV_PASSTHROUGH_ADDITIONS

	if ((${EULA_ACCEPTED:-0})) ; then
		local eula="$BUILD_DIR/../sources/meta-imx/LICENSE.txt"
		warn "Using this you are accepting NXP's EULA: $eula"
	fi
}

adv_modular_bsp_setup()
{
	hook_in_layer meta-modular-bsp-nxp
}

adv_secure_boot_setup()
{
	[ "${SIG_DATA_PATH:-}" != "" ] || return 0
	[ "${SIG_TOOL_PATH:-}" != "" ] || error "Missing: SIG_TOOL_PATH"

	hook_in_layer meta-modular-bsp-extra/meta-secure-boot-nxp

	if ((${ENABLE_ROOTFS_ENCRYPTION:-0} + 0 > 0)) ; then
		hook_in_layer meta-modular-bsp-extra/meta-rootfs-enc-core
		hook_in_layer meta-modular-bsp-extra/meta-rootfs-enc-nxp
	fi
}

adv_other_setup()
{
	local i
	for i in $ADD_EXTRA_LAYERS ; do hook_in_layer $i ; done
}

# main

IMX_SETUP_SH=imx-setup-release.sh

export BSPDIR=.
export EULA_ACCEPTED=${EULA_ACCEPTED:-0}
export EULA=$(($EULA_ACCEPTED || ${EULA:-0}))

source "$IMX_SETUP_SH" "$@" || error "Can not source $IMX_SETUP_SH"

adv_setup

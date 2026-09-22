Advantech Secure Boot and rootfs encryption for ARM systems

# Overview

Currently this repository includes three Yocto layers:

- [meta-secure-boot-nxp](meta-secure-boot-nxp/README.md): Secure Boot support for NXP i.MX devices (currently only NXP i.MX8/9). This is a implementation matching NXP's meta-secure-boot in their reference design ([1]) , but with a different architecture to avoid build/cache issues, and allowing composing on top other layers. We use the same name in order to provide a direct replacement when using NXP i.MX SoCs.
- [meta-rootfs-enc-core](meta-rootfs-enc-core/README.md): root filesystem encryption for `meta-secure-boot-*` layers (core layer).
- [meta-rootfs-enc-nxp](meta-rootfs-enc-nxp/README.md): root filesystem encryption for the `meta-secure-boot-*` layers (HW-specific layer).

Future support for other SoC vendors will follow the pattern:

```
meta-secure-boot-[SOC]
meta-rootfs-enc-core
meta-rootfs-enc-[SOC]
```

# Compatibility

In 'meta-secure-boot-nxp', in order to keep functionality we include recipes for both the new NXP IMX signer and also for the legacy one. Rationale: 1) SPSDK is very slow signing big Linux images, 2) some SoCs, e.g., iMX8QXP, are not being currently covered with SPSDK, e.g., for signing with SGKs. Once the functionality and fixes gets added to SPSDK, we'll switch to the new signer for NXP SoCs.

# Currently supported hardware

i.MX8 and i.MX9 NXP SoCs. Tested on Advantech modules.

# Yocto compatibility

Yocto 5.0 (scarthgap) to 6.0 (wrynose)

# i.MX integration example (following NXP's style)

```
# variables used for the build folders and the setup

export MACHINE=rom2820-ed93
export DISTRO=fsl-imx-xwayland

# install the 'repo' tool

mkdir ~/bin
curl http://commondatastorage.googleapis.com/git-repo-downloads/repo  > ~/bin/repo
chmod a+x ~/bin/repo
export PATH=$PATH:~/bin

# workspace folder

WORKSPACE=$HOME/yocto/$MACHINE
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"

YOCTO_REPO=https://github.com/Advantech-EECC/imx-manifest
YOCTO_MANIFEST=imx-6.18.20-2.0.0-adv.xml
YOCTO_BRANCH=imx-linux-wrynose-adv

repo init -u "$YOCTO_REPO" -b "$YOCTO_BRANCH" -m "$YOCTO_MANIFEST"
repo sync

# bitbake environment setup (layers and local configuration)

export ENABLE_ROOTFS_ENCRYPTION=1
export FACTORY_KEYS_DIR=/opt/private/keys/factory
export OPT_RM_WORK=1
export SIG_TOOL_PATH=/opt/cst
export SIG_DATA_PATH=/opt/private/keys/nxp/hab4_rsa2048_sha256
export SSTATE_DIR=/mnt/yocto/sstate-data
export DL_DIR=/mnt/yocto/downloads
export BB_ENV_PASSTHROUGH_ADDITIONS=" \
		SIG_TOOL_PATH SIG_DATA_PATH SSTATE_DIR DL_DIR FACTORY_KEYS_DIR"

source adv-imx-setup-release.sh -b build-$MACHINE

# bitbake build

bitbake core-image-minimal
bitbake imx-image-full
```

# i.MX manual integration in other existing build systems

1) Add the layers:

```
meta-secure-boot-nxp
meta-rootfs-enc-core
meta-rootfs-enc-nxp
```
-> By adding the `meta-secure-boot-nxp` layer it will enable the Secure Boot build, enabling the SB bootloader and signing the bootloader and Linux (NXP i.MX)
-> By adding the `meta-rootfs-enc-core` and `meta-rootfs-enc-nxp` layer will enable the rootfs encryption (NXP i.MX)

2) Set the signature and key paths, and add to the BitBake env passthrough:

```
export SIG_TOOL_PATH=/opt/cst
export SIG_DATA_PATH=/opt/private/keys/nxp/hab4_rsa2048_sha256
export BB_ENV_PASSTHROUGH_ADDITIONS="$BB_ENV_PASSTHROUGH_ADDITIONS \
				SIG_TOOL_PATH SIG_DATA_PATH FACTORY_KEYS_DIR"
```

# Generating factory key pair

Factory keys are used for signing the SHA256 file for the ext4 rootfs integrity, and also for HABv4 for signing the 'dtb' files.

For generating e.g.,

```
tools/gen-factory-signing-keys.sh
```

# Flashing images

E.g. writing to a memory card:

```
bmaptool copy core-image-minimal-rom2820-ed93.rootfs.wic.zst /dev/mmcblk0
```

Using NXP's [UUU](https://github.com/nxp-imx/mfgtools/wiki/UUU) tool:

```
# Example for ROM-2820 (ROM-ED93 carrier), pre-requisites:
# - Set the boot mode to 'serial downloader'
# - Connect the USB OTG cable to the computer

uuu -b sd_all core-image-minimal-rom2820-ed93.rootfs.wic.zst
uuu -b emmc_all core-image-minimal-rom2820-ed93.rootfs.wic.zst
```

# References

[1] https://github.com/nxp-imx-support/meta-nxp-security-reference-design


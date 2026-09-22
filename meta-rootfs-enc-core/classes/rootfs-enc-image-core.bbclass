#
# meta-rootfs-enc-core/classes/rootfs-enc-image-core.bbclass
#
# Expand base BSP images for supporting rootfs encryption
#
# Copyright (c) 1983-2026 Advantech Co., Ltd. All rights reserved.
#

inherit factory_key_pair rootfs_enc

FACTORY_KEY_TASKS = "do_generate_factory_hashes"

DEPENDS:append = " coreutils-native openssl-native"

CORE_IMAGE_EXTRA_INSTALL:append = " cryptsetup lvm2 keyutils"
CORE_IMAGE_EXTRA_INSTALL:append:ee_caam = " keyctl-caam"

INITRAMFS_IMAGE = "rootfs-enc-image-initramfs"
IMAGE_FSTYPES:remove = "tar tar.gz tar.bz2 tar.xz tar.zst"
IMAGE_FSTYPES:append = " ${IMAGE_ROOTFS_FSTYPE}"
IMAGE_TYPEDEP:wic:append = " ${IMAGE_ROOTFS_FSTYPE}"

IMAGE_BOOT_FILES:append = " \
    ${FACTORY_ROOTFS_SHA256_FILE} \
    *${FACTORY_SIG_FILE_SUFFIX} \
"

IMAGE_BOOT_FILES:remove = " \
    ${OPTEE_BOOT_IMAGE} \
"

python __anonymous() {
    d.appendVar(
        "EXTRA_IMAGECMD:" + d.getVar("IMAGE_ROOTFS_FSTYPE"),
        " -b " + d.getVar("DM_TABLE_SECTOR_SIZE")
    )
}

do_image_wic[depends] += " \
    virtual/kernel:do_deploy \
    ${UBOOT_BB}:do_deploy \
    ${TGT_BOOT_BB}:do_deploy \
"

do_generate_factory_hashes[depends] += " \
    virtual/kernel:do_deploy \
    coreutils-native:do_populate_sysroot \
    openssl-native:do_populate_sysroot \
    ${PN}:do_image_${IMAGE_ROOTFS_FSTYPE} \
"

generate_factory_hash() {
    ROOTFS_IMG="${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.${IMAGE_ROOTFS_FSTYPE}"
    HASH_FILE="${DEPLOY_DIR_IMAGE}/${FACTORY_ROOTFS_SHA256_FILE}"

    bbnote "Computing SHA256($ROOTFS_IMG) ..."

    [ -f "$ROOTFS_IMG" ] || bbfatal "File not found: $ROOTFS_IMG"

    sha256sum "$ROOTFS_IMG" | cut -d ' ' -f1 > "$HASH_FILE" ||
        bbfatal "Cannot compute SHA256 for $ROOTFS_IMG"

    bbnote "$HASH_FILE: $(cat "$HASH_FILE")"
}

sign_files() {
    key="${FACTORY_KEYS_DIR}/${FACTORY_SIGNING_KEY_FILE}"

    [ -f "$key" ] || bbfatal "Factory signing key not found: $key"

    for i in "$@"
    do
        s=$i.sig
        [ -f "$i" ] || bbfatal "File not found: $i"
        openssl dgst -sha256 -sign "$key" -out "$s" "$i" ||
            bbfatal "Cannot sign $i"
        bbnote "Signature for $i: $s"
    done
}

do_generate_factory_hashes() {
    generate_factory_hash
    sign_files "${DEPLOY_DIR_IMAGE}/${FACTORY_ROOTFS_SHA256_FILE}"
}

IMAGE_CMD:wic:append() {
    bbnote "Re-generating WIC without holes... (rootfs enc)"

    wic="${out}.wic"
    full="$wic.full"

    [ -f "$wic" ] || bbfatal "$wic is missing"

    cp --reflink=never --sparse=never "$wic" "$full" ||
        bbfatal "Can't create $full"

    mv -f "$full" "$wic" || bbfatal "Can't replace $wic"
}

addtask generate_factory_hashes \
    after do_image_${IMAGE_ROOTFS_FSTYPE} \
    before do_image_wic

def kernel_dtb_boot_files(d):
    import os
    suffix = d.getVar("FACTORY_SIG_FILE_SUFFIX")
    dtbs = d.getVar("KERNEL_DEVICETREE").split()
    files = []
    for dtb in dtbs:
        name = os.path.basename(dtb)
        files.append(name)
        files.append(name + suffix)
    return " ".join(files)
